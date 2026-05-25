# Research Hub

## プロジェクト概要

パーソナルAIリサーチ基盤。Web検索で収集した記事をSupabase DBに蓄積し、Webビューワーで閲覧する。
Deep Research機能で記事の深掘り調査を実行し、結果をビューワーに表示する。
朝6:57 JSTにDiscordへスマホプッシュ通知を送る。

## アーキテクチャ

```
[投入パイプライン]
  auto-research-collect    (3:03 JST) ─┐
  auto-claude-code-watch   (4:00 JST) ─┤  ← Claude Code 公式 + 学習マップ
  ChatGPT GPTs ────────────────────────┼→ research-hub-relay (Cloudflare Worker) →┐
  Gmail Import (外部スクリプト) ───────┘                                          ▼
                                                          Edge Function (insert-article) → RPC → DB

[Deep Research パイプライン]
  Web UI 🔬ボタン → deep_research_requests (pending)
  deep-research-runner (6:00 JST) → Web検索深掘り → Edge Function (deep-research) → RPC → DB (completed)

[通知パイプライン]
  auto-research-morning-email (6:57 JST) → Worker /notify/discord → Discord webhook → スマホ通知

[学習マップ（スタンプラリー）]
  docs/claude-code-learning-map.md (SSOT)
    ↓ scripts/seed-claude-code-topics.mjs
  research.claude_code_topics (進捗tracking)
    ↑ auto-claude-code-watch が未カバー優先で解説記事化

[表示]
  index.html (GitHub Pages) → Supabase REST API → research スキーマ → ブラウザ表示
```

クラウド sandbox から Supabase に直接アクセスすると Cloudflare bot 検知で 403 になるため、
すべての Routines は `research-hub-relay` Worker を経由する。詳細は `scheduled-tasks.md` を参照。

## 技術スタック

- **フロントエンド**: 静的HTML（index.html単体、GitHub Pages 配信: https://takfukushima1978-spec.github.io/research-hub/）
- **バックエンド**: Supabase（PostgreSQL + Edge Functions）
- **中継層**: Cloudflare Workers (`research-hub-relay`)
- **通知**: Discord webhook
- **DBスキーマ**: `research`（articles, tags, article_tags, categories, deep_research_requests 等）
- **Edge Functions**: Deno（TypeScript）
- **認証**: INTERNAL_TOKEN（X-Internal-Token / Authorization: Bearer 両対応）

## Edge Functions

| 関数名 | 用途 | 認証 |
|---|---|---|
| `insert-article` | 記事投入（v2.3: 品質ノルマ検証 + embedding重複検知 opt-in） | INTERNAL_TOKEN |
| `deep-research` | Deep Research（request / list_pending / complete） | INTERNAL_TOKEN |
| `articles` | 記事HTMLビューワー（読み取り専用） | なし |

## Cloudflare Workers (research-hub-relay)

| 項目 | 値 |
|---|---|
| URL | `https://research-hub-relay.tak-fukushima1978.workers.dev` |
| ソース | このリポジトリの `worker/` |
| デプロイ | `cd worker && npx wrangler deploy` |
| Secret | `INTERNAL_TOKEN` / `SUPABASE_URL` / `SUPABASE_ANON_KEY` / `DISCORD_WEBHOOK_URL`（`wrangler secret bulk` で JSON 経由登録） |
| ログ確認 | `cd worker && npx wrangler tail` |

エンドポイント:

| メソッド | パス | 役割 |
|---|---|---|
| POST | `/functions/v1/insert-article` | Supabase Edge Function 中継 |
| POST | `/functions/v1/deep-research` | Supabase Edge Function 中継 |
| POST | `/rest/v1/rpc/<name>` | Supabase RPC 中継 (public スキーマ、Accept-Profile 付与なし) |
| GET | `/rest/v1/articles?<query>` | research スキーマのテーブル取得 (Accept-Profile: research 付与) |
| POST | `/notify/discord` | DISCORD_WEBHOOK_URL に body をそのまま転送 |

クライアントは `X-Internal-Token` のみ送る。Worker が Supabase 向けに `Authorization: Bearer <anon>` と `apikey` を内部付与する。

## RPC一覧

