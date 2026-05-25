# Claude Code 学習マップ（スタンプラリー方式）

このファイルは **Claude Code 学習領域の SSOT（Single Source of Truth）**。
`auto-claude-code-watch` Routine が未カバーのトピックを優先的に解説記事化するために使う。

## 運用ルール

- このファイル＝マスタ（人間が編集 / PR レビュー対象）
- DB テーブル `research.claude_code_topics`＝進捗管理（Routine が書き込む）
- 同期: 編集後に `node scripts/seed-claude-code-topics.mjs` を実行 → DB upsert
- `coverage_status` の遷移:
  - `uncovered` → 未着手
  - `covered` → 1 回解説記事化済み
  - `deep` → 2 回以上 or Deep Research まで完了

## トピック表

各表は `| topic_id | title | doc_url | priority | description |` の固定スキーマ。
priority は 1（低）〜 5（高）。Routine はこの順で未カバー候補を選定する。

### 📘 基礎・概念

| topic_id | title | doc_url | priority | description |
|---|---|---|---|---|
| basics.install | インストールとセットアップ | https://docs.claude.com/en/docs/claude-code/setup | 5 | npm/native インストール、OS別の前提、初回起動フロー |
| basics.model-selection | モデル選択（Opus/Sonnet/Haiku） | https://docs.claude.com/en/docs/claude-code/model-config | 5 | /model コマンドと用途別の使い分け、コスト差 |
| basics.cost-management | コスト・トークン管理 | https://docs.claude.com/en/docs/claude-code/costs | 5 | /cost 表示、prompt cache、無駄を減らす運用 |
| basics.session-management | セッション基本操作 | https://docs.claude.com/en/docs/claude-code/interactive-mode | 4 | /clear /compact /resume の挙動と使い所 |
| basics.settings | settings.json の階層構造 | https://docs.claude.com/en/docs/claude-code/settings | 5 | global / project / local の優先順位、env / permissions / hooks |

### 📗 対話・操作

| topic_id | title | doc_url | priority | description |
|---|---|---|---|---|
| ux.slash-commands | スラッシュコマンド全般 | https://docs.claude.com/en/docs/claude-code/slash-commands | 5 | 組み込み slash 一覧と自作との関係 |
| ux.permissions | permission モード | https://docs.claude.com/en/docs/claude-code/iam | 5 | default / acceptEdits / bypassPermissions / plan の違い |
| ux.keybindings | キーバインドカスタマイズ | https://docs.claude.com/en/docs/claude-code/keyboard-shortcuts | 3 | keybindings.json と chord、shift+enter 等の標準キー |
| ux.thinking-modes | thinking モード | https://docs.claude.com/en/docs/claude-code/thinking | 4 | think / think hard / ultrathink のトリガー語と使い分け |
| ux.effort-modes | effort モード | https://docs.claude.com/en/docs/claude-code/effort | 4 | /effort low/medium/high と /btw の使い分け |

### 📙 ツールシステム

| topic_id | title | doc_url | priority | description |
|---|---|---|---|---|
| tools.file-ops | Read/Edit/Write の使い分け | https://docs.claude.com/en/docs/claude-code/tools | 5 | offset/limit、replace_all、Write は上書き |
| tools.search | Glob/Grep の使い分け | https://docs.claude.com/en/docs/claude-code/tools | 5 | multiline 検索、type フィルタ、head_limit |
| tools.bash | Bash ツールの制約と並列実行 | https://docs.claude.com/en/docs/claude-code/tools | 4 | run_in_background、タイムアウト、shell state |
| tools.todowrite | TodoWrite と Plan モード | https://docs.claude.com/en/docs/claude-code/plan-mode | 4 | EnterPlanMode、ExitPlanMode、todo の粒度 |
| tools.tool-restrictions | ツール許可・拒否 | https://docs.claude.com/en/docs/claude-code/iam | 4 | settings.json の permissions、deny の優先 |

### 📕 拡張機構

