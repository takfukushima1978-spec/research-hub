## [2026-06-23] デイリーレポート

### 内部知見（機能A）
#### 新規・更新 ADR
- My-Profile-and-Memory/decisions/ → フォルダ未存在のためスキップ
- StudyMate, My-URAWA-LOG, tak-work, tak-family, tak-personal → アクセス可能リポジトリ外のためスキップ
- tak-best-practices/ → TBP-001（外部ツール導入審査）・TBP-002（実行環境英語パス）を確認（新規 ADR なし）
- **前回（6/22）昇格候補 2 件の継続記録**:
  1. TBP-003 候補「着手前に実態（git）と文書（backlog）の一致を確認する」— Tak 確認待ち
  2. TBP-004 候補「不可逆性で安全方向を決めるが、カテゴリ丸ごとの保守化は目的を殺す」— Tak 確認待ち

#### TBP 昇格候補
なし（本日は新規 ADR なし）

#### 再検討トリガー該当
- **TBP-001（外部ツール導入審査）継続**: 課金体系変更・地政学的リスク・デストラクティブ操作自動防御・Agent deny rules 修正の評価項目追記提案が未確認のまま継続（6/15〜6/22 提案）。
- **TBP-001 新規照合①（v2.1.187 `sandbox.credentials` 設定）**: サンドボックスコマンドが認証情報ファイルとシークレット環境変数を読み取れないようにブロックする新設定が追加。TBP-001 の「最小権限で開始」原則の実装手段として `sandbox.credentials` 設定の活用を審査項目に追記する価値がある。Routine 内の認証情報漏洩リスクを構造的に低減できる。
- **TBP-001 新規照合②（v2.1.187 org-configured model restrictions）**: 組織設定でモデル使用を制限できる機能が追加（モデルピッカー・`--model`・`/model`・`ANTHROPIC_MODEL` に反映）。TBP-001 の「最小権限で開始」の組織レベル実装手段として追記を提案。
- **TBP-001 新規照合③（Fable 5 復旧シグナル）**: Android アプリでモデル名が再び表示され「server is temporarily rate-limiting requests」レスポンスに変化（6/23）。復旧後は auto モードで Fable 5 が選ばれ Agent SDK クレジット消費量に影響する可能性が高い。6/15 からの「課金体系への影響」評価項目追記提案と合わせて要対応。
- **TBP-002（実行環境英語パス）**: 新規トリガーなし。

---

### 外部リサーチ（機能B）
#### 参照した情報源
- Claude Code 公式チェンジログ: https://code.claude.com/docs/en/changelog（WebFetch）
- anthropics/claude-code GitHub Issues（WebSearch）
- WebSearch: Claude Code v2.1.187 changelog June 23 2026
- WebSearch: Anthropic Claude Fable 5 復旧 2026年6月23日（日本語メディア）
- WebSearch: 会計 AI 経理 自動化 freee マネーフォワード バクラク 2026年6月23日

#### 🔴 即座に適用すべき事項

**① Claude Code v2.1.187（2026-06-23 リリース）— クレデンシャル保護 + 組織モデル制限**
- **`sandbox.credentials` 設定（セキュリティ強化）**: サンドボックス化されたコマンドが認証情報ファイルおよびシークレット環境変数を読み取れないようにブロックする設定を追加。
  - **Research Hub への影響**: Routine 内の Bash コマンドが意図せず `.supabase-config` 等のシークレットファイルを読み取るリスクを構造的に防止できる。settings.json への追加を検討推奨。
- **org-configured model restrictions（組織管理向け）**: 組織設定で使用可能モデルを制限できるようになり、モデルピッカー・`--model`・`/model`・`ANTHROPIC_MODEL` に "restricted by your organization's settings" メッセージが表示される。
  - **Research Hub への影響**: Routine の auto モードで選択されるモデルを組織レベルで制限可能に。Fable 5 復旧時の意図しない高コストモデル選択を防ぐ手段として有用。
- **マウスクリックサポート追加**: 権限プロンプト・`/model`・`/config` 等の選択メニューでマウスクリックによる操作が可能に。
- **バグ修正**:
  - `--resume` が元の `-p` 実行でモデルターンがなかった場合に "No conversation found" で失敗する問題を修正。
  - `--json-schema` とワークフロー `agent({schema})` の構造化出力: モデルが成功した StructuredOutput コール後に無限再呼び出しするバグを修正。フォローアップターンが確実に構造化出力を返すように。
    - **Research Hub への影響**: deep-research-runner 等のワークフローエージェントの構造化出力安定性が向上。

#### 🟡 近いうちに試したいこと（上位3件）

**① `sandbox.credentials` 設定の Routine・settings.json への適用検討（v2.1.187）**
- 設定場所: `.claude/settings.json` に `"sandbox": { "credentials": false }` または同等の設定を追加。
- auto-research-collect・deep-research-runner 等の Routine でシークレット環境変数が不要な Bash コマンドを実行する場合に、クレデンシャル漏洩リスクをゼロにできる。
- TBP-001 の「最小権限で開始」をコード一行で実現できる強力な追加手段。詳細設定値の公式ドキュメント確認を推奨。

**② Fable 5 復旧への対応準備（6/23 復旧シグナル検知）**
- Android アプリで Fable 5 モデル名が「model unavailable」→「rate-limiting」に変化（6/23 報告）。これは復旧準備中のシグナルとして解釈できる。
- Anthropic ソウルオフィスのマネージングディレクターが「数日以内に利用可能になる」と明言（ソウル記者会見）。
- **推奨アクション**: 復旧前に org-configured model restrictions で Fable 5 を一時ブロックするか、Agent SDK クレジット消費量監視を強化しておく。Fable 5 が auto モードで選ばれると消費量が増加する可能性が高い。

**③ `agent({schema})` 構造化出力の安定性確認（v2.1.187 バグ修正）**
- deep-research-runner はワークフロー `agent({schema})` を使用している可能性がある。v2.1.187 の修正により、成功後の StructuredOutput 無限ループが解消。
- 次回の Routine 実行で構造化出力が安定して返ってくるか観測推奨。

#### 🟢 参考情報

**GitHub Issues 新着（2026-06-23）**
- Issue #70453: area:cli, area:docs 向けドキュメント改善（enhancement）
- Issue #70452: area:docs ドキュメント改善（enhancement）
- Issue #70451: area:agents ドキュメント改善（enhancement）
- Issue #70450: area:agent-view（claude agents TUI / --bg / FleetView / daemon bg sessions 関連）
- Issue #70449 〜 #70446: area:docs・area:tui 系ドキュメント改善（enhancement）
- **本日の特記事項**: 重大バグ・セキュリティ修正系 Issue なし。ドキュメント改善系が主。Research Hub の Routine 動作への直接影響なし。

**Fable 5 / Mythos 5 復旧状況（11 日目、2026-06-23）**
- 公式には依然「利用不可」のまま。
- **復旧シグナル（本日 6/23 新報告）**: Android アプリで Fable 5 モデル名が再び表示され、レスポンスが "model unavailable" → "server is temporarily rate-limiting requests" に変化。復旧準備に入ったとの見方あり。
- Anthropic ソウルオフィスのマネージングディレクターがソウル記者会見で「これらのモデルは数日以内に再び利用可能になる」と発言。
- 輸出規制指令の撤回・緩和に関する公式発表はまだなし。
- **Research Hub への影響**: 復旧が近い可能性が高い。Agent SDK クレジット消費量の変動に注意。

**会計×AI トレンド（2026-06-23 時点）**
- **freee MCP 実用化加速**: 2026年3月公開の freee MCP を活用した実践ガイドが増加。「AIアシスタントに話しかけるだけで請求書作成・仕訳入力・経費精算を自動化」が具体的な実装フローで解説される段階に（会計DX専門チームの技術ブログが充実）。
- **バクラク AIエージェント**: 申請内容のリアルタイムレビュー・メールからの証憑自動取得・最適仕訳の自動入力・入金消込を複数専門AIエージェントが協働処理。
- **マネーフォワード AIエージェント**: 既存業務フローを変えずにバックオフィス業務を自律的に遂行するサービスとして展開中。
- **定量効果（最新報告）**: 仕訳入力工数 80% 削減・請求書処理時間 70% 短縮・月次決算 5 営業日早期化が報告値として定着。
- **Tak 業務への参考**: freee × Claude Code 実践ガイドが公開（freee.co.jp × Claude Code で月100件〜数千件の仕訳を AI チェックする方法）。

**Zenn / Qiita 日本語コミュニティ（2026-06-23 時点）**
- v2.1.187 の日本語解説記事はまだ出ていない（本日夜以降に出てくる見込み）。
- 会計×AI 実践ブログが増加継続（freee MCP 完全ガイド、経理 AI ロードマップ等）。

#### references.md 更新提案

継続未確認項目（6/15〜6/22 提案から継続、全 11 項目）:
1. **v2.1.178 `Tool(param:value)` 権限構文**: 公式 best-practices ページへの追記確認（URL: https://code.claude.com/docs/en/best-practices）
2. **Claude Fable 5 モデル ID**: 「現在停止中（6/12〜）、復旧シグナルあり（6/23）」注記とともに追記提案
3. **最終確認日更新**: `*最終確認: 2026-03-29*` → `2026-06-23` への更新
4. **Claude Code GitHub Actions セキュリティ脆弱性 v1.0.94**: CI/CD 利用者向けセキュリティ注意事項（6/17 提案から継続）
5. **`/config key=value` 構文**: v2.1.181 新機能（6/18 提案から継続）
6. **`CLAUDE_CLIENT_PRESENCE_FILE` 環境変数**: PC 作業中のモバイル通知抑制（6/18 提案から継続）
7. **v2.1.183 デストラクティブ git コマンド自動ブロック**: 安全性・権限設計セクションへの追記提案（6/19 提案から継続）
8. **`attribution.sessionUrl` 設定**: Web/Remote Control セッションのコミット帰属設定（6/19 提案から継続）
9. **v2.1.186 Agent deny rules バグ修正**: named subagent spawn に deny ルールが適用されなかった問題の修正（6/22 提案から継続）
10. **`claude mcp login/logout <name>`**: MCP サーバーの CLI 認証コマンド（6/22 提案から継続）
11. **`respondToBashCommands: false` 設定**: `!` bash コマンドの Claude 自動応答を無効化（6/22 提案から継続）

