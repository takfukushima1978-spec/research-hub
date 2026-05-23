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

## auto-research-morning-email（朝6:57 JST の Discord サマリー通知）

### 設定情報
- **Trigger ID**: trig_01849zsAtA2CXcHwXoVwyKhv
- **スケジュール**: 毎日 6:57 JST（cron: `57 21 * * *` UTC）
- **環境**: Anthropic クラウド sandbox + 「Cloudflare Workers_My Reserch」環境（research-hub-relay を Allowed domains に登録）
- **必須コネクター**: 不要（Worker 経由の HTTP のみで完結）
- **通知先**: Discord 個人サーバーの `#research-hub-notify` チャンネル（Webhook 経由）
- **管理画面**: https://claude.ai/code/scheduled/trig_01849zsAtA2CXcHwXoVwyKhv
- **プロンプト本体**: `prompts/morning-email-CONSOLE.md`（Console 上の prompt は手動コピペで同期）
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