| topic_id | title | doc_url | priority | description |
|---|---|---|---|---|
| ext.skills | Skills の作成と SKILL.md | https://docs.claude.com/en/docs/claude-code/skills | 5 | description トリガー、~/.claude/skills/ 配置 |
| ext.subagents | Subagents と Agent ツール | https://docs.claude.com/en/docs/claude-code/subagents | 5 | サブエージェント定義、isolation、tools 制限 |
| ext.hooks | Hooks 全種類 | https://docs.claude.com/en/docs/claude-code/hooks | 5 | PreToolUse / PostToolUse / SessionStart / Stop など |
| ext.mcp | MCP server 設定と運用 | https://docs.claude.com/en/docs/claude-code/mcp | 5 | mcp.json、stdio/sse、tool name の解決 |
| ext.plugins | Plugins の導入と管理 | https://docs.claude.com/en/docs/claude-code/plugins | 4 | enabledPlugins、外部 plugin の audit |
| ext.custom-slash | 自作 slash command | https://docs.claude.com/en/docs/claude-code/slash-commands | 4 | .claude/commands/ 配置、allowed-tools |

### 📓 連携・統合

| topic_id | title | doc_url | priority | description |
|---|---|---|---|---|
| integ.vscode | VS Code 拡張 | https://docs.claude.com/en/docs/claude-code/vscode | 4 | ネイティブ拡張、ide_selection、コード参照リンク |
| integ.jetbrains | JetBrains 拡張 | https://docs.claude.com/en/docs/claude-code/jetbrains | 3 | IntelliJ/PyCharm 等での導入手順 |
| integ.github-actions | GitHub Actions 連携 | https://docs.claude.com/en/docs/claude-code/github-actions | 4 | /review、claude action、CI 統合 |
| integ.cloud-code | Cloud Code（claude.ai/code） | https://docs.claude.com/en/docs/claude-code/cloud | 4 | sandbox 制約、Allowed domains、scheduled tasks |
| integ.telegram | Telegram プラグイン | https://docs.claude.com/en/docs/claude-code/telegram | 3 | bot token 設定、access policy、reply フロー |

### 📔 開発・運用

| topic_id | title | doc_url | priority | description |
|---|---|---|---|---|
| ops.agent-sdk | Claude Agent SDK | https://docs.claude.com/en/docs/claude-code/sdk | 5 | カスタムエージェント構築、tool 定義 |
| ops.routines | Scheduled Tasks（Routines） | https://docs.claude.com/en/docs/claude-code/scheduled-tasks | 5 | cron 設定、Allowed domains、host_not_allowed 罠 |
| ops.worktrees | Git Worktrees 活用 | https://docs.claude.com/en/docs/claude-code/worktrees | 4 | 並列開発、worktree remove の Windows 罠 |
| ops.parallel-agents | サブエージェント駆動開発 | https://docs.claude.com/en/docs/claude-code/parallel-development | 4 | dispatching-parallel-agents、独立タスク分割 |
| ops.cli-flags | CLI フラグ（--print 等） | https://docs.claude.com/en/docs/claude-code/cli | 3 | --print、--output-format、--channels |

### 📒 ベストプラクティス

| topic_id | title | doc_url | priority | description |
|---|---|---|---|---|
| bp.claude-md | CLAUDE.md の書き方 | https://docs.claude.com/en/docs/claude-code/claude-md | 5 | 階層配置、肯定形ルール、肥大化を避ける |
| bp.context-mgmt | コンテキスト管理戦略 | https://docs.claude.com/en/docs/claude-code/context | 5 | /compact のタイミング、subagent による分離 |
| bp.memory-system | 自動メモリシステム | https://docs.claude.com/en/docs/claude-code/memory | 4 | user/feedback/project/reference の使い分け |
| bp.cost-optimization | コスト最適化 | https://docs.claude.com/en/docs/claude-code/costs | 5 | Haiku 優先、サブエージェント、キャッシュ温存 |
| bp.tdd-workflow | TDD ワークフロー（superpowers） | https://docs.claude.com/en/docs/claude-code/superpowers | 3 | brainstorming → writing-plans → executing-plans |

## 集計

- 領域数: 7
- トピック数: 36
- 初期状態: 全 uncovered（0/36）

## 増減のルール

- トピック追加: このファイルに行を追加 → seed スクリプトで upsert
- トピック削除: `coverage_status` を `archived` に変える運用（履歴を残す）
- doc_url 変更: 公式ドキュメント URL が変わったら更新（記事の source_urls との突合は別途）