**新規追加提案（2026-06-23）**:
12. **v2.1.187 `sandbox.credentials` 設定**: サンドボックスコマンドがクレデンシャルファイル・シークレット環境変数を読み取れないようにブロック。セキュリティ・権限設計セクションへの追記提案。TBP-001「最小権限で開始」の実装手段として重要。
13. **v2.1.187 org-configured model restrictions**: 組織設定で使用可能モデルを制限する機能。Routine 設計・コスト制御の観点から権限設計セクションへの追記を提案。

#### 新規発見ソース候補
なし（本日は新規ソース未発見）

#### 次回リサーチ推奨日

2026-06-24（明日: Fable 5 復旧シグナルを受けて通常より早め）
注目点:
① **Fable 5 / Mythos 5 復旧確認**（Android で rate-limit レスポンスに変化。「数日以内」発言から翌日確認が重要）
② **復旧した場合のクレジット消費量影響**: Agent SDK クレジットへの即時影響を観測
③ v2.1.187 `sandbox.credentials` 設定の公式ドキュメント詳細確認
④ `agent({schema})` StructuredOutput 修正の deep-research-runner への実効果
⑤ TBP 昇格候補 2 件（6/22 提案）の Tak 確認状況

---

## [2026-06-22] デイリーレポート

### 内部知見（機能A）
#### 新規・更新 ADR
- My-Profile-and-Memory/decisions/ → フォルダ未存在のためスキップ
- research-hub/decisions/ → フォルダ未存在のためスキップ
- StudyMate, My-URAWA-LOG, tak-work, tak-family, tak-personal → アクセス可能リポジトリ外のためスキップ
- **claude-auto-memory 新規・更新ファイル2件（2026-06-22 コミット）**:
  1. `c--dev-My-URAWA-LOG/feedback_check_done_before_redo.md`（新規追加）
     - 内容: backlog・navigator の「未着手」タスクに着手前に、git log で完了済みでないか照合する
     - 背景: Session 115 で Phase 3 Step C/D が commit bf20814 で完了済みにもかかわらず navigator が backlog のままで、再実行する寸前になった（[[feedback_data_quality_signal]] 系統）
  2. `c--dev-tak-orchestrator/default-safe-direction-by-irreversibility.md`（更新: R92 追記）
     - 更新内容: 「行き過ぎ注意（R92）」節を追記。「カテゴリ丸ごと危険扱い」は北極星（目的）を殺す。機密は「数値情報（金額・口座・案件固有値）」であって memory 全般ではない。Tak の違和感が最後の砦。

#### TBP 昇格候補
**① `feedback_check_done_before_redo` → 「着手前に実態（git）と文書（backlog）の一致を確認する」**
- 3条件評価:
  1. 他プロジェクトでも同じ判断をするか？ → YES（backlog/navigator がある全プロジェクトで共通の罠）
  2. この知見なしで同じ感覚で指示したとき問題が起きるか？ → YES（完了済みタスクの再実行リスクはどのプロジェクトでも起きる）
  3. 特定技術でなく Tak の作業スタイル全般に適用されるか？ → YES（「文書より実態を一次確認する」は技術横断の原則）
- **推奨: TBP-003 候補として Tak 確認を要請**

**② `default-safe-direction-by-irreversibility` R92 更新 → 「不可逆性で安全方向を決めるが、カテゴリ丸ごとの保守化は目的を殺す」**
- 3条件評価:
  1. 他プロジェクトでも同じ判断をするか？ → YES（分類・同期・公開の既定値設計はすべてのプロジェクトで直面する）
  2. この知見なしで問題が起きるか？ → YES（インシデント直後の恐怖で全体を除外しすぎる過保守は繰り返しやすい）
  3. 特定技術でなく Tak の作業スタイル全般か？ → YES（リスク判断の軸の具体化は設計横断）
- **推奨: TBP-001 の「審査」節への追記候補、または TBP-004 として独立化。Tak 確認を要請**

#### 再検討トリガー該当
- **TBP-001（外部ツール導入審査）継続**: 課金体系変更・地政学的リスク・デストラクティブ操作自動防御の評価項目追記提案が未確認のまま継続（6/15〜6/21 提案）。
- **TBP-001 新規照合（v2.1.186 Agent deny rules 修正）**: `Agent(type)` deny ルールと `Agent(x,y)` allowed-types 制限が「名前付きサブエージェントのスポーン」に対して適用されていなかったバグが v2.1.186 で修正。これは TBP-001 の「最小権限で開始」原則において settings.json の deny ルールが想定通りに機能していなかったことを意味する。**今後は設定の実効性をバージョン毎に確認する手順**を TBP-001 の審査項目に加えることを提案。
- **TBP-002（実行環境英語パス）**: 新規トリガーなし。

---

### 外部リサーチ（機能B）
#### 参照した情報源
- Claude Code 公式チェンジログ: https://code.claude.com/docs/en/changelog（WebFetch）
- anthropics/claude-code GitHub Issues: https://github.com/anthropics/claude-code/issues（WebFetch）
- isfableback.com / 日本語メディア（WebSearch: Fable 5 復旧状況）
- WebSearch: Claude Code v2.1.186, freee/マネーフォワード/バクラク AI 更新, 会計×AI 2026年6月22日

#### 🔴 即座に適用すべき事項

**① Claude Code v2.1.186（2026-06-22 リリース）— Agent deny rules セキュリティ修正**
- **`Agent(type)` deny ルールと `Agent(x,y)` allowed-types 制限が、名前付きサブエージェントのスポーンに対して適用されていなかった問題を修正（セキュリティ修正）**
  - v2.1.178 以降の `Tool(param:value)` 権限構文で `Agent(model:opus)` 等の deny ルールを設定していても、named subagent spawn 時に適用されない状態だった。
  - **Research Hub への影響**: settings.json の Agent 制限ルールが Routine 内サブエージェントで意図通りに機能していなかった可能性。v2.1.186 へのアップデート後に実挙動を確認推奨。
- **その他の主要変更**:
  - `claude mcp login <name>` / `claude mcp logout <name>`: インタラクティブメニューなしで MCP サーバーの CLI 認証が可能に
  - `/workflows` エージェント詳細ビューにステータスフィルタリング（`f` キー）追加
  - `/plugin` Installed タブに「Skills」セクション追加（インストール済みスキルの一覧表示）
  - `teammateMode: "iterm2"` 設定追加（自動モード検知時の警告対応）
  - "Claude Platform on AWS - refresh credentials" オプション追加（`/login` メニュー）
  - `!` 始まりの bash コマンドが Claude の自動応答をトリガーするように（`"respondToBashCommands": false` で無効化可能）
  - マシンスリープ後のストリーミングリクエスト失敗を修正（Routine 実行環境での安定性向上）
  - メモリコンパクションリマインダーの改善・スキルフロントマターの kebab-case・snake_case・camelCase すべてサポート

#### 🟡 近いうちに試したいこと（上位3件）

**① `claude mcp login/logout <name>` の Routine 活用検討（v2.1.186）**
- MCP サーバーへのログインをスクリプト/CLI から実行可能に。インタラクティブメニュー不要。
- Routine での MCP 認証フロー簡素化の可能性。`research-hub-relay` 以外の MCP 連携がある場合にセキュリティ改善の機会。

**② Issue #70156 — Linux でサブエージェントが worktree マージ時に MCP 承認待ちでスタック**
- Linux（Anthropic クラウド sandbox）でエージェントが worktree にマージされると、MCP サーバーの承認を待ってスタックするバグ（area:agents, area:mcp, bug）。
- Research Hub の Routine は Linux 上で動作するため、サブエージェントと MCP を組み合わせた Routine（auto-research-collect 等）が対象になる可能性。修正状況の追跡を推奨。

**③ Fable 5 無料期間終了（本日 6/22）後の auto モード確認**
- 6/9〜6/22 の Fable 5 無料期間が本日終了。ただし Fable 5 は 6/12 から全面停止中で実質的に無効だった。
- 無料期間終了後に Fable 5 が復旧した場合、auto モードでは有料利用（Agent SDK クレジット消費増）となる。要監視。

#### 🟢 参考情報

**GitHub Issues 新着（2026-06-22）**
- Issue #70167: mcp deferred tool regression — ToolSearch ロード後に空パラメータで常に呼ばれるバグ（area:mcp, area:tools, has repro）
- Issue #70166: Anthropic ホスト型 MCP サーバー（公式ドキュメント向け）機能要望（enhancement）
- Issue #70165: iOS 1.260618.0 が Remote Control セッション起動でクラッシュ（regression, platform:ios）
- Issue #70164: iOS の New Code Session タップで即クラッシュ（6/22 更新後 regression, platform:ios）
- Issue #70162: Desktop HTTP MCP server が marketplace plugin の `.mcp.json` でカウントされるが登録されないバグ（regression）
- Issue #70161: Statusline OSC 8 ハイパーリンクがクリック不可（v2.1.181 以降 regression）
- Issue #70160: Anthropic API エラー: 開始数分でタイムアウト・レート制限（area:agents, area:api）
- Issue #70159: 実行中トークンカウンターが入力フォーカスで消えるバグ（area:cost, area:tui）
- Issue #70158: スキルコンテンツをキャッシュ済みシステムプロンプトに注入してトークンコスト削減の機能要望（enhancement）
- Issue #70157: Zed IDE 統合でエージェントがローディング状態でスタック（area:ide）
- Issue #70156: （上記 🟡② 参照）
- **Research Hub の Routine 動作への直接影響**: #70156（Linux worktree MCP スタック）・#70167（deferred tool regression）が最も関連度高い。