| RPC名 | スキーマ | 用途 |
|---|---|---|
| `insert_research_article` | public | 記事投入（カテゴリ自動作成・slug重複対策付き） |
| `create_deep_research_request` | public | Deep Researchリクエスト登録 |
| `complete_deep_research` | public | Deep Research結果書き戻し |
| `get_pending_deep_research` | public | 未処理リクエスト一覧 |
| `get_article_research` | public | 記事のDeep Research結果取得（result_body含む） |
| `toggle_article_flag` | public | 記事の既読/クリップフラグ切替 |
| `add_manual_article` | public | 手動記事登録 |
| `get_recent_article_digests` | public | 直近N日分のtitle/summary/tags/category取得（重複検知用、デフォルト14日） |
| `find_similar_articles_by_embedding` | public | embeddingベース類似記事検索（pgvector cosine、opt-in） |
| `update_article_embedding` | public | 記事のembeddingを書き戻す |
| `get_uncovered_claude_code_topics` | public | Claude Code 学習マップの未カバートピック取得（auto-claude-code-watch 用） |
| `mark_topic_covered` | public | トピックを covered/deep にマークし article_count を更新 |
| `get_claude_code_coverage_summary` | public | 領域別の coverage 進捗サマリ |
| `upsert_claude_code_topic` | public | learning-map.md → DB 同期用 upsert（seed スクリプトから呼ぶ） |

注: 全 RPC が `public` スキーマ。PostgREST 直叩きで呼ぶ場合、`Accept-Profile: research` を**付けてはいけない**（schema 不一致で `PGRST202: Could not find function` になる）。Edge Function 経由なら supabase client が適切に解決する。

## 設定ファイル

| ファイル | 場所 | 内容 |
|---|---|---|
| `.supabase-config` | tak-work/リサーチ/auto-research/ | SUPABASE_URL, INTERNAL_TOKEN, PROJECT_ID |
| `.discord-config` | tak-work/リサーチ/auto-research/ | DISCORD_WEBHOOK_URL（Worker secret 再登録用、git管理外） |
| `openapi-research-hub.json` | このリポジトリ | ChatGPT GPTs用 OpenAPI Schema |
| `05_gmail_to_supabase.py` | tak-work/リサーチ/auto-research/ (git管理外) | Gmail Import → insert-article 呼び出しスクリプト。`.claude/settings.local.json` に allow 登録あり |
| `worker/wrangler.toml` | このリポジトリ | research-hub-relay の Cloudflare Workers 設定 |
| `prompts/*-CONSOLE.md` | このリポジトリ | Anthropic Console 貼り付け用プロンプトテンプレ (プレースホルダ含む) |
| `prompts/CONSOLE-READY-*.md` | このリポジトリ (.gitignore) | 上記テンプレに実値を埋め込んだローカル専用ファイル。絶対に commit しない |

## スケジュールタスク（Routines）

詳細は `scheduled-tasks.md` を参照。トリガー ID とプロンプト同期日も同ファイルで管理する。

| 名前 | trigger ID | cron (JST) | 内容 |
|---|---|---|---|
| `auto-research-collect` | trig_01M35mr4nxRZZVWjFrtRdZyf | 3:03 | Web検索（曜日別軸+公式ニュース最優先） → Worker経由でDB投入 + 重要記事のDR自動キューイング |
| `auto-claude-code-watch` | （未登録） | 4:00 | Claude Code 公式の新規発信を記事化。不足分は学習マップから未カバートピックを解説記事化（合計3件保証） |
| `deep-research-runner` | trig_01C2e5bSQA4xqznQ3oY3QgQU | 6:00 | pendingなDRを最大3件処理 → 深掘りWeb検索 → completed書き戻し |
| `auto-research-morning-email` | trig_01849zsAtA2CXcHwXoVwyKhv | 6:57 | 本日記事をDBから取得 → Worker /notify/discord → Tak のスマホDiscord通知 (embed形式) |
| `daily-research` | trig_01Kzbo6hYAe2nqo52FdxfsmA | 8:00 | My-Profile-and-Memoryリポジトリ。Research Hub とは別系統 |

全 Routine の環境設定は「**Cloudflare Workers_My Reserch**」を共有。Allowed domains に `research-hub-relay.tak-fukushima1978.workers.dev` を登録済み。

## ChatGPT GPTs連携

- GPTs名: Research Hub Writer
- Actions: `insertArticle`（記事投入）、`deepResearch`（Deep Research）
- 認証: API Key (Bearer) — INTERNAL_TOKENと同じ値
- スキーマ: `openapi-research-hub.json`
- ※ ChatGPT GPTs は data center IP からのアクセスでも Cloudflare bot 検知に弾かれにくい (User-Agent が ChatGPT 公式で許可されている)。Worker 中継は使わず Supabase Edge Function 直叩きで OK

