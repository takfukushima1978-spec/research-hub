# Scheduled Tasks設定メモ

## auto-research-collect（毎日の自動リサーチ→DB投入）

### 設定情報
- **Trigger ID**: trig_01M35mr4nxRZZVWjFrtRdZyf
- **スケジュール**: 毎日 3:03 JST（cron: `3 18 * * *` UTC）
- **環境**: Anthropicクラウド（リモート実行）
- **管理画面**: https://claude.ai/code/scheduled/trig_01M35mr4nxRZZVWjFrtRdZyf
- **プロンプト本体**: `prompts/auto-research-collect.md`（Console 上の prompt は手動コピペで同期）

### 既知の問題と再発防止
- **2026-05-23 発覚**: Console 上の prompt がローカル PC 前提（`.supabase-config` 読み込み・`git push`）で書かれていたため、クラウド sandbox で全実行が空振りしていた（緑チェックが付くが DB 投入ゼロ）。リポジトリ内の v2.2 仕様とも乖離していた
- **教訓**: Console prompt とリポジトリ `prompts/` の同期は手動運用。prompt 更新時は scheduled-tasks.md の「最終同期日」を更新すること
- **最終同期日**: （未同期 / 復旧作業中）
- **2026-06-10 タクソノミー再編**: 曜日軸を新7ジャンルに刷新 + Step 2.5 にタグ語彙表（controlled vocabulary）を追加。`category_name` は7ジャンルL1スラッグ、`tag_names` は確定スラッグ厳密一致に変更。
- **2026-06-10 演出レイヤー追加**: Step 4 に「冒頭フック層」を追加（背骨=NewsPicks断定型B + A情景/C引きを少量ブレンド、デフォルト上品、テーマで強度可変）。薄さ防止ガードレール（演出は冒頭のみ・本文は具体性UP・フックを削っても本文だけで成立する検証ルール）を明記。
- **2026-06-10 好みフィードバック・ループ追加**（ADR-LG-009 / tak-lifelog）: Step 1.7 を新設。クリップ記事から `get_preference_profile` RPC（migration `20260610000002`）で好みプロファイル（タグ別重み・直近重め半減期30日）を取得し、topic を「好み/バランス/探索」3系統で配分（コールドスタート: clips<5で好み0 / 5〜14で1 / 15以上で2）。ジャンル占有上限40%・探索枠≥1必達・由来系統を Step 8 サマリに出力。
- **最終同期日**: 2026-06-11（タクソノミー再編・演出レイヤー・好みフィードバックの3件をまとめて反映）

### ローカル手動予備（クラウド障害時の手動実行）

本番は**クラウド Routines が主**。クラウドが落ちた/結果が空振りした朝の**予備手段**として、ローカル Claude Code で手動実行できる。

| 項目 | 内容 |
|---|---|
| 使うプロンプト | `prompts/auto-research-collect.md`（**CONSOLE-READY 版ではない**。リポジトリ版＝トークンを `.supabase-config` から読む） |
| 前提 | `C:\dev\.secrets\.supabase-config` が存在すること（正本・git 射程外・token 源）。fallback: `C:\dev\tak-work\リサーチ\auto-research\.supabase-config` |
| 手順 | ① research-hub でローカル Claude Code 起動 → ② 上記 `.md` を渡して実行 → ③ Step 0 で token を**シェル変数**に読込（コマンド行に出ない＝bash-advisor 安全） → ④ curl は **Allow Once** で都度承認（attended） |
| 禁止 | `Bash(curl:*)` 等の広い Always-Allow を settings.json に登録しない（dont-do 準拠）。CONSOLE-READY 版（token 埋込）をローカルで使わない |
| 仕様の正 | 語彙・演出・ガードレールは CONSOLE 版 + `article-style-guide.md` に従う |
| 発火確認 | クラウド側の手動トリガは Console の「Run now」。ローカル予備の動作確認は上記手順を1回流す |

## auto-basics-fill（ローカル /loop・全7ジャンルの基礎面埋め）

> Routine（クラウド・最新ニュース）とは**別系統**。夜間に**ローカル Claude Code の `/loop`** で
> 学習マップ（`research.learning_topics`）の未カバー基礎トピックを**入門記事化**し、7ジャンルの「面」を埋める。

| 項目 | 内容 |
|---|---|
| 実行方式 | ローカル `/loop auto-basics-fill`（PC起動中・無人自走）。クラウド Routine ではない |
| プロンプト | `prompts/auto-basics-fill.md`（ローカル版・トークン埋込なし） |
| DB I/O | **必ず `scripts/learning-cli.mjs` 経由**（生 curl 禁止／秘密をコマンド行に出さない＝bash-advisor 安全・無人で停止しない） |
| 許可 | `.claude/settings.local.json` に `Bash(node scripts/learning-cli.mjs:*)` を narrow 登録済 |
| SSOT | `docs/learning-maps/<genre>.md`（41トピック起案済）→ `node scripts/seed-learning-topics.mjs` で DB 同期 |
| 依存 | migration `20260610000001_learning_topics.sql`（テーブル+RPC4本+source_type basics_fill） |
| 識別 | 基礎記事は `learning_topics.related_article_ids` のリンクで識別（source_type は将来用） |
| ガードレール | 1 iteration 最大3トピック / 再生成最大2回でskip / 1件失敗で止めない / 409・レート想定内 / 未カバー0で DRY 終了 |
| 記事型 | 入門8セクション（定義→全体像→用語集→誤解→最初の一歩）。演出は `article-style-guide.md` 準拠（上品） |
| 起動前提 | ① migration 適用 ② `seed-learning-topics.mjs` 実行 |