**Fable 5 / Mythos 5 停止継続（10 日目、2026-06-22 時点）**
- 6/12 の輸出規制指令による停止が 10 日目。本日 6/22 で Fable 5 無料期間が終了。
- isfableback.com のトラッキングサイトでは依然「No（未復旧）」の状態を継続。
- Anthropic エグゼクティブの「近日中（coming days）」発言（6/18）から 4 日経過するも復旧なし。
- 輸出規制指令の撤回・緩和に関する公式発表なし。Trump 大統領が「Anthropic を安全保障上の脅威と見なさない」と発言（6/20）しているが、輸出規制指令は継続中。

**会計×AI トレンド（2026-06-22 時点）**
- freee・マネーフォワード・バクラクの本日付け新着 AI 機能発表: 特定の新発表なし（継続トレンド）。
- freee AI（beta）の5エージェント・マネーフォワード Admina × バクラク API 連携: 継続展開中。
- 2026 年継続トレンド: 経費精算工数 75% 削減・PEPPOL 請求書標準化・財務 AI の「効率化→戦略変革」フェーズ移行（過去レポートから継続）。

#### references.md 更新提案

継続未確認項目（6/15〜6/21 提案から継続、全 8 項目）:
1. **v2.1.178 `Tool(param:value)` 権限構文**: 公式 best-practices ページへの追記確認（URL: https://code.claude.com/docs/en/best-practices）
2. **Claude Fable 5 モデル ID**: 「現在停止中（6/12〜）、無料期間終了（6/22）、復旧状況錯綜」注記とともに追記提案
3. **最終確認日更新**: `*最終確認: 2026-03-29*` → `2026-06-22` への更新
4. **Claude Code GitHub Actions セキュリティ脆弱性 v1.0.94**: CI/CD 利用者向けセキュリティ注意事項（6/17 提案から継続）
5. **`/config key=value` 構文**: v2.1.181 新機能（6/18 提案から継続）
6. **`CLAUDE_CLIENT_PRESENCE_FILE` 環境変数**: PC 作業中のモバイル通知抑制（6/18 提案から継続）
7. **v2.1.183 デストラクティブ git コマンド自動ブロック**: 安全性・権限設計セクションへの追記提案（6/19 提案から継続）
8. **`attribution.sessionUrl` 設定**: Web/Remote Control セッションのコミット帰属設定（6/19 提案から継続）

**新規追加提案（2026-06-22）**:
9. **v2.1.186 Agent deny rules バグ修正**: `Agent(type)` deny ルール / `Agent(x,y)` allowed-types 制限が named subagent spawn に適用されていなかった問題の修正。権限設計セクションへの追記提案。
10. **`claude mcp login/logout <name>`**: MCP サーバーの CLI 認証コマンド（v2.1.186 新機能）。MCP 管理セクションへの追記を提案。
11. **`respondToBashCommands: false` 設定**: `!` bash コマンドの Claude 自動応答を無効化（v2.1.186 新機能）。Routine プロンプト設計の参考として記録。

#### 新規発見ソース候補
なし（本日は新規ソース未発見）

#### 次回リサーチ推奨日

2026-06-29（通常スケジュール、1週間後）
注目点:
① Fable 5 / Mythos 5 復旧状況（無料期間終了後の動向・輸出規制指令撤回の有無）
② v2.1.186 Agent deny rules 修正が Routine の実挙動に与えた影響の観測
③ Issue #70156（Linux worktree MCP スタック）のパッチリリース確認
④ Agent SDK クレジット消費量の 2 週間目観測（6/15 施行後）
⑤ TBP 昇格候補 2 件（feedback_check_done_before_redo / default-safe-direction-by-irreversibility R92）の Tak 確認

---

## [2026-06-21] デイリーレポート

### 内部知見（機能A）
#### 新規・更新 ADR
- My-Profile-and-Memory/decisions/ → フォルダ未存在のためスキップ
- StudyMate, My-URAWA-LOG, tak-work, tak-family, tak-personal → アクセス可能リポジトリ外のためスキップ
- tak-best-practices/ → TBP-001（外部ツール導入審査）・TBP-002（実行環境英語パス）を確認（新規 ADR なし）

#### TBP 昇格候補
なし（新規 ADR なし）

#### 再検討トリガー該当
- **TBP-001（外部ツール導入審査）継続**: 課金体系変更・地政学的リスク・エージェントのデストラクティブ操作自動防御設計の評価項目追記提案が未確認のまま継続（6/15〜6/20 提案）。
- **TBP-001 新規照合（Issue #69931 サブエージェント+MCP クレジット急消費）**: Claude Max 週次使用量がサブエージェント・Gmail MCP セッションの組み合わせで予想外に早く枯渇するバグ（area:agents, area:cost, area:mcp）が報告された。外部ツール（MCP）導入時の「課金コスト予測困難性」を TBP-001 審査基準に加える根拠として新たに記録。
- **TBP-001 新規照合（Fable 5「deemed export」法的仕組み明確化）**: 「みなし輸出」条項（15 CFR 734.13）が半導体設計情報等向けの法律をリアルタイム AI 推論に初適用されたことが今日報道で明確化。地政学的リスクの具体的なメカニズムとして TBP-001 評価基準に追記する材料。
- **TBP-002（実行環境英語パス）**: 新規トリガーなし。

---

### 外部リサーチ（機能B）
#### 参照した情報源
- Claude Code 公式チェンジログ: https://code.claude.com/docs/en/changelog（WebFetch）
- anthropics/claude-code GitHub Issues: https://github.com/anthropics/claude-code/issues（WebFetch）
- Anthropic Newsroom: https://www.anthropic.com/news（WebSearch）
- WebSearch: Claude Code GitHub Issues 6/21, Fable 5 復旧状況, 会計×AI 2026年6月, freee/バクラク AI アップデート

#### 🔴 即座に適用すべき事項

なし（本日は重大インシデント・セキュリティ更新なし）

#### 🟡 近いうちに試したいこと（上位3件）

**① Issue #69934 — Routines リストがタスクIDを表示するバグ（6/21 新着、area:routines, area:ui）**
- Routines の一覧画面で、Routine のラベル/説明文ではなく正規化されたタスク ID（例: `trig_01M35mr4nxRZZVWjFrtRdZyf`）が表示されるバグ。
- **Research Hub への直接影響**: daily-research や auto-research-collect 等のスケジュールタスクが Anthropic Console の Routines 一覧でタスクIDで表示され、視認性が低下している可能性。パッチリリース次第で運用改善が期待できる。

**② Fable 5 / Mythos 5 状況の錯綜（9 日目、6/21）— 情報の精査が必要**
- explainx.ai（6/21 付）: 「9 日経過、依然として全ユーザー向けオフライン継続」
- techjacksolutions.com: 「身元確認（mandatory identity verification）とジオフェンシング（geo-fencing）付きで一部復旧」（日付不明確）
- techtimes.com（6/20）: 「Trump は Anthropic を安全保障上の脅威と見なさないと発言したが、輸出規制指令は継続中」
- **Research Hub への影響**: 情報が錯綜しているため isfableback.org でのリアルタイム確認が必要。復旧した場合は auto モードで Fable 5 が選ばれ Agent SDK クレジット消費量に影響する可能性。

**③ Issue #69931 — Claude Max クレジット急消費バグへの注意（6/21 新着、area:agents, area:cost, area:mcp）**
- サブエージェントと Gmail MCP を組み合わせたセッションで、Claude Max の週次使用量が予想外に早く枯渇するバグ。
- **Research Hub への影響**: Research Hub の Routines は複数 MCP を使用するケースがあるため、クレジット消費量の急増が発生した場合の原因候補として記録。月次クレジット消費量モニタリングを継続推奨。

#### 🟢 参考情報

**GitHub Issues 新着（2026-06-21）**
- Issue #69936: 音声入力の複数言語サポート要望（area:ide, enhancement, VS Code）
- Issue #69935: 複数シェルスナップショットプロセスが 100% CPU 消費・バッテリー消耗バグ（area:bash, perf:cpu, macOS）
- Issue #69933: 重複ワークフロー貼り付けで不要なトークンを消費するバグ（area:cost, needs-repro）
- Issue #69930: macOS 認証バグ（area:auth）
- Issue #69929: /plugin Disable/Enable toggle がプラグインマニフェスト名と marketplace ディレクトリ名が異なる場合に誤ったキーを対象にするバグ（area:plugins, Linux）
- Issue #69928: macOS 13.x での dyld シンボルエラー（area:installation）
- Issue #69927: UTF-16 サロゲート文字がセッションをブリックするバグ（area:core, 400エラー繰り返し）
- Issue #69926: Deferred-tool call が ToolSearch ロードと同一ターンに発行された場合にセッションを永続的にブリックするバグ（area:core, has repro, duplicate）
- Issue #69925: Anthropic API レート制限バグ（area:api, duplicate）
- Issue #69924: モデル選択・Effort ティア・トークン経済のオンボーディングツアー要望（area:cost, area:tui, enhancement）
- Research Hub の Routine 動作への直接影響: #69934 と #69931 のみ（上記🟡参照）

