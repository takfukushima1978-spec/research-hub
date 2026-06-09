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
- **2026-06-10 タクソノミー再編**: 曜日軸を新7ジャンルに刷新 + Step 2.5 にタグ語彙表（controlled vocabulary）を追加。`category_name` は7ジャンルL1スラッグ、`tag_names` は確定スラッグ厳密一致に変更。⚠️ **Console 貼り直し待ち**: `prompts/CONSOLE-READY-auto-research-collect.md` を Console タスクに再貼付する必要あり（貼付後にこの行を「貼付済 2026-06-10」へ更新）
- **2026-06-10 演出レイヤー追加**: Step 4 に「冒頭フック層」を追加（背骨=NewsPicks断定型B + A情景/C引きを少量ブレンド、デフォルト上品、テーマで強度可変）。薄さ防止ガードレール（演出は冒頭のみ・本文は具体性UP・フックを削っても本文だけで成立する検証ルール）を明記。同じ再貼付に含まれる

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
