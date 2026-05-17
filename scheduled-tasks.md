# Scheduled Tasks設定メモ

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