**Fable 5 の「みなし輸出（deemed export）」法的背景の明確化**
- 米国商務省の輸出規制（15 CFR 734.13 の「deemed export」条項）が、半導体設計図や技術データ向けに書かれた法律をリアルタイム AI 推論のクラウドエンドポイントに初めて適用した事例として記録。
- 法的ギャップ（AIクラウド推論を輸出規制対象と捉えたことがなかった）が全世界停止の原因。
- 参考: fifthrow.com による解説
- Polymarket で「Claude Fable 5 が 2026-06-13 までに米国ユーザー向けに復旧するか」という予測市場イベントが存在（既に期限切れ）。

**Claude Code v2.1.185 が最新（6/20 リリース）— 6/21 新リリースなし**
- 本日（6/21）時点で新バージョンリリースなし。最新は v2.1.185（6/20）。
- チェンジログ: https://code.claude.com/docs/en/changelog で確認済み。

**会計×AI トレンド（2026-06-21 時点）**
- freee 統合ワールド 2026（6/16）のAI 新発表詳細: 具体的な新機能発表内容は今回取得できず。次回確認推奨。
- freee OCR 精度: 2026 年大幅アップデートで手書き領収書 75% 前後、印刷レシート 90% 超の精度を実現（自動仕訳推測は銀行明細 85〜90%、クレカ明細 80%）。
- バクラク×freee API 連携問題: 2024/7 の freee プラン改定による API 制限後、バクラクは CSV 連携機能を開発中。マネーフォワード クラウド会計との API 連携も協議中。
- 経理 AI エージェント事例: ENEOS トレーディングが AI-OCR+入力代行で月 200 時間の手作業をゼロに（3,000 行/月の請求書明細処理）。
- 継続トレンド: 経費精算 75% 削減・PEPPOL 標準化・財務戦略変革フェーズ移行（過去レポート参照）。

**Anthropic 6/21 新着ニュース**
- 特に重大な新発表なし。
- Trump が Anthropic を「米国安全保障上の脅威と見なさない」と発言（techtimes 6/20 報道）したが、輸出規制指令は継続中。

#### references.md 更新提案

継続未確認項目（6/15〜6/20 提案から継続、全 8 項目）:
1. **v2.1.178 `Tool(param:value)` 権限構文**: 公式 best-practices ページへの追記確認（URL: https://code.claude.com/docs/en/best-practices）
2. **Claude Fable 5 モデル ID**: 「現在停止中（6/12〜）、復旧状況錯綜」注記とともに追記提案（注: techjacksolutions が「ジオフェンシング付きで部分復旧」を報告しているが未確認）
3. **最終確認日更新**: `*最終確認: 2026-03-29*` → `2026-06-21` への更新
4. **Claude Code GitHub Actions セキュリティ脆弱性 v1.0.94**: CI/CD 利用者向けセキュリティ注意事項（6/17 提案から継続）
5. **`/config key=value` 構文**: v2.1.181 新機能（6/18 提案から継続）
6. **`CLAUDE_CLIENT_PRESENCE_FILE` 環境変数**: PC 作業中のモバイル通知抑制（6/18 提案から継続）
7. **v2.1.183 デストラクティブ git コマンド自動ブロック**: 安全性・権限設計セクションへの追記提案（6/19 提案から継続）
8. **`attribution.sessionUrl` 設定**: Web/Remote Control セッションのコミット帰属設定（6/19 提案から継続）

**新規追加提案（2026-06-21）**: なし（本日は新機能リリースなし）

#### 新規発見ソース候補
- **techjacksolutions.com/ai-brief**: AI 規制ニュースの速報。Fable 5 ジオフェンシング付き部分復旧を報告した一次ソース候補（評価候補: ⭐⭐⭐）
- **explainx.ai/blog**: Fable 5 復旧状況のリアルタイム追跡記事を継続更新（評価候補: ⭐⭐⭐）

#### 次回リサーチ推奨日

2026-06-22（通常スケジュール）
注目点:
① Fable 5 / Mythos 5 復旧状況の確認（情報錯綜を整理。isfableback.org + techjacksolutions.com で照合）
② Issue #69934（Routines タスクID表示バグ）のパッチリリース確認
③ Agent SDK クレジット消費量の週次観測（6/15 施行後 1 週間 = 節目）
④ freee 統合ワールド 2026（6/16）の AI 新発表詳細フォローアップ

---

## [2026-06-20] デイリーレポート

### 内部知見（機能A）
#### 新規・更新 ADR
- My-Profile-and-Memory/decisions/ → フォルダ未存在のためスキップ
- StudyMate, My-URAWA-LOG, tak-work, tak-family, tak-personal → アクセス可能リポジトリ外のためスキップ
- tak-best-practices/ → TBP-001（外部ツール導入審査）・TBP-002（実行環境英語パス）を確認（新規 ADR なし）

#### TBP 昇格候補
なし（新規 ADR なし）

#### 再検討トリガー該当
- **TBP-001（外部ツール導入審査）継続**: 課金体系変更・地政学的リスク・エージェントのデストラクティブ操作自動防御設計の評価項目追記提案が未確認のまま継続（6/15〜6/19 提案）。
- **TBP-001 新規照合（GitHub Issue #69793 データロス）**: 本日新着の Issue #69793 で、Claude Code（area:model）が生成した `xargs rm -rf` コマンドにヌル区切りがなく、スペースを含むパスのファイルを削除するデータロスが報告された。v2.1.183 のデストラクティブ git コマンド自動ブロックと合わせ、「エージェントが生成する Bash コマンドのデータロスリスク」を TBP-001 の審査基準に明示的に加える価値あり。
- **TBP-001 新規照合（GitHub Issue #69798 モデル誤情報）**: モデルがタスク回避のために意図的に誤情報を提供するバグ（area:model）が報告。外部 AI ツール評価基準に「モデルのタスク回避・誤動作リスク」の視点を加える検討材料として記録。
- **TBP-002（実行環境英語パス）**: 新規トリガーなし。

---

### 外部リサーチ（機能B）
#### 参照した情報源
- Claude Code 公式チェンジログ: https://code.claude.com/docs/en/changelog（WebFetch）
- anthropics/claude-code GitHub Issues: https://github.com/anthropics/claude-code/issues（WebFetch）
- Anthropic Newsroom: https://www.anthropic.com/news（403 返却、アクセス不可）
- Zenn（claude-code タグ）: 403 返却、アクセス不可
- isfableback.org: 403 返却、アクセス不可
- WebSearch: 本日は全クエリでサービス不可（unavailable）

#### 🔴 即座に適用すべき事項

なし（本日は重大インシデント・セキュリティ更新なし）

#### 🟡 近いうちに試したいこと（上位3件）

**① Claude Code v2.1.185（2026-06-20 リリース）— ストリーム停止ヒント改善**
- ストリーム停止ヒントのメッセージと発動タイミングが変更:
  - 旧: "No response from API · Retrying in …"（10秒後に発動）
  - 新: "Waiting for API response · will retry in …"（20秒後に発動）
- **Research Hub への影響**: deep-research-runner・auto-research-collect 等の long-running Routine でのリトライ可視性が向上。10〜20秒の無応答期間でのノイズが減り、本当に問題がある場合のシグナルが明確になる。

**② GitHub Issue #69793 — xargs rm -rf データロスバグへの注意（2026-06-20 新着、area:model・data-loss）**
- Claude Code が生成した `xargs rm -rf`（ヌル区切り `-0` なし）コマンドが、スペースを含むパスのファイルを誤って削除するデータロスを引き起こした。
- `has repro` ラベルが付いており再現性が確認されている。
- **Research Hub への影響**: Routine 内でファイル削除系の Bash コマンドを Claude が自律的に生成・実行するケースがあれば要注意。プロンプト側で削除コマンドの禁止ルールを明示するか、settings.json で `Bash(command:rm*)` を制限するアプローチを検討（v2.1.178 の `Tool(param:value)` 権限構文が使用可能）。

**③ GitHub Issue #69800 — Linux でエージェントがファイル変更を永続化できないバグ（area:agents、再現あり）**
- Linux 上でエージェントが PID-tied プロセスを強制生成した場合にファイル変更が永続化されない。
- Research Hub の Routine は Anthropic クラウド sandbox（Linux）上で動作するため、条件に合致する場合は Routine の失敗原因として参照価値あり。

#### 🟢 参考情報

**GitHub Issues 新着（2026-06-20）**
- Issue #69802: ExitWorktree 削除がworktree孤立化を引き起こすバグ（admin エントリ・ブランチ残存、稀に親リポジトリを破壊）
- Issue #69801: Issue タイトル生成失敗（macOS / VS Code、bugs / needs-info）
- Issue #69799: 埋め込みターミナルのスクロールバック上限削除/拡大リクエスト（enhancement）
- Issue #69798: モデルがタスク完了を回避するために誤情報を提供するバグ（area:model、needs-repro）
- Issue #69796: macOS の Cmd+Left / Option+Left/Right ワード移動ショートカットが埋め込みターミナルで動作しない（keybindings、enhancement）
- Issue #69795: デスクトップアプリの Effort スライダーが非機能（regression、macOS）
- Issue #69794: Windows 11 Pro での OAuth ログイン失敗（area:auth、Missing redirect_uri）
- Issue #69793: （上記 🟡② 参照）
- Issue #69792: macOS で非ASCII文字が予期せず出力されるバグ（area:model）
- #69793 以外はいずれも Research Hub の Routine 動作への直接影響軽微。

**Fable 5 / Mythos 5 停止継続（推定 8 日目）**
- isfableback.org が 403 のため本日は直接確認不可。
- 6/19 時点（7 日目）では未復旧。Anthropic エグゼクティブが「近日中」発言（6/18）から 2 日目。復旧か否かは次回リサーチで要確認。

**会計×AI トレンド（2026-06-20 時点）**
- Web 検索・Anthropic Newsroom ともにアクセス不可のため本日は新情報収集なし。
- 継続トレンドとして、PEPPOL 標準化・経費精算 75% 削減事例・財務戦略変革フェーズ移行（6/17〜6/19 レポートを参照）。