## auto-claude-code-watch（毎日 4:00 JST の Claude Code 学習マップ専属タスク）

### 設定情報
- **Trigger ID**: trig_015mNBjdX8Uyq9av2FSRTa2T
- **スケジュール**: 毎日 4:00 JST（cron: `0 19 * * *` UTC）
- **環境**: Anthropic クラウド sandbox + 「Cloudflare Workers_My Reserch」環境（research-hub-relay.tak-fukushima1978.workers.dev を Allowed domains に登録済み）
- **管理画面**: https://claude.ai/code/scheduled/trig_015mNBjdX8Uyq9av2FSRTa2T
- **プロンプト本体**: `prompts/auto-claude-code-watch-CONSOLE.md`（Console 上の prompt は手動コピペで同期）
- **役割**:
  1. Claude Code 公式の新規発信（docs 更新 / Anthropic blog / 公式 X / GitHub release）を毎日チェックして記事化
  2. 新規がない / 不足する日は既存ドキュメントの未カバートピックを解説記事化（合計 3 件保証）
  3. 学習マップ（`research.claude_code_topics`）の coverage を更新し、Discord サマリーに進捗バーを含める
- **依存**:
  - migration `20260526000001_claude_code_topics.sql`（テーブル）
  - migration `20260526000002_claude_code_topics_rpc.sql`（RPC 4 本）
  - SSOT: `docs/claude-code-learning-map.md`
  - seed スクリプト: `node scripts/seed-claude-code-topics.mjs`
- **初期セットアップ手順**:
  1. Supabase SQL Editor で migration 2 本を実行
  2. ローカルで `node scripts/seed-claude-code-topics.mjs` を実行（36 トピック初期投入）
  3. ローカルで `CONSOLE-READY-auto-claude-code-watch.md` を生成（RELAY_URL / INTERNAL_TOKEN 置換）
  4. Console で trigger 新規作成 → CONSOLE-READY 版を貼り付け → 4:00 JST に登録
  5. このファイルの「Trigger ID」と「最終同期日」を埋める
- **最終同期日**: 2026-05-26（初回登録）
- **2026-06-10 タクソノミー再編**: `category_name` を `claude_code_official` → `tools` に変更。`tag_names` をハイフン区切り → 階層スラッグ（`tools`/`claude_code`/L3）に変更。重複検知も tags の `claude_code` で判定。Step 6 に演出フック層（上品トーン基本）＋薄さ防止ガードレールを追加。⚠️ **Console 貼り直し待ち**: `prompts/CONSOLE-READY-auto-claude-code-watch.md` を再貼付する必要あり
- **作成日**: 2026-05-26
- **既知の未実装**: スタンプラリー UI（index.html に「🎯 学習マップ」タブ追加）は Phase 2

## auto-research-morning-discord（朝6:57 JST の Discord サマリー通知）

> **2026-05-24 更新**: 旧 name `auto-research-morning-email` から `auto-research-morning-discord` に改名済（Discord 切替時の改名が反映されていなかった drift を修正）。trigger_id 自体は不変。prompt ファイル名 `prompts/morning-email-CONSOLE.md` は依然旧名で残存中、scheduled-tasks 集約セッション（tak-orchestrator/scheduled-tasks.md 新設時）で `morning-discord-CONSOLE.md` にリネーム予定。

### 設定情報
- **Trigger ID**: trig_01849zsAtA2CXcHwXoVwyKhv
- **スケジュール**: 毎日 6:57 JST（cron: `57 21 * * *` UTC）
- **環境**: Anthropic クラウド sandbox + 「Cloudflare Workers_My Reserch」環境（research-hub-relay を Allowed domains に登録）
- **必須コネクター**: 不要（Worker 経由の HTTP のみで完結）
- **通知先**: Discord 個人サーバーの `#research-hub-notify` チャンネル（Webhook 経由）
- **管理画面**: https://claude.ai/code/scheduled/trig_01849zsAtA2CXcHwXoVwyKhv
- **プロンプト本体**: `prompts/morning-email-CONSOLE.md`（Console 上の prompt は手動コピペで同期。ファイル名は旧名のまま、上記注記参照）
- **役割**: 本日の新規記事を Supabase DB から取得して Discord webhook で Tak のスマホに通知。各記事に GitHub Pages ビューワーリンク + DR キューイング状況を embed 形式で含める
- **更新履歴**:
  - 2026-05-23 (Discord版): Gmail から Discord webhook に切替。`gmail_send_draft` が Routine 環境で利用不可と判明したため。Worker に `/notify/discord` エンドポイント追加 (DISCORD_WEBHOOK_URL secret 経由)
  - 2026-05-23 (Gmail版・廃止): クラウド sandbox 対応版 Gmail Draft 作成試行 → 送信不可で断念
  - ~2026-04 (旧版・廃止): ローカル `daily-summary/*.md` 読み込み前提。クラウド sandbox では空振り
