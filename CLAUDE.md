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
| `insert-article` | 記事投入（v2.1） | INTERNAL_TOKEN |
| `deep-research` | Deep Research（list_pending / complete） | INTERNAL_TOKEN |
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

## 開発メモ

- Edge FunctionのINTERNAL_TOKENはSupabase Dashboard > Edge Functions > Manage Secretsで管理
- ChatGPT GPTsは同一ドメインで複数Actionを作れない（1スキーマに統合が必要）
- ChatGPT GPTsのOpenAPIはoneOfに非対応（単一objectスキーマで代替）
- Supabase Free tierはアイドル時にスリープ → 初回アクセスで502タイムアウトの可能性あり