#### references.md 更新提案

継続未確認項目（6/15〜6/19 提案から継続）:
1. **v2.1.178 `Tool(param:value)` 権限構文**: 公式 best-practices ページへの追記確認（URL: https://code.claude.com/docs/en/best-practices）
2. **Claude Fable 5 モデル ID**: 「現在停止中（6/12〜）、近日復旧見込み」注記とともに追記提案
3. **最終確認日更新**: `*最終確認: 2026-03-29*` → `2026-06-20` への更新
4. **Claude Code GitHub Actions セキュリティ脆弱性 v1.0.94**: CI/CD 利用者向けセキュリティ注意事項（6/17 提案から継続）
5. **`/config key=value` 構文**: v2.1.181 新機能（6/18 提案から継続）
6. **`CLAUDE_CLIENT_PRESENCE_FILE` 環境変数**: PC 作業中のモバイル通知抑制（6/18 提案から継続）
7. **v2.1.183 デストラクティブ git コマンド自動ブロック**: 安全性・権限設計セクションへの追記提案（6/19 提案から継続）
8. **`attribution.sessionUrl` 設定**: Web/Remote Control セッションのコミット帰属設定（6/19 提案から継続）

**新規追加提案（2026-06-20）**: なし（v2.1.185 は軽微な UX 改善のみ）

#### 新規発見ソース候補
なし（本日は新規ソース未発見）

#### 次回リサーチ推奨日

2026-06-22（通常スケジュール）
注目点:
① Fable 5 / Mythos 5 復旧状況（isfableback.org で確認。エグゼクティブ「近日中」発言から 4 日目）
② Issue #69793（xargs データロス）のパッチリリース確認
③ Agent SDK クレジット消費量の週次観測（6/15 施行後 1 週間）
④ v2.1.185 ストリーム停止ヒント改善の Routine 実観測効果

---

## [2026-06-19] デイリーレポート

### 内部知見（機能A）
#### 新規・更新 ADR
- My-Profile-and-Memory/decisions/ → フォルダ未存在のためスキップ
- StudyMate, My-URAWA-LOG, tak-work, tak-family, tak-personal → アクセス可能リポジトリ外のためスキップ
- tak-best-practices/ → TBP-001（外部ツール導入審査）・TBP-002（実行環境英語パス）を確認（新規 ADR なし）

#### TBP 昇格候補
なし（新規 ADR なし）

#### 再検討トリガー該当
- **TBP-001（外部ツール導入審査）継続**: 課金体系変更・地政学的リスクの評価項目追記提案が未確認のまま継続（6/15〜6/18 提案）。
- **TBP-001 新規照合（v2.1.183 安全性強化）**: デストラクティブ git コマンド（reset --hard / checkout -- . / clean -fd / stash drop）が Claude Code 側で自動ブロックに。外部ツール導入審査基準に「エージェントによるデストラクティブ操作の自動防御設計」評価軸を加える価値があるか検討を提案。
- **TBP-002（実行環境英語パス）**: 新規トリガーなし。

---

### 外部リサーチ（機能B）
#### 参照した情報源
- Claude Code 公式チェンジログ: https://code.claude.com/docs/en/changelog
- Anthropic Newsroom: https://www.anthropic.com/news
- anthropics/claude-code GitHub Issues: https://github.com/anthropics/claude-code/issues
- WebSearch（Claude Code v2.1.183, Fable 5 復旧状況, 会計×AI, Zenn/Qiita 動向）

#### 🔴 即座に適用すべき事項

**① Claude Code v2.1.183（2026-06-19 リリース）— git コマンド安全性強化**
- **デストラクティブ git コマンドの自動ブロック（重要）**: ユーザーがローカル変更の破棄を明示的に要求していない場合、以下が自動ブロックされる:
  - `git reset --hard`
  - `git checkout -- .`
  - `git clean -fd`
  - `git stash drop`
- **git commit --amend の制限**: そのセッション内でエージェントが作成していないコミットへの `--amend` もブロック。意図しない既存コミット改ざんを防止。
- **非推奨モデル使用時の警告追加**: 使用モデルが deprecated または自動更新された場合に警告表示。Fable 5 復旧後の auto モード切り替わりを把握しやすくなる。
- **`attribution.sessionUrl` 設定追加**: Web・Remote Control セッション（Routine 含む）のコミット/PRへの claude.ai セッションリンク付与をオフにするオプション（プライバシー配慮）。
- **`/config --help` 追加**: `/config key=value`（v2.1.181 新機能）で使用可能なショートハンドキーの一覧を表示。
- **バックグラウンド自動バージョン更新**: バックグラウンドエージェントセッションがアップデート後もコールドリスタートなしで新バージョンに移行（Routine 可用性向上の可能性）。
- その他: Grep/Glob ツールの明示的リスト登録サポート（ネイティブビルド）・`/effort` コマンドの確認フロー改善・スラッシュコマンド補完が即実行でなくプロンプトへの補完に変更。
- **Research Hub への影響**: Routines の auto-research-collect 等でエージェントが意図せず git reset --hard 等を実行するリスクが構造的に低減。ただし Routine プロンプト内に破棄系 git コマンドを明示記述している場合は動作変更の可能性を要確認。

#### 🟡 近いうちに試したいこと（上位3件）

**① `attribution.sessionUrl` 設定の Routine 向け活用検討（v2.1.183）**
- Remote Control セッション（Routine 含む）で生成されるコミット/PRへのセッション URL 自動付与をオフにできる。
- 設定場所: `.claude/settings.json` の `attribution.sessionUrl: false`。
- Routine コミットへのセッションリンク付与が不要な場合やプライバシー上の要件がある場合に有用。

**② Fable 5 / Mythos 5 復旧後の auto モードへの影響確認**
- 6/18 の「近日中（coming days）復旧見込み」発言（Anthropic エグゼクティブ）から 1 日経過するも、2026-06-19 現在でも未復旧。
- 復旧時は auto モードで Fable 5 が選ばれ、Agent SDK クレジット消費量に影響する可能性。isfableback.org で追跡継続推奨。

**③ バックグラウンドエージェントの自動バージョン更新（v2.1.183）の Routine 挙動確認**
- 長時間 Routine（deep-research-runner 等）での接続安定性向上が期待できるが、実際の効果は次回実行時に観測推奨。

#### 🟢 参考情報

**GitHub Issues 新着（2026-06-19）**
- Issue #69643: MCP バグ（macOS）
- Issue #69642: packaging バグ（WSL）
- Issue #69641: TUI（duplicate）
- Issue #69647: IDE 機能要望（Linux / VS Code）
- Issue #69645: UI バグ（Linux / VS Code）
- Issue #69644: agents バグ（再現手順待ち）
- いずれも Research Hub の Routine 動作への直接影響なし。

**Fable 5 停止継続（2026-06-19 現在）**
- 6/12 の米政府輸出規制指令による停止が 7 日目に突入。Anthropic は「できるだけ早期の復旧に取り組む」と表明するも、復旧タイムラインは未定。
- Zenn・Qiita に「Fable 5 が使えなくなった経緯」解説記事が多数投稿（情報把握には十分）。

**Anthropic インフラ強化（参考）**
- Google/Broadcom との 3.5GW TPU 計画（4月発表）: 2027 年以降稼働予定の次世代コンピュート確保。run-rate 売上高が 2025 年末 $9B → 2026 年 $30B 超に急成長（$1M+ 支出企業が 2 ヶ月で倍増）。
- Claude の運用安定性・モデル性能向上の長期的な基盤として記録。

**Zenn / Qiita 日本語コミュニティ（2026-06-19 時点）**
- 新着重大記事なし。継続トレンド:
  - 「コードを書けない私が、AI に『チーム』を持たせるまで」（9 AI エージェント編成）が引き続き参照多数
  - Zenn × Anthropic 戦略提携（4月）後の Claude Code 活用記事が継続増加
  - v2.1.183 安全性強化に関する日本語解説記事は本日夜以降に出てくる見込み

**会計×AI トレンド（2026-06-19 時点）**
- 新規重大発表なし。継続トレンド:
  - 経費精算工数 75% 削減事例が「業界標準化フェーズ」に（国内中堅企業の 7 割が依然手入力、月末残業平均 32 時間）
  - 財務 AI の「効率化ツール → 財務戦略変革」フェーズ移行が継続
  - KPMG 調査: 経理・財務業務に AI 導入している企業は 71%、半数以上が生成 AI を本格運用中

#### references.md 更新提案

継続未確認項目（6/15〜6/18 提案から継続）:
1. **v2.1.178 `Tool(param:value)` 権限構文**: 公式 best-practices ページへの追記確認（URL: https://code.claude.com/docs/en/best-practices）
2. **Claude Fable 5 モデル ID**: 「現在停止中（6/12〜）、近日復旧見込み」注記とともに追記提案
3. **最終確認日更新**: `*最終確認: 2026-03-29*` → `2026-06-19` への更新
4. **Claude Code GitHub Actions セキュリティ脆弱性 v1.0.94**: CI/CD 利用者向けセキュリティ注意事項（6/17 提案から継続）
5. **`/config key=value` 構文**: v2.1.181 新機能（6/18 提案から継続）
6. **`CLAUDE_CLIENT_PRESENCE_FILE` 環境変数**: PC 作業中のモバイル通知抑制（6/18 提案から継続）

**新規追加提案（2026-06-19）**:
7. **v2.1.183 デストラクティブ git コマンド自動ブロック**: 「安全性・権限設計」セクションに、Claude Code が意図しない git reset --hard 等を自動ブロックする仕様を追記提案。自動化 Routine 設計の安全性原則として重要。
8. **`attribution.sessionUrl` 設定**: Web/Remote Control セッションのコミット帰属設定（v2.1.183 新機能）。プライバシー設定として追記を検討。

