# AIツール・開発 学習マップ（基礎の面・幅広版）

> genre=`tools`。SSOT。`node scripts/seed-learning-topics.mjs tools` で DB 同期。
> ※ Claude Code の基礎は別マップ `docs/claude-code-learning-map.md`（claude_code_topics）が担当。本マップは Claude Code 以外。
> AI領域＝**基礎を幅広く充実**。表スキーマ: `| topic_id | title | doc_url | priority | description |`。

### 🔧 プロンプト・API

| topic_id | title | doc_url | priority | description |
|---|---|---|---|---|
| tools.prompt-basics | プロンプトの基本原則 |  | 5 | 明確な指示・文脈付与・出力形式指定・反復改善、役割設定 |
| tools.prompt-advanced | 高度なプロンプト技法 |  | 4 | few-shot、思考の連鎖（CoT）、構造化出力、プロンプトチェーン |
| tools.api-basics | LLM API の基礎 |  | 4 | トークン課金、temperature、システムプロンプト、ストリーミング |
| tools.structured-output | 構造化出力・関数呼び出しの基礎 |  | 3 | JSON出力、tool use、スキーマ強制、業務連携への応用 |

### 🔧 主要ツール

| topic_id | title | doc_url | priority | description |
|---|---|---|---|---|
| tools.chatgpt-codex | ChatGPT / Codex の基礎 |  | 4 | 用途、Claudeとの違い、コード生成エージェントとしての特性 |
| tools.gemini-basics | Gemini の基礎 |  | 3 | マルチモーダル、Google Workspace統合、長文脈 |
| tools.grok-basics | Grok の基礎 |  | 2 | xAI、リアルタイム情報、X連携の特性 |
| tools.claude-app | Claude.ai / Projects / Artifacts の基礎 |  | 4 | Web版Claude、Projects、Artifacts（Claude Code以外の使い方） |
| tools.notion-ai | Notion とAI活用の基礎 |  | 3 | データベース・テンプレート・Notion AI、ナレッジ基盤 |

### 🔧 開発・自動化

| topic_id | title | doc_url | priority | description |
|---|---|---|---|---|
| tools.context-engineering | コンテキスト設計の基礎 |  | 5 | CLAUDE.md/ルール/メモリ、コスト最適化、ハーネスの考え方 |
| tools.agent-sdk | エージェント構築の基礎 |  | 3 | Agent SDK、tool use、MCP接続、自作エージェントの全体像 |
| tools.vibe-coding | バイブコーディングの基礎 |  | 3 | AI駆動開発、ペアプロ、レビュー前提の進め方 |
| tools.automation-tools | ワークフロー自動化ツールの基礎 |  | 3 | n8n・Zapier・GAS・Dify の位置づけと使い分け |
