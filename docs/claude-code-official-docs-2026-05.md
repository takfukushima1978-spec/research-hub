<!-- snapshot: 2026-05-31 -->

# Claude Code 公式ドキュメント調査レポート（2026年5月公表分）

> 目的: 2026年5月に Anthropic 公式が公表した Claude Code のドキュメント・リリースノートを一次情報から整理し、research-hub の運用に効く更新を拾う。
> スコープ: 2026年5月公表分のみ（v2.1.120〜v2.1.157 / What's new Week 18〜22）。
> 調査方法: 公式「What's new」週次ダイジェスト・公式 changelog（GitHub `anthropics/claude-code`）を一次ソースとして横断取得。
> 一次ソース: [code.claude.com/docs/en/whats-new](https://code.claude.com/docs/en/whats-new) ／ [CHANGELOG.md](https://raw.githubusercontent.com/anthropics/claude-code/refs/heads/main/CHANGELOG.md)
> 注意: 本レポートは公式ドキュメントのスナップショット（2026-05-31 時点）。最新は会話への貼り付け／`--help`／`/release-notes` を優先する。

---

## 0. エグゼクティブ・サマリー — 5月の3大トピック

2026年5月の Claude Code は「**モデル世代交代（Opus 4.8）**」「**自律実行の本格化（auto mode / dynamic workflows）**」「**セキュリティの内製化（security-guidance plugin）**」の3軸で大きく動いた。

| # | トピック | 公表週 | バージョン | research-hub への効き |
|---|---|---|---|---|
| 1 | **Claude Opus 4.8** が各プラン既定モデル化（high effort 既定 + `/effort xhigh`） | W22 (5/25–29) | v2.1.154+ | 設計判断の質向上。要 v2.1.154 以降 |
| 2 | **Dynamic workflows**（数十〜数百サブエージェントをスクリプトでオーケストレーション） | W22 | v2.1.154 | 横断監査・大規模移行・クロスチェック型リサーチに直結 |
| 3 | **security-guidance plugin**（編集・コミット時に脆弱性を自動レビュー） | W22 | v2.1.150–157 | Edge Function / Worker のシークレット混入防止 |
| 4 | **Fast mode が Opus 4.8 に**（$10/$50 per MTok、標準2倍料金で約2.5倍速） | W22 | v2.1.154 | コスト/速度トレードオフの再設計余地 |
| 5 | **Auto mode が Pro プランへ**（Sonnet 4.6 対応、許可プロンプトを背後の安全チェックに置換） | W21 (5/18–22) | v2.1.143–149 | 深夜バッチの承認待ち解消 |
| 6 | **`/usage`** がスキル/サブエージェント/プラグイン/MCP 別に上限消費を内訳表示 | W21 | v2.1.149 | コスト要因の可視化（Tak のコスト意識に直結） |
| 7 | **`/code-review`** コマンド（正確性バグを報告。`/simplify` を改称・再編） | W21–22 | v2.1.147–152 | コミット前の品質ゲート |
| 8 | **`claude agents` エージェントビュー**（全セッションを1画面で俯瞰） | W20 (5/11–15) | v2.1.139–142 | 複数 Routine の進行管理 |
| 9 | **`/goal`**（完了条件を満たすまでターンを跨いで継続） | W20 | v2.1.139 | 長尺リサーチの自走 |

以下、週次の流れと主要機能の詳細。

---

## 1. 週次タイムライン（2026年5月）

公式「What's new」の週次ダイジェスト区分に沿う。

| 週 | 期間 | バージョン | ヘッドライン機能 |
|---|---|---|---|
| **Week 18** | 4/27–5/1 | v2.1.120–126 | **Windows で Git Bash 不要に**（Bash 不在時は PowerShell をシェルツールに）。`claude ultrareview`（CI/スクリプト向けクラウドコードレビュー）、`claude project purge`、PR URL を `/resume` に貼ると作成セッションを特定 |
| **Week 19** | 5/4–5/8 | v2.1.128–136 | **プラグインを `.zip` / URL から読込**（`--plugin-dir` が `.zip` 対応、`--plugin-url` で当該セッションに取得）。`worktree.baseRef`、auto mode の `hard_deny` ルール、hook が effort レベルを `effort.level`/`$CLAUDE_EFFORT` で参照可能に |
| **Week 20** | 5/11–5/15 | v2.1.139–142 | **`claude agents`（エージェントビュー）**を Research Preview で追加。`/goal`（完了条件まで継続）、fast mode が Opus 4.7 既定に、Rewind メニューの「Summarize up to here」で過去コンテキストを圧縮 |
| **Week 21** | 5/18–5/22 | v2.1.143–149 | **Auto mode が Pro プランで稼働**（Sonnet 4.6 対応）。`/usage` の上限消費内訳、新 `/code-review`、バックグラウンドセッションが `/resume` に出現しピン留めで生存 |
| **Week 22** | 5/25–5/29 | v2.1.150–157 | **Claude Opus 4.8** 既定化。**dynamic workflows**、**security-guidance plugin**、**fast mode が Opus 4.8 に**（$10/$50 per MTok） |

---

## 2. 主要機能の詳細

### 2.1 Claude Opus 4.8（W22 / v2.1.154 以降）

- Max / Team Premium / Enterprise pay-as-you-go / Anthropic API の**既定モデル**に。
- **high effort が既定**。最難タスクは `/effort xhigh`。
- 切替: `> /model claude-opus-4-8`（またはモデルピッカー）。
- **要件: v2.1.154 以降**（古いバージョンでは選べない）。
- v2.1.156 で「Opus 4.8 利用時に thinking ブロックが改変されて API エラーになる不具合」を修正。
- W22 で「Claude が多肢選択の質問を本当に不確実なときだけに留める」「lean system prompt が既定（Haiku/Sonnet/Opus 4.7 以前を除く）」も同時導入。

### 2.2 Dynamic workflows（W22 / v2.1.154・Research Preview）

- **Claude がタスク用のオーケストレーションスクリプトを書き、多数のサブエージェントを背後で実行**する仕組み。
- 想定用途: 1会話で調整しきれない大規模タスク（コードベース全体の監査、大規模移行、クロスチェックが要るリサーチ）。
- 起動: プロンプトに **`workflow` の語を含める**。例 `> create a workflow that migrates every internal fetch() call to the new HttpClient wrapper`。
- 管理: `/workflows` コマンドで実行を管理。
- 設定: `/config` に「Workflow keyword trigger」設定が追加（v2.1.157）。トリガーキーワード後の Backspace で要求を取り消し可能。

> research-hub 適用メモ: 「複数記事の横断品質監査」「学習マップ全領域の一括リサーチ」など、現在 Routine で逐次処理している部分を workflow 化できる可能性。ただし Research Preview かつコスト大なので、Tak のコスト方針に照らし**明示要求時のみ**の運用が無難。

### 2.3 Security guidance plugin（W22 / plugin）

- **Claude のコード変更を脆弱性観点でレビューし、同一セッション内で修正**する公式プラグイン。
- 3段階レビュー: ①各編集で高速パターンチェック → ②各ターン末にモデルレビュー → ③コミット/プッシュ時に深いエージェント的レビュー。
- プロジェクト固有ルールは `.claude/claude-security-guidance.md` に記述。
- 導入: `> /plugin install security-guidance@claude-plugins-official` → `> /reload-plugins` で有効化。

> research-hub 適用メモ: Edge Function（`insert-article` 等）/ Worker の編集時に、`CONSOLE-READY-*.md` のシークレット混入や RLS 抜けを機械的に検知できる。グローバル `settings-guard.py` フックと役割が一部重なるため、二重防御の整理を要検討。

### 2.4 Fast mode が Opus 4.8 に（W22 / v2.1.154・Research Preview）

- fast mode の既定が **Opus 4.8、$10/$50 per MTok**（標準の2倍料金で約2.5倍速）。
- Opus 4.7 / 4.6 は $30/$150 のまま。**Opus 4.6 の fast mode は非推奨（deprecated）**。
- 切替: `> /fast`。

### 2.5 Auto mode の拡大（W21 / v2.1.143–149、源流は W13）

- **Pro プランで auto mode が稼働**し、Opus に加えて **Sonnet 4.6** に対応。許可プロンプトを背後の安全チェックに置換。
- v2.1.152 で auto mode が opt-in 同意不要に。
- W19 で `settings.autoMode.hard_deny` ルール（allow 例外に関係なく無条件ブロック）を追加。
- v2.1.154 で auto-mode 分類器のデータ持出し検知を改善。

### 2.6 `/usage` のコスト内訳（W21 / v2.1.149）

- **スキル / サブエージェント / プラグイン / MCP サーバー別**にプラン上限の消費要因を分解表示。
- 大きいセッションファイルも内訳に含む（v2.1.152）。

> research-hub 適用メモ: 4つの Routine と MCP がどれだけ上限を食っているかを定量把握できる。コスト最適化の起点に最適。

### 2.7 `/code-review` への再編（W21–W22 / v2.1.147–152）

- v2.1.147 で `/simplify` → `/code-review` に改称。
- v2.1.152 で `/code-review --fix`（指摘の適用＋改善提示）、`/simplify` は `/code-review --fix` を呼ぶ整理に。
- v2.1.154 で `/simplify` は「クリーンアップ専用レビュー＋修正適用」に再定義。

### 2.8 `claude agents`（エージェントビュー）と `/goal`（W20 / v2.1.139）

- `claude agents`: 全 Claude Code セッションを1画面で俯瞰（実行中 / ユーザー待ち / 完了）。Research Preview。
- W22 で機能拡充: `! <command>` でバックグラウンドジョブ実行（`claude --bg --exec 'pytest -x'` 相当）、`/logout` がバックグラウンド化でなくサインアウトに。
- `/goal`: 完了条件が満たされるまでターンを跨いで Claude が継続。

### 2.9 スキル/プラグイン運用の改善（W22 中心）

- `.claude/skills` 配下のプラグインを**マーケットプレイス不要で自動ロード**（v2.1.157）。
- `claude plugin init <name>` で新規プラグインを雛形生成。
- `/reload-skills`（再起動なしでスキルディレクトリ再スキャン）。`SessionStart` フックが `reloadSkills: true` を返すと同一セッションで反映。
- スキル/スラッシュコマンドが frontmatter に **`disallowed-tools`** を設定可能（有効時にツールを外す）。
- 新 **`MessageDisplay`** フックイベント（表示時にアシスタントメッセージを変換/隠蔽）。
- プラグインが `defaultEnabled: false` を宣言可能（インストールしても有効化は手動）。
- プライマリモデルが見つからない場合、**`--fallback-model`** にセッション内で自動切替（毎リクエスト失敗を回避）。

---

## 3. research-hub への適用候補（優先度つき）

| 優先 | 施策 | 根拠機能 | 工数感 |
|---|---|---|---|
| 高 | `/usage` で4 Routine + MCP の上限消費を棚卸し → コスト要因を特定 | 2.6 | 10分 |
| 高 | Edge Function / Worker 編集フローに security-guidance plugin を試験導入 | 2.3 | 30分 |
| 中 | 既定モデル方針の見直し（設計=Opus 4.8 / 収集=Sonnet 4.6 / 要約=Haiku） | 2.1, 2.5 | 30分 |
| 中 | 「横断品質監査」を dynamic workflow で試作（明示要求時のみ） | 2.2 | 1–2時間 |
| 低 | 複数 Routine の進行管理に `claude agents` ビューを常用 | 2.8 | 即 |

> 既存レポート [claude-code-best-practices-2026-05.md](claude-code-best-practices-2026-05.md) と相互補完。あちらは「ベストプラクティス発掘」、本レポートは「2026年5月の公式更新の事実整理」。

---

## 4. 出典（一次ソース）

- [What's new — Claude Code Docs](https://code.claude.com/docs/en/whats-new)（週次ダイジェスト Week 18–22）
- [Week 22 digest (May 25–29, 2026)](https://code.claude.com/docs/en/whats-new/2026-w22)
- [Claude Code CHANGELOG.md (anthropics/claude-code)](https://raw.githubusercontent.com/anthropics/claude-code/refs/heads/main/CHANGELOG.md)（v2.1.120–v2.1.157）
- [Introducing Claude Opus 4.8 — Anthropic News](https://www.anthropic.com/news/claude-opus-4-8)
- [Enabling Claude Code to work more autonomously — Anthropic News](https://www.anthropic.com/news/enabling-claude-code-to-work-more-autonomously)

> 検索結果には releasebot.io / claudelog.com / claudefa.st 等の二次まとめも存在したが、本レポートは**一次ソース（公式 docs + 公式 changelog）のみ**で構成した。