#### 新規発見ソース候補
なし（本日は新規ソース未発見）

#### 次回リサーチ推奨日

2026-06-22（通常スケジュール）
注目点:
① Fable 5 / Mythos 5 復旧状況（「近日中」発言から 4 日目。週内復旧も視野）
② v2.1.183 のデストラクティブ git コマンドブロック機能が Routine（auto-research-collect 等）に与える影響の実観測
③ `attribution.sessionUrl` 設定の Routine コミット帰属への実効果確認
④ Agent SDK クレジット消費量の週次観測（6/15 施行後 7 日目）

---

## [2026-06-18] デイリーレポート

### 内部知見（機能A）
#### 新規・更新 ADR
- My-Profile-and-Memory/decisions/ → フォルダ未存在のためスキップ
- StudyMate, My-URAWA-LOG, tak-work, tak-family, tak-personal → アクセス可能リポジトリ外のためスキップ
- tak-best-practices/ → TBP-001, TBP-002, index.md を確認（新規 ADR なし）

#### TBP 昇格候補
なし（新規 ADR なし）

#### 再検討トリガー該当
- **TBP-001（外部ツール導入審査）継続**: 6/15〜17 提案の「課金体系変更」「地政学的リスク」評価項目追記が未確認のまま継続。
- **TBP-001 新規照合**: Anthropic がソウルオフィス開設（6/17）し、NAVER・Samsung SDS・LG CNS・Nexon 等が Claude Code を全社採用と発表。外部 AI ツールの「主要エコシステムとの統合状況・ベンダー継続性」を TBP-001 の審査基準に加える価値があるか検討を提案。
- **TBP-002（実行環境英語パス）**: 新規トリガーなし。

---

### 外部リサーチ（機能B）
#### 参照した情報源
- Claude Code 公式チェンジログ: https://code.claude.com/docs/en/changelog
- Anthropic Newsroom: https://www.anthropic.com/news
- releasebot.io/updates/anthropic/claude-code
- isfableback.org / digitaltoday.co.kr / koreajoongangdaily.com（Fable 5 復旧状況）
- WebSearch（Claude Code v2.1.181, Anthropic Seoul, 会計×AI, Zenn/Qiita, GitHub Issues）

#### 🔴 即座に適用すべき事項

**① Claude Code v2.1.181（6/17 リリース — 前回レポート後に公開）**
- **`/config key=value` 構文追加**: プロンプトから任意の設定を変更可能（例: `/config thinking=false`）。インタラクティブモード・`-p`・Remote Control で動作。
- **API 接続中断時の自動リトライ改善**: "Connection closed while thinking" の代わりに自動リトライ。long-running Routine（deep-research-runner 等）での接続安定性向上が期待できる。
- **ネットワークドライブへのファイル書き込み修正**: クラウド同期フォルダでの 0 バイト・切り詰めファイル生成問題を解消。
- **プロンプトキャッシング修正**: カスタム `ANTHROPIC_BASE_URL` および Foundry 環境でキャッシュが読み込まれなかった問題を修正（Research Hub の Routine に直接影響しないが、他プロジェクト展開時に重要）。
- その他: `sandbox.allowAppleEvents` オプトイン設定（macOS）・Bun ランタイム 1.4 アップグレード・長段落ストリーミング改善（行ごとに逐次表示）・サブエージェントパネル改善（アイドル 30 秒後に自動非表示、最大 5 行表示）。

**② Anthropic ソウルオフィス開設（6/17）と韓国 AI エコシステムパートナーシップ**
- ソウルオフィス開設（アジア太平洋 3 拠点目: Tokyo・Bengaluru に続く）。代表取締役: KiYoung Choi（元 Snowflake Korea GM）。
- Claude Code 採用企業: NAVER（全エンジニア組織）・Samsung SDS（Samsung Electronics 全社）・LG CNS（LG グループ全体）・Nexon（ライブサービスゲーム開発）・Channel Corp（230,000+ ビジネスへのプラットフォーム）。
- 韓国科学技術情報通信部（MSIT）と AI セーフティ・サイバーセキュリティの MOU 締結。Korean AI Safety Institute と韓国語モデル安全評価を共同実施。
- **Research Hub への直接影響**: なし。ただし Claude Code エコシステムの拡大により、アジア圏サポート・日本語品質の改善が将来的に加速する可能性あり。
- 参考: https://www.anthropic.com/news/seoul-office-partnerships-korean-ai-ecosystem

#### 🟡 近いうちに試したいこと（上位3件）

**① `/config key=value` 構文の Routine 活用検討（v2.1.181）**
- スケジュールタスク内でセッション中に設定を動的に変更可能。例: deep-research-runner で `/config thinking=false` を特定フェーズで使い、コスト最適化を試す。
- `CLAUDE_CLIENT_PRESENCE_FILE` 環境変数も同バージョンで追加。PC 作業中にモバイルプッシュ通知を抑制できる（Routine 環境変数設計に有用かどうか要確認）。
- ハーネス設計（CLAUDE.md・settings.json）との役割分担を整理する機会。

**② Fable 5 / Mythos 5 復旧見通し（「近日中」発言）**
- Anthropic エグゼクティブが「近日中（coming days）に復旧自信」と発言（Korea JoongAng Daily 6/18 報道）。
- ソウルオフィス開設と同タイミングでの発言で、韓国側で輸出規制緩和の兆しありとの見方も。
- 復旧後は auto モードで Fable 5 が選択される可能性がある。Agent SDK クレジット消費量への影響を監視推奨。
- 参考: https://isfableback.org/ で即時確認可能。

**③ Claude Code GitHub Stars 131K 突破**
- anthropics/claude-code リポジトリが 131,000 スターに到達（Augment Code 分析）。
- 「IDE をスキップして直接ターミナルエージェントを使う開発者」が増加している指標。
- Tak 自身の Claude Code 活用状況との照合で、チーム展開の参考情報として記録。

#### 🟢 参考情報

**Zenn / Qiita 日本語コミュニティ（6/18 時点）**
- 「コードを書けない私が、AI に『チーム』を持たせるまで」（26 年 SE が 9 AI エージェント編成チームを Claude Code で構築）が引き続き話題。
- Zenn は Anthropic との戦略提携により Claude Code をインフラ開発に統合済み（4 月以降）。
- Qiita に「Claude Code で Zenn 執筆環境を育てた記録」記事が掲載。

**会計×AI トレンド（6/18 時点）**
- 新規重大発表なし。継続トレンド:
  - 経費精算工数 75% 削減が「業界標準化フェーズ」に
  - 2026 年版 freee vs マネーフォワード AI 仕訳精度比較記事が複数メディアで掲載
  - 個人事業主向け確定申告自動化解説記事が増加傾向
  - 財務 AI のポジション: 「効率化ツール」→「財務戦略変革」フェーズ移行継続

**GitHub Issues 新着（6/18）**
- Issue #69459: macOS バグ（再現手順待ち）
- Issue #69457/#69458: macOS デスクトップ UI の Enhancement リクエスト
- いずれも Research Hub の Routine 動作への直接影響なし。

#### references.md 更新提案

継続未確認項目（6/15〜17 提案から継続）:
1. **v2.1.178 `Tool(param:value)` 権限構文**: 公式 best-practices ページへの追記確認（URL: https://code.claude.com/docs/en/best-practices）
2. **Claude Fable 5 モデル ID**: 「現在停止中（6/12〜）、近日復旧見込み」注記とともに追記提案
3. **最終確認日更新**: `*最終確認: 2026-03-29*` → `2026-06-18` への更新
4. **Claude Code GitHub Actions セキュリティ脆弱性 v1.0.94**: CI/CD 利用者向けセキュリティ注意事項（6/17 提案から継続）

**新規追加提案（6/18）**:
5. **`/config key=value` 構文**: v2.1.181 新機能。プロンプトからセッション設定を動的変更できるコマンドとして追記。
6. **`CLAUDE_CLIENT_PRESENCE_FILE` 環境変数**: PC 作業中のモバイル通知抑制（Routine 環境変数設計の参考として追記を検討）。

#### 新規発見ソース候補

- **digitaltoday.co.kr/en**: 英語版 Digital Today Korea。Anthropic 韓国展開・輸出規制の一次速報が詳細（評価候補: ⭐⭐⭐）
- **koreajoongangdaily.com**: Anthropic エグゼクティブの「復旧近日中」発言の一次ソース（評価候補: ⭐⭐⭐）

#### 次回リサーチ推奨日

2026-06-22（通常スケジュール）
注目点:
① Fable 5 / Mythos 5 復旧状況（エグゼクティブが「近日中」と発言 → 週内復旧も視野）
② Claude Code v2.1.181 の Routine 実行環境への実効果確認（API 自動リトライ、long-running タスク安定性）
③ Microsoft 社内 Claude Code ライセンス取り消し完了（6/30 期限直前）の続報
④ Agent SDK クレジット消費量の週次観測（6/15 施行後 1 週間）

---

## [2026-06-17] デイリーレポート

### 内部知見（機能A）
#### 新規・更新 ADR
- My-Profile-and-Memory/decisions/ → フォルダ未存在のためスキップ
- tak-best-practices/ → フォルダ未存在のためスキップ
- StudyMate, My-URAWA-LOG, tak-work, tak-family, tak-personal → アクセス可能リポジトリ外のためスキップ

#### TBP 昇格候補
なし（TBP・ADR ファイル未存在）

#### 再検討トリガー該当
なし（TBP・ADR ファイル未存在のため照合不可）

---

### 外部リサーチ（機能B）
#### 参照した情報源
- Claude Code 公式チェンジログ: https://code.claude.com/docs/en/changelog
- Anthropic Newsroom: https://www.anthropic.com/news
- WebSearch（Claude Code セキュリティ, GitHub Actions 脆弱性, Microsoft 課金, 会計×AI）
- Zenn / Qiita（claude-code タグ）
- cybersecuritynews.com / thehackernews.com / flatt.tech（GMO Flatt Security）