- **既知の未実装**: 5段階評価フィードバック（Discord reaction → DB 反映 → auto-research-collect で読み取り）は Phase 2 で実装予定

## deep-research-runner（Deep Research pending → completed ランナー）

### 設定情報
- **Trigger ID**: trig_01C2e5bSQA4xqznQ3oY3QgQU
- **スケジュール**: 毎日 6:00 JST（cron: `0 21 * * *` UTC）
- **環境**: Anthropic クラウド sandbox + 「Cloudflare Workers_My Reserch」環境（research-hub-relay.tak-fukushima1978.workers.dev を Allowed domains に登録）
- **管理画面**: https://claude.ai/code/scheduled/trig_01C2e5bSQA4xqznQ3oY3QgQU
- **プロンプト本体**: `prompts/deep-research-runner-CONSOLE.md`（Console 上の prompt は手動コピペで同期）
- **役割**: スマホビューワーで 🔬 ボタンを押した記事 (= deep_research_requests の pending) を毎朝拾って、Web 検索で深掘り → completed まで進める
- **1セッション最大処理数**: 3件（残りは翌日へ）
- **作成日**: 2026-05-23（要望④の構造的欠落を埋めるため新規追加）

## feedback-article-runner（記事フィードバック → フォローアップ記事ランナー）

### 設定情報
- **Trigger ID**: trig_01MYmCzYp5uGNEncchErp2vX
- **管理画面**: https://claude.ai/code/routines/trig_01MYmCzYp5uGNEncchErp2vX
- **スケジュール**: 毎日 7:30 JST（cron: `30 22 * * *` UTC） — deep-research-runner（6:00）/ 朝Discord（6:57）の後段
- **コネクター**: なし（Web検索 + Worker経由HTTPSのみで完結。Gmail/Calendar 等は登録しない＝最小権限）
- **環境**: Anthropic クラウド sandbox + 「Cloudflare Workers_My Reserch」環境（research-hub-relay を Allowed domains に登録済み・既存タスクと共有）
- **プロンプト本体**: `prompts/feedback-article-runner-CONSOLE.md`（Console 上の prompt は手動コピペで同期）
- **役割**: ビューワー記事末尾の💬フィードバック（`research.article_feedbacks` の pending）を毎朝拾い、フィードバック内容を起点に追加詳細記事を生成・投入 → `complete_article_feedback` で `follow_up_article_id` をリンク
- **1セッション最大処理数**: 3件（残りは翌日へ）
- **依存**: migration `20260611000001_article_feedbacks.sql`（テーブル + RPC 3本）。**Supabase SQL Editor で適用してから登録すること**
- **初期セットアップ手順**:
  1. Supabase SQL Editor で migration `20260611000001_article_feedbacks.sql` を実行
  2. ローカルで `node scripts/generate-console-ready.mjs feedback-article-runner` を実行（要 `.supabase-config`）→ `CONSOLE-READY-feedback-article-runner.md` 生成
  3. Console で trigger 新規作成 → CONSOLE-READY 版を貼り付け → 7:30 JST に登録
  4. このファイルの「Trigger ID」を埋める
- **作成日**: 2026-06-11
- **登録日**: 2026-06-12（migration 適用 + RPC ラウンドトリップ検証済 → Console 登録完了）

## daily-research（リサーチ＆ナレッジエージェント）

### 設定情報
- **Trigger ID**: trig_01Kzbo6hYAe2nqo52FdxfsmA
- **スケジュール**: 毎日 8:00 JST（cron: `0 23 * * *` UTC）
- **モデル**: claude-sonnet-4-6
- **リポジトリ**: My-Profile-and-Memory
- **環境**: Anthropicクラウド（リモート実行）
- **管理画面**: https://claude.ai/code/scheduled/trig_01Kzbo6hYAe2nqo52FdxfsmA

### 3機能構成
- **機能A**: 各プロジェクトのADR横断確認 → TBP昇格候補検出
- **機能B**: Claude Code + 会計×AI の外部リサーチ
- **機能C**: 外部情報とADR/TBPの再検討トリガー照合

### 出力先
- global-settings/research-log.md にデイリーレポートを追記
- コミット・プッシュまで自動実行

### 手動実行の方法
任意のプロジェクトで以下を入力するだけ：
「最新情報を調べて」
または
「Claude Codeのアップデートを確認して」

## 注意事項
- リモート実行のため自宅PCの起動は不要
- 他リポジトリにdecisions/が作成されたらソース追加が必要
- decisions/やtak-best-practices/が未作成の場合、機能A・Cはスキップされ機能Bのみ実行