## 記事品質ノルマ（insert-article v2.2 〜）

auto-research-collect の連日重複・薄っぺら問題対策として `insert-article` で以下を強制する:

| 項目 | 下限 | 環境変数で上書き |
|---|---|---|
| `body_text` 文字数 | 1500 | `MIN_BODY_TEXT_LENGTH` |
| `source_urls` 件数 | 3 | `MIN_SOURCE_URLS` |
| `tag_names` 件数 | 4 | `MIN_TAG_NAMES` |

ノルマ未達時は 400 を返し、`details` に不足項目を列挙する。
手動投入で一時的にスキップしたい場合のみ payload に `quality_override: true` を付ける。

スケジュールタスク側の対応プロンプトは `prompts/auto-research-collect-CONSOLE.md` を参照（リポジトリ版は手動同期、Console 上は固定文字列でコピーされる仕様）。
収集前に `get_recent_article_digests` を呼んで重複テーマを除外し、JST曜日別の軸ローテーションでネタ偏りを防ぐ。

## 公式ニュース最優先ルール (auto-research-collect)

主要AIラボ・プラットフォーマー・規制機関の公式ソース (Anthropic / OpenAI / Google DeepMind / Meta / NVIDIA / EU AI Act / NIST 等) で
過去 24〜48 時間以内に新規発表があれば、当日の曜日軸とは別枠で **必ず** 記事化する。
既存記事と重複する場合は、技術詳細・競合比較・反対意見など別アングルで再記事化する。
詳細は `prompts/auto-research-collect-CONSOLE.md` Step 1.5 を参照。

## 自動 Deep Research

`auto-research-collect` は重要記事 (公式メジャーリリース / 業界インパクト大 / 業務直結) を投入した直後に
`deep-research` Edge Function の `action: "request"` を呼んで Deep Research を自動キューイングする。
priority は 1〜3 で、公式メジャーリリースは 3 を指定。

pending な request は翌朝 6:00 JST の `deep-research-runner` が拾って深掘り処理する（最大3件/日）。

※ 2026-05-23 観測: auto-research-collect が `action=request` した直後に DR が `completed` 状態になる現象あり。Phase 2 で要調査（memory `dr-self-completion-mystery.md` 参照）。

## embedding ベース重複検知 (opt-in)

`articles.embedding vector(1536)` カラムと `find_similar_articles_by_embedding` RPC を用意済み。
auto-research-collect が投入時に `embedding` を payload に含めると、insert-article が cosine 類似度を計算し
閾値 (デフォルト 0.85) 以上の既存記事があれば 409 で重複拒否する。embedding 生成は呼び出し側の責務
(OpenAI text-embedding-3-small / Voyage AI voyage-3 等)。embedding を送らない既存フローはそのまま動作。

## 開発メモ

- Edge FunctionのINTERNAL_TOKENはSupabase Dashboard > Edge Functions > Manage Secretsで管理
- ChatGPT GPTsは同一ドメインで複数Actionを作れない（1スキーマに統合が必要）
- ChatGPT GPTsのOpenAPIはoneOfに非対応（単一objectスキーマで代替）
- Supabase Free tierはアイドル時にスリープ → 初回アクセスで502タイムアウトの可能性あり
- **Anthropic Routines のクラウド sandbox は outbound allowlist 方式**。任意ホストへの接続は Routine 個別の環境設定 → ネットワークアクセス → Custom → Allowed domains で追加する。グローバル `claude.ai/settings/capabilities` の追加は反映バグあり
- **Supabase Edge Function 前段の Cloudflare bot 検知**でデータセンター IP（Anthropic Routines / GitHub Actions 等）は 403 → Worker 中継で回避済み
- **Routines の Gmail コネクター**は `gmail_create_draft` のみ提供、`gmail_send_draft` は環境内で利用不可。自動メール送信したい場合は Discord/Slack/Telegram の webhook 型を選ぶ
- **Console プロンプトとリポジトリの prompts/ は手動同期**。リポジトリ更新後は scheduled-tasks.md の「最終同期日」を更新するルール
- **PowerShell stdin pipe で wrangler secret put すると改行混入**。必ず `wrangler secret bulk` で JSON ファイル経由を使う