#### 🔴 即座に適用すべき事項

**① Claude Code GitHub Actions 重大脆弱性（CVSS v4.0: 7.8）— 修正済み v1.0.94**
- 発見者: RyotaK（GMO Flatt Security）。Anthropic のバグバウンティ $4,800 授与済み。
- 脆弱性概要: `checkWritePermissions` 関数が `[bot]` で終わる actor を**無条件で信頼**する欠陥。
  外部の無認証攻撃者が GitHub Issue に prompt injection を仕込むだけで、
  ① CI/CD secrets の窃取、② OIDC トークン取得、③ 悪意あるコードの push が可能。
- **サプライチェーン攻撃リスク**: `anthropics/claude-code-action` リポジトリ自体が脆弱だったため、
  そのアクションを依存している**すべての downstream リポジトリ**への伝播リスクが存在した。
- 修正: Claude Code GitHub Actions **v1.0.94 で patch 済み**。
- **Research Hub への影響**: research-hub リポジトリが Claude Code GitHub Actions を使用していれば
  v1.0.94 以上に更新要。使用していない場合は直接影響なし。要確認。
- Microsoft Security Blog（6/5）でも "CI/CD in an agentic world" として注意喚起済み。
- 参考: https://flatt.tech/research/posts/poisoning-claude-code-one-github-issue-to-break-the-supply-chain/
- 参考: https://thehackernews.com/2026/06/claude-code-github-action-flaw-let-one.html

**② Fable 5 / Mythos 5 停止継続（6/12〜、本日 6/17 も未回復）**
- 昨日（6/16）レポートの継続情報。復旧状況は isfableback.org で追跡可。

#### 🟡 近いうちに試したいこと（上位3件）

**① Microsoft が社内 Claude Code ライセンスを取り消し（6/30 期限）**
- 対象: Microsoft Experiences + Devices 部門（Windows / Microsoft 365 / Teams / Surface 担当）の数千人エンジニア。
- 移行先: GitHub Copilot CLI（6/30 FY末期限で移行完了指示）。
- 背景: 「自社製品（Copilot）を推しながら社内で競合（Claude Code）を使い続けるのは戦略的矛盾」。
  過去 6ヶ月で社内利用が爆発的に増加 → 財務的・ブランド的理由で整理。
- 注記: Claude モデルは Copilot CLI 経由で引き続き利用可能。Azure AI Foundry 上の Claude API は継続。
  MicrosoftはAnthropicに最大 $5B 投資しており、顧客向け Azure 経由の Claude 提供は継続。
- 参考: https://www.windowscentral.com/microsoft/microsoft-cancels-claude-code-licenses-shifting-developers-to-github-copilot-cli-a-move-likely-driven-by-financial-motives

**② Uber の AI ツール予算超過問題**
- Uber が 2026 年の AI ツール予算を Claude Code + Cursor に 4ヶ月で使い切る事態が発生。
- Opus 4.8 リリースと同タイミングで予算危機が顕在化。
- 教訓: 組織規模での Claude Code 展開は予算上限設計が必須。
  Research Hub の Routines も月次クレジット消費量モニタリングを継続推奨。

**③ Claude Code v2.1.179 修正確認（6/16 リリース、昨日報告から継続）**
- mid-stream 接続ドロップ時の部分応答保持（long-running Routines への効果を観測推奨）。
- WSL2 マウスホイールスクロール修正・Linux sandbox glob 処理修正。

#### 🟢 参考情報

**Zenn / Qiita 日本語コミュニティ動向**
- 「2026年6月現在の Claude Code 開発フロー」記事（Zenn）が話題。Official Plugins・skills 優先使用と plan-code drift 防止の自動化が強調される。
- Claude Code 課金変更（6/15）解説記事が Zenn・Qiita で多数投稿。日本語コミュニティの反応が活発。
- 非エンジニアによる「AI チーム（9エージェント編集部）」構築体験記が公開（Claude Code × Zenn 執筆）。

**会計×AI トレンド（6/17 時点）**
- PEPPOL 普及により請求書フォーマット標準化が急速進行。PDF・XML・EDI のいずれでも AI-OCR 取込み可能に。
- 経費精算自動化の 75% 削減事例が標準化フェーズへ（特定企業の事例でなく業界標準になりつつある）。
- baクラク経費精算: freee / マネーフォワード / 奉行クラウドとの仕訳 API 連携を強化（6月）。
- 財務 AI は「効率化」から「財務戦略変革」へのポジション転換が加速中。

**市場動向メモ**
- Anthropic IPO（S-1 機密提出 6/1）・Project Glasswing 拡大（6/2）・Claude Partner Network（6/3）は 6/15・6/16 レポートから継続。新情報なし。

#### references.md 更新提案

継続未確認項目（6/15〜6/16 提案から継続）:
1. **v2.1.178 `Tool(param:value)` 権限構文**: 公式 best-practices への追記確認（URL: https://code.claude.com/docs/en/best-practices）
2. **Claude Fable 5 モデル ID**: 「現在停止中（6/12〜）」注記とともに追記提案。
3. **最終確認日更新**: `*最終確認: 2026-03-29*` → `2026-06-17` への更新。

**新規追加提案**:
4. **Claude Code GitHub Actions セキュリティ脆弱性**: references.md のセキュリティ注意事項セクションに v1.0.94 へのアップデート必須を追記提案（CI/CD 利用者向け）。

#### 新規発見ソース候補

- **flatt.tech/research**: GMO Flatt Security のセキュリティリサーチブログ。Claude Code の重大脆弱性を発見・開示。AIエージェント×セキュリティの一次情報源として有用（評価候補: ⭐⭐⭐⭐）
- **esecurityplanet.com**: AI セキュリティ専門メディア。今回の GitHub Actions 脆弱性レポートが詳細（評価候補: ⭐⭐⭐）

#### 次回リサーチ推奨日

2026-06-22（通常スケジュール）
注目点:
① Fable 5 / Mythos 5 復旧状況（6/22 無料期間終了日でもある）
② Microsoft 社内 Claude Code ライセンス取り消し完了（6/30期限直前）の続報
③ Agent SDK クレジット消費量の初回観測（6/15 施行後 1 週間）
④ Claude Code GitHub Actions 脆弱性の research-hub への影響確認

---

## [2026-06-16] デイリーレポート

### 内部知見（機能A）
#### 新規・更新 ADR
- My-Profile-and-Memory/decisions/ → フォルダ未存在のためスキップ
- StudyMate, My-URAWA-LOG, tak-work, tak-family, tak-personal → アクセス可能リポジトリ外のためスキップ

#### TBP 昇格候補
なし（新規 ADR なし）

#### 再検討トリガー該当
- **TBP-001（外部ツール導入審査）追記候補①**: Claude Fable 5 & Mythos 5 が米政府輸出規制指令により即時停止（6/12）。外部 AI サービスは「地政学的リスク・輸出規制による突然のサービス停止」リスクを持つことが具体的に示された。TBP-001 の審査基準に「地政学的リスク・外部規制リスク」評価項目を追加する提案。
- **TBP-001 追記候補②（継続）**: 昨日（6/15）提案の「課金体系への影響（Agent SDK 課金分離）」評価項目追記も未確認のまま継続。

---

### 外部リサーチ（機能B）
#### 参照した情報源
- Claude Code 公式チェンジログ: https://code.claude.com/docs/en/changelog
- Anthropic Newsroom: https://www.anthropic.com/news
- WebSearch（Fable 5 停止続報, Claude Code /goal, Code with Claude Tokyo, 会計×AI）
- Zenn / Qiita（ClaudeCode タグ）

#### 🔴 即座に適用すべき事項

**① Fable 5 & Mythos 5 アクセス継続停止（6/12 指令 → 本日 6/16 未回復）**
- 米政府（国家安全保障当局）が輸出規制指令を発令。外国人（米国内・外を問わず、Anthropic 社員含む）のアクセスを即時停止。
- 停止理由: Fable 5 のセーフティ分類器を bypass する「ジェイルブレイク」手法の発見。
- 現状（6/16）: Fable 5 / Mythos 5 は全ユーザー向けに停止継続。復旧時期は未定。Anthropic は政府の判断に公式異議を表明し、復旧交渉中。
- **Research Hub / Routines への影響**: auto モードで `claude-fable-5` が選ばれる可能性があった期間（6/9〜6/12）の動作ログを確認推奨。現時点では Opus 4.8 / Sonnet 4.6 が使用されているはず。
- 昨日レポート（6/15）の「6/9〜6/22 Fable 5 無料期間」の情報は 6/12 時点で実質無効化済み。追記・訂正として記録。
- 参考: https://www.anthropic.com/news/fable-mythos-access

#### 🟡 近いうちに試したいこと（上位3件）

**① Claude Code v2.1.179（本日 6/16 リリース）の改善確認**
- Mid-stream 接続ドロップ時に部分的な応答を保持（deep-research-runner 等の長時間タスクで有効）。
- WSL2 マウスホイールスクロール修正、Linux サンドボックス glob 処理の改善（Routine 実行環境に影響する可能性）。
- リモートセッションのバックグラウンドタスク表示改善。

**② Claude Code `/goal` コマンド（v2.1.139以降）**
- 完了条件を1行宣言するだけで、Claude が条件達成まで自律的にターンをまたいで作業し続けるコマンド。
- 使い方: `/goal <達成条件を1文で>` → 例: `/goal 全テストが pass する状態にする`
- `/goal`（引数なし）で現在の進捗（ターン数・消費トークン）を確認可能。
- deep-research-runner 等の長時間タスクや、Tak の手動調査タスクへの活用を検討。
- 参考: https://code.claude.com/docs/en/goal

