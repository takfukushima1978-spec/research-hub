# Research Hub

## プロジェクト概要

パーソナルAIリサーチ基盤。Web検索で収集した記事をSupabase DBに蓄積し、Webビューワーで閲覧する。
Deep Research機能で記事の深掘り調査を実行し、結果をビューワーに表示する。

## アーキテクチャ

```
[投入パイプライン]
  Claude スケジュールタスク ─┐
                             ├→ Edge Function (insert-article) → RPC → DB
  ChatGPT GPTs ─────────────┘

[Deep Research パイプライン]
  Web UI 🔬ボタン → リクエスト登録 (pending)
  ChatGPT/Claude → Edge Function (deep-research) → RPC → DB (completed)
  Web UI → 結果自動表示

[表示]
  index.html → Supabase REST API → research スキーマ → ブラウザ表示
```

## 技術スタック

- **フロントエンド**: 静的HTML（index.html単体、GitHub Pages等で配信）
- **バックエンド**: Supabase（PostgreSQL + Edge Functions）
- **DBスキーマ**: `research`（articles, tags, article_tags, categories, deep_research_requests 等）
- **Edge Functions**: Deno（TypeScript）
- **認証**: INTERNAL_TOKEN（X-Internal-Token / Authorization: Bearer 両対応）

## Edge Functions

| 関数名 | 用途 | 認証 |
|---|---|---|
| `insert-article` | 記事投入（v2.3: 品質ノルマ検証 + embedding重複検知 opt-in） | INTERNAL_TOKEN |
| `deep-research` | Deep Research（request / list_pending / complete） | INTERNAL_TOKEN |
| `articles` | 記事HTMLビューワー（読み取り専用） | なし |

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

## 設定ファイル

| ファイル | 場所 | 内容 |
|---|---|---|
| `.supabase-config` | tak-work/リサーチ/auto-research/ | SUPABASE_URL, INTERNAL_TOKEN, PROJECT_ID |
| `openapi-research-hub.json` | このリポジトリ | ChatGPT GPTs用 OpenAPI Schema |

## スケジュールタスク（Remote Triggers）

| 名前 | cron (UTC) | 内容 |
|---|---|---|
| `auto-research-collect` | 18:03 毎日 (=翌3:03 JST) | Web検索→Markdown生成→Edge Function経由DB投入 |
| `auto-research-morning-email` | 21:57 毎日 (=翌6:57 JST) | daily-summaryをGmail送信 |
| `daily-research` | 23:00 毎日 (=翌8:00 JST) | ADR横断・外部リサーチ・TBP昇格判断 |

## ChatGPT GPTs連携

- GPTs名: Research Hub Writer
- Actions: `insertArticle`（記事投入）、`deepResearch`（Deep Research）
- 認証: API Key (Bearer) — INTERNAL_TOKENと同じ値
- スキーマ: `openapi-research-hub.json`

## 記事品質ノルマ（insert-article v2.2 〜）

auto-research-collect の連日重複・薄っぺら問題対策として `insert-article` で以下を強制する:

| 項目 | 下限 | 環境変数で上書き |
|---|---|---|
| `body_text` 文字数 | 1500 | `MIN_BODY_TEXT_LENGTH` |
| `source_urls` 件数 | 3 | `MIN_SOURCE_URLS` |
| `tag_names` 件数 | 4 | `MIN_TAG_NAMES` |

ノルマ未達時は 400 を返し、`details` に不足項目を列挙する。
手動投入で一時的にスキップしたい場合のみ payload に `quality_override: true` を付ける。

スケジュールタスク側の対応プロンプトは `prompts/auto-research-collect.md` を参照。
収集前に `get_recent_article_digests` を呼んで重複テーマを除外し、JST曜日別の軸ローテーションでネタ偏りを防ぐ。

## 公式ニュース最優先ルール (auto-research-collect)

主要AIラボ・プラットフォーマー・規制機関の公式ソース (Anthropic / OpenAI / Google DeepMind / Meta / NVIDIA / EU AI Act / NIST 等) で
過去 24〜48 時間以内に新規発表があれば、当日の曜日軸とは別枠で **必ず** 記事化する。
既存記事と重複する場合は、技術詳細・競合比較・反対意見など別アングルで再記事化する。
詳細は `prompts/auto-research-collect.md` Step 1.5 を参照。

## 自動 Deep Research

`auto-research-collect` は重要記事 (公式メジャーリリース / 業界インパクト大 / 業務直結) を投入した直後に
`deep-research` Edge Function の `action: "request"` を呼んで Deep Research を自動キューイングする。
priority は 1〜3 で、公式メジャーリリースは 3 を指定。

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