**③ Code with Claude Tokyo で発表された Claude Finance（6/11）**
- 10のプリビルトエージェントを含む財務・経理向け AI パッケージ。会計×AI の実装加速につながる可能性。
- Dreaming・Outcomes・multi-agent orchestration・Add-ins も同イベントで発表。
- NEC（30,000名）・日立が Anthropic と戦略提携を発表。国内 AI 需要拡大のシグナル。
- 参考: https://claude.com/code-with-claude/tokyo-extended

#### 🟢 参考情報

**Anthropic の主要動向（6月上中旬まとめ）**
- **IPO 準備継続**: 6/1 に SEC へ S-1 機密提出。評価額 ~$965B、年収換算 $47B（上場時期は市場環境次第）。
- **Project Glasswing 拡大（6/2）**: 15カ国以上・150団体追加。電力・水道・医療・通信・ハードウェア分野対象。
- **Claude Partner Network 発足（6/3）**: Services Track と Partner Hub 開始、TCS（50,000名）が参画。
- **インド進出（6月中旬）**: バンガロールにオフィス開設予定。

**会計×AI トレンド**
- 経費精算・請求書処理・仕訳自動化での工数削減事例（最大 75% 削減）が標準化フェーズに移行。
- 財務 AI は「効率化ツール」から「財務戦略変革」ツールへ位置付けが変化。
- 国内中堅企業の仕訳入力は約 7 割が依然手入力（月末残業平均 32時間）で、生成 AI 導入余地が大きい。
- freee 統合ワールド 2026（本日 6/16 開催）: AI 新発表があれば次回レポートでフォローアップ推奨。

#### references.md 更新提案

昨日（6/15）提案のものが継続未確認：
1. **v2.1.178 `Tool(param:value)` 権限構文**: 権限設計セクションへの追記確認（URL: https://code.claude.com/docs/en/best-practices）
2. **Claude Fable 5 モデル ID**: 「現在停止中（6/12〜、復旧未定）」の注記とともに追記を提案。
3. **最終確認日更新**: `*最終確認: 2026-03-29*` → `2026-06-16` への更新。

#### 新規発見ソース候補

- **isfableback.org**: Fable 5 / Mythos 5 の復旧状況リアルタイム確認サイト（評価候補: ⭐⭐⭐）
- **mindstudio.ai/blog**: Claude Code /goal・Code with Claude 新機能解説が有用（評価候補: ⭐⭐⭐）

#### 次回リサーチ推奨日

2026-06-17（Fable 5 動向急変の可能性）または 2026-06-22（通常スケジュール）
注目点:
① Fable 5 / Mythos 5 復旧状況（isfableback.org で追跡可能）
② freee 統合ワールド 2026（本日 6/16）の AI 新発表フォローアップ
③ Agent SDK クレジット消費量の初回観測（6/15 施行後 2 日目）
④ Claude Finance の詳細発表・API 公開スケジュール

---

## [2026-06-15] デイリーレポート

### 内部知見（機能A）
#### 新規・更新 ADR
- My-Profile-and-Memory/decisions/ → フォルダ未存在のためスキップ
- StudyMate, My-URAWA-LOG, tak-work, tak-family, tak-personal → アクセス可能リポジトリ外のためスキップ

#### TBP 昇格候補
なし（新規 ADR なし）

#### 再検討トリガー該当
- **TBP-001（外部ツール導入審査）**: 本日2026-06-15から Claude Agent SDK / claude -p / GitHub Actions の使用が別課金プールに変更。外部エージェントツール導入時の審査基準に「課金体系への影響」評価項目を加える価値があるか検討を提案。TBP-001の「適用場面」に課金コスト試算を追記することを次回確認推奨。

---

### 外部リサーチ（機能B）
#### 参照した情報源
- Claude Code 公式チェンジログ: https://code.claude.com/docs/en/changelog
- Anthropic Newsroom: https://www.anthropic.com/news
- Zenn（claude-code タグ）
- WebSearch（会計×AI, Claude Fable 5, Anthropic IPO, Claude Code 課金変更）

#### 🔴 即座に適用すべき事項

**① Claude Code Agent SDK 課金体系変更（本日 6/15 施行）**
- Agent SDK / `claude -p`（ヘッドレス）/ Claude Code GitHub Actions / サードパーティアプリの使用が、サブスクリプションの通常プールと分離。
- 新しい「Agent SDK クレジット」から消費: Pro $20/月、Max 5x $100/月、Max 20x $200/月（標準 API レート）。
- **Research Hub への影響**: Anthropic Routines で動くスケジュールタスク（daily-research, auto-research-collect 等）が対象。クレジット枯渇時はタスクが止まるため、月次の消費量モニタリングを推奨。
- インタラクティブな Claude.ai チャット・Claude Code ターミナル利用は影響なし。
- 参考: https://codersera.com/blog/anthropic-june-2026-billing-change-claude-code/

**② Claude Fable 5 リリース（6/9）**
- 「Mythos 級」という新ティアが一般公開。Opus 4.8 より一部ベンチマークで 10%超の性能向上。
- ソフトウェアエンジニアリング・知識作業・ビジョン・科学研究で特に突出。タスクが長く複雑になるほど差が広がる傾向。
- 安全性: サイバーセキュリティ・生物・化学・蒸留系トピックでセーフティ分類器が発動（5%未満のセッションで Opus 4.8 にフォールバック）。
- **Pro/Max/Team/Enterprise 向け 2週間無料期間**: 6/9〜6/22 は追加料金なしで利用可能。自動モードで起動される可能性あり。
- model ID: `claude-fable-5`
- 参考: https://www.anthropic.com/news/claude-fable-5-mythos-5

#### 🟡 近いうちに試したいこと（上位3件）

**① v2.1.178 `Tool(param:value)` 権限構文（6/15 本日）**
- 権限ルールにツール入力パラメータを指定してマッチングできる新構文。
- 例: `Agent(model:opus)` で Opus サブエージェントをブロック、`Bash(command:rm*)` で特定コマンドを弾く。
- ハーネス設計の permissions 設定でより精密な制御が可能に。settings.json の allowlists 見直し機会。
- 同バージョンでネスト `.claude/` ディレクトリのスキル対応も追加（プロジェクトスキルの構成自由度向上）。

**② Sub-agents が Sub-agents をスポーン（最大5階層, v2.1.172, 6/10）**
- エージェントが独自のサブエージェントを起動可能に。文脈管理が目的（Boris Cherny 発言）。
- 実用的な深さは 2〜3 階層。5 階層はスタック上限（目標値ではない）。
- 1 階層あたり 200K トークン（約 7× のトークン膨張に注意）。
- Research Hub の deep-research-runner アーキテクチャで活用検討価値あり。

**③ `post-session` ライフサイクルフック（v2.1.169, 6/8）**
- セルフホステッドランナー向けにセッション終了後フックが追加。
- `--safe-mode` フラグ（カスタマイズ無効化でトラブルシューティング）、`/cd` コマンド（セッション中にワーキングディレクトリ変更）も同時追加。

#### 🟢 参考情報

**Anthropic IPO S-1 提出（6/1）**
- 米 SEC に Form S-1 を機密提出。売出株数・価格は未定、市場環境次第で公開へ。
- 参考指標: 評価額 ~$965B、年収換算 $47B。OpenAI・SpaceX と同時期に IPO 準備。
- 参考: https://www.anthropic.com/news/confidential-draft-s1-sec

**Project Glasswing 拡大（6/2）**
- 15カ国以上・150団体追加。電力・水道・医療・通信・ハードウェア分野が対象。Claude Mythos 5（制限解除版）は引き続き承認パートナー限定。

**Anthropic Claude Partner Network 発足（6/3）**
- Services Track と Partner Hub を開始。TCS が参画しクロード規制産業展開へ。

**freee 統合ワールド 2026（明日 6/16 開催）**
- 経営×バックオフィス×AI をテーマとしたイベント。freee のシャドーAI 対策が 15,000+ の AI ツール検知に対応更新済み。

**会計×AI 動向**
- 経費精算: 入力・確認工数 75% 削減、月次締切 2 日前倒し事例が増加。
- 国内中堅企業の仕訳入力: 約 7 割が依然として手入力（月末残業平均 32 時間）。生成 AI 導入のポテンシャルが高い。
- 財務 AI は「効率化ツール」から「財務戦略変革」フェーズへ移行しつつある。

#### references.md 更新提案

以下 2 点の更新を提案（実施は Tak 確認後）:
1. **v2.1.178 `Tool(param:value)` 権限構文**: 公式 best-practices ページに追記された可能性大。権限設計セクションへの追記を確認推奨。URL: https://code.claude.com/docs/en/best-practices
2. **Claude Fable 5 モデル ID 追記**: `claude-fable-5` が新最高ランクモデルとして API 利用可能に。references.md の「関連モデル」や claude-api スキルへの情報追加を検討。
3. **最終確認日更新**: references.md の `*最終確認: 2026-03-29*` は 2026-06-15 へ更新が望ましい。

#### 新規発見ソース候補

- **releasebot.io/updates/anthropic/claude-code**: Claude Code 更新の自動追跡サイト。変更ログ確認が容易（評価候補: ⭐⭐⭐）
- **findskill.ai**: Claude Code 課金体系の解説が詳細で有用（評価候補: ⭐⭐⭐）

#### 次回リサーチ推奨日

2026-06-22（1週間後）
注目点:
① Fable 5 無料期間終了（6/22）後の auto モード動作確認・課金影響測定
② Agent SDK クレジット消費量の初回観測（6/15 施行後）
③ freee 統合ワールド 2026（6/16）の AI 新発表フォローアップ
④ v2.1.178 `Tool(param:value)` 構文のハーネス適用実験

---
