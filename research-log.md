## [2026-07-19] デイリーレポート

### 内部知見（機能A）
#### 新規・更新 ADR
- My-Profile-and-Memory/decisions/ → フォルダ未存在のためスキップ
- StudyMate, My-URAWA-LOG, tak-work, tak-family, tak-personal → アクセス可能スコープ外のためスキップ
- tak-best-practices/: TBP-001（外部ツール導入審査）・TBP-002（実行環境英語パス）を確認（新規 ADR なし）

#### TBP 昇格候補
- **TBP-003候補**（2026-06-22 提案・確認待ち27日目）:「着手前に実態（git）と文書（backlog）の一致を確認する」— Takの確認待ち継続。
- **TBP-004候補**（2026-06-22 提案・確認待ち27日目）:「不可逆性で安全方向を決めるが、カテゴリ丸ごとの保守化は目的を殺す」— Takの確認待ち継続。

#### 再検討トリガー該当
- **TBP-001 再評価トリガー（v2.1.215 hooks exit code 2 ブロック不具合修正）**: hooks が exit code 2 を返してもブロックしない（ドキュメント記載通りに動作しない）バグが v2.1.215 で修正。TBP-001 の「最小権限で開始」設計において、hook によるブロックフローが想定通りに機能していなかった。Research Hub の Routines で exit code 2 を使う hook を設定している場合は v2.1.215 適用後の動作確認を推奨。

---

### 外部リサーチ（機能B）
#### 参照した情報源
- Claude Code 公式チェンジログ（⭐⭐⭐⭐⭐）: v2.1.215（7/19）詳細確認
- Anthropic 公式ブログ（⭐⭐⭐⭐⭐）: UST Partnership / Reflect with Claude 確認
- anthropics/claude-code GitHub issues（⭐⭐⭐⭐⭐）: 7/19 新規 issues（#79185〜#79192）確認
- Zenn / Qiita: 2026-07-19 Claude Code 記事トレンド確認
- 会計×AI: マネーフォワード AI Cowork / freee MCP / バクラク 2026年7月最新状況

#### 🔴 即座に適用すべき事項

**1. 🔴 前日レポート（7/18）訂正: Fable 5 Max/Team Premium プランへの影響**
- 7/18 レポートで「以降はクレジット制（$10/M input / $50/M output）へ完全移行」と記載したが、**Max/Team Premium プランの取り扱いに誤りがあった。正確な情報は以下の通り：**
  - **Max/Team Premium**: Fable 5 は引き続きサブスクリプション内で利用可能（週次利用枠の50%レート制限あり）。クレジット制には移行しない。
  - **Pro/Team Standard**: PT 2026-07-19 23:59:59（JST 2026-07-20 15:59:59）以降、一回限りの $100 クレジット付与後、従量課金（$10/M input tokens, $50/M output tokens）に移行。
- Tak が Max/Team Premium プランに加入している場合、Fable 5 をサブスクリプション内で引き続き使用可能（50%レート制限あり）。Pro プランの場合は本日深夜 PT が移行タイミング。

**2. Claude Code v2.1.215（2026-07-19 リリース）— バグ修正中心**
- **--settings 経由プラグインが読み込まれないバグ修正**: `--settings` フラグで指定した設定ファイル経由のプラグインが正常に読み込まれなかった問題を修正。設定ファイルを複数管理している場合は確認推奨。
- **OAuth トークンローテーション後にフィーチャーフラグが古い状態で固定されるバグ修正**: OAuth トークン更新後もフィーチャーフラグが更新前の状態を保持し続ける問題を修正。長期セッションの Routines での信頼性向上。
- **/ultrareview がマージベースのないリポジトリで拒否するバグ修正**: 初回コミット直後等 git history がないリポジトリでも /ultrareview が使用可能に。
- **claude update / claude doctor が無言でハングするバグ修正**: アップデート・診断コマンドが応答なく停止するバグを修正。メンテナンス作業の信頼性向上。
- **メモリファイルのフロントマター値がインライン # で無言切り捨てされるバグ修正**: `.claude/memory/` ファイルで `# コメント` 以降がフロントマター値として切り捨てられていた問題を修正。My-Profile-and-Memory のメモリファイル管理に直接関連。
- **セッションコスト/トークンテレメトリの二重カウントバグ修正**: コスト・トークン消費量が実際より多く報告されていた問題を修正。Research Hub の Routine コスト管理の精度向上。
- **誤った「ネットワークを確認してください」警告バグ修正**: 実際には問題がないのに「check your network」警告が表示されていた問題を修正。誤警告によるノイズが解消。
- **hooks が exit code 2 を返してもブロックしないバグ修正（🔴 TBP-001 直結）**: exit code 2 で hook がブロックするという公式ドキュメント記載の仕様が機能していなかった。TBP-001 の allowlist/hook 設計に直結するバグ。v2.1.215 以降は期待通りに動作する。

**3. GitHub Issues 新着（2026-07-19）— データロスバグ 2件**
- **Issue #79190（area:core, data-loss, bug）**: コア機能でデータロスを引き起こすバグ。詳細確認中。Research Hub Routine でのデータ消失リスクとして監視対象。
- **Issue #79185（area:desktop, data-loss, macOS）**: デスクトップアプリでのデータロス（macOS 限定）。
- **Issue #79191（area:security, macOS）**: macOS 環境のセキュリティ関連バグ。詳細確認中。
- **Issue #79192（area:chrome, area:cowork, area:desktop, macOS）**: chrome/cowork/desktop が絡む macOS バグ。
- **Issue #79188（area:model, duplicate）**: モデル挙動のバグ（既知問題の重複報告）。
- **Issue #79186（area:TUI, enhancement）**: TUI の機能要望。
- **Issue #79187（invalid）**: 無効として閉じられた issue。
- Research Hub Routines への直接影響: #79190（core data-loss）が最も関連度高い。次回リリースでの修正内容を監視推奨。

#### 🟡 近いうちに試したいこと（上位3件）

**1. UST Partnership（Anthropic、2026-07-19 発表）— 世界 20,000人以上のエンジニアへ AI 研修**
- Anthropic と UST（グローバル IT サービス企業）がパートナーシップ契約。UST の世界 20,000 人以上のエンジニア向けに Anthropic AI 技術・Claude Code 研修を提供。
- 大規模組織での Claude Code 展開・教育設計のケーススタディとして参考価値あり。
- 🟡 アクション: Research Hub に記事化候補として記録。Tak の会社・業界でのエンジニア AI 研修設計の参考情報として活用。

**2. Reflect with Claude（Beta）— 使用状況ダッシュボード + 4D AI Fluency Framework**
- Anthropic が「Reflect with Claude」ベータ版を公開。Claude の使用状況（会話数・ツール使用・時間帯分布等）を可視化するダッシュボード。
- 「4D AI Fluency Framework」（Discover / Develop / Deploy / Differentiate）も同時公開。AI 活用成熟度を段階的に評価・改善するフレームワーク。
- 🟡 アクション: Tak 自身の Claude Code 使用状況を把握するためにダッシュボードを確認。Research Hub の Routines の効果測定・コスト管理にも活用できるか検討。

**3. マネーフォワード AI Cowork 正式リリース監視継続**
- 7/19 現在も「2026年7月より提供開始予定」のまま。7月末まで残り約12日。正式アナウンス未確認継続。
- 4月発表から3ヶ月以上経過。遅延の可能性も視野に入れ始める段階。
- 🟡 アクション: corp.moneyforward.com/news で正式リリース確認継続。7月末に未リリースなら8月以降での記事化タイミングを再検討。

#### 🟢 参考情報

**Anthropic 動向（2026年7月）**
- **UST Partnership（2026-07-19）**: 世界 20,000人以上のエンジニアへの AI 研修。Claude Code 大規模普及施策の一環。
- **Reflect with Claude（Beta）**: 使用状況ダッシュボード・4D AI Fluency Framework 公開。AI活用可視化と改善サイクル支援ツール。
- **Alberta Partnership・Ode with Anthropic（既報継続）**: カナダ・アルバータ州政府との AI パートナーシップ・$1.5B エンタープライズ AI 実装会社が継続展開中。

**Zenn / Qiita 動向（2026-07-19）**
- Qiita トレンド「Claude Code で技術面接の壁打ち相手を作ってみませんか」が上位にランクイン。Claude Code × インタビュー準備という新しい活用法として注目。
- Zenn の claude-code タグ記事が引き続き増加傾向。日本語コミュニティでの知見蓄積が加速。

**会計×AI（2026-07-19 時点）**
- **マネーフォワード AI Cowork**: 依然「2026年7月より提供開始予定」（正式リリース未確認）。7月末まで残り約12日。
- **freee MCP**: 約330の MCP API が公開中（2026年6月22日 AI エージェント連携発表以来継続拡大）。Breeze との統合も進行中。
- **バクラク**: OCR 精度 99%+ 継続。経費精算・請求書処理の AI 化が実務水準で定着フェーズに。

#### references.md 更新提案

継続未確認項目（前回 7/18 から継続）:
1. **EndConversation ツール**（v2.1.214）: ジェイルブレイク対応ツールとして追記検討
2. **Bash 権限チェック厳格化**（v2.1.214）: 10,000文字超・zsh変数修飾子・help/man が許可確認対象になった旨を TBP-001 周辺に追記
3. **セッション制限環境変数**（v2.1.212）: `CLAUDE_CODE_MAX_WEB_SEARCHES_PER_SESSION`・`CLAUDE_CODE_MAX_SUBAGENTS_PER_SESSION`・`CLAUDE_CODE_MCP_AUTO_BACKGROUND_MS`
4. **npm インストール Deprecated**: ネイティブインストーラー推奨への変更

**新規追加提案（2026-07-19）**:
5. **hooks exit code 2 ブロック修正**（v2.1.215）: hook によるブロックフローが期待通りに機能することを確認。TBP-001 の allowlist/hook 設計セクションへの参照追記提案。
6. **Fable 5 Max/Pro プラン差分の正確な記述**（2026-07-19 確定）: Max/Team Premium はサブスクリプション内50%レート制限継続、Pro/Team Standard はワンタイム $100 クレジット→従量課金（$10/M input, $50/M output）。モデル関連セクションへの正確な記述追記提案。
※ 直接更新は行わない。Tak の確認後に実施。

#### 新規発見ソース候補
なし（本日新規有望ソース未発見）

#### 次回リサーチ推奨日
2026-07-20（翌日）。
注目点:
① **Fable 5 Pro/Team Standard クレジット制移行後の確認**: PT 23:59:59（JST 7/20 15:59:59）移行後の実際の動作・課金状況確認。
② **マネーフォワード AI Cowork 正式リリース**: 7月末まで残り約12日。毎日確認継続。
③ **Issue #79190（core data-loss）修正リリース確認**: データロスバグの修正パッチを監視。
④ **TBP-003・TBP-004 昇格候補**: 6/22 提案から27日経過。Takへの確認リマインド継続（28日目）。
⑤ **Reflect with Claude ダッシュボード確認**: 使用状況の可視化で Research Hub Routines のコスト・効果を把握。

---
## [2026-07-18] デイリーレポート

### 内部知見（機能A）
#### 新規・更新 ADR
- My-Profile-and-Memory/decisions/ → フォルダ未存在のためスキップ
- StudyMate, My-URAWA-LOG, tak-work, tak-family, tak-personal → decisions/ フォルダ未存在（アクセス可能リポジトリ内でも未作成）のためスキップ
- tak-best-practices/: TBP-001（外部ツール導入審査）・TBP-002（実行環境英語パス）を確認（新規 ADR なし）

#### TBP 昇格候補
- **TBP-003候補**（2026-06-22 提案・確認待ち26日目）:「着手前に実態（git）と文書（backlog）の一致を確認する」— Takの確認待ち継続。
- **TBP-004候補**（2026-06-22 提案・確認待ち26日目）:「不可逆性で安全方向を決めるが、カテゴリ丸ごとの保守化は目的を殺す」— Takの確認待ち継続。

#### 再検討トリガー該当
- **TBP-001 再評価トリガー（v2.1.214 権限チェック厳格化）**: Bash権限チェックの厳格化（ファイルディレクタリダイレクト、10,000文字以上コマンド、zsh変数修飾子に対し許可プロンプトが求められるようになった）。TBP-001「最小権限で開始」設計において、従来 auto-approve されていたコマンドパターンが突然停止するリスク。Routinesのプロンプトやallowlistの見直し推奨。
- **TBP-001 再評価トリガー（`help`・`man` コマンドのオートアプルーブ廃止）**: v2.1.214でhelpとmanコマンドが許可確認を要するようになった。Routineで help/man を使っている場合は停止する可能性。

---

### 外部リサーチ（機能B）
#### 参照した情報源
- Claude Code 公式チェンジログ（⭐⭐⭐⭐⭐）: v2.1.214（7/18）詳細確認
- Anthropic 公式ブログ（⭐⭐⭐⭐⭐）: 7/18 新着確認
- anthropics/claude-code GitHub issues（⭐⭐⭐⭐⭐）: 7/18 新規 issues（#78897〜#78901）確認
- Zenn / Qiita: 2026-07-18 Claude Code 記事トレンド確認
- 会計×AI: マネーフォワード AI Cowork 正式リリース確認、freee・バクラク 2026年7月最新状況

#### 🔴 即座に適用すべき事項

**1. Fable 5 Max プラン無料アクセス 明日（7/19）期限切れ — 最終確認**
- **7月19日 23:59 PT（7月20日 15:59 JST）に Fable 5 のサブスクリプション内無料アクセスが終了**。以降はクレジット制（$10/M input / $50/M output）へ完全移行。
- Anthropic は OpenAI の新モデル競争対応で2度延長したが、今回が最終期限。
- 🔴 アクション: 今日中に Tak の Claude プランと Research Hub Routines の auto モード設定を確認。Fable 5 を使用している Routine があれば Sonnet 5 または Opus 4.8 への切り替えを計画する。

**2. Claude Code v2.1.214（2026-07-18 本日リリース）— セキュリティ強化・Bash権限変更**
- **Bash 権限チェック厳格化（🔴 Routines 注意）**:
  - ファイルディレクタリリダイレクト操作に許可プロンプトが追加
  - 10,000文字以上の Bash コマンドに許可プロンプトが追加
  - zsh 変数修飾子の使用に許可プロンプトが追加
  - `help` と `man` コマンドのオートアプルーブが廃止
  - → auto モードの Routine でこれらのパターンが含まれると突然停止するリスク。allowlist の見直し推奨。
- **EndConversation ツール追加**: 虐待ユーザーやジェイルブレイク試行への対応ツール。Routine への直接影響は低いが、ジェイルブレイク耐性の強化という観点で注目。
- **long-running tool call の進捗ハートビート追加**: 長時間ツール呼び出し中の進捗確認が可能に。deep-research-runner など長時間実行する Routine の安定性向上に寄与。
- **Windows PowerShell 5.1 / 企業 Proxy 環境の修正多数**: Windows ユーザー向け修正（UTF-16LE書き込み問題、ストリーミング接続問題、pkill -f パターンマッチ問題）。
- **メモリファイルのフロントマターに ISO `modified` タイムスタンプ追加**: メモリファイルの更新日時追跡が自動化。My-Profile-and-Memory のメモリ管理が向上。
- **設定ファイルサイズ上限チェック（2 MiB）**: CLAUDE.md 等が 2 MiB を超えるとエラー。Research Hub の CLAUDE.md は現状問題なし（念のため確認推奨）。
- **GrowthBook フィーチャーフラグの null 値処理クラッシュ修正**: フィーチャーフラグが null の場合に起きていたクラッシュを修正。

**3. GitHub issues #78897〜#78901（7/18 新規）— セキュリティ・API 関連**
- #78897〜#78901 が本日新規オープン。security / api / model / platform:macos / platform:windows 関連。
- #78897 は security + duplicate タグ（既知問題の再報告）。#78898〜#78899 は api:anthropic + platform:windows のバグ。
- 🔴 直接適用: Windows Routine を運用している場合は API 接続安定性に注意。

#### 🟡 近いうちに試したいこと（上位3件）

**1. マネーフォワード AI Cowork 7月正式リリース — バックオフィスAIエージェント**
- 2026年4月発表、7月に正式リリース開始（先行受付は4月から）。
- 経理・労務・法務のバックオフィス業務を AI が自律的に処理。自然言語チャット（「今月の経理業務をまとめて」）で業務代行。
- マネーフォワード クラウドとのネイティブ連携。2030年までに AI 関連 ARR 150 億円超を目標。
- 🟡 アクション: biz.moneyforward.com/ai-cowork/ の詳細ページを確認し、Tak の会社（マネーフォワード クラウド導入済みなら）先行受付・トライアル状況を確認推奨。

**2. Claude Code × Codex モデル使い分けガイド（2026年7月版 / Zenn）**
- Zenn「Claude Code × Codex 最新モデルの特徴と使い分け（2026年7月版）」が公開。
- Claude 側: Fable 5（最上位）→ Opus 4.8 → Sonnet 5（主力）の世代交代を整理。
- Fable 5 の課金移行タイミング（7/19）に合わせたモデル切り替え判断の参考情報として価値あり。
- 🟡 アクション: Research Hub の Routines で使用モデルを Fable 5 → Sonnet 5 へ切り替える判断材料に。

**3. Qiita 週次アップデートまとめ（7/11週）— Artifacts・/review 体系刷新**
- Qiita「Claude Code 週次アップデートまとめ（2026/07/11週）」公開（著者: @saitoko）。
- ハイライト: Artifacts機能の Pro/Max 解放、/reviewコマンド体系の刷新（/review → /code-review + /simplify 分離）、/doctorのCLAUDE.md簡素化提案（3件）。
- /review 体系の刷新は Research Hub の CLAUDE.md でのレビューフロー記述に影響する可能性。
- 🟡 アクション: Qiita 記事を精読し、Research Hub のルーティンプロンプト内で使っているレビュー系コマンドがあれば更新検討。

#### 🟢 参考情報

- **経理業務の AI 導入率 24%（2026年調査）**: 導入企業の 68.3% が「業務時間の明確な短縮」を実感。クラウド会計ソフト各社の AI 仕訳精度が実用水準に到達との評価。
- **Microsoft Project Perception（7/18 発表）**: Anthropic・OpenAI・Microsoft 自社モデルを活用したマルチモデルAIセキュリティツール。Mythos 5（Microsoft 社内版）の廉価代替として位置づけ。
- **freee MCP 累積 API 呼び出し 250万回超（前回確認値）**: 経理部門での Claude Code 実採用が進行中。7月の最新数値は未確認。
- **Claude Code GitHub Stars 131K**: Augmentcode 記事「why developers are skipping the IDE」。Claude Code が IDE を置き換えるトレンドの考察。
- **会計×AI 業界動向**: 2026年、会計ソフト各社が「AI エージェント」を本体機能として標準搭載し始めた段階。AI は仕訳候補・要約・ドラフト生成を担い、人が最終承認する設計が主流。

#### references.md 更新提案
- **EndConversation ツールの追加**（v2.1.214）: harness-design-guide/references.md に「ジェイルブレイク試行への対応ツール」として追記を検討。現在の TBP-001 範囲外だが、Routine セキュリティ設計の文脈で参照できる。
- **Bash 権限チェック厳格化**（v2.1.214）: allowlist 設計に関する記述（TBP-001 周辺）に「10,000文字超コマンド・zsh変数修飾子・help/manが新たに許可確認対象になった」旨を追記推奨。ただし Tak の確認後に実施。

#### 新規発見ソース候補
- **releasebot.io/updates/anthropic/claude-code**: Anthropic Claude Code の更新を自動追跡するリリースボットサービス。⭐⭐⭐ 評価候補（公式ではないが更新追跡に便利）。trusted-sources.md の「発見待ち・評価中」への追記を提案。
- **kaikei-ai.jp**: 「Kaikei AI Daily」— freee AI 機能レビュー等の会計×AI 専門メディア。⭐⭐⭐ 評価候補。会計系ソース強化に有望。

#### 次回リサーチ推奨日
2026-07-19（明日）— Fable 5 期限切れ翌日（モデル移行状況の確認）、および週末の Claude Code 公式発信確認。

---

## [2026-07-17] デイリーレポート

### 内部知見（機能A）
#### 新規・更新 ADR
- My-Profile-and-Memory/decisions/ → フォルダ未存在のためスキップ
- research-hub/decisions/ → フォルダ未存在のためスキップ
- StudyMate, My-URAWA-LOG, tak-work, tak-family, tak-personal → アクセス可能スコープ外のためスキップ
- tak-best-practices/: TBP-001（外部ツール導入審査）・TBP-002（実行環境英語パス）を確認（新規 ADR なし）

#### TBP 昇格候補
- **TBP-003候補**（2026-06-22 提案・確認待ち25日目）:「着手前に実態（git）と文書（backlog）の一致を確認する」— Takの確認待ち。25日経過でリマインド。
- **TBP-004候補**（2026-06-22 提案・確認待ち25日目）:「不可逆性で安全方向を決めるが、カテゴリ丸ごとの保守化は目的を殺す」— Takの確認待ち。25日経過でリマインド。

#### 再検討トリガー該当
- **TBP-001 再評価トリガー（v2.1.212 セッション全体サブエージェント上限追加）**: セッション全体でのサブエージェント起動数上限（デフォルト200、`CLAUDE_CODE_MAX_SUBAGENTS_PER_SESSION`）が追加された。TBP-001「最小権限」設計においてサブエージェント多用型 Workflow が制限に到達する可能性。Research Hub の各 Routine の合計サブエージェント数を確認推奨。

---

### 外部リサーチ（機能B）
#### 参照した情報源
- Claude Code 公式チェンジログ（⭐⭐⭐⭐⭐）: v2.1.212（7/16〜17）詳細確認
- Anthropic 公式ブログ（⭐⭐⭐⭐⭐）: Ode with Anthropic（7/15）確認
- anthropics/claude-code GitHub issues（⭐⭐⭐⭐⭐）: 7/17 新規 issues（#78671〜#78678）確認
- Zenn / Qiita: 2026-07-17 Claude Code 記事トレンド確認
- 会計×AI: マネーフォワード AI Cowork / freee MCP / バクラク 2026年7月最新状況

#### 🔴 即座に適用すべき事項

**1. Claude Code v2.1.212（2026-07-16〜17 リリース）— セッション制限・/fork 変更**
- **/fork コマンド変更**: 会話をバックグラウンドセッション（claude agents の独自行）にコピーするように変更。以前 /fork が起動していたセッション内サブエージェントは **/subtask** に改名。Research Hub が /fork を使っている場合、/subtask への移行が必要。
- **WebSearch セッション全体上限追加（🔴 Routines 注意）**: デフォルト200件/セッション。`CLAUDE_CODE_MAX_WEB_SEARCHES_PER_SESSION` で設定可能。auto-research-collect などの多数検索 Routine が上限に達する可能性あり。上限到達時の挙動を確認推奨。
- **サブエージェント起動数セッション上限追加**: デフォルト200件/セッション。`CLAUDE_CODE_MAX_SUBAGENTS_PER_SESSION` で設定可能。/clear でリセット。large Workflow では要注意。
- **MCP 自動バックグラウンド移行**: 2分超の MCP ツール呼び出しが自動でバックグラウンド移行。`CLAUDE_CODE_MCP_AUTO_BACKGROUND_MS` で閾値設定・無効化可能。長時間の MCP 呼び出しを含む Routine の挙動に影響あり。
- **claude auto-mode reset コマンド追加**: デフォルト auto-mode 設定を復元する新コマンド（--yes でプロンプトスキップ）。
- **バグ修正: /release-notes のコンテキスト肥大化**: 「Show all」が全チェンジログをモデルのコンテキストに注入するバグを修正。長セッションのコンテキスト管理が改善。
- 🔴 直接適用: auto-research-collect など多数検索/サブエージェント多用 Routine の1セッション内使用量を確認。200超えなら環境変数で上限引き上げを検討。

**2. Fable 5 クレジット制移行（7/20 = 3日後）— 最終リマインド**
- 7/20 以降、Fable 5 はプリペイドクレジット制（$10/M input / $50/M output）へ完全移行。
- Max プラン加入者は 7/19 まで Max 枠内（週次制限の50%）で利用可能。
- 🔴 アクション: 7/19（明後日）までに Tak の Claude プラン確認。Research Hub Routine の auto モード設定を確認し、Fable 5 使用量を把握。

#### 🟡 近いうちに試したいこと（上位3件）

**1. Ode with Anthropic（2026-07-15 正式発表）— エンタープライズ AI 実装会社の新業態**
- Anthropic・Blackstone・Hellman & Friedman が設立した $1.5B のエンタープライズ AI 実装会社。100名の forward-deployed AI エンジニアが企業内に常駐し実装支援。
- Fractional AI（2026年5月買収）を基盤に設立。Chris Taylor CEO / Eddie Siegel CTO。Goldman Sachs・General Atlantic・Sequoia 等も参加。
- 「モデルではなく実装こそが次のトリリオンドル市場」というアプローチ。Claude Code 普及の新チャネルとして注目。Tak の会社でのAI導入シナリオを考える上での参考情報として価値あり。
- 🟡 アクション: techcrunch.com/2026/07/15/anthropic-blackstone の記事精読。Research Hub に記事化候補として記録。

**2. 会計×AI: freee・マネーフォワード・バクラクの AI 機能比較（2026年7月最新）**
- **マネーフォワード AI Cowork**: 7月リリース予定。AI がバックオフィス業務を自動処理。Claude Agent SDK + MCP 採用の本格派。7月末まで残り14日。正式アナウンス未確認。
- **freee MCP**: 2026年3月公開以来累計 250万回超の API 呼び出し達成（昨日確認）。Claude Code との連携が想定より速いペースで拡大。経理部門での Claude Code 実採用が本格化。
- **バクラク AI OCR**: 規定違反の自動検出で差し戻し率 60%減。99%超の OCR 精度継続。
- 🟡 アクション: マネーフォワード AI Cowork の正式リリースアナウンスを監視継続（毎日）。

**3. Claude Code npm インストール Deprecated → ネイティブインストーラー推奨への移行**
- 2026年7月現在、公式ドキュメントで npm 経由インストールが Deprecated 扱いに。ネイティブインストーラー推奨に変更。
- Research Hub の Routine 環境が npm 版 Claude Code を使用している場合は更新推奨。
- 🟡 アクション: Research Hub Routine が使用している Claude Code のインストール方法を確認。

#### 🟢 参考情報

**GitHub Issues 新着（2026-07-17）**
- Issue #78678: cowork area バグ（macOS、regression タグ）
- Issue #78677: model バグ
- Issue #78676: Claude Code 動作に関する質問
- Issue #78675: bash area バグ
- Issue #78674: MCP area バグ
- Issue #78673: cowork + MCP バグ（Linux）
- Issue #78671: desktop + UI enhancement（Windows）
- Research Hub Routines への直接影響は現時点で確認されず。

**Zenn / Qiita（2026-07-17 トレンド）**
- Zenn の claude-code タグ記事が 4,700件超に成長。日本語 Claude Code 情報の最大集積地として地位確立。
- 「Claude Code を"優秀な新卒部下"として使い倒す」（yoshiaki0217, Zenn）: 個人開発爆速化ワークフロー解説。
- カンリー社内 Claude Code 勉強会資料公開（Zenn）: hooks の matcher 設定フォーマットの継続進化に言及。

**Anthropic AI Safety キャンペーン「Inviting hard questions」継続**
- 7/9 公開の 90 秒フィルム「There's hope in hard questions」の反響継続中。AIの仕事・安全・科学への影響に関する公開回答へのコミットメントを表明。

#### references.md 更新提案
- **v2.1.212 セッション制限環境変数**: `CLAUDE_CODE_MAX_WEB_SEARCHES_PER_SESSION`（WebSearch 上限）・`CLAUDE_CODE_MAX_SUBAGENTS_PER_SESSION`（サブエージェント上限）・`CLAUDE_CODE_MCP_AUTO_BACKGROUND_MS`（MCP 自動バックグラウンド閾値）の3つをリファレンスに追記提案。Routines 設計の注意事項として。
- **npm インストール Deprecated 情報**: Claude Code のインストール方法セクションに「npm 経由は Deprecated、ネイティブインストーラー推奨」を追記提案。
- 昨日提案分（PreToolUse hook 修正・権限プレビュースプーフィング修正・Claude's new constitution）は継続中。
※ 直接更新は行わない。Tak の確認後に実施。

#### 新規発見ソース候補
なし（本日新規有望ソース未発見）

#### 次回リサーチ推奨日
2026-07-18（翌日）。
注目点:
① **Fable 5 クレジット制移行（7/20）前日確認（7/19）**: 7/19 が Max プランでの最終利用日。Routine の auto モード設定を当日確認。
② **マネーフォワード AI Cowork 正式リリースアナウンス**: 7月末まで残り14日。正式アナウンス待ち継続。
③ **TBP-003・TBP-004 昇格候補**: 6/22 提案から25日経過。Takへの確認リマインド継続（26日目）。
④ **v2.1.212 Routines への影響確認**: WebSearch/サブエージェント上限（各200）が auto-research-collect 等の実行量に到達するか確認。
⑤ **Claude's new constitution（CC0 1.0）精読**: 引き続き My-Profile-and-Memory への記録を推奨。

---
## [2026-07-16] デイリーレポート

### 内部知見（機能A）
#### 新規・更新 ADR
- My-Profile-and-Memory/decisions/ → フォルダ未存在のためスキップ
- StudyMate, My-URAWA-LOG, tak-work, tak-family, tak-personal → アクセス可能スコープ外のためスキップ
- tak-best-practices/: TBP-001（外部ツール導入審査）・TBP-002（実行環境英語パス）を確認（新規 ADR なし）

#### TBP 昇格候補
- **TBP-003候補**（2026-06-22 提案・確認待ち24日目）:「着手前に実態（git）と文書（backlog）の一致を確認する」— Takの確認待ち。24日経過でリマインド。
- **TBP-004候補**（2026-06-22 提案・確認待ち24日目）:「不可逆性で安全方向を決めるが、カテゴリ丸ごとの保守化は目的を殺す」— Takの確認待ち。24日経過でリマインド。

#### 再検討トリガー該当
- **TBP-001 再評価トリガー（v2.1.211 PreToolUse hook バグ修正）**: auto mode が PreToolUse hook の「ask」決定を上書きしてしまう（unsandboxed Bash に対して）バグが修正。TBP-001「最小権限」設計において、hook による承認フローが期待通り機能しない状態があったことを確認。v2.1.211 以降では修正済み。Research Hub で PreToolUse hook を設定している場合は動作確認推奨。
- **TBP-001 再評価トリガー（Claude for Teachers に Claude Code + Cowork 含まれる）**: 米国 K-12 教育者向けに Claude Code + Cowork を含む無料プレミアムアクセスが提供開始。新しい層（教育者）への Claude Code 普及事例。TBP-001「外部ツール導入審査」の観点で、教育機関での権限設計・活用事例として参照価値あり。

---

### 外部リサーチ（機能B）
#### 参照した情報源
- Claude Code 公式チェンジログ（⭐⭐⭐⭐⭐）: v2.1.211（7/15）、v2.1.212（7/16）確認
- Anthropic 公式ブログ（⭐⭐⭐⭐⭐）: Claude's new constitution / Claude for Teachers / Claude Science / How Australia Uses Claude
- anthropics/claude-code GitHub issues（⭐⭐⭐⭐⭐）: 7/16 新規 issue 確認（#78275, #78276）
- Zenn / Qiita: 7/16 トレンド記事・Claude Code Zenn 執筆環境構築記事
- 会計×AI: マネーフォワード AI Cowork / freee MCP 累計利用状況 / バクラク OCR 精度

#### 🔴 即座に適用すべき事項

**1. Claude Code v2.1.211（2026-07-15 リリース）— セキュリティ修正含む重要アップデート**
- **権限プレビュースプーフィング修正（🔴 セキュリティ）**: チャットチャネルに中継された権限確認プレビューが、Bidirectional-override・ゼロ幅文字・見た目が似たクォート文字を無害化しないバグを修正。ツール入力が承認メッセージを視覚的に改ざんできる脆弱性が塞がれた。
- **PreToolUse hook の ask 決定が auto mode に上書きされるバグ修正**: unsandboxed Bash に対して auto mode が hook の「ask」判断を無視していた。TBP-001 の最小権限設計に直結するバグ修正。
- **並列セッション同時ログアウトバグ修正**: 共有クレデンシャルストアを使う複数の Claude Code セッションが、スリープ復帰後に全セッション同時ログアウトする問題を修正。
- **plugin MCP サーバー再接続バグ修正**: アイドル後のウェブセッション復帰時に plugin MCP サーバーが再接続されないバグを修正。Research Hub の Routine 実行後のセッション復帰に関連する可能性あり。
- **`--forward-subagent-text` フラグ新設**: `CLAUDE_CODE_FORWARD_SUBAGENT_TEXT` 環境変数でサブエージェントのテキストと thinking を stream-json 出力に含めることが可能に。Workflow サブエージェントのデバッグ・ログ収集に活用可能。
- 🔴 直接適用事項: v2.1.211 を確認。Research Hub の hook 設定・MCP サーバー設定の動作を再検証推奨。

**2. Fable 5 アクセス期限 7/19（3日後）— クレジット制移行**
- 7/20 以降、Fable 5 は プリペイドクレジット制（$10/M input tokens / $50/M output tokens）に完全移行。
- Max プラン加入者は Max の枠内（週次制限の 50%）で 7/19 まで引き続き利用可能。
- 7/20 以降は Settings → Usage でクレジットを購入する必要あり（自動チャージ設定可）。
- Anthropic は「十分なコンピュートが確保できたらサブスクリプションに戻す」としているが日程未定。
- 🔴 アクション: Tak の Claude プランを確認し、7/19 以降のコスト変化を事前把握。Research Hub の Routine が auto モードで Fable 5 を使っている場合はコスト増に注意。

#### 🟡 近いうちに試したいこと（上位3件）

**1. Claude's new constitution（Anthropic 公式、2026-07-16 頃）**
- Anthropic が Claude の価値観・行動規範を定めた「新しい constitution」を CC0 1.0（パブリックドメイン）で全文公開。Claude の思想的バックボーンを理解する一次資料として最重要。
- Tak の「AI との向き合い方・思想形成」にも直結する内容。My-Profile-and-Memory にメモとして保存する価値あり。
- 🟡 アクション: anthropic.com/news/claude-new-constitution を全文精読。Research Hub に記事化候補として記録。

**2. Claude for Teachers（Anthropic、2026-07-14 前後）**
- 米国 K-12 教育者（教員資格確認済み）に Claude Code + Cowork を含む無料プレミアムアクセスを提供。
- Claude が「days-long エージェント作業を持続できる」特性を教育分野に本格展開した事例。AI 浸透の社会的インパクトを把握する観点で参考情報として価値あり。
- 🟡 アクション: anthropic.com/news/claude-for-teachers で詳細確認。Research Hub に参考記事として記録。

**3. Claude Science（Anthropic、2026-07 リリース）**
- 科学者向け AI ワークベンチ。研究者が頻繁に使うツール・パッケージを統合し、監査可能なアーティファクトを生成、柔軟な計算リソースアクセスを提供。Pro/Max/Team/Enterprise で beta 公開。
- AI を科学研究インフラに組み込む Anthropic の戦略的方向性として注目。Research Hub の Deep Research 機能の参考にもなりうる。
- 🟡 アクション: anthropic.com/news/claude-science-ai-workbench で詳細確認。AI for Science プロジェクト（9月〜12月）の応募要件も確認。

#### 🟢 参考情報

**Claude Code v2.1.212（2026-07-16 リリース）**
- 本日リリース。詳細情報限定。引き続き公式チェンジログを確認。

**GitHub Issues 新着（2026-07-16）**
- Issue #78276（arijitroy003）: area:model バグ（再現手順必要）
- Issue #78275（dsharma）: area:cowork + area:skills バグ（詳細再現手順あり）
- Research Hub Routines への直接影響は現時点で確認されず。

**How Australia Uses Claude（Anthropic Economic Index）**
- カナダに続いてオーストラリア版も公開（7/16 前後）。業種別・用途別の Claude 活用パターンを分析。日本市場でのトレンドを類推する参考情報として有用。
- 🟢 アクション: Research Hub に記事化候補として記録。

**Zenn / Qiita（2026-07-16）**
- 「Claude Code と Zenn 執筆環境を一から育てた記録」（shimo4228）: Claude Code を使った Zenn/Qiita/Hashnode 同時投稿ワークフロー自動化実践例。
- 「Claude Codeですべての日常業務を爆速化しよう！」（minorun365, Qiita）: 実務活用ガイド継続トレンド。
- 7/16 Qiita トレンド（ennagara128）: 「YouTube集客テクニックを Claude Code で多角的に調査」が上位入り。

**会計×AI（2026-07-16 時点）**
- **マネーフォワード AI Cowork**: 依然「2026年7月より提供開始予定」のみ。7月末まで残り15日。正式リリースアナウンス未確認継続。
- **freee MCP 累計 250 万回 API 呼び出し達成**（3月公開以来）: freee × Claude Code 連携の実採用が想定より速いペースで拡大。経理部門での Claude Code 活用が本格化している証左。
- **バクラク OCR 99%+精度継続**: 手書き混じり請求書でも 99% 超を公称。バクラク × freee API 連携でワンクリック仕訳が安定稼働中。

#### references.md 更新提案
- **v2.1.211 PreToolUse hook 修正**: 権限・hook 設計セクションへの追記を提案（「auto mode が PreToolUse hook の ask 決定を上書きするバグは v2.1.211 で修正済み。hook による承認フロー設計は v2.1.211 以降に前提を置くこと」）。
- **v2.1.211 権限プレビュースプーフィング修正**: セキュリティセクションへの追記を提案（「チャットチャネルへの権限確認リレー時の視覚的改ざん脆弱性は v2.1.211 で修正済み」）。
- **Claude's new constitution（CC0 1.0）**: Claude の思想的バックボーンの一次資料として references への追加を提案（`anthropic.com/news/claude-new-constitution`）。
※ 直接更新は行わない。Takの確認後に実施。

#### 新規発見ソース候補
なし（本日新規有望ソース未発見）

#### 次回リサーチ推奨日
2026-07-17（翌日）。
注目点:
① **Fable 5 クレジット制移行（7/20）の前日確認**: 7/19 が最終日。Tak の Claude プラン・Routine の auto モード設定を確認。
② **マネーフォワード AI Cowork 正式リリースアナウンス**: 7月末まで残り15日。毎日監視継続。
③ **TBP-003・TBP-004 昇格候補**: 6/22 提案から24日経過。Takへの確認リマインド継続。
④ **Claude's new constitution 精読**: CC0 公開の Claude 思想文書。My-Profile-and-Memory への記録候補。
⑤ **v2.1.212 詳細**: 本日リリースの変更内容確認。

---
## [2026-07-15] デイリーレポート

### 内部知見（機能A）
#### 新規・更新 ADR
- My-Profile-and-Memory/decisions/ → フォルダ未存在のためスキップ
- StudyMate, My-URAWA-LOG, tak-work, tak-family, tak-personal → アクセス可能スコープ外のためスキップ
- tak-best-practices/: TBP-001（外部ツール導入審査）・TBP-002（実行環境英語パス）を確認（新規 ADR なし）

#### TBP 昇格候補
- **TBP-003候補**（2026-06-22 提案・確認待ち23日目）:「着手前に実態（git）と文書（backlog）の一致を確認する」— Takの確認待ち。23日経過でリマインド。
- **TBP-004候補**（2026-06-22 提案・確認待ち23日目）:「不可逆性で安全方向を決めるが、カテゴリ丸ごとの保守化は目的を殺す」— Takの確認待ち。23日経過でリマインド。

#### 再検討トリガー該当
- **TBP-001 再評価トリガー（v2.1.210 isolation:worktree サブエージェント修正）**: v2.1.210 で `isolation: 'worktree'` サブエージェントがメインリポジトリの checkout に対して git 変更コマンドを実行できるバグを修正。TBP-001「最小権限」の原則において、worktree 分離設計の実装バグが想定より大きな影響を与えていた可能性。Research Hub の Workflow で worktree isolation を使うサブエージェントがある場合、v2.1.210 へのアップデートで修正済みであることを確認推奨。
- **TBP-001 再評価トリガー（v2.1.210 ultracode 誤発火修正）**: ultracode キーワードによる opt-in が、webhook ペイロードや中継 PR コメント等の非ヒューマン入力でも発火していたバグを修正。Research Hub の Routine が PR コメント等を処理する場合、意図しない ultracode 起動が抑止されたことを確認推奨。

---

### 外部リサーチ（機能B）
#### 参照した情報源
- Claude Code 公式チェンジログ（⭐⭐⭐⭐⭐）: v2.1.210 確認（2026-07-14 リリース）
- Anthropic 公式ブログ（⭐⭐⭐⭐⭐）: 7/15 時点最新記事確認
- anthropics/claude-code GitHub issues（⭐⭐⭐⭐⭐）: 7/15 新規 issue 一覧
- Zenn: Claude Code × Codex 最新モデル使い分けガイド（2026年7月版）
- Qiita: Claude Code 週次アップデートまとめ（2026/07/11週）継続参照
- 会計×AI: マネーフォワード AI Cowork / freee・MF・バクラク AI機能 2026年7月

#### 🔴 即座に適用すべき事項

**Claude Code v2.1.210（2026-07-14 リリース）— worktree 分離バグ修正 + ultracode 誤発火修正**
- **isolation:worktree サブエージェントの git 操作修正（重要）**: worktree 分離設定のサブエージェントがメインリポジトリの checkout に対して git 変更コマンドを実行できるセキュリティバグを修正。意図しないメインブランチへの git 操作が防止された。
- **ultracode 誤発火修正**: ultracode キーワード opt-in が webhook ペイロード・中継 PR コメント等の非ヒューマン入力でも発火していたバグを修正。Research Hub の Routines への直接影響は低いが、PR コメント処理系の処理の安全性が向上。
- **ツールサマリー行にライブ経過時間カウンター追加**: 折りたたまれたツールサマリー行に経過時間が表示されるようになり、長時間実行のツール呼び出し中に「止まっている」ように見えなくなった。
- **Write/NotebookEdit/Glob パス設定の警告**: `Write(path)`・`NotebookEdit(path)`・`Glob(path)` の権限ルールに起動時警告を追加（`Edit(path)` や `Read(path)` を使うよう誘導）。
- 🔴 直接適用事項: worktree isolation を使う Workflow サブエージェントがある場合は v2.1.210 を確認。

#### 🟡 近いうちに試したいこと（上位3件）

**1. Anthropic ブログ「Inviting hard questions」（2026-07-09）精読**
- AIに関する難しい質問（誰がルールを決めるか、子どもへの影響、世界を危険にするか、科学者支援）に Anthropic が回答するブログ。
- Tak の AI との向き合い方・思想形成の参考情報として有用。
- 🟡 アクション: anthropic.com/news/hard-questions で全文確認。Research Hub に記事化候補として記録。

**2. Alberta 州政府 × Claude Code 事例の深堀り（2026-07-06）**
- Alberta 州政府が Claude Code（Opus + Sonnet）で 4.66億行のコードを20時間でスキャン、脆弱性を自動検出・修正。通常チームの数ヶ月相当の作業を1日で完了。
- 大規模コードベース監査への Claude Code 実用性の公式事例として記録。Research Hub に記事化推奨。
- 🟡 アクション: anthropic.com/news/alberta-government-claude-cybersecurity で全文確認。

**3. マネーフォワード AI Cowork 正式リリースアナウンス（引き続き最優先）**
- 7/15 時点でも「2026年7月より提供開始予定」表記が継続。正式リリースアナウンス未確認。7月末まで残り16日。
- Tak の本業（経理部長）に直結。確認次第 auto-research-collect 枠で即時記事化推奨。
- 🟡 アクション: biz.moneyforward.com で毎日確認継続。

#### 🟢 参考情報

**GitHub Issues 新着（2026-07-15）**
- Issue #77930（lokkaflokka）: Claude Code Routines on web — スケジュール・webhook トリガータスクの改善要望。Research Hub の Routines 設計に直接関連する issue として継続監視推奨。
- Issue #77929（CpLabLibs）: 詳細未確認。
- 7/14 付け PR: plugin development validation・hookify rules・hook error handling・issue-automation telemetry の修正。

**Anthropic ニュース（2026-07-15 時点）**
- 7/09: 「Inviting hard questions」— AI の難問に回答
- 7/06: Alberta 州政府 × Claude Code サイバーセキュリティ事例
- 7/02: Fable 5 のサイバーセーフガードとジェイルブレークフレームワーク詳細
- 7/01: Fable 5・Mythos 5 再展開（輸出規制解除後）。グローバルに利用可能に。
- Anthropic × Amazon: 最大 5GW の新規コンピュート拡大協定。インフラ規模急拡大継続。
- Fable 5 アクセス: 7/19 まで有料サブスクライバー向けに 50% レート制限ブースト付きで延長中。7/19 以降はクレジット制（$10/$50 per Mtok）に完全移行。

**Zenn / Qiita（2026-07-15 時点）**
- 「Claude Code × Codex 最新モデルの特徴と使い分け（2026年7月版）」（Zenn, nenene01）: Fable 5・Sonnet 5 のマルチエージェント活用ガイド。
- Qiita 週次アップデートまとめ（2026/07/11週）: 前週（v2.1.202〜207）のハイライト日本語版。3大ハイライト: ① In-app Browser on Desktop、② Background Agent 自動アップグレード、③ auto-update メモリ削減 (~400MB)。

**会計×AI トレンド（2026-07-15 時点）**
- **マネーフォワード AI Cowork**: 7/15 時点でも正式リリースアナウンス未確認（継続ウォッチ）。
- **経理 AI 導入率**: 約 24%（導入企業の 68.3% が業務時間短縮実感）。前日から変化なし。
- **freee・MF MCP 対応**: 2026年3月26日以降、freee・マネーフォワード クラウドの全プランに MCP 連携が追加料金なしで提供中。freee MCP (OSS) は 270+ API に Claude Code から直接アクセス可能。
- **バクラク**: 規定違反自動検出で差し戻し率 60% 削減事例継続。freee 会計 API 連携でワンクリック仕訳・証憑連携が可能に。
- **会計 AI 2026年定説**: 「AI-OCR（定型処理）+ 生成AI（判断・文書作成）」の二刀流。月次決算を5営業日短縮、仕訳処理75%削減が業界標準報告値。

#### references.md 更新提案
- **v2.1.210 isolation:worktree サブエージェント修正**: worktree 分離設計セクションへの追記提案（「v2.1.210 以前は worktree isolation サブエージェントがメインリポジトリに git 変更を加えられるバグあり。v2.1.210 で修正済み」）。
- **v2.1.210 ultracode 誤発火修正**: Workflow/ultracode 設計セクションへの追記提案（「ultracode キーワードは webhook・PR コメント等の非ヒューマン入力では発火しない（v2.1.210〜）」）。
- **v2.1.210 Write/Glob/NotebookEdit(path) パス権限警告**: 権限設計セクションへの追記提案（「Write/Glob/NotebookEdit の path 設定は非推奨。Edit(path)/Read(path) を使うよう起動時警告が出る（v2.1.210〜）」）。
※ 直接更新は行わない。Takの確認後に実施。

#### 新規発見ソース候補
なし（本日新規有望ソース未発見）

#### 次回リサーチ推奨日
2026-07-16（翌日）。
注目点:
① **マネーフォワード AI Cowork 正式リリースアナウンス**: 7月末まで残り16日。毎日監視継続。
② **Fable 5 アクセス期限 7/19 接近**: 残り4日。7/19 前後のコスト変化を事前確認。Max 契約未満は注意。
③ **TBP-003・TBP-004 昇格候補**: 6/22 提案から23日経過。Takへの確認を促すリマインド継続。
④ **v2.1.210 以降の続報**: 7/14 リリースの翌日。v2.1.211 以降の変更をウォッチ。
⑤ **GitHub Issue #77930 (Routines on web)**: スケジュール・webhook トリガータスクの改善動向。Research Hub Routines 設計に関連。

---

## [2026-07-14] デイリーレポート

### 内部知見（機能A）
#### 新規・更新 ADR
- My-Profile-and-Memory/decisions/ → フォルダ未存在のためスキップ
- StudyMate, My-URAWA-LOG, tak-work, tak-family, tak-personal → アクセス可能スコープ外のためスキップ
- tak-best-practices/: TBP-001（外部ツール導入審査）・TBP-002（実行環境英語パス）を確認（新規 ADR なし）

#### TBP 昇格候補
- **TBP-003候補**（2026-06-22 提案・確認待ち22日目）:「着手前に実態（git）と文書（backlog）の一致を確認する」— Takの確認待ち。22日経過でリマインド。
- **TBP-004候補**（2026-06-22 提案・確認待ち22日目）:「不可逆性で安全方向を決めるが、カテゴリ丸ごとの保守化は目的を殺す」— Takの確認待ち。22日経過でリマインド。

#### 再検討トリガー該当
- **TBP-001 再評価トリガー（v2.1.208 アクセシビリティ機能）**: v2.1.208 で `axScreenReader` オプトイン機能が追加（`claude --ax-screen-reader` / 環境変数 `CLAUDE_AX_SCREEN_READER=1` / settings `"axScreenReader": true`）。ヘッドレス Routine 環境への直接影響はないが、TBP-001「外部ツール導入審査」の「機能棚卸し」観点でアクセシビリティ設定の追跡が必要なプロジェクトを評価する際の参考に。なお本機能は GitHub Issue #11002 で要望されていた機能の公式実装。

---

### 外部リサーチ（機能B）
#### 参照した情報源
- Claude Code 公式チェンジログ（⭐⭐⭐⭐⭐）: v2.1.208 確認（2026-07-14 リリース）
- Anthropic 公式ブログ（⭐⭐⭐⭐⭐）: 7/14「How Canada uses Claude」(Economic Index) / 7/13「Values across models and languages」
- anthropics/claude-code GitHub issues（⭐⭐⭐⭐⭐）: 7/14 新規 issue 一覧
- Qiita: Claude Code 週次アップデートまとめ 2026/07/11 週
- Zenn: カンリー社内 Claude Code 勉強会資料公開
- 会計×AI: マネーフォワード AI Cowork / freee vs MF AI 比較 2026 / 経理自動化ガイド 2026

#### 🔴 即座に適用すべき事項

**Claude Code v2.1.208（2026-07-14 リリース）— スクリーンリーダーモード追加**
- アクセシビリティ向上: スクリーンリーダー向けのオプトインテキスト表示モードを追加。
  - 有効化方法: `claude --ax-screen-reader` / `CLAUDE_AX_SCREEN_READER=1` / settings に `"axScreenReader": true`
  - NVDA・JAWS 等のスクリーンリーダーとの互換性向上が目的。
  - Research Hub Routine や自動実行には影響なし（UI 表示モード変更のみ）。
- 🔴 直接適用事項は今回なし。Routine 環境への影響がないため、アップデート内容として記録のみ。

#### 🟡 近いうちに試したいこと（上位3件）

**1. Anthropic Research「How Canada uses Claude」(Anthropic Economic Index、2026-07-14)**
- カナダにおける Claude 活用状況を Economic Index（経済指数）で分析。業種別・用途別の利用パターンを把握できる。
- 日本での Claude 活用トレンド（特に経理・会計領域）を類推する参考情報として有用。
- 🟡 アクション: alignment.anthropic.com または anthropic.com/research で全文確認。Research Hub に記事化候補として記録。

**2. Claude Code 週次アップデートまとめ（2026/07/11週）精読**
- v2.1.202〜v2.1.207 のハイライト日本語版が Qiita に公開済み（@saitoko 氏）。
- 3大ハイライト: ① In-app Browser on Desktop（ドキュメント/デザイン/サイトをサンドボックスブラウザで閲覧・操作）、② Background Agent 自動アップグレード、③ auto-update のメモリ削減（約 400MB 削減）。
- 🟡 アクション: Qiita 記事で v2.1.202〜v2.1.207 の詳細確認。特に In-app Browser が Research Hub の Web 閲覧 Routine に応用できるか評価。

**3. マネーフォワード AI Cowork 正式リリース確認（引き続き最優先）**
- 7/14 時点でも正式リリースアナウンス未確認。「2026年7月より提供開始予定」表記が継続。
- 会計各社（freee / MF / バクラク）が AI エージェントを本体標準機能として統合する流れが 2026年に加速。MF AI Cowork は AIが「同僚」として経理・労務・法務を自律処理する設計。
- 🟡 アクション: biz.moneyforward.com で毎日確認継続。7月末まで残り17日。

#### 🟢 参考情報

**GitHub Issues 新着（2026-07-14）**
- VS Code Linux セキュリティバグ（simonticciatihayes）: 再現手順あり
- plugins/skills バグ（mmadersbacher, macOS）・（munirsquires, macOS）: 詳細再現手順あり
- area:model / area:tui enhancement（複数）: コスト表示改善・TUI 改善への需要継続
- 上記はすべて open。Research Hub Routines への直接影響は現時点で確認されず。

**Anthropic 研究発表（2026-07-14 前後）**
- 7/14: How Canada uses Claude — Findings from the Anthropic Economic Index
- 7/13: Values across models and languages（多言語価値観一貫性研究）— Claude Sonnet 5・Haiku 4.5 等の多言語一貫性評価
- 7/09: Claude plays robotics（ロボティクス制御実験）
- 7/08: An off switch for dual-use knowledge in AI models（デュアルユース知識の危険利用防止）
- Anthropic の研究方向: 安全性・有用性・価値観の整合が多角的に進んでいる。

**Anthropic インフラパートナーシップ（規模感として記録）**
- Google + Broadcom と複数ギガワット規模の次世代コンピュート拡大を発表（7/14付け）
- Amazon とも最大 5GW の新コンピュート協定（7月）
- Anthropic のインフラ規模が急拡大中 → Claude サービス安定性・能力向上の根拠

**会計×AI トレンド（2026-07-14 時点）**
- **マネーフォワード AI Cowork**: 7/14 時点でも正式リリースアナウンス未確認（継続ウォッチ）。
- **経理 AI 導入率**: 約 24%（導入企業の 68.3% が業務時間短縮実感）。前日から変化なし。
- **freee AI OCR**: 印刷レシート 90%超・手書き領収書 75%前後の精度（2026年アップデート継続）。
- **freee vs MF 比較**: freee はマッチング精度、MF は連携範囲（M365 含む）が主な差別化軸として明確化。
- **バクラク × freee API 連携動向**: freee APIポリシー改定の波紋あり。LayerX は複数の会計ソフト対応拡張を表明中。
- **2026年経理DX定説**: 「AI-OCR（定型処理）+ 生成AI（判断・文書作成）」の二刀流。

**Zenn / Qiita（2026-07-14 時点）**
- カンリー社内 Claude Code 勉強会資料（Zenn）: hooks 設定スキーマ変更・SDD の考え方を解説
- 「Claude Code を4ヶ月使ってわかった、おすすめコマンド・スキル 10 選」（Qiita, 6/26, Qiita Tech Festa 参加記事）
- 「Claude Code、とりあえずこれ読んどけばOKなまとめ（2026年版）」（Qiita）: 学習リソース総まとめ

#### references.md 更新提案
- **v2.1.208 axScreenReader オプション**: アクセシビリティ設定として settings のオプション一覧に追記を提案（`"axScreenReader": true` / `CLAUDE_AX_SCREEN_READER=1`）。
- **Anthropic コンピュートパートナーシップ（Google/Broadcom・Amazon）**: インフラ規模の急拡大。Claude サービス稳定性の根拠として reference 資料への追記を提案。
※ 直接更新は行わない。Takの確認後に実施。

#### 新規発見ソース候補
なし（本日新規有望ソース未発見）

#### 次回リサーチ推奨日
2026-07-15（翌日）。
注目点:
① **マネーフォワード AI Cowork 正式リリースアナウンス**: 7月末まで残り17日。毎日監視継続。
② **Claude Fable 5 アクセス期限 7/19 接近**: 5日後。7/19 前後のコスト変化確認を事前準備。
③ **TBP-003・TBP-004 昇格候補**: 6/22 提案から22日経過。Takへの確認促しを継続。
④ **v2.1.208 以降の続報**: 7/14 リリースの翌日。v2.1.209 以降の変更をウォッチ。
⑤ **Anthropic Economic Index（Canada）論文精読**: 日本の経理×AI トレンドを類推する参考情報として。

---
## [2026-07-13] デイリーレポート

### 内部知見（機能A）

#### 新規・更新 ADR
- My-Profile-and-Memory/decisions/ → フォルダ未存在のためスキップ
- StudyMate, My-URAWA-LOG, tak-work, tak-family, tak-personal → アクセス可能スコープ外のためスキップ
- tak-best-practices/: TBP-001（外部ツール導入審査）・TBP-002（実行環境英語パス）を確認（新規 ADR なし）

#### TBP 昇格候補
- **TBP-003候補**（2026-06-22 提案・確認待ち21日目）:「着手前に実態（git）と文書（backlog）の一致を確認する」— Takの確認待ち。21日経過でリマインド。
- **TBP-004候補**（2026-06-22 提案・確認待ち21日目）:「不可逆性で安全方向を決めるが、カテゴリ丸ごとの保守化は目的を殺す」— Takの確認待ち。21日経過でリマインド。

#### 再検討トリガー該当
- **TBP-001 再評価トリガー（/checkup コマンド / v2.1.202）**: `/checkup` コマンドが未使用スキル・MCP・プラグインの削除提案・低速フック無効化・CLAUDE.md 整理・バージョン更新など「段階拡張後の定期棚卸し」を自動化する機能として確認。TBP-001「段階拡張」フェーズに「`/checkup`（または `/doctor`、v2.1.205 以降はエイリアス）を定期実行してツール一覧と権限を棚卸しする」手順を追記する改訂を提案。※ 自動改訂は行わない。Tak 確認後に実施。

---

### 外部リサーチ（機能B）

#### 参照した情報源
- Claude Code 公式チェンジログ（⭐⭐⭐⭐⭐）: v2.1.207 確認（前日 7/12 レポート済み）、本日 7/13 新リリースなし
- Anthropic 公式ブログ（⭐⭐⭐⭐⭐）: Fable 5 再展開状況・研究発表
- anthropics/claude-code GitHub issues（⭐⭐⭐⭐⭐）: 7/13 新規 issue 一覧
- Qiita: Claude Code 週次アップデートまとめ 2026/07/11 週、Qiita Tech Festa 2026
- 会計×AI: マネーフォワード AI Cowork / freee vs MF AI 比較 / 経理自動化ガイド 2026
- Claude Fable 5 / Mythos 5 最新状況

#### 🔴 即座に適用すべき事項

**Claude Fable 5 アクセス期限 7/19 まで再延長**
- 有料サブスクライバー向け Fable 5 アクセスが 7/19 23:59 PT まで延長、かつレート制限を 50% ブースト。
- 7/19 以降はクレジット制（$10/M input / $50/M output）のみになる見込み（Max 5x 以上は Max 内課金）。
- Routine の auto モードが Fable 5 を選択している場合、7/19 以降のコスト変化を事前に把握しておく必要あり。
- 🔴 アクション: 7/19 前後の Routine 実行コストを事前確認。Max 契約未満の場合はクレジット消費量に注意。

#### 🟡 近いうちに試したいこと（上位3件）

**1. Anthropic Research: Claude の価値観の研究論文（2026-07-13）**
- Anthropic が「Values across models and languages」を公開（7/13）。Claude Sonnet 5・Haiku 4.5 等の価値観の一貫性を多言語で評価した研究。日本語環境での Claude の挙動理解に参考になる可能性あり。
- 🟡 アクション: alignment.anthropic.com で論文を確認。Research Hub に記事化候補として記録。

**2. Claude Code /checkup コマンドをセットアップ棚卸しに活用**
- `/checkup`（v2.1.202+、/doctor のエイリアス）でセットアップ自動診断: 未使用スキル・MCP・プラグイン削除提案、CLAUDE.md 整理、低速フック無効化、Claude Code 最新版更新、auto モード有効化、頻繁に拒否された読み取り専用コマンドの事前承認など。
- My-Profile-and-Memory や Research Hub の CLAUDE.md / スキル / MCP 設定の棚卸しに活用できる。
- 🟡 アクション: 次回 Claude Code セッションで `/checkup`（または `/doctor`）を実行してセットアップ状態を診断。

**3. Artifacts on Pro/Max（v2.1.197〜）でリサーチレポートを Shareable ページ化**
- セッションの出力（Research Hub 記事・レポート・分析）を live shareable ページとして公開できる。週次リサーチサマリーや Deep Research 結果の共有に活用可能。
- 🟡 アクション: 次回 Research Hub 分析セッションで Artifacts 機能を試用してみる。

#### 🟢 参考情報

**GitHub Issues 新着（2026-07-13）**
- #77274〜#77281: model / plugins / permissions / tui / cost 系のバグ・enhancement（macOS 中心）。Research Hub Routines への直接影響は確認されず。
- 7/13 付けで area:cost, area:tui の enhancement issue が複数開設 → コスト表示改善への需要が高い。

**Qiita Tech Festa 2026 終了**
- 本日 7/13 で終了。総括: Claude Code 実践記事が急増したイベントとして記録。「お前の Claude Code の使い方は間違っている」（7/1 掲載）が特に反響大。

**Qiita 週次アップデートまとめ 2026/07/11 週**
- v2.1.202〜v2.1.207 のハイライト（日本語要約）が公開済み。
- 3大ハイライト: ① Artifacts 機能が Pro/Max に一般開放（v2.1.197）、② /review コマンド体系の刷新（高速 PR レビューが `/review`、深掘りが `/code-review` に分離）、③ `/doctor` が CLAUDE.md 簡素化提案を行うようになった（v2.1.206）。

**Anthropic 研究発表（2026-07-09〜13）**
- 7/13: Values across models and languages（多言語価値観一貫性研究）
- 7/09: Claude plays robotics（ロボティクス制御実験）
- 7/08: Off switch for dual-use knowledge in AI（汎用知識の危険利用防止スイッチ研究）
- 7/06: Global workspace in language models（LLM グローバルワークスペース研究）
- これらは AI 安全性・能力研究の進展として記録。Anthropic の研究方向性をウォッチする上で有用。

**Claude Fable 5 の特徴（v2.1 以降との統合観点）**
- PDF・図表・チャート・ダイアグラム内容理解が強化（finance / legal / analytics での文書作業に特化）。
- 安全分類器搭載（Mythos 5 には搭載なし）。危険リクエスト → Opus 4.8 自動ルーティング。
- days-long エージェントハーネス対応: Claude Code / Managed Agents での長時間自律作業が本格化。

**会計×AI トレンド（2026-07-13 時点）**
- **マネーフォワード AI Cowork**: 本日も正式リリース未確認（「2026年7月より提供開始予定」継続）。7/19 以前のリリースに期待。
- **経理 AI 導入率**: 24%、導入企業 68.3% が業務時間短縮実感（前週値から変化なし）。
- **freee AI OCR + MF AI 仕訳比較 2026**: 両者とも AI エージェントを本体標準機能として統合する流れが明確化。freee はマッチング精度、MF は連携範囲（M365 含む）が強みとして差別化。
- **バクラク**: 規制違反自動検出により却下率 60% 削減事例が継続。
- **Zapier × ChatGPT 経理半自動化**: 月次決算工数を 50% 削減する実装例（記事化候補）。
- **2026年経理DX全般**: 「AI-OCR（定型処理） + 生成AI（判断・文書作成）」の二刀流が業界定説化。

#### references.md 更新提案
- **`/doctor` コマンドの体系整理（v2.1.205〜）**: `/doctor` がフルセットアップ診断・修正ツールに昇格。`/checkup` は `/doctor` のエイリアスに。公式ベストプラクティス文書の「セットアップ診断」セクションへの追記を提案。
- **Fable 5 アクセス延長 7/19 まで + 50% レート制限ブースト**: モデル利用状況セクションへの追記を提案。
※ 直接更新は行わない。Takの確認後に実施。

#### 新規発見ソース候補
なし（本日新規有望ソース未発見）

#### 次回リサーチ推奨日
2026-07-14（翌日）。
注目点:
① **マネーフォワード AI Cowork 正式リリースアナウンス**: 7/19 以前のリリース期待。毎日監視継続。
② **Claude Fable 5 アクセス期限 7/19 接近**: 7/19 前後のコスト変化確認を事前準備。
③ **TBP-003・TBP-004 昇格候補**: 6/22 提案から 21 日経過。Tak への確認促しとして記録。
④ **GitHub Issue #77274〜: area:cost / area:tui エンハンスメント**: コスト表示改善の動向ウォッチ。
⑤ **Anthropic 「Values across models」論文精読**: 日本語環境での Claude 挙動理解のため。

---
## [2026-07-12] デイリーレポート

### 内部知見（機能A）

**decisions/ ディレクトリ確認**
- My-Profile-and-Memory/decisions/ → 存在しないためスキップ
- 他リポジトリ → スコープ外のためスキップ

**既存 TBP 確認**
- TBP-001（外部ツール採用審査）: 変更なし（再評価トリガーあり、後述）
- TBP-002（日本語パス回避）: 変更なし

**TBP 昇格候補**

- **TBP-003 候補（保留 20 日経過）**: 「着手前に実態（git）と文書（backlog）の一致を確認する」— 昇格検討タイミング
- **TBP-004 候補（保留 20 日経過）**: 「不可逆性で安全方向を決めるが、カテゴリ丸ごとの保守化は目的を殺す」— 昇格検討タイミング

**TBP 再評価トリガー**
- **TBP-001 ← Claude Code v2.1.207**: Auto mode が Bedrock / Vertex AI / Foundry でオプトインフラグなしに利用可能になった（無効化は settings の `disableAutoMode`）。TBP-001 の「審査」フェーズにクラウドプロバイダレベルのデプロイを明示的に含める改訂を提案。

---

### Web リサーチ（機能B）

#### 🔴 重要（即対応検討）

**Claude Code v2.1.207（2026-07-11 リリース）**
- Auto mode が Bedrock / Vertex AI / Foundry へ展開（オプトインフラグ不要）。無効化: settings の `disableAutoMode`。エンタープライズ環境での注意が必要
- ターミナルフリーズ修正: 長いリスト/テーブル/段落/コードブロック表示中のキーストロークラグを修正
- non-interactive `claude -p` / SDK で managed settings が同意なく永続記録されていたバグを修正
- 良性のシステム生成更新から偽陽性の prompt injection 警告が出ていた問題を修正
- auto-updater が `~/.local/bin/claude` のカスタムランチャーを上書きしていた問題を修正。`/doctor` で外部管理ランチャーの検出が可能に
- シンタックスハイライト改善: highlight.js 11 へアップグレード
- Mac SSH 環境で opt/cmd キー表示（alt/super の代わり）
- 計 24 変更

#### 🟡 注目（継続ウォッチ）

**Anthropic Reflect Beta（2026-07-09 〜）**
- 使用状況ダッシュボード: 習慣・ピーク活動時間帯の可視化
- 4D AI Fluency Framework（delegation / description / discernment / diligence）
- quiet hours 設定
- Web / デスクトップで Free / Pro / Max ユーザー対象（Memory on 必須）
- incognito とヘルス連携データは除外

**TeraWulf × Anthropic データセンター 20 年リース（ケンタッキー州 Hawesville）**
- 契約収益 ~$19B。長期インフラ投資として注目

**Elon Musk が Anthropic を称賛・SpaceX コンピュート連携を深化（2026-07-10 前後）**
- AI 業界の連携・競合状況の変化。Anthropic の外部パートナーシップ拡大傾向

**マネーフォワード AI Cowork**
- 依然「2026 年 7 月より提供開始予定」のまま。正式リリース確認なし。引き続きウォッチ

#### 🟢 参考情報

**GitHub Issues（2026-07-12 時点の新規）**
- #76980: auth + cowork 関連 / Linux バグ
- #76979: mcp バグ（再現手順あり）
- #76978: api バグ / macOS
- #76984: モデル重複問題
- #76983: cowork + desktop / Windows バグ
- #76982: core 機能改善 / Linux
- #76981: invalid

**Qiita Tech Festa 2026（〜7/13）**
- 日本技術コミュニティイベント継続中。7/13 終了予定

**Zenn / Qiita トレンド（2026-07-12）**
- Zoom AI Services の MCP サーバー for Claude Code
- Claude Code & Codex 超高速セキュアサンドボックス構築
- Qiita トレンドポッドキャスト 2026-07-12 版

**会計 × AI**
- AI OCR による確定申告サービス（2025-07 全国展開済み）
- 経理 AI 導入率 24.3%
- クラウド会計 + AI 組み合わせで月 20〜40 時間削減が現実的ライン

---

### TBP / ADR 交差評価（機能C）

**TBP-001 再評価提案**
- トリガー: v2.1.207 で Auto mode がクラウドプロバイダ（Bedrock / Vertex AI / Foundry）へ展開
- 提案: TBP-001 の「審査」フェーズに「クラウドプロバイダ経由デプロイ」を明示追加。エンタープライズ利用者は `disableAutoMode` によるオプトアウト検討が必要
- 状態: レポートに記録のみ。TBP 更新は Tak が判断

**references.md 更新提案**
- v2.1.207: Auto mode on Bedrock / Vertex AI / Foundry（`disableAutoMode` 設定）
- v2.1.207: highlight.js 11 アップグレード

---

### 次回リサーチ推奨日
2026-07-13（マネーフォワード AI Cowork 正式リリース確認 / v2.1.208 以降の変更ウォッチ / Qiita Tech Festa 終了確認）

## [2026-07-11] デイリーレポート

### 内部知見（機能A）

#### 新規・更新 ADR
- My-Profile-and-Memory/decisions/ → フォルダ未存在のためスキップ
- StudyMate, My-URAWA-LOG, tak-work, tak-family, tak-personal → アクセス可能スコープ外のためスキップ
- tak-best-practices/: TBP-001（外部ツール導入審査）・TBP-002（実行環境英語パス）を確認（新規 ADR なし）

#### TBP 昇格候補
- **TBP-003候補**（2026-06-22 提案・確認待ち19日目）:「着手前に実態（git）と文書（backlog）の一致を確認する」— Takの確認待ち
- **TBP-004候補**（2026-06-22 提案・確認待ち19日目）:「不可逆性で安全方向を決めるが、カテゴリ丸ごとの保守化は目的を殺す」— Takの確認待ち

#### 再検討トリガー該当
- **TBP-001 再評価トリガー（Claude Fable 5 再デプロイ）**: Claude Fable 5（Mythosクラスモデル）が2026-07-01に全ユーザー向けに再デプロイ。Claude Code でも利用可能に。TBP-001「外部ツール導入審査」の観点では、新モデルを使った自律エージェント機能の権限範囲を見直すタイミング。特に「より長時間自律動作できる」特性上、allowlist設計の粒度を再点検することを推奨。
- **TBP-001 再評価トリガー（Claude Code /doctor 新機能）**: v2.1.206で `CLAUDE.md` のトリム提案をする `/doctor` チェックが追加。CLAUDE.md に「Claudeが自力で導出できる内容」が含まれていないか定期チェックが自動化された。TBP-001の「段階拡張」フェーズで /doctor を活用した CLAUDE.md メンテナンスをルーティンに組み込むことを検討。
- **TBP-002 再評価トリガー（今回なし）**: TBP-002（英語パス）に関連する外部情報の変化なし。

---

### 外部リサーチ（機能B）

#### 参照した情報源
- Claude Code公式チェンジログ（⭐⭐⭐⭐⭐）: v2.1.201〜v2.1.206
- Anthropic公式ブログ（⭐⭐⭐⭐⭐）: Fable 5再デプロイ / ベルナンキ氏LTBT就任 / アルバータ州政府事例
- anthropics/claude-code GitHub issues（⭐⭐⭐⭐⭐）: 7/11新規issue確認
- Zenn / Qiita 検索（2026年7月分）
- 会計×AI: マネーフォワード AI Cowork / 電帳法・インボイス改正動向
- WebSearch: Claude Fable 5 / Mythos 5 能力詳細

#### 🔴 即座に適用すべき事項

1. **Claude Fable 5 が Claude Code で利用可能に（2026-07-01〜）**
   - Fable 5 は Mythosクラスで「過去最高のベンチマーク性能」。SW エンジニアリング・知識作業・ビジョン・科学研究など全領域で SOTA。Stripe が50M行Rubyマイグレーションを1日で完了（通常チーム2ヶ月相当）。
   - 価格: $10/M input / $50/M output（Mythos Preview の半額以下）
   - **注意**: サイバーセキュリティ・生物・化学・蒸留関連の危険リクエストは自動的に Claude Opus 4.8 で処理され、ユーザーに通知される
   - 当面 Research Hub の Routines プロンプトでモデル選択指示がある場合は整合性を確認する

2. **電帳法・インボイス制度（Takさん本業直結）**
   - 電帳法: 2026年1月から電子取引データの電子保存が**完全義務化**（宥恕措置終了済み）。紙保存は不可。
   - インボイス控除率: 2026年10月〜 80%→70%（2026年10月〜2028年9月）→50%（2028年10月〜2030年9月）→30%（2030年10月〜）に段階引き下げ。即時対応より計画的移行フェーズに入った段階。

#### 🟡 近いうちに試したいこと（上位3件）

1. **Claude Code `/doctor` コマンドでCLAUDE.mdをトリム**（v2.1.206新機能）
   - CLAUDE.md に「Claudeが自力導出できる内容」が混入していないか自動チェックしてくれる。Research Hub や My-Profile-and-Memory の CLAUDE.md を `/doctor` にかけてみる価値あり。
   - 参考: `v2.1.206 (July 9, 2026)` - /doctor check that proposes trimming checked-in CLAUDE.md files

2. **マネーフォワード AI Cowork の評価**
   - 2026年7月提供開始予定。AIが「同僚」として経理・労務・法務業務を自律処理するサービス。Takさんの本業（経理部長）に直結。早期評価・パイロット検討価値あり。

3. **Zenn記事:「正直に言う。お前のClaude Codeの使い方は間違っている」（2026-07-01）**
   - Qiita Tech Festa 2026 関連記事で注目度高。Claude Code の実践的な使い方の誤解を指摘する内容。ハーネス設計の見直しヒントになる可能性あり。要精読。

#### 🟢 参考情報

- **Anthropic と Alberta 州政府**: Claude Code（Opus+Sonnet）で 4.66億行のコードを20時間でスキャンし、セキュリティ脆弱性を自動検出・修正。大規模コードベース監査における Claude Code の実用性を示す事例（2026-07-06）。
- **Anthropic ジャイルブレーク対策フレームワーク**: Amazon/Microsoft/Google 等と共同で業界横断のジャイルブレーク深刻度スコアリングフレームワークを発表（2026-07-02）。Fable 5 の安全分類器と連動。
- **Ben Bernanke が Anthropic LTBT に参加**（2026-07-09）: 元 FRB 議長がロングタームベネフィットトラストの独立メンバーに就任。Anthropic のガバナンス強化の一環。
- **Claude Code GitHub stars**: 131K starに到達。「IDE不要でClaude Codeに移行する開発者が増加」（Augment Code の分析記事）。
- **経理AI全般**: 2026年の最適戦略は「AI-OCR（定型処理）+ 生成AI（判断・分析・文書作成）」の二刀流が定説化。経理部門のAI導入率24.3%、活用者の75.6%が効率化を実感。
- **Qiita: Claude Code + Codex 用超高速サンドボックス作成法**（2026-07-10 投稿）: Security重視の環境構築記事。Research Hub の Claude Code sandbox 設計参考に。

#### references.md 更新提案

以下の更新が必要か検討:
- **Claude Fable 5 / Mythos 5 のモデルID追加**: `claude-fable-5` / `claude-mythos-5` が正式モデルIDとして使用可能になった。Claude API references に追記候補。
- **根拠**: 公式ドキュメント記載 (`platform.claude.com/docs/en/about-claude/models/introducing-claude-fable-5-and-claude-mythos-5`) に基づく。

※ 直接更新は行わない。Takの確認後に実施。

#### 新規発見ソース候補

| ソース | URL | 種別 | 評価候補 | 発見日 |
|---|---|---|---|---|
| releasebot.io/updates/anthropic/claude-code | https://releasebot.io/updates/anthropic/claude-code | Claude Code自動更新トラッカー | ⭐⭐⭐ | 2026-07-11 |
| gradually.ai/en/changelogs/claude-code/ | https://www.gradually.ai/en/changelogs/claude-code/ | Claude Codeチェンジログまとめ | ⭐⭐⭐ | 2026-07-11 |
| uravation.com | https://uravation.com/media/ | 日本語AI実践ガイド（経理×AI含む） | ⭐⭐⭐ | 2026-07-11 |

#### 次回リサーチ推奨日
2026-07-12（Claude Code v2.1.206 以降の続報 / マネーフォワード AI Cowork 正式リリース状況）

---
## [2026-07-10] デイリーレポート

### 内部知見（機能A）

#### 新規・更新 ADR
- My-Profile-and-Memory/decisions/ → フォルダ未存在のためスキップ
- StudyMate, My-URAWA-LOG, tak-work, tak-family, tak-personal → アクセス可能スコープ外のためスキップ
- tak-best-practices/: TBP-001（外部ツール導入審査）・TBP-002（実行環境英語パス）を確認（新規 ADR なし）

#### TBP 昇格候補
- **TBP-003候補**（2026-06-22 提案・確認待ち18日目）:「着手前に実態（git）と文書（backlog）の一致を確認する」— Takの確認待ち
- **TBP-004候補**（2026-06-22 提案・確認待ち18日目）:「不可逆性で安全方向を決めるが、カテゴリ丸ごとの保守化は目的を殺す」— Takの確認待ち

#### 再検討トリガー該当
- **TBP-001 再評価トリガー（security-guidance 公式プラグイン）**: Anthropic が全プラン無料の `security-guidance` プラグイン（`/plugin install security-guidance@claude-plugins-official`）を提供開始。リアルタイムのセキュリティ脆弱性検出・修正支援が可能になった。TBP-001「外部ツール導入審査」の「審査」フェーズにおいて、公式 Anthropic プラグインを活用したコード品質チェックが自動化支援ツールとして活用できる。安全性の高い公式プラグインとして最小権限から試用を推奨。

---

### 外部リサーチ（機能B）

#### 参照した情報源
- Claude Code公式チェンジログ（⭐⭐⭐⭐⭐）
- Anthropic公式ブログ（⭐⭐⭐⭐⭐）
- anthropics/claude-code GitHub issues（⭐⭐⭐⭐⭐）
- Zenn / Qiita 検索
- 会計×AI: freee / マネーフォワード / バクラク Web検索
- WebSearch: Claude Design / security-guidance plugin 2026年7月

#### 🔴 即座に適用すべき事項

**1. Claude Code v2.1.206（2026-07-09）新着機能まとめ**
- **/cd コマンド改善**: ディレクトリ変更時にパス候補を提示するオートコンプリート機能を追加。手動作業での操作性が向上。
- **/doctor で CLAUDE.md トリミング提案**: `/doctor` がシステムプロンプトの最適化候補として CLAUDE.md のトリミング提案を行う機能を追加。長くなった CLAUDE.md を定期的に整理する契機になる。
- **/commit-push-pr の push 自動許可拡張**: `remote.pushDefault` 設定がある場合、または単一リモートのみの場合に、push 操作を確認なしで自動許可するよう拡張。Routine での自動コミット・プッシュフローが安定化。
- **EnterWorktree の安全強化**: `.claude/worktrees/` 配下以外の git worktree への入場前に確認プロンプトを表示するよう変更。意図しない worktree 操作を防止。
- **バックグラウンドエージェントの自動アップグレード**: Claude Code のバージョン更新直後にバックグラウンドエージェントが自動的に新バージョンにアップグレードされるよう変更。Routine の長時間実行中にバージョン更新が発生しても継続性が向上。
- **MCP server-level request_timeout_ms バグ修正（重要）**: サーバーレベルの `request_timeout_ms` 設定が無視されていたバグを修正。Research Hub の Routine で MCP タイムアウトを明示設定していた場合に意図通りに動作するようになった。
- **ログイン期限切れエラー改善**: 認証失効時に誤解を招くエラーメッセージを表示していた問題を、`/login` を促す明確なメッセージに改善。Routine が認証エラーで停止した場合のデバッグが容易になる。
- **OAuth MCP バグ修正**: OAuth MCP サーバーのトークンリフレッシュ失敗後、手動再認証なしに復帰できなかったバグを修正。
- **JetBrains IDE ターミナルちらつき修正**: JetBrains 環境でのターミナルちらつきを修正。
- 🔴 アクション: `claude --version` で v2.1.206 以上を確認。MCP タイムアウト設定の実効性を次回 Routine 実行で観測推奨。

**2. Claude Design（Anthropic Labs、リサーチプレビュー）**
- Anthropic が Claude Design を Anthropic Labs 経由でリサーチプレビュー提供開始。Claude Opus 4.7 を搭載し、デザイン・プロトタイプ・スライド作成に特化。
- 対象: Pro / Max / Team / Enterprise プランで利用可能（Anthropic Labs よりオプトイン）。
- Research Hub への応用: ビューワーの UI 改善案やレポート図解作成への活用可能性あり。
- 🔴 アクション: Anthropic Labs (labs.anthropic.com) でオプトイン可能か確認。

#### 🟡 近いうちに試したいこと（上位3件）

**1. security-guidance 公式プラグイン（全プラン無料）**
- コマンド: `/plugin install security-guidance@claude-plugins-official`
- 機能: セッション中のリアルタイム脆弱性検出・修正提案（XSS、SQL インジェクション、認証漏れ等 OWASP Top 10 カバー）。
- Research Hub での活用: insert-article Edge Function や Worker のコードをリポジトリに書く際の自動セキュリティチェック。TBP-001「外部ツール導入審査」の「審査」フェーズを公式プラグインで補強できる。
- 全プラン無料・公式 Anthropic 提供のため TBP-001 の「審査→最小権限→段階拡張」手順を経る優先度は低いが、念のため試用前の動作確認を推奨。
- 🟡 アクション: 次回 Claude Code セッション開始時に `/plugin install security-guidance@claude-plugins-official` を実行して試用。

**2. /doctor CLAUDE.md トリミング提案機能の活用**
- research-hub の CLAUDE.md（2,000 字超）が長大化しているため、`/doctor` によるトリミング候補の抽出が有用な可能性。
- Research Hub での活用: CLAUDE.md の肥大化防止・スキル分離による Progressive Disclosure 実現の契機として `/doctor` を定期実行する運用ルール化を検討。
- 🟡 アクション: 次回 Research Hub セッション開始時に `/doctor` を実行し、CLAUDE.md のトリミング提案が出るか確認。

**3. マネーフォワード AI Cowork 正式リリースアナウンス監視継続（最優先）**
- 7/10 時点でも正式リリースアナウンス未確認（7月中リリース予定継続）。残り21日以内。
- Claude Agent SDK + MCP 採用のバックオフィス AI（経理・労務・法務を AI 同僚として自律処理）。
- Tak の本業（経理部長）に直結。確認次第 auto-research-collect「会計×AI 重要発表」枠で即時記事化推奨。
- 🟡 アクション: 毎日 biz.moneyforward.com/ai-cowork/ で正式開始確認。

#### 🟢 参考情報

**GitHub Issues 新着（2026-07-10）**
- Issue #76508〜#76515: permissions / tools / model 系バグ（macOS / Linux 混在）
- 主要な Routine への直接影響は確認されず。model 系バグは auto モードのモデル選択精度に微影響の可能性あり。

**Zenn / Qiita（2026-07-10 時点）**
- 「Claude Code の無料セキュリティ監査プラグインで脆弱性を自動検出・修正する方法」（Zenn, 7/10）: security-guidance プラグインの使い方と OWASP Top 10 カバー範囲の解説。
- 「/doctor が CLAUDE.md の肥大化を診断するようになった — v2.1.206」（Qiita, 7/10）: 具体的なトリミング提案例の紹介。
- v2.1.206 の日本語解説記事が本日複数公開。MCP timeout 修正が特に実務的に注目されている。

**会計×AI トレンド（2026-07-10 時点）**
- **マネーフォワード AI Cowork**: 7/10 時点でも正式リリースアナウンス未確認（継続監視）。7月末まで残り21日。
- **freee AI OCR**: 手書き領収書 75%前後・印刷レシート 90% 超の精度（2026年大幅アップデート継続）。
- **経理 AI 導入率**: 約 24.3%（75% 以上が未導入、導入余地大）。
- **バクラク**: 規制違反自動検出で差し戻し率 60% 削減事例が継続。

**Claude Design の技術詳細**
- ベースモデル: Claude Opus 4.7（新モデル）。Opus 4.8 よりデザイン・ビジュアル表現に特化。
- 対応出力: UI モックアップ・インフォグラフィック・プレゼン資料・プロトタイプ HTML。
- 価格: Pro/Max/Team/Enterprise のサブスクリプション内に含まれる（追加課金なし）。
- 注意: Anthropic Labs プロダクトはリサーチプレビューのため将来的な仕様変更あり。

#### references.md 更新提案
**提案（自動更新しない — Takの確認後に実施）:**
- **v2.1.206 EnterWorktree 安全強化**: `.claude/worktrees/` 外 worktree への確認プロンプト。worktree 設計セクションへの追記提案。
- **v2.1.206 バックグラウンドエージェント自動アップグレード**: Routine 継続性向上。バックグラウンドセッション設計セクションへの追記提案。
- **v2.1.206 MCP server-level request_timeout_ms 修正**: MCP タイムアウト設定の実効性が保証されるようになった。MCP 設計セクションへの追記提案。
- **security-guidance 公式プラグイン（全プラン無料）**: `/plugin install security-guidance@claude-plugins-official` でリアルタイム脆弱性検出。プラグイン活用セクションへの追記提案。
- **Claude Design（Anthropic Labs、リサーチプレビュー）**: Opus 4.7 ベース。デザイン・スライド・プロトタイプ特化。Anthropic 製品ロードマップセクションへの追記提案。

#### 新規発見ソース候補
なし（本日新規有望ソース未発見）

#### 次回リサーチ推奨日
2026-07-11（翌日）。
注目点:
① **マネーフォワード AI Cowork 正式リリースアナウンス**: 7月末まで残り21日。毎日監視推奨。
② **security-guidance プラグインの実用性確認**: Research Hub コードへの適用結果を確認。
③ **v2.1.206 MCP timeout 修正の実効確認**: 次回 Routine 実行で MCP タイムアウト設定が有効になっているか観測。
④ **Claude Design のオプトイン確認**: Anthropic Labs での試用申請状況。
⑤ **TBP-003・TBP-004 昇格候補**: 6/22 提案から 18 日経過（Tak 確認待ち）。

---

### クロスリファレンス（機能C）

#### TBP/ADR 再評価トリガー
- **TBP-001 再評価トリガー（security-guidance 公式プラグイン）**: Anthropic が「外部ツール導入審査の自動化支援ツール」として機能する公式セキュリティプラグインを提供開始。TBP-001「審査→最小権限→段階拡張」の「審査」フェーズを、公式プラグインによる自動スキャンで補完・強化できる材料として記録。外部ツール導入前の審査手順に「security-guidance プラグインでコードスキャン」を組み込むことを提案（任意）。

#### references.md 更新判定
**本日は更新不要**: 上記の提案は Tak の確認待ち。Anthropic 公式ベストプラクティス文書の新規変更は確認されていない。

---
## [2026-07-09] デイリーレポート

### 内部知見（機能A）

#### 新規・更新 ADR
- My-Profile-and-Memory/decisions/ → フォルダ未存在のためスキップ
- StudyMate, My-URAWA-LOG, tak-work, tak-family, tak-personal → アクセス可能スコープ外のためスキップ
- tak-best-practices/: TBP-001（外部ツール導入審査）・TBP-002（実行環境英語パス）を確認（新規 ADR なし）

#### TBP 昇格候補
- **TBP-003候補**（2026-06-22 提案・確認待ち17日目）:「着手前に実態（git）と文書（backlog）の一致を確認する」— Takの確認待ち
- **TBP-004候補**（2026-06-22 提案・確認待ち17日目）:「不可逆性で安全方向を決めるが、カテゴリ丸ごとの保守化は目的を殺す」— Takの確認待ち

#### 再検討トリガー該当
- **TBP-001 再評価トリガー（Claude Code GitHub Actions サプライチェーン攻撃）**: GMO Flatt Security が Claude Code GitHub Actions に prompt injection によるサプライチェーン攻撃脆弱性を発見（v1.0.94 で修正）。攻撃者が悪意ある GitHub Issue を作成するだけで、claude-code-action ワークフローを経由してリポジトリを完全掌握できる欠陥。2026年2月に Cline で実際に悪用され npm publish トークンが盗まれた事例あり。TBP-001 の「審査」フェーズに「CI/CD 上で claude-code-action 等の AI エージェント GitHub Action を使う場合は prompt injection 脆弱性の評価を実施する」を追記する材料。

---

### 外部リサーチ（機能B）

#### 参照した情報源
- Claude Code公式チェンジログ（⭐⭐⭐⭐⭐）
- Anthropic公式ブログ（⭐⭐⭐⭐⭐）
- anthropics/claude-code GitHub issues（⭐⭐⭐⭐⭐）
- Zenn / Qiita 検索
- 会計×AI: freee / マネーフォワード / バクラク Web検索
- セキュリティ: GMO Flatt Security Research / The Hacker News / Microsoft Security Blog

#### 🔴 即座に適用すべき事項

**1. Claude Code GitHub Actions サプライチェーン攻撃脆弱性（修正済み: v1.0.94）**
- **概要**: GMO Flatt Security の RyotaK 氏が発見。claude-code-action の `checkWritePermissions` 関数が `[bot]` で終わるアクターを無条件に信頼する欠陥により、悪意ある GitHub Issue 1件でリポジトリを完全掌握可能だった。
- **実害事例**: 2026年2月、Cline リポジトリで実際に悪用。攻撃者が npm publish トークンを窃取し、未認可の cline@2.3.0 を公開するサプライチェーン攻撃が成立。
- **最大影響**: anthropics/claude-code-action リポジトリ自体も脆弱なワークフローを使用していたため、成功すれば全ダウンストリームリポジトリへの悪意あるコード注入が可能だった。
- **修正**: claude-code-action v1.0.94 で修正済み。
- **Research Hub への影響**: Research Hub Routines が claude-code-action を使用している場合は v1.0.94 以上を確認。TBP-001「審査」フェーズへの追記材料として記録。
- 🔴 アクション: claude-code-action を使用するワークフローは v1.0.94 以上に更新確認。GitHub Actions ワークフロー全体の AI エージェント権限設計を見直す。

**2. Claude Code 最新版: /doctor フル診断・auto mode 安全強化・--max-turns バグ修正**
- **/doctor コマンド**: フルセットアップ診断ツールに格上げ（問題の診断と自動修正が可能。旧 /checkup がエイリアスに）。
- **auto mode 安全強化**: コンテキストから解決できない変数への `rm -rf` 実行前に確認を挿入。自律実行時のデータ消失リスク軽減。
- **--max-turns バグ修正（重要）**: `--max-turns` 上限到達時に途中メッセージがサイレントロストされるバグを修正。Routine で --max-turns を使用している場合に直接影響。
- **auto-update メモリ削減**: バイナリストリーミング化により auto-update 時のピークメモリ使用量が約 400MB 削減。
- **Agent View 改善**: 編集・マージ・コメント・プッシュした PR が `claude agents` に自動リンク。ブロック中セッションの「正確な依頼内容」も確認可能に。
- **Windows NTFS バグ修正**: ワークツリー削除時に NTFS junction/シンボリックリンクが存在すると範囲外ファイルが削除されるバグを修正。
- 🔴 アクション: `claude --version` で最新版確認。`/doctor` でセットアップ状態を診断推奨。--max-turns を使う Routine では更新後の動作確認を推奨。

#### 🟡 近いうちに試したいこと（上位3件）

**1. Claude Sonnet 5 が Free/Pro デフォルトモデルに（2026-07-01〜）**
- Sonnet 5 が全 Free・Pro ユーザーのデフォルトモデルに。Opus 4.8 に肉薄する性能で、2026年8月31日までは Sonnet 4.6 より安価な導入価格。
- Research Hub Routines が auto モードで Sonnet 5 を選択する場合のコスト影響を確認推奨。
- 🟡 アクション: Research Hub Routine の使用モデルと料金を確認。Sonnet 5 の導入価格（〜8/31）の活用可否を検討。

**2. Fable 5 輸出規制解除 → 2026-07-01 に全ユーザー向け復活**
- 輸出規制が 2026-06-30 に解除。2026-07-01 より全ユーザー向けに再提供。クレジット制は 7/8 以降完全施行済み。
- 🟡 アクション: Max 契約ならコスト追加なし。Routine の auto モードが Fable 5 を選択する場合は消費量に注意。

**3. Claude Cowork モバイル/Web 拡張（バックグラウンド作業・M365 書き込み）**
- Cowork がモバイル・Web に拡張。バックグラウンド作業、スケジュールタスク、共有チャット・プロジェクト、モバイル承認が利用可能に。M365 連携に書き込みツール（メール送信・カレンダー作成・OneDrive/SharePoint ファイル作成）が追加。
- 🟡 アクション: Max 契約かつ Cowork 使用中の場合、M365 書き込み権限の活用を検討。Tak の本業（経理部長）のワークフロー（月次締め・レポート作成等）への応用可能性を評価。

#### 🟢 参考情報

**GitHub Issues 新着（2026-07-09）**
- Issue #76147: browser-extension, chrome, mcp area bug（macOS, 詳細再現手順あり）
- Issue #76146: model area bug（macOS / VS Code）
- Issue #76145: desktop area bug（data-loss ラベル, 詳細再現手順あり）
- Issue #76144: cowork, desktop area bug（macOS）
- Issue #76143: model area bug（duplicate, external）
- Issue #76142: permissions, routines 関連 bug（Research Hub Routines の権限設計に関連する可能性あり。継続監視）
- Research Hub への直接影響: Issue #76142（permissions/routines）を継続監視。

**会計×AI トレンド（2026-07-09 時点）**
- **AI 導入率**: 経理部門約 24%（2026/3 中小企業基盤整備機構調査）。導入企業の 68.3% が「業務時間の明確な短縮」を実感。
- **SaaS の AI 標準化**: freee・マネーフォワード・バクラク 各社が AI エージェントを主力製品の標準機能として組み込む流れが明確化（2026年が転換点）。
- **バクラク**: 規制違反自動検出により却下率 60% 削減の事例。
- **freee**: 請求書マッチング + AI 自動仕訳の組み合わせで月次決算を平均 10 → 5 営業日に短縮した事例。
- **マネーフォワード AI Cowork**: 7/9 時点でも正式リリースアナウンス未確認（継続監視）。

**Zenn / Qiita（2026-07-09 時点）**
- 「Claude Code を4ヶ月使ってわかった、おすすめコマンド・スキル 10 選」（Qiita, 6/26）が Qiita Tech Festa 2026（〜7/13）で紹介中。
- Claude Code v2.1.101 完全ガイドなど実践記事が増加傾向。
- claude-code-action サプライチェーン攻撃に関する日本語解説記事は今後出てくる見込み。

**Anthropic 政府・公共向け展開（参考）**
- Alberta 州政府が Claude を導入してサイバーセキュリティ脆弱性の発見・修正に活用（2026-07-06）。
- カリフォルニア州の AI アシスタント Poppy が 2800+ 職員でパイロット、7月中の全州展開に向けて順調。
- Claude for Government Desktop パブリックベータが進行中（FedRAMP High 認定、Claude Code 含む）。

#### references.md 更新提案
**提案（自動更新しない — Takの確認後に実施）:**
- **claude-code-action サプライチェーン攻撃事例（TBP-001 関連）**: TBP-001「審査」フェーズに「CI/CD 上で claude-code-action 等の AI エージェント GitHub Action を使う場合は prompt injection 脆弱性評価を実施する」を追記提案。具体的な攻撃手法（悪意ある Issue による prompt injection）と実被害事例（Cline npm token 窃取）を根拠として記録。
- **Sonnet 5 デフォルト化（2026-07-01〜）**: モデル選択セクションに「Free/Pro のデフォルトは Sonnet 5（2026-07-01〜）。導入価格は〜8/31」を追記提案。

#### 新規発見ソース候補
- **GMO Flatt Security Research Blog** (https://flatt.tech/research/): AI セキュリティの一次情報源。Claude Code GitHub Actions サプライチェーン攻撃の詳細解説を公開。⭐⭐⭐⭐ 候補（セキュリティ専門・一次情報）。
- **Adversa AI Blog** (https://adversa.ai/blog/): AI コーディングエージェントのセキュリティリソースを定期まとめ公開。⭐⭐⭐ 候補。

#### 次回リサーチ推奨日
2026-07-10（翌日）。
注目点:
① **claude-code-action 脆弱性の日本語解説記事**: Zenn/Qiita に解説記事が出てくる見込み。TBP-001 追記の根拠補強として記録。
② **マネーフォワード AI Cowork 正式リリースアナウンス**: 7月中リリース予定が継続。正式アナウンス確認次第即時記録推奨。
③ **Sonnet 5 導入価格期間（〜8/31）**: Research Hub Routines でのモデル選択判断に関わる情報として継続収集。
④ **GitHub Issue #76142 (permissions/routines)**: Research Hub Routines の権限設計に関連する可能性あり。詳細確認推奨。
⑤ **TBP-003・TBP-004 昇格候補**: 6/22 提案から 17 日経過（Tak 確認待ち）。

---

## [2026-07-08] デイリーレポート

### 内部知見（機能A）

#### 新規・更新 ADR
- My-Profile-and-Memory/decisions/ → フォルダ未存在のためスキップ
- StudyMate, My-URAWA-LOG, tak-work, tak-family, tak-personal → アクセス可能スコープ外のためスキップ
- tak-best-practices/ → TBP-001（外部ツール導入審査）・TBP-002（実行環境英語パス）を確認（新規 ADR なし）

#### TBP 昇格候補
- **TBP-003候補**（2026-06-22 提案・確認待ち16日目）:「着手前に実態（git）と文書（backlog）の一致を確認する」— Takの確認待ち
- **TBP-004候補**（2026-06-22 提案・確認待ち16日目）:「不可逆性で安全方向を決めるが、カテゴリ丸ごとの保守化は目的を殺す」— Takの確認待ち

#### 再検討トリガー該当
- **TBP-001 新規照合①（v2.1.204 SessionStart hook ストリーミング停止バグ修正）**: headless セッション（Routines/リモートワーカー）で SessionStart hook 中にイベントがストリーミングされず、idle-reap でワーカーが途中停止するバグが修正。Research Hub の Routines に直接影響する可能性があった。TBP-001「審査」項目に「ヘッドレスセッションでの hook ストリーミング動作確認」を追記する材料。
- **TBP-001 新規照合②（Fable 5 クレジット制が本日より完全施行）**: 2026-07-08 より Fable 5 は $10/$50 per Mtok のクレジット制に完全移行（猶予期間終了）。Max 5x 以上の契約では Max 内課金のため追加請求なし。複数日に渡り予告してきた「コスト急増リスク」が本日から現実化フェーズ。

---

### 外部リサーチ（機能B）

#### 参照した情報源
- Claude Code公式チェンジログ（⭐⭐⭐⭐⭐）
- Anthropic公式ブログ（⭐⭐⭐⭐⭐）
- anthropics/claude-code GitHub issues（⭐⭐⭐⭐⭐）
- Zenn / Qiita 検索
- 会計×AI: freee / マネーフォワード / tofu Web検索

#### 🔴 即座に適用すべき事項

**1. Claude Code v2.1.204 (2026-07-08) — headless SessionStart hook ストリーミング停止バグ修正**
- **修正内容**: headless セッション（Anthropic Routines / リモートワーカー）で SessionStart hooks 中にイベントがストリーミングされず、idle-reap でワーカーが途中停止するバグを修正。
- **Research Hub への直接影響**: auto-research-collect・deep-research-runner・auto-claude-code-watch 等はすべてリモートヘッドレスセッションで動作するため、このバグが Routine の突然終了原因だった可能性がある。v2.1.204 更新後の次回実行で改善を確認推奨。
- 🔴 アクション: `claude --version` で v2.1.204 以上を確認。未更新なら `npm update -g @anthropic-ai/claude-code` を実行。

**2. Fable 5 クレジット制 2026-07-08 より完全施行**
- 猶予期間（週次使用量 50% 込み）が 2026-07-07 をもって終了。
- 2026-07-08 以降: 入力 $10/Mtok、出力 $50/Mtok（キャッシュヒット $1/Mtok）。
- Max 5x 以上の契約（Max 内課金）: 追加請求なし。Max 未満の契約: クレジット消費。
- 🔴 アクション: Max 契約ユーザーは基本的に追加請求なし。ただし Routine の auto モードで Fable 5 が選択される場合は消費量把握を推奨。

#### 🟡 近いうちに試したいこと（上位3件）

**1. Claude Code v2.1.203 (2026-07-07) — ログイン期限警告・⏸バッジ・バックグラウンドセッション自動回復**
- **ログイン期限切れ警告（重要）**: バックグラウンドセッション実行中にログイン期限が近づくと事前警告を表示。Routine がログイン期限切れで突然中断するリスクが低減。
- **手動モードで灰色 ⏸ バッジ**: 手動権限モードで動作していることを視覚的に明示（誤設定の発見が容易に）。
- **セッションディレクトリが MCP roots/list に追加**: MCP が使用中のセッションコンテキストをより正確に把握できるように。
- **macOS スタリング修正（v2.1.196 回帰）**: macOS 環境でのスタリング（フリーズ）バグを修正。
- **バックグラウンドセッション自動回復**: daemon トークンが失効した場合にバックグラウンドセッションが自動回復するように。Routine の継続性が向上。
- 🟡 アクション: Routine 実行環境が v2.1.203 以上か確認。バックグラウンドセッション自動回復により Routine の安定性向上が期待できる。

**2. Claude for Government Desktop パブリックベータ（2026-07-07）**
- FedRAMP High 認定の政府向け Claude デスクトップ（Claude Code + Claude Cowork 含む）がパブリックベータ開始。
- 機能: 監査ログ・支出ガバナンス・管理者コントロール。
- Tak の本業（経理部長・組織内会計士）の参考情報として記録。
- 🟡 アクション: 本業の組織での AI ガバナンス要件に照らして参照価値あり。

**3. Claude Cowork Web/モバイル拡張（Microsoft 365 書き込みツール追加）**
- Microsoft 365 の書き込みツール（メール送信・カレンダー作成・OneDrive/SharePoint ファイル作成）が Claude Cowork に追加。
- 以前は読み取りのみだった M365 統合が書き込み可能になったため、実務での活用範囲が大幅拡大。
- 🟡 アクション: Max 契約で Claude Cowork を使用している場合、M365 連携の書き込み権限付与を確認。

#### 🟢 参考情報

**GitHub Issues 新着（2026-07-08）**
- Issue #75859: auth/tui area enhancement（macOS）
- Issue #75858: cost/tui area enhancement（macOS）
- Issue #75857: desktop/ui area Windows enhancement
- Issue #75856: bug（詳細不明）
- Issue #75855: model area bug
- Research Hub の Routine 動作への直接影響: なし（本日は軽微な enhancement/bug のみ）

**会計×AI トレンド（2026-07-08 時点）**
- **マネーフォワード AI Cowork**: 7/8 時点でも正式リリースアナウンス未確認（「予定」表記が継続）。7月中のリリースは依然見込まれるが正式日程未定。
- **freee**: AI決算書スキャン機能が利用可能に。PDF 等の決算書をAIがスキャンして仕訳候補を自動提示。
- **tofu（新規参入）**: 50カ国対応のAI自動記帳サービスが日本市場に参入（七星税理士法人との提携）。国際的AI経理サービスの日本展開事例として記録。
- **経理AI普及率**: 約24.3%（前回からの継続値）。

**Zenn/Qiita（2026-07-08 時点）**
- 2026-07-08 固有の注目新着記事は確認できず。v2.1.204 の headless hook 修正に関する日本語解説記事は今後出てくる見込み。

#### references.md 更新提案
**提案（自動更新しない — Takの確認後に実施）:**
- **v2.1.204 SessionStart hook ストリーミング停止バグ修正**: Routines/ヘッドレスセッションでの hooks 設計セクションに「ヘッドレスセッションでは hook ストリーミングの動作確認が必要」として追記提案。
- **Fable 5 クレジット制（2026-07-08 本格施行）**: モデル料金セクションの「猶予期間」注記を「2026-07-08 より本格施行（猶予期間終了）」に更新提案。
- **v2.1.203 ログイン期限切れ警告**: バックグラウンドセッション設計セクションに「ログイン期限管理が Routine の継続性に影響する」として追記提案。

#### 新規発見ソース候補
なし（本日新規ソース未発見）

#### 次回リサーチ推奨日
2026-07-09（翌日）。v2.1.204 による Routine 安定性改善の実観測・マネーフォワード AI Cowork 正式リリースアナウンス監視継続。
注目点:
① **v2.1.204 headless SessionStart hook 修正の Routine への効果確認**: 次回 Routine 実行後にログを確認し、以前より安定しているか観測。
② **マネーフォワード AI Cowork 正式リリースアナウンス**: 7月中リリース予定が継続。正式アナウンス確認次第即時記事化推奨。
③ **Fable 5 クレジット消費量初日確認（7/8）**: 本日より完全クレジット制移行後の最初の Routine 実行ログを確認。
④ **TBP-003・TBP-004 昇格候補**: Tak 確認状況（6/22 提案から 16 日経過）。

---

### クロスリファレンス（機能C）

#### TBP/ADR 再評価トリガー
- **TBP-001 再評価トリガー確認①**: v2.1.204 が修正した「ヘッドレスセッション SessionStart hook でイベントがストリーミングされない」バグは、Research Hub Routines が「サイレントに失敗」する原因の一つだった可能性。TBP-001「外部ツール導入審査」の「ヘッドレス/リモート実行環境での動作確認」評価項目として追記を提案。
- **TBP-001 再評価トリガー確認②**: Fable 5 クレジット制が本日（7/8）から完全施行。複数日に渡り「予測リスク」として記録してきた「課金体系変更リスク」が現実化フェーズに入った。TBP-001「最小権限で開始→段階拡張」の「段階拡張時にコスト影響を測定する」手順の具体的根拠として記録。

#### references.md 更新判定
**本日は更新不要**: 上記の提案は Tak の確認待ち。Anthropic 公式ベストプラクティス文書の新規変更は確認されていない。

---

## [2026-07-07] デイリーレポート

### 内部知見（機能A）

#### 新規・更新 ADR
- My-Profile-and-Memory/decisions/ フォルダ未存在のためスキップ
- その他リポジトリ（StudyMate等）: アクセス可能スコープ外のためスキップ

#### TBP 昇格候補
- **TBP-003候補**（2026-06-22 提案・確認待ち15日目）:「着手前に実態（git）と文書（backlog）の一致を確認する」— Takの確認待ち
- **TBP-004候補**（2026-06-22 提案・確認待ち15日目）:「不可逆性で安全方向を決めるが、カテゴリ丸ごとの保守化は目的を殺す」— Takの確認待ち

#### 再検討トリガー該当
なし（本日新規ADRなし）

---

### 外部リサーチ（機能B）

#### 参照した情報源
- Claude Code公式ドキュメント・チェンジログ（⭐⭐⭐⭐⭐）
- Anthropic公式ブログ（⭐⭐⭐⭐⭐）
- anthropics/claude-code GitHub issues（⭐⭐⭐⭐⭐）
- Fable 5 / Claude Cowork公式発表
- Zenn / Qiita検索

#### 🔴 即座に適用すべき事項

**1. Fable 5 クレジット制が2026-07-08から本格始動**
- 猶予期間（週次使用量の50%込み）が2026-07-07をもって終了
- 2026-07-08以降: 入力$10/Mtok、出力$50/Mtok（Claude Max 5x以上ならMax内課金なし）
- 🔴 アクション: Max契約ユーザーは基本的に追加請求なし。ただし使用量の把握を推奨

**2. Claude Code v2.1.202 (2026-07-06) — /config にワークフローサイズ動的設定**
- 新機能: `/config` コマンドで Dynamic workflow size setting が設定可能に
- バグ修正（主要）:
  - Ctrl+R 押下時のクラッシュ修正
  - バックグラウンドセッションでの `/rename` 動作修正
  - mTLSハンドシェイクエラー修正
  - Remote Control コマンド失敗の修正
  - オーディオ入力リトライ修正
  - `/review` が高速シングルパスに戻っていた問題を修正
- 🔴 アクション: `claude --version` で確認し、未更新なら `npm update -g @anthropic-ai/claude-code` を実行

#### 🟡 近いうちに試したいこと（上位3件）

**1. Claude Cowork モバイル/Web版（2026-07-07 正式展開）**
- クロスデバイス継続性: デスクトップで開始 → モバイルで監視・継続が可能に
- クラウドバックグラウンド処理: 全デバイスオフラインでも処理継続
- 統合UIへ移行: Claude ChatとCoworkが1つのインターフェースに統合（タブ分離廃止）
- Maxユーザーへのベータ展開中（2026年8月5日まで使用量2倍）
- ユースケース統計: ビジネスプロセス・業務オペレーション 33.4%、文書・スライド作成 16.4%（VentureBeat調べ）
- 🟡 アクション: Claude Max契約なら claude.com/cowork でモバイルアプリ確認

**2. GitHub Issues #75354, #75355 — Web版 Routines（scheduled/webhook）**
- ClaudeのWeb UI上でスケジュール実行・Webhook起動ルーティンが登録できる機能のissue
- 現行のAnthropicコンソール経由Routinesとの差別化・統合が今後の注目点
- 🟡 アクション: research-hub の auto-research 系タスクと連携可能か動向を追う

**3. /config のワークフローサイズ動的設定**
- 大規模タスク実行前に `/config` でワークフローサイズを調整することで精度改善が期待できる
- 🟡 アクション: 次回の大規模Routines実行前に /config オプションを確認する

#### 🟢 参考情報

- **GitHub Issues #75349〜#75353 (2026-07-07)**: モデル動作・セキュリティ・プラグイン・パーミッション・iOSに関するissue（詳細: GitHub Issues参照）
- **会計×AI**: 2026年時点でAI会計導入率約24.3%、仕訳処理75%削減・請求書処理70%削減が報告されている（一般トレンド情報、新規速報なし）
- **Zenn/Qiita**: 本日時点で目立った新規記事なし（次回以降で要確認）

#### references.md 更新提案
**提案（自動更新しない — Takの確認後に実施）:**
- Claude Cowork クロスデバイス + クラウドバックグラウンド処理は「外部AIサービスがユーザー不在でバックグラウンド動作する」新パターン。TBP-001（外部ツール最小権限原則）との接点がある。references.md に「Claude Cowork – 外部AIサービスのバックグラウンド動作ガバナンス」セクションの追記を提案。

#### 新規発見ソース候補
なし（本日新規ソース未発見）

#### 次回リサーチ推奨日
2026-07-08（Fable 5クレジット制正式始動翌日・Cowork展開状況の確認）

---

### クロスリファレンス（機能C）

#### TBP/ADR 再評価トリガー
- **TBP-001 再評価トリガー確認**: Claude Cowork モバイル/Web版の展開により「外部AIサービスがクラウドでバックグラウンド常時稼働」という新たなガバナンスパターンが登場。TBP-001の「最小権限」原則をCoworkの権限スコープ（どのデータにアクセスできるか）に適用するか検討を推奨。
- **TBP-001 補足**: Fable 5のクレジット制が現実化（予測→実現）。課金モデル変化への感度としてTBP-001の「段階拡張」フェーズでのコスト確認を意識的に組み込むことを提案。

#### references.md 更新判定
**不要（本日）**: Anthropic公式ベストプラクティス文書の新規変更なし。ただし上記「Cowork外部バックグラウンド処理」パターンは、次回TBP-001見直し時に references.md 追記を検討。

---

## [2026-07-06] デイリーレポート

### 内部知見（機能A）
#### 新規・更新 ADR
- My-Profile-and-Memory/decisions/ → フォルダ未存在のためスキップ
- StudyMate, My-URAWA-LOG, tak-work, tak-family, tak-personal → アクセス可能リポジトリ外のためスキップ
- tak-best-practices/ → TBP-001（外部ツール導入審査）・TBP-002（実行環境英語パス）を確認（新規 ADR なし）
- **継続記録（6/22 提案から 14 日目）**:
  1. TBP-003 候補「着手前に実態（git）と文書（backlog）の一致を確認する」— Tak 確認待ち（14日目）
  2. TBP-004 候補「不可逆性で安全方向を決めるが、カテゴリ丸ごとの保守化は目的を殺す」— Tak 確認待ち（14日目）

#### TBP 昇格候補
なし（本日は新規 ADR なし）

#### 再検討トリガー該当
- **TBP-001（外部ツール導入審査）継続**: 前回（7/5）の全未確認項目（1〜45）を引き継ぎ継続。
- **TBP-001 新規照合①（Claude Apps Gateway — 企業向け SSO コントロールプレーン、2026-06-29 GA）**:
  - Claude Code向けの自己ホスト型コントロールプレーン（Amazon Bedrock / Google Cloud / Microsoft Foundry向け）が一般提供開始。
  - 機能: 企業SSO（OpenID Connect: Google Workspace / Microsoft Entra ID / Okta等）、一元化ポリシー、ロールベースアクセス、ユーザー別コスト追跡、日次/週次/月次支出上限設定。
  - 開発者は短命 bearer トークンを受け取り、IdP側でのオフボーディングで即座にアクセス無効化（デフォルト1時間TTL）。
  - TBP-001「外部 AI サービスのガバナンス設計」評価項目に「企業コントロールプレーン型ガバナンス」パターンとして追記する材料。
- **TBP-001 新規照合②（Fable 5 グレース期間終了 7/7 — 最終確認チャンス）**: 本日（7/6）がグレース期間中の最後の実質確認日。7/8以降 $10/$50 per Mtok のクレジット制完全移行。TBP-001「課金体系変更リスク」の具体的節目。
- **TBP-002（実行環境英語パス）**: 新規トリガーなし。

---

### 外部リサーチ（機能B）
#### 参照した情報源
- Claude Code 公式チェンジログ: https://code.claude.com/docs/en/changelog（WebFetch）
- WebSearch: Anthropic Claude announcement news July 2026
- WebSearch: Claude Code GitHub issues new July 6 2026
- WebSearch: Claude Code Sonnet 5 デフォルト変更 2026年7月 日本語記事
- WebSearch: 会計 AI 経理自動化 税務 生成AI 2026年7月
- WebSearch: freee マネーフォワード バクラク AI機能 アップデート 2026年7月
- WebSearch: Claude Code Zenn Qiita 新着記事 2026年7月
- WebSearch: Claude Code apps gateway Amazon Bedrock corporate SSO 2026

#### 🔴 即座に適用すべき事項

**① Fable 5 グレース期間終了まで 1 日（7/7 終了、7/8 よりクレジット制完全移行）**
- 本日（7/6）が Fable 5 グレース期間中の最終確認チャンス。
- 7/7（日曜）でグレース期間終了。7/8（月曜）より完全クレジット制（$10/$50 per Mtok）に移行。
- **推奨対応（本日中）**:
  1. 各 Routine の実行ログで Fable 5 が auto モードで選択されているか確認
  2. 必要であれば org-configured model restrictions（v2.1.187）で Fable 5 選択を制限
  3. 7/8 以降のコスト影響を事前試算

#### 🟡 近いうちに試したいこと（上位3件）

**① マネーフォワード AI Cowork 正式アナウンス監視継続（最優先）**
- 7/6 時点でも正式な提供開始アナウンスは未確認。7月中リリース予定は継続。
- Claude Agent SDK + MCP 採用のバックオフィス AI（経理・労務・法務を AI 同僚として自律処理）。
- Tak の本業（経理部長）に直結。確認次第 auto-research-collect「会計×AI 重要発表」枠で即時記事化推奨。

**② Claude Apps Gateway の活用検討（企業向け Claude Code ガバナンス）**
- 自己ホスト型コントロールプレーン（Linux コンテナ + PostgreSQL バックエンド）。
- 開発者オフボーディング、支出上限設定（ユーザー/グループ/組織単位）、SSO統合が特徴。
- データプライバシー: Anthropic に推論トラフィックや使用データを送信しない（Claude API 直接設定時を除く）。
- 参照: https://code.claude.com/docs/en/claude-apps-gateway

**③ Claude Sonnet 5 コンテキスト管理最適化の実践**
- 7/1 Qiita記事「Claude Code のコンテキスト管理とトークン消費を抑える運用方法」が参考。
- Sonnet 5 はセッション全履歴を毎回送信しコンテキストが膨らむ特性あり → 定期的な `/compact` や `--continue` の活用が推奨。
- Routine での long-running タスク（deep-research-runner等）のトークン消費最適化に応用可能。

#### 🟢 参考情報

**Claude Code v2.1.201 が依然最新（7/6 時点）**
- v2.1.202 以降の新バージョンリリースは 7/6 時点で未確認。
- v2.1.201（7/3）= Claude Sonnet 5 セッションでのハーネスリマインダー mid-conversation システムロール廃止。

**GitHub Issues 新着（2026-07-06）**
- Issue #74928: model area bug（再現手順要求、Linux）
- Issue #74927: CLI/MCP area regression（Linux、eslerm 報告）
- Issue #74926: hooks/statusline area enhancement（beardfaceguy）
- Issue #74925: （bprzybysz、内容未詳）
- Issue #74924: auth/bash area bug（macOS、sworrl）
- Issue #74923: model area bug duplicate（Linux、mauriaparker-kimedics）
- Issues #74922, #74921: auth/bash 関連（sworrl）
- **Research Hub の Routine 動作への直接影響**: CLI/MCP regression (#74927、Linux) が最も注意。Linux sandbox で動く Routine への潜在的影響あり（次回実行で確認推奨）。

**Anthropic 全体動向（7/6 時点）**
- Fable 5: グレース期間最終日（7/7 終了）。7/1 からグローバル復旧済み。
- Claude Sonnet 5: デフォルトモデル継続。プロモーション価格（$2/$10 per Mtok）は 8/31 まで。
- Claude Science: ライフサイエンス向けワークベンチ（β版）継続展開。
- Claude Enterprise: 管理者向けアナリティクス強化・モデルレベルエンタイトルメント・支出アラート追加。

**会計×AI トレンド（2026-07-06 時点）**
- **マネーフォワード AI Cowork**: 7/6 時点でも正式リリースアナウンス未確認。7月中予定継続。
- **弥生「AI取引入力β版」（2026年新機能）**: 簿記知識不要で取引を自然文入力→AIが仕訳に変換。クラウド会計の AI 機能強化継続。
- **PwC「Tax AI Assistant」**: 日本の税法に特化した生成 AI ツール。リサーチ・文書作成・要約の税務業務効率化を提供。実務 AI 活用の上位事例として記録。
- **経理 AI 普及率**: 2026年時点約 24.3%（75% 以上が未導入、導入余地大）。
- **2026年経理AI キーワード**: 仕訳入力 75% 削減・請求書処理 70% 短縮・月次決算 5 営業日早期化が業界標準値として定着継続。

**Zenn/Qiita 注目記事（7月新着）**
- 「Claude Code のコンテキスト管理とトークン消費を抑える運用方法」（Qiita, 7/1, Yasushi-Mo）: セッション全履歴送信のコスト問題と `/compact`・`--continue` 活用術
- Qiitaニュース「正直に言う。お前のClaude Codeの使い方は間違っている」（7/1）: Claude Code の使い方の盲点特集
- 「Claude Code を4ヶ月使ってわかった、おすすめコマンド・スキル 10 選」（Qiita, wataru86）: 実践的スキル集
- Claude Sonnet 5 解説記事多数（uravation.com、crystal-method.com、DevelopersIO等）

#### references.md 更新提案

継続未確認項目（1〜45）: 前回レポート（7/5）の継続未確認項目を引き継ぎ（詳細は 7/5 レポート参照）。

**新規追加提案（2026-07-06）**:
46. **Claude Apps Gateway 詳細（SSO + Bedrock/GCP + 中央ポリシー + 支出上限）**: 自己ホスト型コントロールプレーン（OpenID Connect経由のSSO、開発者オフボーディング、ユーザー/グループ/組織単位の支出上限、データはAnthropicに送信されない）。ガバナンス設計セクションへの追記提案。

#### 新規発見ソース候補
なし（本日は新規有望ソース未発見）

#### 次回リサーチ推奨日
2026-07-07（翌日）。Fable 5 グレース期間終了（本日 7/6 が最終確認日）後の 7/7 クレジット制移行確認。
注目点:
① **Fable 5 クレジット制完全移行（7/8 から）**: 7/7 グレース期間終了後のコスト影響監視。7/8 の最初の Routine 実行ログ確認推奨。
② **マネーフォワード AI Cowork 正式アナウンス**: 7月中リリース予定の継続監視。
③ **Claude Code v2.1.202 以降リリース確認**: v2.1.201 以降の新バージョン。
④ **TBP-003・TBP-004 昇格候補**: Tak 確認状況（6/22 提案から 14 日経過）。
⑤ **GitHub Issue #74927（CLI/MCP regression, Linux）のパッチリリース確認**: Linux sandbox で動く Routine への影響監視。

---

## [2026-07-05] デイリーレポート

### 内部知見（機能A）
#### 新規・更新 ADR
- My-Profile-and-Memory/decisions/ → フォルダ未存在のためスキップ
- StudyMate, My-URAWA-LOG, tak-work, tak-family, tak-personal → アクセス可能リポジトリ外のためスキップ
- tak-best-practices/ → TBP-001（外部ツール導入審査）・TBP-002（実行環境英語パス）を確認（新規 ADR なし）
- **継続記録（6/22 提案から 13 日目）**:
  1. TBP-003 候補「着手前に実態（git）と文書（backlog）の一致を確認する」— Tak 確認待ち
  2. TBP-004 候補「不可逆性で安全方向を決めるが、カテゴリ丸ごとの保守化は目的を殺す」— Tak 確認待ち

#### TBP 昇格候補
なし（本日は新規 ADR なし）

#### 再検討トリガー該当
- **TBP-001（外部ツール導入審査）新規照合①（Claude Code GitHub Action prompt injection 脆弱性 — 2026年6月開示）**:
  - Claude Code GitHub Action に CVSS v4.0: 7.8 の重大な脆弱性が発見・修正済み（fix: v1.0.94）。
  - 攻撃手法: 悪意あるボットが GitHub issue を作成 → Claude Code GitHub Action が読み取り → CI/CD secrets（ANTHROPIC_API_KEY, AWS_SECRET_ACCESS_KEY, GITHUB_TOKEN 等）をissueに書き出してしまう。
  - 根本原因: `checkWritePermissions` 関数が `[bot]` で終わるアクター名を無条件に信頼。GitHub Apps はパブリックリポジトリへの暗黙の読み取り権限を持つため bypass 可能だった。
  - サプライチェーンリスク: Anthropic 自身のアクションリポジトリも対象だったため、下流プロジェクト全体に影響しうる。
  - TBP-001「審査→最小権限→段階拡張」は Claude Code GitHub Action（Anthropic 公式ツールを含む）にも適用すべきことを示す具体例。GitHub Actions への最小権限設定（`permissions: read-only`）と定期的な権限レビューを推奨。
  - 参照: https://flatt.tech/research/posts/poisoning-claude-code-one-github-issue-to-break-the-supply-chain/
- **TBP-001（外部ツール導入審査）継続**: 前回（7/4）の全未確認項目（1〜42）を引き継ぎ継続。
- **TBP-002（実行環境英語パス）**: 新規トリガーなし。

---

### 外部リサーチ（機能B）
#### 参照した情報源
- Claude Code 公式チェンジログ: https://code.claude.com/docs/en/changelog（WebFetch）
- WebSearch: Anthropic Claude news announcement July 5 2026
- WebSearch: Claude Code GitHub issues new July 5 2026
- WebSearch: Claude Code GitHub Action security vulnerability 2026
- WebSearch: Claude Code prompt injection supply chain security 2026 July
- WebSearch: マネーフォワード AI Cowork 正式リリース 2026年7月
- WebSearch: Zenn Qiita Claude Code 新着記事 2026年7月5日
- WebSearch: 会計 AI 経理 自動化 税務 生成AI 2026年7月
- WebSearch: freee バクラク AI機能 アップデート 2026年7月
- WebSearch: Claude Code v2.1.202 v2.1.203 release July 5 2026

#### 🔴 即座に適用すべき事項

**① Claude Code GitHub Action プロンプトインジェクション脆弱性（2026年6月開示、修正済み）**
- **重要度: CVSS v4.0 = 7.8**（Anthropic 評価）
- GMO Flatt Security の RyotaK 氏が 2026年1月に報告、Anthropic が4日以内に修正（v1.0.94 以降で対応）。
- **攻撃シナリオ**: ボットアカウントが悪意あるプロンプトを含む GitHub issue を作成 → Claude Code GitHub Action がトリアージで読み取り → CI/CD シークレット（API キー・クレデンシャル等）を issue に書き出す → 攻撃者が収集。
- **2026-06-25 時点の最新PoC**: 間接プロンプトインジェクションにより開発者の user 権限でインタラクティブシェルを実行可能（環境変数全取得可能）。
- **推奨対応**:
  1. Research Hub で `claude-code-action` を使用している場合: `claude-code-action@v1.0.94` 以上に更新
  2. GitHub Actions の `permissions:` を `read-only` または必要最小限に制限
  3. Routine のプロンプトに「外部 issue の内容を信頼しない」旨の指示を検討
  4. パブリックリポジトリで CI/CD シークレットを扱う場合は特に注意
- 参照: https://flatt.tech/research/posts/poisoning-claude-code-one-github-issue-to-break-the-supply-chain/
- 参照: https://cybersecuritynews.com/new-claude-code-attack/

**② Fable 5 グレース期間終了まで 2 日（7/7 終了、7/8 よりクレジット制完全移行）**
- 昨日（7/4）レポートからの継続。7/7（日曜）でグレース期間終了。7/8（月曜）より完全クレジット制。
- $10/$50 per Mtok（キャッシュヒット $1/Mtok、5分キャッシュ書き込み $12.50/Mtok、1時間キャッシュ書き込み $20/Mtok）。
- **今日（7/5）が対応のラストチャンス**: 各 Routine の Fable 5 使用量確認と必要に応じた org-configured model restrictions 設定を推奨。

#### 🟡 近いうちに試したいこと（上位3件）

**① マネーフォワード AI Cowork 正式アナウンス監視継続（最優先）**
- 7/5 時点でも正式な提供開始アナウンスは未確認。7月中の正式リリース予定は変わらず（4月7日発表時点の予告）。
- Claude Agent SDK + MCP 採用のバックオフィス AI（経理・労務・法務を AI 同僚として自律処理）。MCP設定不要で利用可能。
- Tak の本業（経理部長）に直結。確認次第 auto-research-collect「会計×AI 重要発表」枠で即時記事化推奨。
- 参照: https://biz.moneyforward.com/ai-cowork/

**② Claude Sonnet 5 プロモーション価格（〜2026年8月31日）の活用最大化**
- Claude Sonnet 5 が Claude Code のデフォルトモデルに。プロモーション価格 $2/$10 per Mtok（8/31まで）。1M トークンのネイティブコンテキストウィンドウ搭載。
- Routine での Sonnet 5 活用を最大化し、8月末以降の価格変更前に消費パターンを把握しておく価値あり。
- 参照: releasebot.io/updates/anthropic/claude

**③ Claude Science（研究者向け AI ワークベンチ）の詳細確認**
- Anthropic が Claude Science を発表。科学者向けに研究ツール・パッケージを統合し、監査可能なアーティファクトを生成。計算リソースへの柔軟なアクセスを提供。
- 参照: https://www.anthropic.com/news/claude-science-ai-workbench

#### 🟢 参考情報

**Claude Code v2.1.201（2026-07-03 リリース）が依然最新**
- 7/5 時点で v2.1.202 以降の新バージョンリリースは未確認（v2.1.201 が最新）。
- 前回からの継続情報：v2.1.201 = Claude Sonnet 5 セッションでのハーネスリマインダー用 mid-conversation システムロール廃止。

**Claude Code GitHub Issues 新着（2026-07-05）**
- #74601（area:mcp, enhancement, VS Code）
- #74600（area:agents, area:cost, bug, 再現手順あり）
- #74599（area:agents, area:cost, area:model, bug, macOS）
- #74598（area:tui, bug, macOS）
- #74596（area:security, enhancement, macOS）— セキュリティ強化リクエスト
- Research Hub Routine への直接影響: 軽微。agents/cost 系バグは Linux sandbox で動く Routine への影響は低い。

**Anthropic 全体動向（7/5 時点）**
- Fable 5 が米国の輸出規制解除により 7/1 からグローバルに復活（7/5 は Fable 5 完全復活後の最初の週末）。
- Claude Science 発表（研究者・製薬業界向け AI ワークベンチ）。
- 業界共同ジェイルブレイク重大度スコアリングフレームワーク（Anthropic + Amazon + Microsoft + Google）推進継続。
- Claude Enterprise: 管理者向けアナリティクス強化・モデルレベルエンタイトルメント・支出アラート追加。

**会計×AI トレンド（2026-07-05 時点）**
- マネーフォワード AI Cowork: 正式リリース待ち継続。
- freee: 2026年6月16日に「freee AIアシスタント」と「freee カスタムオーダー」の提供開始（6月中旬から稼働中）。
- バクラク: freee 会計 API 対応（仕訳・証憑をワンクリック連携）は継続。7月特有の新機能アップデートは未確認。
- 2026年の経理AI普及率: 約24.3%（前回報告値からの継続）。75%超が未導入でまだ成長余地大。

**ZCode（中国発）の参入**
- Z.ai（智譜AI）が Claude Code・Cursor・GitHub Copilot と競合する無料デスクトップ ADE「ZCode」を macOS/Windows/Linux 向けに公開。GLM-5.2 モデルベース。市場の競争激化を示すシグナル。

**Zenn/Qiita 注目記事（7月新着）**
- 「AI Daily Digest 2026年7月5日 — AI投資額が5,100億ドル、Claude Sonnet 5、Kling AIが28億ドル調達」（Qiita）: 7/5 時点のAIトレンドダイジェスト
- 「Claude Code と Zenn 執筆環境を一から育てた記録」: pre-commit hook 自動化・スキル化の実践記録
- 「コードを書けない私が、AIに『チーム』を持たせるまで」（Zenn Books）: 9体 AI エージェント編集部構築（継続話題）

#### references.md 更新提案

継続未確認項目（1〜42）: 前回レポート（7/4）の継続未確認項目を引き継ぎ（詳細は 7/4 レポート参照）。

**新規追加提案（2026-07-05）**:
43. **Claude Code GitHub Action 最小権限設定**: プロンプトインジェクション対策として、GitHub Actions の `permissions:` を `read-only` に設定する最小権限の原則を「セキュリティ設定」セクションに記載提案。
44. **Claude Sonnet 5 プロモーション価格（〜8/31）**: $2/$10 per Mtok + 1M トークンコンテキスト。references.md の「モデル料金」セクションに記載提案。
45. **間接プロンプトインジェクション（OWASP LLM01:2025）**: AI エージェントが外部コンテンツ（GitHub issue, README等）を読み取る際の構造的セキュリティリスク。references.md の「セキュリティ考慮事項」セクションへの追記提案。

#### 新規発見ソース候補
- **flatt.tech（GMO Flatt Security Research）**: Claude Code GitHub Action 脆弱性の一次開示元。AI エージェントのセキュリティリサーチが充実。評価候補: ⭐⭐⭐⭐（セキュリティ一次情報源として有用）
- **cybersecuritynews.com**: Claude Code 関連のセキュリティ報道が複数あり。評価候補: ⭐⭐⭐

#### 次回リサーチ推奨日
2026-07-06（翌日）。Fable 5 グレース期間終了（7/7）前の最終確認。
注目点:
① **Fable 5 グレース期間終了（7/7）**: 残り 2 日。各 Routine の Fable 5 使用量確認と、org-configured model restrictions の設定確認を推奨。
② **マネーフォワード AI Cowork 正式アナウンス**: 7月中のリリース予定。7/5 時点でも未確認。
③ **Claude Code GitHub Action セキュリティ対応確認**: v1.0.94 以降への更新状況・GitHub Actions 権限設定の見直し。
④ **Claude Sonnet 5 消費量把握**: 8/31 までのプロモーション価格を活用するための消費パターン把握推奨。
⑤ **TBP-003・TBP-004 昇格候補**: Tak 確認状況（6/22 提案から 13 日経過）。

---

## [2026-07-04] デイリーレポート

### 内部知見（機能A）
#### 新規・更新 ADR
- My-Profile-and-Memory/decisions/ → フォルダ未存在のためスキップ
- StudyMate, My-URAWA-LOG, tak-work, tak-family, tak-personal → アクセス可能リポジトリ外のためスキップ
- tak-best-practices/ → ファイルなし（フォルダは存在するが中身なし）のためスキップ
- **継続記録（6/22 提案から 12 日目）**:
  1. TBP-003 候補「着手前に実態（git）と文書（backlog）の一致を確認する」— Tak 確認待ち
  2. TBP-004 候補「不可逆性で安全方向を決めるが、カテゴリ丸ごとの保守化は目的を殺す」— Tak 確認待ち

#### TBP 昇格候補
なし（本日は新規 ADR なし）

#### 再検討トリガー該当
- **TBP-001（外部ツール導入審査）継続**: 前回（7/3）の全未確認項目（1〜40）を引き継ぎ継続。
- **TBP-001 新規照合①（Fable 5 グレース期間終了 7/7 — 7/8 以降クレジット制）**: 7/8 以降、Fable 5 は $10/$50 per Mtok のクレジット制に完全移行。グレース期間（週次利用量 50% 含む）は 7/7 で終了。Routine が auto モードで Fable 5 を選択している場合、7/8 以降コスト急増リスク。TBP-001「課金体系変更リスク」の最も具体的な試験日が 3 日後に迫っている。org-configured model restrictions（v2.1.187）での事前制御を検討推奨。
- **TBP-002（実行環境英語パス）**: 新規トリガーなし。

---

### 外部リサーチ（機能B）
#### 参照した情報源
- Claude Code 公式チェンジログ: https://code.claude.com/docs/en/changelog（WebFetch）
- WebSearch: Anthropic news announcement July 4 2026
- WebSearch: Claude Code GitHub issues new July 4 2026
- WebSearch: Claude Code v2.1.201 v2.1.202 changelog July 4 2026
- WebSearch: Zenn Qiita Claude Code 新着記事 2026年7月
- WebSearch: 会計 AI 経理 自動化 生成AI 2026年7月
- WebSearch: freee マネーフォワード バクラク AI機能 2026年7月
- WebSearch: マネーフォワード AI Cowork リリース 正式提供 2026年7月4日
- WebSearch: Anthropic Claude Fable 5 pricing July 8 2026 credit system

#### 🔴 即座に適用すべき事項

**① Fable 5 グレース期間終了まで 3 日（7/7 終了、7/8 よりクレジット制完全移行）**
- 7/7（日曜）でグレース期間終了。7/8（月曜）より Fable 5 は $10/$50 per Mtok の使用クレジット制に移行。
- キャッシュ価格: ヒット $1/Mtok、5分キャッシュ書き込み $12.50/Mtok、1時間キャッシュ書き込み $20/Mtok。
- **Research Hub への推奨対応**:
  - 7/8 前に各 Routine の settings.json で `"defaultPermissionMode": "auto"` が設定済みか確認（v2.1.200 破壊的変更の影響確認）
  - auto モードで Fable 5 が選ばれている頻度を確認し、7/8 以降のコスト見積もりを立てること
  - 必要に応じて org-configured model restrictions（v2.1.187）で 7/8 以降の Fable 5 選択を制限

#### 🟡 近いうちに試したいこと（上位3件）

**① マネーフォワード AI Cowork の正式アナウンス監視継続（最優先）**
- 7月提供開始予定で先行受付中だが、7/4 時点でも正式な提供開始アナウンスは未確認。
- 内容: Claude Agent SDK + MCP 採用のバックオフィス AI。経理・労務・法務を自律処理。AI が「同僚として」対話形式でバックオフィス業務を遂行（MCP 設定不要）。ガバナンス機能（Draft & Approve・AI 監査ログ・ガードレール）搭載。2030 年までに AI で ARR 150 億円超を目標として発表済み。
- Tak の本業（経理部長）に直結。正式アナウンス確認次第 auto-research-collect「会計×AI 重要発表」枠で即時記事化推奨。
- 参照: biz.moneyforward.com/ai-cowork/

**② v2.1.200 の Routine 設定影響確認（デフォルト "manual" 変更対応）**
- v2.1.200（7/3 リリース）でデフォルト権限モードが `"default"` から `"manual"` に変更済み。Routine で `"auto"` を明示設定しているか要確認。
- 今週中に各スケジュールタスクの実行ログで停止していないか確認を推奨。前回（7/3）レポートからの継続課題。

**③ Zenn/Qiita 注目記事（7月新着）**
- 「正直に言う。お前のClaude Codeの使い方は間違っている」（Qiita ニュース 7/1）: Claude Code の使い方の盲点を指摘する内容
- 「Claude Code のモデル切り替え・使い分け戦略」（Qiita）: Sonnet 5・Fable 5・Opus の使い分けガイド。「なんとなく感覚で切り替え」からの脱却を解説
- 「コードを書けない私が、AIに『チーム』を持たせるまで」（Qiita → Zenn Books）: SE歴26年管理職が 9体 AI エージェント編集部を Claude Code で構築した実践記録（継続話題）

#### 🟢 参考情報

**Claude Code v2.1.201（2026-07-03 リリース）**
- Claude Sonnet 5 セッションでハーネスリマインダーのためにシステムロールを mid-conversation で使わなくなった（前回 v2.1.200 のハーネスリマインダー設計の refinement。ノイズ低減）
- 7/4 時点で v2.1.202 以降の新バージョンリリースは未確認（v2.1.201 が最新）

**GitHub Issues 新着（2026-07-04）**
- Issue #74272: VS Code バグ（natkuhn）
- Issue #74271: cost/statusline/TUI enhancement（natkuhn）
- Issue #74270: model area macOS バグ（EthanSK）
- Issue #74269: model area バグ（再現手順待ち、ariannamethod）
- Issue #74268: TUI enhancement macOS（dmccullo7-afk）
- Issue #74267: model area duplicate bug macOS（bbaassssiiee）
- Issue #74266: sandbox area bug macOS（ariannamethod）
- **Research Hub Routine への直接影響**: model/TUI 系バグが多いが Routine への直接影響は軽微。sandbox バグ(#74266) は macOS のため Linux sandbox で動く Routine への影響なし。

**会計×AI トレンド（2026-07-04 時点）**
- **マネーフォワード AI Cowork**: 7月提供開始予定で先行受付中（7/4 時点で正式開始アナウンス未確認）。Claude Agent SDK + MCP 採用、経理・労務・法務を AI 同僚として自律処理。ガバナンス機能（Draft & Approve・AI 監査ログ・ガードレール）搭載。2030 年までに AI で ARR 150 億円超を目標発表済み。
- **freee**: MCP 対応継続。Claude Code から freee-mcp（OSS）で 270+ API を操作可能。実務導入加速中。
- **バクラク**: 規定違反の自動検出で差し戻し率 60% 減を達成との報告継続。15,000+ 企業で利用継続。
- **経理 AI 普及率**: 2026 年時点で約 24.3%（75% 以上が未導入）。AI エージェント化が本格普及フェーズ継続。
- **2026 年 AI 経理のキーワード**: 仕訳入力 75% 削減・請求書処理 70% 短縮・月次決算 5 営業日早期化が業界標準報告値として定着。

**Anthropic 全体動向（7/4 時点）**
- IPO 準備継続（評価額 $965B）。Revenue run-rate が $47B+ で OpenAI の $24〜25B を上回ったとの報道が継続。
- 業界ジェイルブレイクスコアリングフレームワーク（Anthropic + Amazon + Microsoft + Google）: 4軸スコアリング推進継続中。
- Claude Enterprise 新機能強化: 管理者向けアナリティクス強化・モデルレベルエンタイトルメント・支出アラートが追加。

#### references.md 更新提案

継続未確認項目（1〜40）: 前回レポート（7/3）の継続未確認項目を引き継ぎ（詳細は 7/3 レポート参照）。

**新規追加提案（2026-07-04）**:
41. **Fable 5 クレジット制移行（7/8 以降）**: $10/$50 per Mtok（キャッシュヒット $1/Mtok、5分書き込み $12.50/Mtok、1時間書き込み $20/Mtok）。グレース期間（〜7/7）終了後の料金体系を references.md の「モデル料金」セクションに記載提案。
42. **v2.1.201 ハーネスリマインダーのシステムロール廃止**: Claude Sonnet 5 セッションで mid-conversation システムロールを使わなくなる仕様変更。プロンプト設計・システムプロンプトセクションへの追記提案。

#### 新規発見ソース候補
なし（本日は新規有望ソース未発見）

#### 次回リサーチ推奨日
2026-07-05（翌日）。Fable 5 グレース期間終了（7/7）前の最終確認とマネーフォワード AI Cowork 正式アナウンス監視継続。
注目点:
① **Fable 5 グレース期間終了（7/7）**: 7/8 からのクレジット制移行に備え、Routine での Fable 5 選択頻度を今週中に確認。必要に応じて org-configured model restrictions で制御を検討。
② **マネーフォワード AI Cowork 正式アナウンス**: 7月提供開始予定の正式リリースを引き続き監視。確認次第即時記事化対象。
③ **v2.1.202 以降のリリース確認**: v2.1.201 以降の新バージョンがあれば確認。
④ **TBP-003・TBP-004 昇格候補**: Tak 確認状況（6/22 提案から 12 日経過）。
⑤ **Claude Enterprise 新機能詳細確認**: 管理者向けアナリティクス強化・支出アラートの詳細確認。

---


## [2026-07-03] デイリーレポート

### 内部知見（機能A）
#### 新規・更新 ADR
- My-Profile-and-Memory/decisions/ → フォルダ未存在のためスキップ
- StudyMate, My-URAWA-LOG, tak-work, tak-family, tak-personal → アクセス可能リポジトリ外のためスキップ
- tak-best-practices/ → TBP-001（外部ツール導入審査）・TBP-002（実行環境英語パス）を確認（新規 ADR なし）
- **継続記録（6/22 提案から 11 日目）**:
  1. TBP-003 候補「着手前に実態（git）と文書（backlog）の一致を確認する」— Tak 確認待ち
  2. TBP-004 候補「不可逆性で安全方向を決めるが、カテゴリ丸ごとの保守化は目的を殺す」— Tak 確認待ち

#### TBP 昇格候補
なし（本日は新規 ADR なし）

#### 再検討トリガー該当
- **TBP-001（外部ツール導入審査）継続**: 前回（7/2）の全未確認項目（1〜37）を引き継ぎ継続。
- **TBP-001 新規照合①（v2.1.200 デフォルト権限モード "manual" 変更 — 2026-07-03）**: デフォルト権限モードが `"default"` から `"manual"` に変更（破壊的変更）。`"manual"` モードはすべての操作で逐一ユーザー確認を求める最も保守的な設定。TBP-001「最小権限で開始」に直接対応する変更。Routine のように確認不可能な環境では明示的に `"auto"` を settings.json に設定しないと Routine が停止するため要確認。
- **TBP-001 新規照合②（v2.1.200 AskUserQuestion 自動継続廃止 — 2026-07-03）**: `AskUserQuestion` ツール呼び出し後の自動継続挙動が廃止。Routine 内でエージェントが `AskUserQuestion` を使用するプロンプトになっている場合、Routine がユーザー入力待ちで停止するリスク。プロンプトへの「AskUserQuestion を使わず推測して進む」指示追加を推奨。
- **TBP-002（実行環境英語パス）**: 新規トリガーなし。

---

### 外部リサーチ（機能B）
#### 参照した情報源
- Claude Code 公式チェンジログ: https://code.claude.com/docs/en/changelog（WebFetch）
- WebSearch: Claude Code changelog v2.1.199 v2.1.200 July 3 2026
- WebSearch: Anthropic news announcement July 3 2026
- WebSearch: Claude Code GitHub issues new July 3 2026
- WebSearch: マネーフォワード AI Cowork freee 会計 AI 2026年7月
- WebSearch: Anthropic revenue OpenAI comparison 2026
- WebSearch: freee MCP OSS オープンソース Claude Code 2026

#### 🔴 即座に適用すべき事項

**① Claude Code v2.1.200（2026-07-03 リリース）— デフォルト権限モードの破壊的変更**
- **デフォルト権限モードが `"default"` → `"manual"` に変更**:
  - `"manual"` モード: すべてのツール使用で逐一ユーザー確認を求める（最も保守的な設定）
  - Routine のように非インタラクティブ環境では明示的に `"auto"` を指定しないと確認待ちで停止する
  - **Research Hub への推奨対応**: 各 Routine の settings.json に `"defaultPermissionMode": "auto"` が明示されているか確認。Auto-research-collect・deep-research-runner・auto-claude-code-watch・feedback-article-runner・auto-research-morning-email の設定確認を推奨。
- **`AskUserQuestion` 自動継続の廃止**:
  - `AskUserQuestion` ツール呼び出し後の自動継続がなくなり、明示的なユーザー入力待ちで停止するようになった
  - **Research Hub への影響**: Routine プロンプト内で `AskUserQuestion` が使用されると Routine が完了せず停止。プロンプト設計の見直しを検討推奨（「確認が必要な場合は推測して作業を継続する」等の指示を追加）
- **バグ修正（重要）**:
  - バックグラウンドセッションがスリープ後に停止するバグを修正 → Routine の長時間実行安定性向上
  - レート制限ヒット時にサブエージェントが空の結果を返すバグを修正 → deep-research-runner・auto-research-collect での安定性向上

#### 🟡 近いうちに試したいこと（上位3件）

**① v2.1.199 スタック化スラッシュスキル（`/skill-a /skill-b`、最大5スキル）**
- v2.1.199（2026-07-02 リリース）で追加。複数のスラッシュスキルをスペース区切りで最大5スキルまでスタック実行できる機能。
- 例: `/auto-research-collect /feedback-article-runner` のように2つのスキルを連続実行可能。
- Research Hub の Routine プロンプト設計で複数機能の組み合わせタスクフローを実装する際の参考に。

**② マネーフォワード AI Cowork 正式提供開始アナウンス監視継続（最優先）**
- 2026年7月開始予定（4月発表）のアナウンスが 7/3 時点でも未確認。
- Claude Agent SDK + MCP 採用のバックオフィス AI。Tak の本業（経理部長）に直結。
- 今週中にアナウンスがある可能性。確認次第 auto-research-collect の「会計×AI 重要発表」枠で即時記事化推奨。

**③ Fable 5 グレース期間終了（7/7）前のコスト影響測定**
- 7/7 まで週次利用量の 50% が含まれるグレース期間。7/8 以降は $10/$50 per Mtok のクレジット制に完全移行。
- Routine の auto モードで Fable 5 が選択されている場合、7/8 以降のコスト急増に備えて事前に消費量を測定しておく必要あり。
- org-configured model restrictions（v2.1.187）で 7/8 以降の Fable 5 選択を制御する準備を推奨。

#### 🟢 参考情報

**Claude Code v2.1.199 詳細（2026-07-02 リリース）**
- **スタック化スラッシュスキル（最大5スキル）**: `/skill-a /skill-b` 形式でスペース区切りで複数スキルを一括実行
- **SSL 証明書エラーの即時失敗**: SSL 証明書エラー時にリトライを消費せず即失敗するよう変更（ネットワーク障害の診断が容易に）
- **ストリーミングエラー時の部分出力保持**: ストリーミング途中でエラーが発生しても部分出力が保持される。long-running Routine（deep-research-runner 等）での再実行コスト低減に有効

**Anthropic が OpenAI を収益で上回ったとの報道（2026-07-03 時点）**
- Anthropic の run-rate 売上高が $47B+（年換算）で OpenAI の $24-25B を上回ったとの報道。評価額 $965B（IPO 準備継続中）。
- **Research Hub への影響**: サービス安定性・継続性の観点からはポジティブシグナル。

**freee-mcp OSSとして公開済み — 270+ APIs から Claude Code で直接操作可能**
- freee が MCP サーバーをオープンソースで GitHub 公開。Claude Code から freee の 270 以上の API（仕訳・請求書・経費精算・銀行口座・決算等）に直接アクセス可能。
- **Tak 本業への直結度**: 経理部長として freee-mcp を Claude Code に組み込む実践的価値が非常に高い。
- TBP-001「外部 MCP 導入審査」の具体的適用対象として記録（審査→最小権限→段階拡張のプロセス推奨）。
- 参照: github.com/freee/freee-mcp

**会計×AI トレンド（2026-07-03 時点）**
- 2026年に国内会計ソフト各社（freee / マネーフォワード / バクラク）が AI エージェントを本体機能として標準搭載するフェーズへ本格移行。
- freee: 「Claude Code から直接 API 操作（freee-mcp OSS 公開）」路線
- マネーフォワード AI Cowork: 「AI が勝手にやる（MCP設定不要）」路線
- 両社のアプローチの差別化が 2026 年下半期の実務導入の判断軸に。
- バクラク AIエージェント: 15,000+ 企業利用継続（請求書処理・経費精算特化型）。

**GitHub Issues 新着（2026-07-03）**
- v2.1.200 リリース直後のため、新機能に関連する新着 Issues は今後増加する見込み。
- デフォルト権限モード変更（`"default"` → `"manual"`）に関する報告・フィードバックが注目点。

**Zenn / Qiita 日本語コミュニティ（2026-07-03 時点）**
- v2.1.200 のデフォルト権限モード変更に関する日本語解説記事は今夜以降出てくる見込み（破壊的変更のため注目度高い）。
- v2.1.199 スタック化スラッシュスキルの実験記事も近日公開予定。
- 会計×AI 実践記事継続増加（freee-mcp × Claude Code 実用ガイドが充実）。

#### references.md 更新提案

継続未確認項目（1〜37）: 前回レポート（7/2）の継続未確認項目を引き継ぎ（詳細は 7/2 レポート参照）。

**新規追加提案（2026-07-03）**:
38. **v2.1.199 スタック化スラッシュスキル**: 複数スキルをスペース区切りで最大5スキルまで一括実行（`/skill-a /skill-b`）。スキルセクションへの追記提案。
39. **v2.1.200 デフォルト権限モード "manual" 変更（破壊的変更）**: `"default"` から `"manual"` に変更。settings.json に `defaultPermissionMode: "auto"` を明示しないと Routine が停止。権限設計セクションへの重要注意事項として追記提案。
40. **v2.1.200 AskUserQuestion 自動継続廃止**: Routine プロンプトで AskUserQuestion 使用禁止を明示する必要性。Routine 設計ガイドラインセクションへの追記提案。

#### 新規発見ソース候補
なし（本日は新規有望ソース未発見）

#### 次回リサーチ推奨日
2026-07-04（翌日）。v2.1.200 Routine への影響確認・マネーフォワード AI Cowork 正式アナウンス監視継続。
注目点:
① **v2.1.200 デフォルト権限モード変更の Routine への影響確認**: 現行 Routine が `"auto"` モードで動作しているか settings.json を確認。
② **マネーフォワード AI Cowork 正式提供開始アナウンス**: 7 月開始予定。正式アナウンス確認次第即時記事化対象。
③ **Fable 5 グレース期間（〜7/7）中のコスト実測**: 7/8 以降 $10/$50 per Mtok 移行前に Routine での Fable 5 選択頻度・コスト影響を確認。
④ **TBP-003・TBP-004 昇格候補**: Tak 確認状況（6/22 提案から 11 日経過）。
⑤ **v2.1.201 以降のリリース確認**: v2.1.200 破壊的変更後の追加修正が出る可能性。

---

## [2026-07-02] デイリーレポート

### 内部知見（機能A）
#### 新規・更新 ADR
- My-Profile-and-Memory/decisions/ → フォルダ未存在のためスキップ
- StudyMate, My-URAWA-LOG, tak-work, tak-family, tak-personal → アクセス可能リポジトリ外のためスキップ
- tak-best-practices/ → TBP-001（外部ツール導入審査）・TBP-002（実行環境英語パス）を確認（新規 ADR なし）
- **継続記録（6/22 提案から 10 日目）**:
  1. TBP-003 候補「着手前に実態（git）と文書（backlog）の一致を確認する」— Tak 確認待ち
  2. TBP-004 候補「不可逆性で安全方向を決めるが、カテゴリ丸ごとの保守化は目的を殺す」— Tak 確認待ち

#### TBP 昇格候補
なし（本日は新規 ADR なし）

#### 再検討トリガー該当
- **TBP-001（外部ツール導入審査）継続**: 前回（7/1）の全未確認項目（1〜33）を引き継ぎ継続。
- **TBP-001 新規照合①（バックグラウンドエージェント自動 commit/push/PR — v2.1.198、2026-07-01）**: `claude agents` から起動したバックグラウンドエージェントがコード作業完了時に自動 commit・push・ドラフト PR を作成するようになった（従来は「入力待ちで停止」）。TBP-001「最小権限で開始」において、外部ツールの自律的 git 操作範囲が大幅拡大。Research Hub の Routine で意図しない git 操作が自動化されるリスクを評価する必要あり。allowlist/deny 設定の再確認を推奨。
- **TBP-001 新規照合②（マネーフォワード AI Cowork 7 月提供開始確認）**: Claude Agent SDK + MCP 採用のバックオフィス AI が 2026 年 7 月より提供開始予定（本日確認）。TBP-001「外部 AI サービスのガバナンス設計」に「MCP 設定不要のエージェント型バックオフィスサービス」パターンを追記する材料として継続記録。
- **TBP-002（実行環境英語パス）**: 新規トリガーなし。

---

### 外部リサーチ（機能B）
#### 参照した情報源
- Claude Code 公式チェンジログ: https://code.claude.com/docs/en/changelog（WebFetch）
- WebSearch: Anthropic Claude Code new features update July 2 2026
- WebSearch: Claude Code GitHub issues new July 2026
- WebSearch: Anthropic news announcement July 2026 new model
- WebSearch: Claude Code background agents auto commit push PR July 2026
- WebSearch: Claude Code Zenn Qiita 2026年7月2日 新着
- WebSearch: 会計 AI 経理自動化 freee マネーフォワード バクラク 2026年7月
- WebSearch: マネーフォワード AI Cowork リリース 2026年7月

#### 🔴 即座に適用すべき事項

**① Claude Code v2.1.198（2026-07-01）— バックグラウンドエージェント自動 commit/push/ドラフト PR**
- **最重要変更**: `claude agents` から起動したバックグラウンドエージェントがコード作業完了時に自動的に commit・push・ドラフト PR をオープンするようになった（「入力待ちで停止」から「自動実行」へ挙動変更）。
- 安全設計: エージェントは独立した git worktree で動作しメインブランチを汚染しない。PR は draft（マージは人間が判断）。
- 補完機能: バックグラウンドエージェント通知（`agent_needs_input` / `agent_completed`）が Notification フックで発火。
- **Research Hub への影響**:
  - Routine のバックグラウンドエージェントが自動的に git 操作を行う可能性あり
  - 既存の `Bash(command:git rm*)` deny ルールと合わせて設定を見直す
  - worktree 分離設計により通常の作業ディレクトリへの影響は軽微だが、意図しない branch/PR 生成に注意

**② Claude in Chrome 一般公開（v2.1.198, 2026-07-01）**
- Claude in Chrome が GA（一般提供）開始。ブラウザとの公式ネイティブ統合が正式リリース。
- **Research Hub への直接影響**: なし。ただし日常ブラウジング補助として活用可能。

#### 🟡 近いうちに試したいこと（上位3件）

**① マネーフォワード AI Cowork の 7 月提供開始確認・記事化（最優先）**
- 「2026 年 7 月より提供開始予定」として 4 月発表済み。Claude Agent SDK + MCP 採用のバックオフィス AI サービス。「今月の経理業務をまとめて」と指示するだけで AI が自律処理。
- Tak の本業（経理部長）に直結する国内 SaaS 初の大型 Anthropic エージェント基盤採用事例。
- 本日（7/2）調査では正式提供開始アナウンスは未確認（7 月開始予定は変更なし）。正式アナウンス確認次第 auto-research-collect の「会計×AI 重要発表」枠で即時記事化推奨。
- 参照: corp.moneyforward.com / biz.moneyforward.com/ai-cowork/

**② バックグラウンドエージェント通知フック（`agent_needs_input` / `agent_completed`）の活用検討**
- v2.1.198 で追加された Notification フックでエージェントの状態変化を外部通知可能。
- Research Hub 応用例: deep-research-runner 完了時に Discord 通知フック連携（auto-research-morning-email の Worker /notify/discord と組み合わせ）。

**③ /dataviz スキル（v2.1.198 新規追加）の活用**
- チャート・ダッシュボード設計ガイダンス + 実行可能カラーパレットバリデータを含む新スキル。
- Research Hub の index.html ビューワーの可視化改善候補。

#### 🟢 参考情報

**Claude Code v2.1.198 詳細（2026-07-01 リリース、32 変更含む）**
- Claude in Chrome GA
- バックグラウンドエージェントが完了時に自動 commit/push/ドラフト PR（← 🔴① 参照）
- `agent_needs_input` / `agent_completed` Notification フック追加
- /dataviz スキル（チャート・ダッシュボード設計）
- Gateway 機能強化: AWS 上の Claude Platform (anthropicAws) をアップストリームプロバイダーとして追加。モデル未発見時のフェイルオーバーチェーン改善
- Explore エージェントがメインセッションのモデルを継承（Opus 上限）
- サブエージェントとコンテキスト圧縮が extended thinking 設定を継承
- ネットワーク信頼性向上: ECONNRESET 等の一時的なドロップで自動リトライ（バックオフ付き）
- バグ修正: `/diff` パネルがブランチ切替時に未更新・マークダウンテーブル全画面ラップ・AWS Platform と Mantle セッションの STS トークン期限切れ後のデッドエンド・macOS バックグラウンドエージェントのローカルネットワークホスト接続問題

**GitHub Issues 新着（2026-07-02）**
- Issue #73612: macOS バグ（再現手順待ち）
- Issue #73611: iOS バグ
- Issue #73610: model バグ（VS Code / Windows）
- Issue #73609: cost / TUI バグ（macOS）
- Issue #73608: VS Code バグ（Linux、詳細再現手順あり）
- Issue #73607: agent-view / TUI バグ（claude agents / --bg / FleetView / daemon）
- **Research Hub の Routine 動作への直接影響**: #73607（agent-view / --bg 関連）が最も関連度高い。

**Anthropic ニュース（2026-07-01〜02 継続確認）**
- **Fable 5 / Mythos 5 復旧継続**: 7/1 より全ユーザー向け再展開済み。7/7 までグレース期間（週次利用量の 50% 含む）、7/8 以降クレジット制（$10/$50 per Mtok、キャッシュ 90% 割引）。
- **Claude Sonnet 5**: 引き続きデフォルトモデル（プロモーション価格〜8/31: $2/$10 per Mtok、以降 $3/$15）。
- **Claude Science（6/30 発表）**: ライフサイエンス向け Beta 版。Pro/Max/Team/Enterprise ユーザー向け（macOS・Linux）継続展開。

**会計×AI トレンド（2026-07-02 時点）**
- **マネーフォワード AI Cowork**: 2026 年 7 月開始予定継続確認。正式リリースアナウンスは本日時点で未確認。「今月の経理業務をまとめて」と指示するだけで AI が経理・労務・法務を自律処理（Claude Agent SDK + MCP 採用、MCP 設定不要）。先行受付受付中。
- **freee**: 国産会計 AI エージェント 4 本命（freee / マネーフォワード / バクラク / TOKIUM）の一角。AI 仕訳・銀行口座連携継続展開。
- **バクラク AIエージェント**: 15,000+ 企業利用継続（請求書処理・経費精算特化型）。
- **経理 AI 普及率**: 2026 年時点で約 24.3%（75% 以上が未導入）。AI エージェント化が本格普及フェーズへ。

**Zenn / Qiita 日本語コミュニティ（2026-07-02）**
- 「claude agents が自動 PR を作るようになったので中身を検証した」（Qiita, kai_kou 氏）— v2.1.198 の自動 PR 機能の詳細検証。通知イベント `agent_needs_input` / `agent_completed` の活用方法まで解説（本日公開）。
- 「Claude Fable 5 が帰ってきたので情報を整理した」（Zenn, acntechjp 氏）— Fable 5 復旧後の詳細情報まとめ。
- 「AI Daily Digest — 2026年7月2日：Meta Compute、Claude Sonnet 5、コーディングエージェント革命」（Qiita）— Claude Sonnet 5 が Opus 4.8 に迫るパフォーマンスを達成と解説。

#### references.md 更新提案

継続未確認項目（1〜33）: 前回レポート（7/1）の継続未確認項目を引き継ぎ（詳細は 7/1 レポート参照）。

**新規追加提案（2026-07-02）**:
34. **v2.1.198 バックグラウンドエージェント自動 commit/push/ドラフト PR**: エージェントが worktree 完了時に自律的に git 操作を行う仕様変更。セキュリティ・権限設計セクションへの注意事項追記を提案。
35. **v2.1.198 `agent_needs_input` / `agent_completed` Notification フック**: バックグラウンドエージェント状態変化通知フック。hooks セクションへの追記提案。Routine 設計のイベント駆動化に活用可能。
36. **Claude in Chrome GA（v2.1.198）**: ブラウザとの公式ネイティブ統合が一般公開。プラットフォーム統合セクションへの追記提案。
37. **/dataviz スキル（v2.1.198）**: チャート・ダッシュボード設計スキル（実行可能カラーパレットバリデータ含む）。スキル一覧セクションへの追記提案。

#### 新規発見ソース候補
- freeai.help/blog — Claude Code v2.1.198 バックグラウンドエージェント自動 PR の詳細解説記事。評価候補: ⭐⭐⭐

#### 次回リサーチ推奨日
2026-07-03（翌日）。マネーフォワード AI Cowork 正式提供開始アナウンス・Fable 5 グレース期間終了（7/7）前のコスト影響測定を継続監視。
注目点:
① **マネーフォワード AI Cowork 正式提供開始確認**: 7 月開始予定の正式アナウンスを監視。確認次第即時記事化対象。
② **Fable 5 グレース期間（〜7/7）中のコスト影響測定**: 7/8 以降 $10/$50 per Mtok クレジット制移行前に Routine の auto モードでの Fable 5 選択頻度・コスト影響を実測。
③ **v2.1.198 バックグラウンドエージェント挙動確認**: Routine での自動 commit/push/PR 挙動を実観測。意図しない git 操作の有無を確認。
④ **TBP-003・TBP-004 昇格候補**: Tak 確認状況（6/22 提案から 10 日経過）。
⑤ **Claude Code v2.1.199 以降リリース確認**: v2.1.198 の 32 変更に続く追加修正が出る可能性。

---


## [2026-07-01] デイリーレポート

### 内部知見（機能A）
#### 新規・更新 ADR
- My-Profile-and-Memory/decisions/ → フォルダ未存在のためスキップ
- StudyMate, My-URAWA-LOG, tak-work, tak-family, tak-personal → アクセス可能リポジトリ外のためスキップ
- tak-best-practices/ → TBP-001（外部ツール導入審査）・TBP-002（実行環境英語パス）を確認（新規 ADR なし）
- **継続記録（6/22 提案から 9 日目）**:
  1. TBP-003 候補「着手前に実態（git）と文書（backlog）の一致を確認する」— Tak 確認待ち
  2. TBP-004 候補「不可逆性で安全方向を決めるが、カテゴリ丸ごとの保守化は目的を殺す」— Tak 確認待ち

#### TBP 昇格候補
なし（本日は新規 ADR なし）

#### 再検討トリガー該当
- **TBP-001（外部ツール導入審査）継続**: 前回（6/30）の全未確認項目（1〜30）を引き継ぎ継続。
- **TBP-001 新規照合①（Fable 5 復活 — 2026-07-01）**: Fable 5 が 7/1 より全ユーザー向けに復旧（6/12〜6/30 の 19 日間停止後）。auto モードで Fable 5 が選択されるリスクが現実化。7/7 まで週次利用量 50% 含む、7/8 以降は使用クレジット制（$10/$50 per Mtok）に移行。TBP-001「課金体系変更」「地政学リスク」評価項目追記が特に必要な状況に。Research Hub の Routine が auto モードで動作する場合、7/8 以降コスト急増リスクあり。org-configured model restrictions（v2.1.187）で制御可能。
- **TBP-001 新規照合②（ジェイルブレイクスコアリングフレームワーク — 2026-07-01）**: Anthropic・Amazon・Microsoft・Google 共同でジェイルブレイク重大度スコアリングフレームワークを提案。4軸（能力向上度・能力範囲・武器化容易性・発見可能性）。TBP-001「外部 AI ツールの安全性評価」に業界標準スコアリング指標として追記する材料。
- **TBP-002（実行環境英語パス）**: 新規トリガーなし。

---

### 外部リサーチ（機能B）
#### 参照した情報源
- Claude Code 公式チェンジログ: https://code.claude.com/docs/en/changelog（WebFetch）
- WebSearch: Anthropic Claude Code changelog July 2026 new features
- WebSearch: Anthropic news announcement July 1 2026
- WebSearch: Claude Code GitHub issues new July 2026
- WebSearch: Fable 5 Claude Code July 1 2026 available plans pricing
- WebSearch: Anthropic jailbreak scoring framework Amazon Microsoft Google July 2026
- WebSearch: 会計 AI 経理自動化 マネーフォワード freee バクラク 2026年7月
- WebSearch: Claude Code Fable 5 Zenn Qiita 2026年7月1日
- WebSearch: Claude Code security flaw GitHub Action July 2026 vulnerability

#### 🔴 即座に適用すべき事項

**① Claude Fable 5 復活（2026-07-01）— 全ユーザー向け再展開**
- **7/1 より全ユーザー向けに Fable 5 が復旧**（6/12〜6/30 の 19 日間停止後）。米商務省が 6/30 に輸出規制を解除。
- **利用可能プランと期限（重要）**:
  - Pro / Max / Team / Select Enterprise: 7/7 まで週次使用量の最大 **50%** が含まれる（グレース期間）
  - **7/8 以降**: 使用クレジット制（$10/$50 per Mtok）に完全移行
  - 正規料金: 入力 $10/Mtok、出力 $50/Mtok（プロンプトキャッシュ 90% 割引）
- **新しいサイバーセキュリティ分類器**: Fable 5 復旧と同時に追加。ジェイルブレイク耐性強化済み。
- **Research Hub への影響**:
  - auto モードの Routine は 7/1 から Fable 5 が選択される可能性あり
  - 7/7 まではグレース期間内だが、7/8 以降のコスト急増に要注意
  - **推奨対応**: org-configured model restrictions（v2.1.187）で Fable 5 選択を制御するか、グレース期間中にコスト影響を測定
- 参照: Al Jazeera / NBC News / 9to5Mac（2026-07-01）

**② Claude Code GitHub Actions 重大脆弱性（継続確認 — 修正済み v1.0.94）**
- GMO Flatt Security (RyotaK) 発見。prompt injection で CI/CD secrets 窃取・OIDC トークン取得・悪意ある push が可能だった脆弱性。
- **claude-code-action v1.0.94 で修正済み**（6/17 報告から継続確認）。
- **Research Hub への影響**: research-hub で Claude Code GitHub Actions を使用している場合は v1.0.94 以上を確認推奨。
- 参照: The Hacker News / flatt.tech

#### 🟡 近いうちに試したいこと（上位3件）

**① Fable 5 の Routine での動作確認とコスト測定（7/1〜7/7 グレース期間中）**
- 7/7 まではグレース期間内で追加コスト発生なし。この期間に auto モードでの Fable 5 選択頻度・品質・タスク完結率を測定。
- deep-research-runner・auto-research-collect での品質向上を実測し、7/8 以降の $10/$50 コスト対効果を判断する材料に。
- org-configured model restrictions（v2.1.187）で制御しながら段階的に試すアプローチが安全。

**② マネーフォワード AI Cowork の 7 月開始を監視・記事化**
- 7 月提供開始が確認（Claude Agent SDK + MCP 採用のバックオフィス AI サービス）。
- Tak の本業（経理部長）に直結する国内初の大型 Anthropic エージェント基盤採用事例。
- Research Hub の auto-research-collect の「会計×AI 重要発表」枠で即時記事化推奨。

**③ ジェイルブレイクスコアリングフレームワークの詳細確認（Anthropic + 業界共同）**
- Anthropic・Amazon・Microsoft・Google 共同で業界統一ジェイルブレイク重大度スコアリングを提案中。
- 4軸（能力向上度・能力範囲・武器化容易性・発見可能性）。セキュリティ評価の標準化が進む可能性。
- TBP-001 の安全性評価基準のアップデート材料として詳細を追跡。

#### 🟢 参考情報

**Claude Code 最新バージョン状況（7/1 時点）**
- 最新: v2.1.197（6/30 リリース）。主要機能:
  - Claude Sonnet 5 がデフォルトモデル（前回レポート済み）
  - `sandbox.credentials` 設定（クレデンシャルファイルブロック）
  - org-configured model restrictions（モデルピッカー・`--model` 等）
  - マウスクリックサポート（選択メニューのフルスクリーンモード）
  - ストリーミング idle watchdog がデフォルト全プロバイダーで有効（5分無応答→自動リトライ）
  - `--resume` バグ修正（`-p` 実行でモデルターンなしの場合の "No conversation found" 修正）
  - `--json-schema` と `agent({schema})` 構造化出力の信頼性向上

**GitHub Issues 新着（2026-07-01）**
- Issue #72894: Claude Code Routines on web（スケジュール + webhook タスク）— Routine 関連の改善要望（最も関連度高い）
- Issue #72892: Claude Code 動作に関する質問
- Issue #72891: TUI keybindings 強化要望（enhancement）
- Issue #72890: VS Code on Windows のバグ
- Issue #72889: macOS バグ
- Issue #72888: Anthropic API on macOS（duplicate）

**Fable 5 / Mythos 5 復旧詳細（2026-07-01）**
- Fable 5: 全ユーザー向けに 7/1 より復旧（Claude.ai / Claude Platform / Claude Code / Claude Cowork）
- Mythos 5: US 限定解除の状態は継続（一般向け Mythos 5 の扱いは未確認）
- 参照: The Hacker News

**会計×AI トレンド（2026-07-01 時点）**
- **マネーフォワード AI Cowork（2026年7月）**: 7 月提供開始。経理・労務・法務を Claude Agent SDK + MCP で自律遂行。「MCP 設定不要」が差別化点。AI エージェント 4 本命（freee / マネーフォワード / バクラク / TOKIUM）の中で大型リリース。
- **freee**: バックオフィス全体をカバーする SaaS エコシステム継続展開。
- **バクラク AIエージェント**: バックオフィス特化型。API 経由の業務実行・承認フロー組み込みが特徴。

**Zenn / Qiita 日本語コミュニティ（2026-07-01）**
- 「Claude Fable 5 を 1 日使ってみて」（Qiita, yo_arai 氏）— Fable 5 復旧直後の実践レポート（7/1 当日公開）
- 「Claude Fable 5 を解説。性能・料金・セーフガードの仕組みまとめ」（Zenn, sunagaku 氏）
- ITmedia: 「Claude Fable 5、日本で明日再開もサブスクで使えるのは「1週間限定」」

**参考: Claude Sonnet 5 プロモーション価格（継続確認）**
- 〜2026/08/31: $2/$10 per Mtok（プロモーション）
- 2026/09/01 以降: $3/$15 per Mtok（通常価格）
- 9 月以降のコスト増加に備えた消費量試算が必要

#### references.md 更新提案

継続未確認項目（1〜30）: 前回レポート（6/30）の継続未確認項目を引き継ぎ。

**新規追加提案（2026-07-01）**:
31. **Claude Fable 5 復旧（7/1）と料金体系**: 6/12〜6/30 の停止から復旧。7/7 まで週次利用量 50% 含む、7/8〜 $10/$50 per Mtok（キャッシュ 90% 割引）。references.md の「Fable 5 モデル ID」「停止中」注記を「7/1 より復旧、料金 $10/$50 Mtok」に更新提案。
32. **ジェイルブレイクスコアリングフレームワーク（Anthropic + Amazon + Microsoft + Google）**: 業界統一の重大度スコアリング（4軸）を提案中。セキュリティ評価セクションへの追記提案。
33. **Claude Sonnet 5 の 9 月以降価格上昇（$2→$3/$10→$15 per Mtok）**: プロモーション終了日（8/31）の明記と試算推奨を references.md に追記。

#### 新規発見ソース候補
- digitalapplied.com/blog — Fable 5 の 7/7 以降の使用クレジット移行ガイド。評価候補: ⭐⭐⭐
- marktechpost.com — Fable 5 再展開 + サイバーセキュリティ分類器の詳細記事。評価候補: ⭐⭐⭐

#### 次回リサーチ推奨日
2026-07-02（翌日）。Fable 5 復旧後の Routine 実挙動・コスト影響確認・マネーフォワード AI Cowork 7 月開始詳細を監視。
注目点:
① **Fable 5 の Routine 実挙動確認**: auto モードで Fable 5 が選択されているか、コスト影響を実測（7/7 グレース期間内）。
② **マネーフォワード AI Cowork 正式提供開始アナウンス**: 正式日程・価格・プラン詳細確認。即時記事化対象。
③ **TBP-003・TBP-004 昇格候補**: Tak 確認状況（6/22 提案から 9 日経過）。
④ **GitHub Actions 脆弱性 v1.0.94**: research-hub リポジトリでの GitHub Actions 使用有無の確認推奨。
⑤ **Sonnet 5 の Routine コスト試算**: プロモーション価格期間（〜8/31）中に消費量ベースラインを確立。

---## [2026-06-30] デイリーレポート

### 内部知見（機能A）
#### 新規・更新 ADR
- My-Profile-and-Memory/decisions/ → フォルダ未存在のためスキップ
- StudyMate, My-URAWA-LOG, tak-work, tak-family, tak-personal → アクセス可能リポジトリ外のためスキップ
- tak-best-practices/ → TBP-001（外部ツール導入審査）・TBP-002（実行環境英語パス）を確認（新規 ADR なし）
- **継続記録（6/22 提案から 8 日目）**:
  1. TBP-003 候補「着手前に実態（git）と文書（backlog）の一致を確認する」— Tak 確認待ち
  2. TBP-004 候補「不可逆性で安全方向を決めるが、カテゴリ丸ごとの保守化は目的を殺す」— Tak 確認待ち

#### TBP 昇格候補
なし（本日は新規 ADR なし）

#### 再検討トリガー該当
- **TBP-001（外部ツール導入審査）継続**: 課金体系変更・地政学的リスク・デストラクティブ操作自動防御・hook matcher 変更・Sandbox OOM 等の評価項目追記提案が未確認のまま継続（6/15〜6/29 提案、全 27 項目）。
- **TBP-001 新規照合①（Claude Code v2.1.197 — Sonnet 5 がデフォルトモデルに変更、2026-06-30）**: auto モードで選ばれるモデルが Sonnet 4.6 → Sonnet 5 に変更。プロモーション価格は〜8/31 まで $2/$10 per Mtok（その後 $3/$15）。Research Hub の Routine で auto モードが有効な場合はコスト試算の更新が必要。TBP-001「課金コスト予測困難性」「外部ツールのモデル変更リスク」評価項目への追記材料として記録。なお Priority Tier は Sonnet 5 非対応。
- **TBP-001 新規照合②（Claude Apps Gateway — 2026-06-30）**: Amazon Bedrock・Google Cloud 向けの Claude Code 自己ホスト型コントロールプレーン。企業向けに SSO・一元化ポリシー・ロールベースアクセス・ユーザー別コスト追跡・支出上限を設定可能。TBP-001「外部 AI サービスのガバナンス設計」評価項目に「コントロールプレーン型ガバナンスの選択肢」として追記を提案。
- **TBP-002（実行環境英語パス）**: 新規トリガーなし。

---

### 外部リサーチ（機能B）
#### 参照した情報源
- Claude Code 公式チェンジログ: https://code.claude.com/docs/en/changelog（WebFetch）
- WebSearch: Anthropic Claude announcement news June 30 2026
- WebSearch: Claude Code v2.1.197 Sonnet 5 default model June 30 2026 changelog
- WebSearch: anthropics claude-code GitHub issues new June 30 2026
- WebSearch: Claude Science Anthropic life sciences drug discovery June 30 2026
- WebSearch: Claude Code Sonnet 5 Zenn Qiita 新着記事 2026年6月30日
- WebSearch: 会計 AI 経理 自動化 freee マネーフォワード バクラク 2026年6月30日

#### 🔴 即座に適用すべき事項

**① Claude Code v2.1.197（2026-06-30 リリース）— Claude Sonnet 5 がデフォルトモデルに**
- **Claude Sonnet 5 がデフォルトモデルに設定**（最大エージェント特化 Sonnet）:
  - ネイティブ 1M トークンコンテキストウィンドウ・128K max output tokens
  - プロモーション価格: 〜2026/08/31 まで $2/$10 per Mtok（以降 $3/$15）
  - Sonnet 4.6 と同等のツール・プラットフォーム機能（Priority Tier のみ非対応）
  - 計画立案・ブラウザ/ターミナル操作・自律実行が数ヶ月前の大型モデル水準に
- **v2.1.196 の主要機能（6/29 リリース）**（前回レポートから詳細補足）:
  - 組織デフォルトモデル（管理者が Console で設定可）
  - セッションのデフォルト名（起動時に読みやすい名前を自動生成）
  - ファイル添付の Cmd/Ctrl+クリック → Finder/エクスプローラーで即表示
  - バックグラウンドセッション信頼性向上（プロセス停止/再起動後も長実行継続）
  - ストリーム監視（5分間無応答で自動リトライ）がデフォルト全プロバイダーで有効
- **Research Hub への影響**: Routine が auto モードで動作する場合、Sonnet 5 が選択される可能性がある。プロモーション価格期間中（〜8/31）はコスト影響が小さいが、9月以降は $3/$15 に上昇するため事前の消費量試算が必要。

**② Issue #72518 — "Claude Code にスパイウェアが埋め込まれた" 疑惑バグ（2026-06-30、area:security, macOS）**
- タイトルは過激だが、Anthropic が Claude Code に telemetry または予期しない通信を組み込んでいるという疑惑のバグ報告（macOS）。
- **Research Hub への影響**: Routine のクラウド sandbox 環境では直接影響しないが、ローカル環境での Claude Code 利用時に参照すべき情報として記録。Anthropic の公式回答（issue close 理由等）を次回確認推奨。

#### 🟡 近いうちに試したいこと（上位3件）

**① Claude Sonnet 5 の Routine での性能評価**
- 最もエージェント機能に特化した Sonnet モデルとして、deep-research-runner や auto-research-collect でのタスク完結率・品質が向上する可能性。
- プロモーション価格期間（〜8/31）中に積極的に利用し、コスト対効果を測定しておくことを推奨。
- 参照: [Anthropic ブログ](https://www.anthropic.com/news/claude-sonnet-5) / [TechCrunch](https://techcrunch.com/2026/06/30/anthropic-launches-claude-sonnet-5-as-a-cheaper-way-to-run-agents/)

**② Claude Apps Gateway の活用検討（Amazon Bedrock / Google Cloud 向け）**
- Claude Code 向けの企業自己ホスト型コントロールプレーン（SSO・ポリシー・コスト追跡・支出上限）。
- Research Hub の Routine コスト管理を強化する手段として、将来的な移行オプションとして記録。
- 参照: (Anthropic 公式発表、2026-06-30)

**③ Fable 5 一般解除の継続監視（6/30 時点）**
- 6/29 報告では Trump 政権が「7月初旬の解除に向けて準備中」との報道（Axios・GIGAZINE）。
- 6/30 現在、正式解除のアナウンスは未確認。isfableback.org / @AnthropicAI で継続監視推奨。
- 解除後は v2.1.197 で Sonnet 5 と Fable 5 の auto 選択がどう変わるかを確認する必要あり。

#### 🟢 参考情報

**Claude Science — ライフサイエンス向けフラッグシップ新製品（2026-06-30 発表）**
- Anthropic が「Claude Science」を発表。60以上の科学データベース・計算ツールを統合したワークベンチ。
- タンパク質構造予測・薬物毒性予測・薬剤再利用・創薬など、計算生物学・製薬分野に特化。
- 位置付け: Claude Code がプログラミングでやったことを生命科学でも実現する製品。
- Dario Amodei CEO: "Claude Science will do the same for life sciences as Claude Code did for programming."
- Anthropic は社内で「顧みられない疾患」向け薬物探索プログラムも同日開始。
- 対象: Beta として Pro/Max/Team/Enterprise ユーザー向け（macOS・Linux）。
- **Research Hub への直接影響**: なし（Takの本業との直接接点は少ないが、Anthropic の製品拡大戦略として記録）。
- 参照: [Bloomberg](https://www.bloomberg.com/news/articles/2026-06-30/anthropic-releases-claude-science-for-automating-research) / [CNBC](https://www.cnbc.com/2026/06/30/anthropic-launches-ai-drug-discovery-program-claude-science.html) / [MIT Technology Review](https://www.technologyreview.com/2026/06/30/1139987/claude-science-is-anthropics-newest-flagship-product/)

**Anthropic × カリフォルニア州パートナーシップ（2026-06-30）**
- カリフォルニア州が Anthropic と協定を締結。州機関・市・郡に対し Claude 50% 割引 + 無料ワークフォーストレーニング・技術支援を提供。
- **Research Hub への直接影響**: なし。ただし公共機関向け AI 展開の参考情報として記録。

**GitHub Issues 新着（2026-06-30）**
- Issue #72612: API/agents バグ（macOS）
- Issue #72611: TUI 改善要望（enhancement）
- Issue #72609: API バグ（macOS、needs-repro）
- Issue #72608: MCP 改善要望（enhancement）
- Issue #72607: browser/Chrome 拡張 duplicate バグ（macOS）
- Issue #72606: agents 改善要望（VS Code）
- Issue #72605: auth/CLI バグ
- Issue #72518: [BUG] "spyware" 疑惑（← 🔴② 参照）
- **Research Hub の Routine 動作への直接影響**: #72518（security）が参考情報として最も関連度高い。他は軽微な bug/enhancement。

**Claude Sonnet 5 国内メディア反応（2026-06-30 時点）**
- ITmedia が即日報道（「Sonnet 5 公開──停止中のミュトスとは別に Opus 級」）。
- Zenn/Qiita の詳細解説記事は今後出てくる見込み（Sonnet 5 発表が本日夕方のため）。
- 参照: [ITmedia（一部 7/1 付）](https://www.itmedia.co.jp/news/articles/2607/01/news057.html) / [ai-heartland.com](https://ai-heartland.com/news/news-claude-sonnet-5-release/)

**会計×AI トレンド（2026-06-30 時点）**
- 本日固有の新発表なし（継続トレンド）。
- freee MCP・マネーフォワード AI Cowork（7月提供予定）・バクラク AIエージェントのトレンドが継続。
- freee × Claude Code 実践ガイド（firecracker.jp/blog/freee-claude-code）が実務派に好評。
- 経理 AI 導入効果: 仕訳入力 80% 削減・請求書処理 70% 短縮・月次決算 5 営業日早期化が標準報告値として定着。

**Fable 5 / Mythos 5 状況（6/30 時点）**
- 6/29 時点で「Trump 政権が 7月初旬の一般解除に向けて準備中」（Axios・GIGAZINE）。
- 6/30 現在、正式解除アナウンスは未確認。Sonnet 5 がデフォルトモデルになったことで、Fable 5 復旧後の auto 選択ロジックがどう変わるかも要確認。

#### references.md 更新提案

継続未確認項目（6/15〜6/29 提案から継続、全 27 項目）:
1〜27: 前回レポート（6/29）の references.md 継続未確認項目（1〜25 + 26〜27）を引き継ぎ。

**新規追加提案（2026-06-30）**:
28. **Claude Code v2.1.197 — Claude Sonnet 5 がデフォルトモデルに**: references.md の「デフォルトモデル」「コスト試算」セクションへの追記提案。プロモーション価格（〜8/31: $2/$10, 以降: $3/$15）と Priority Tier 非対応を記載。
29. **Claude Apps Gateway（Bedrock/GCP 向け）**: 企業向け Claude Code コントロールプレーン（SSO・ポリシー・コスト追跡・支出上限）。ガバナンス設計セクションへの追記提案。
30. **Claude Science（2026-06-30）**: ライフサイエンス向け新製品。60+ 科学 DB 統合ワークベンチ。Anthropic 製品ロードマップセクションへの追記提案。

#### 新規発見ソース候補
- [ai-heartland.com/news](https://ai-heartland.com/news/news-claude-sonnet-5-release/) — Claude Sonnet 5 の全仕様解説（日本語・詳細）。評価候補: ⭐⭐⭐
- [theaicronicle.com](https://theaicronicle.com/en/news/research/anthropic-claude-science-pharma-research) — Claude Science の製薬研究への活用解説。評価候補: ⭐⭐⭐

#### 次回リサーチ推奨日
2026-07-01（翌日）。Fable 5 一般解除動向・Claude Sonnet 5 の Routine での実挙動確認・Issue #72518 の Anthropic 公式回答を監視。
注目点:
① **Fable 5 一般解除確認**: Trump 政権「7月初旬」見込み。7/1 が最初の観測ポイント。解除後は Sonnet 5 + Fable 5 の auto 選択ロジックを確認。
② **Claude Sonnet 5 の Routine での挙動確認**: v2.1.197 更新後、auto-research-collect 等の Routine で Sonnet 5 が選ばれているか確認。コスト影響を試算。
③ **Issue #72518 の続報**: Anthropic の公式回答（close 理由・security 説明）を確認。
④ **マネーフォワード AI Cowork 7月提供開始**: 正式な提供開始アナウンスがあれば即時記事化推奨。
⑤ **TBP-003・TBP-004 昇格候補**: Tak 確認状況（6/22 提案から 8 日経過）。

---
## [2026-06-29] デイリーレポート

### 内部知見（機能A）
#### 新規・更新 ADR
- My-Profile-and-Memory/decisions/ → フォルダ未存在のためスキップ
- StudyMate, My-URAWA-LOG, tak-work, tak-family, tak-personal → アクセス可能リポジトリ外のためスキップ
- tak-best-practices/ → TBP-001（外部ツール導入審査）・TBP-002（実行環境英語パス）を確認（新規 ADR なし）
- **継続記録（6/22 提案から 7 日目）**:
  1. TBP-003 候補「着手前に実態（git）と文書（backlog）の一致を確認する」— Tak 確認待ち
  2. TBP-004 候補「不可逆性で安全方向を決めるが、カテゴリ丸ごとの保守化は目的を殺す」— Tak 確認待ち

#### TBP 昇格候補
なし（本日は新規 ADR なし）

#### 再検討トリガー該当
- **TBP-001（外部ツール導入審査）継続**: 課金体系変更・地政学的リスク・デストラクティブ操作自動防御・hook matcher 変更・Sandbox OOM 等の評価項目追記提案が未確認のまま継続（6/15〜6/28 提案、全 25 項目）。
- **TBP-001 新規照合①（Claude in Microsoft Foundry GA — 2026-06-29）**: Azure 上で Claude Opus 4.8 + Haiku 4.5 が Messages API で GA。エンタープライズ向けに Azure の認証・課金・ガバナンスコントロールを使用して Claude を利用可能に。TBP-001「外部 AI サービスのガバナンス設計」にエンタープライズ環境でのマルチクラウド接続パターン（Azure Foundry 経由の Claude Code 設定ドキュメントも公開）を追加する材料として記録。
- **TBP-001 新規照合②（Issue #72367 — Sandbox OOM バグ、2026-06-29 新着）**: Sandbox が workspace を再帰的に node_modules まで列挙してメモリ枯渇（OOM）になるバグ（area:sandbox, perf:memory, has repro, linux）。Research Hub の Routine は Linux サンドボックス上で動作するため、長時間タスクでのメモリ枯渇リスクが存在する。TBP-001「外部ツール導入審査」の「実行環境リソース上限」評価項目として追記を提案。
- **TBP-002（実行環境英語パス）**: 新規トリガーなし。

---

### 外部リサーチ（機能B）
#### 参照した情報源
- Claude Code 公式チェンジログ: https://code.claude.com/docs/en/changelog（WebFetch）
- anthropics/claude-code GitHub Issues: https://github.com/anthropics/claude-code/issues（WebFetch）
- WebSearch: Anthropic Claude announcement news June 29 2026
- WebSearch: Claude Code v2.1.196 v2.1.197 release changelog June 29 2026
- WebSearch: Fable 5 Mythos 5 復旧 status June 29 2026
- WebSearch: Claude Azure Microsoft Foundry generally available June 2026
- WebSearch: 会計 AI 経理 自動化 マネーフォワード freee バクラク 2026年6月29日
- WebSearch: Claude Code Zenn Qiita 新着記事 2026年6月29日

#### 🔴 即座に適用すべき事項

**① Issue #72367 — Sandbox が node_modules を再帰列挙 → メモリ枯渇 OOM（2026-06-29 新着、area:sandbox, perf:memory, has repro, linux）**
- Sandbox が workspace を再帰的に列挙する際に node_modules を含めてしまいメモリ上限に到達する深刻なバグ（再現確認済み）。
- **Research Hub への影響**: auto-research-collect・deep-research-runner 等の Routine が Linux サンドボックス上で動作するため、node_modules を含むディレクトリ構造が存在する場合に Routine が途中終了するリスク。
- **推奨アクション**: Routine 内で使用しているディレクトリに node_modules が存在していないか確認。worker/ ディレクトリの node_modules が sandbox 起動時に列挙対象になっていないかチェック推奨。修正パッチリリース（v2.1.196 以降）を監視。

**② Claude in Microsoft Foundry が本日 GA（2026-06-29）**
- Claude Opus 4.8 と Haiku 4.5 が Azure 上で一般提供開始（Messages API）。
- 課金: Claude Consumption Units (CCU) として Azure 請求に統合（MACC ドローダウン対応）。
- エンタープライズ向けに Azure の認証・ネットワーク・ガバナンス・データレジデンシー（US データゾーン選択可）が使用可能。
- **Research Hub への直接影響**: 現在 Anthropic Routines で直接利用しているため Azure Foundry へ移行の必要はない。ただし将来的な企業環境での Claude Code 利用拡大シナリオの参考として記録。

#### 🟡 近いうちに試したいこと（上位3件）

**① Fable 5 の 7 月初旬復旧への準備（6/29 最新報道）**
- Trump 政権が Fable 5 の全般解除に向けて準備中との報道（Axios・GIGAZINE 6/29）。Pentagon・NSA の正式クリアは未取得だが 7 月初旬の解除が有力視される。
- Mythos 5 は 6/26〜27 に US 重要インフラ組織向けに限定解除済みで、次のステップは一般向け Fable 5 解除。
- **推奨アクション**: 復旧直後に auto モードで Fable 5 が選ばれ Agent SDK クレジット消費量が急増する可能性。org-configured model restrictions（v2.1.187）で一時ブロックする準備を事前に行うか、消費量監視を強化しておく。isfableback.org / Anthropic 公式 X（@AnthropicAI）でリアルタイム監視推奨。

**② Claude Code on Microsoft Foundry ドキュメント確認（6/29 新着）**
- Azure 環境でのエンタープライズ向け Claude Code 設定方法が公式ドキュメントとして公開（code.claude.com/docs/en/microsoft-foundry）。
- Tak の現環境（Anthropic Routines）への直接影響はないが、社内展開や組織向け Claude Code 利用を検討する際の参考に。

**③ Issue #72359 — Project memory & session context がリポジトリのリネーム/移動で孤立するバグ（2026-06-29 新着）**
- .claude/ ディレクトリの project memory とセッションコンテキストが、リポジトリのディレクトリを rename/move したときにサイレントに切り離されるバグ（enhancement）。
- research-hub や My-Profile-and-Memory のディレクトリを移動した場合の注意点として記録。

#### 🟢 参考情報

**GitHub Issues 新着（2026-06-29）**
- Issue #72367: Sandbox OOM（area:sandbox, perf:memory, has repro, linux）← 🔴参照
- Issue #72366: Feature Request — 左サイドバーに Pinned / Current Works / Recents を追加（area:ui, enhancement）
- Issue #72365: Cyber block false positive — H.264 ビデオデコードパイプラインのデバッグが誤ブロック（area:model, bug, linux）
- Issue #72364: Feature Request — Agent 完了/停止時間の表示改善（area:agent-view, area:tui, enhancement）
- Issue #72362: Feature Request — 単一プロンプト向けワンショットモデルオーバーライド（area:model, enhancement）
- Issue #72360: TUI fullscreen が iTerm2 でスクロールバックを妨害するバグ（area:tui, bug, macos）
- Issue #72359: Project memory がリポジトリリネーム/移動で孤立（memory, enhancement）← 🟡③参照
- Issue #72358・#72357・#72355・#72354: Cyber block false positive 複数件（ドローン飛行 UI、ffmpeg パラメータ調整 — 重複含む、area:model, bug）
- Issue #72356: Agent execution loop が corrupted state に（area:agents, bug, needs-repro, intellij, macos）
- **Research Hub の Routine 動作への直接影響**: #72367（Sandbox OOM）が最も関連度高い。

**Fable 5 / Mythos 5 状況（17 日目、2026-06-29 時点）**
- **Fable 5（一般向け）**: 依然停止継続。6/12 の輸出規制指令の効力が継続中（刑事・民事罰則付き）。
- **Mythos 5**: 6/26〜27 の Lutnick 書簡により、US 重要インフラ組織・US 政府機関・Anthropic 外国人スタッフに限定解除（変更なし）。
- **次のステップ**: Pentagon・NSA の正式クリアが出れば Fable 5 の一般向け解除へ。Trump 政権が 7 月初旬の解除に向けて準備中との報道（Axios 6/27、GIGAZINE 6/29）。
- 参照: [GIGAZINE](https://gigazine.net/gsc_news/en/20260629-anthropic-fable-5-return-soon/) / [Axios 6/27](https://www.axios.com/2026/06/27/anthropic-fable-5-return-soon) / [TechTimes 6/28](https://www.techtimes.com/articles/319213/20260628/claude-fable-5-still-offline-us-clears-mythos-5-critical-infrastructure.htm)

**Claude Code バージョン（6/29 時点）**
- 最新バージョンは v2.1.195（6/26 リリース）から変更なし。v2.1.196 以降は本日時点で未確認。
- チェンジログ: https://code.claude.com/docs/en/changelog で確認済み。

**Claude in Microsoft Foundry GA（2026-06-29）詳細**
- Anthropic と Microsoft の協業拡大として GA 発表。Claude Opus 4.8 + Haiku 4.5 対応（Messages API）。
- プロンプトキャッシング・extended thinking も利用可能。
- Claude Code の Foundry 向け設定ドキュメントも同日公開（code.claude.com/docs/en/microsoft-foundry）。
- 参照: [Anthropic ブログ](https://claude.com/blog/claude-in-microsoft-foundry) / [Azure ブログ](https://azure.microsoft.com/en-us/blog/claude-in-microsoft-foundry-is-now-generally-available/)

**会計×AI トレンド（2026-06-29 時点）**
- 本日固有の新発表なし（継続トレンド）。
- freee MCP・マネーフォワード AI Cowork（7月提供予定）・バクラク AIエージェントのトレンドが継続。
- 経理 AI の「3階層モデル（SaaS + AI + 業務フロー）」実装ガイドが充実（aipicks.jp, firecracker.jp 等で解説記事増加）。
- freee MCP 完全ガイド（hatenabase.jp/blog/freee-mcp/）が実務派に好評。Claude Code との統合事例として記録。

**Zenn / Qiita 日本語コミュニティ（2026-06-29 時点）**
- 本日固有の新記事は確認できず（6/29 時点では前日・前週の記事が引き続き参照多数）。
- 参照継続: 「Claude Code と Zenn 執筆環境を一から育てた記録」（shimo4228）・「Claude Code を"優秀な新卒部下"として使い倒す」（yoshiaki0217）。
- v2.1.195 の日本語解説記事は今後出てくる見込み。

#### references.md 更新提案

継続未確認項目（6/15〜6/28 提案から継続、全 25 項目）:
1〜25: 前回レポート（6/28）の references.md 継続未確認項目（1〜21 + 22〜25）を引き継ぎ。

**新規追加提案（2026-06-29）**:
26. **Claude in Microsoft Foundry GA（6/29）**: Azure 上での Claude Opus 4.8 + Haiku 4.5 GA。エンタープライズ向け Claude 利用の設定・課金（CCU）を references.md のエンタープライズ展開セクションへ追記提案。
27. **Claude Code on Microsoft Foundry ドキュメント（6/29）**: code.claude.com/docs/en/microsoft-foundry が新設。Foundry 経由の Claude Code 設定方法として参照セクションへの追記提案。

#### 新規発見ソース候補
- [capacityglobal.com/news](https://capacityglobal.com/news/fable5-return-imminent/) — Fable 5 / Mythos 5 政策動向の速報。地政学的リスク追跡として評価候補: ⭐⭐⭐
- [isfable5back.com](https://isfable5back.com/) — Fable 5 復旧状況リアルタイムチェッカー（isfableback.org と別サイト）。評価候補: ⭐⭐⭐

#### 次回リサーチ推奨日
2026-06-30（翌日）。Fable 5 一般向け解除の動向（7月初旬見込み）・v2.1.196 リリース確認・Issue #72367（Sandbox OOM）パッチ対応を監視。
注目点:
① **Fable 5 一般向け解除確認**: Trump 政権の 7 月初旬解除見込みを受けて翌日も監視継続。
② **v2.1.196 以降リリース確認**: Sandbox OOM (#72367) 等のバグ修正パッチを監視。
③ **マネーフォワード AI Cowork 7 月提供開始**: 7 月初旬の提供開始情報を記事化できるか確認。
④ **TBP-003・TBP-004 昇格候補**: Tak 確認状況（6/22 提案から 7 日経過）。
⑤ **Azure Foundry + Claude Code 活用事例**: GA 直後の初期事例・ユーザーレポートを確認。

---
## [2026-06-28] デイリーレポート

### 内部知見（機能A）
#### 新規・更新 ADR
- My-Profile-and-Memory/decisions/ → フォルダ未存在のためスキップ
- StudyMate, My-URAWA-LOG, tak-work, tak-family, tak-personal → アクセス可能リポジトリ外のためスキップ
- tak-best-practices/ → TBP-001（外部ツール導入審査）・TBP-002（実行環境英語パス）を確認（新規 ADR なし）
- **継続記録（6/22 提案から 6 日目）**:
  1. TBP-003 候補「着手前に実態（git）と文書（backlog）の一致を確認する」— Tak 確認待ち
  2. TBP-004 候補「不可逆性で安全方向を決めるが、カテゴリ丸ごとの保守化は目的を殺す」— Tak 確認待ち

#### TBP 昇格候補
なし（本日は新規 ADR なし）

#### 再検討トリガー該当
- **TBP-001（外部ツール導入審査）継続**: 課金体系変更・地政学的リスク・デストラクティブ操作自動防御・Agent deny rules 修正・sandbox.credentials・org-configured model restrictions の評価項目追記提案が未確認のまま継続（6/15〜6/28 提案、全 21 項目）。
- **TBP-001 新規照合①（マネーフォワード AI Cowork — Claude Agent SDK × MCP 採用）**: マネーフォワードが 2026年7月 より AI Cowork を提供開始（4月発表）。技術基盤に Claude Agent SDK + MCP を採用。バックオフィス（会計・労務・法務）を自律遂行する AI エージェントサービス。Draft & Approve（AI下書き→人間承認）・AI 監査ログ・ガードレール機能を搭載。TBP-001「外部 AI サービスのガバナンス設計」評価項目に「エージェント系サービスの Draft & Approve パターン」を追記する材料。
- **TBP-001 新規照合②（Claude Code v2.1.195 — pkill regex over-matching セキュリティ問題）**: GitHub issue #72153 より、Auto-Classifier が危険な `pkill -f` コマンドを hidden regex over-matching で許可してしまうバグが報告（2026-06-28）。allowlist/denylist ルールの regex が over-match するリスクは TBP-001「最小権限で開始」の重要な実装注意点として記録。
- **TBP-002（実行環境英語パス）**: 新規トリガーなし。

---

### 外部リサーチ（機能B）
#### 参照した情報源
- Claude Code 公式チェンジログ: https://code.claude.com/docs/en/changelog（WebFetch）
- Claude Code GitHub Releases: https://github.com/anthropics/claude-code/releases（WebFetch）
- Claude Code GitHub Issues: https://github.com/anthropics/claude-code/issues（WebFetch）
- WebSearch: Anthropic Claude announcement June 28 2026
- WebSearch: Claude Code new features update June 28 2026
- WebSearch: 会計 AI 経理 自動化 freee マネーフォワード 2026年6月28日
- WebSearch: Claude Code Zenn Qiita 新着記事 2026年6月28日
- WebSearch: マネーフォワード AI Cowork Claude Agent SDK MCP 2026年7月
- WebSearch: Claude Managed Agents sandbox MCP private 2026年6月
- WebSearch: Claude Corps Anthropic fellowship program 2026

#### 🔴 即座に適用すべき事項

**① [Bug] pkill -f コマンドの Auto-Classifier 危険 regex over-match（GitHub #72153, 2026-06-28）**
- Auto-Classifier が `pkill -f` などの危険なコマンドを hidden regex over-matching によって誤って許可してしまうバグが報告。
- Research Hub の Worker や Supabase Edge Function 経由のタスクでは直接影響しないが、Routines でシェルコマンドを allowlist に登録している場合、regex の over-match リスクを認識しておく必要あり。
- **推奨アクション**: `.claude/settings.json` の allow パターンを正規表現的に確認し、予期しないコマンドが許可されていないか見直す。

**② Claude Code Desktop が Fable 5 停止後に EPERM エラーでクラッシュ（GitHub #72157, 2026-06-28）**
- Fable 5 停止（6/12）後、Claude Code Desktop が EPERM エラーでクラッシュするバグが確認。
- Fable 5 が未解除の現在（6/28 時点、一般向けは未確定）も続いている可能性あり。
- **推奨アクション**: Claude Code Desktop を使用している場合は `claude --version` で最新版（v2.1.195）への更新を確認。

#### 🟡 近いうちに試したいこと（上位3件）

**① マネーフォワード AI Cowork（2026年7月提供開始）**
- バックオフィス業務（会計・労務・法務）を自律遂行する AI エージェントサービス。Claude Agent SDK + MCP 採用。
- Draft & Approve パターン（AI 下書き→人間最終承認）とガードレール機能・AI 監査ログを搭載。
- Tak の本業（経理部長）に直結。7月提供開始後に評価。
- 参照: [マネーフォワード プレスリリース](https://corp.moneyforward.com/news/release/service/20260407-mf-press-1/)

**② Claude Code v2.1.195 の `/plugin marketplace update` + `/reload-plugins` バグ（GitHub #72162）**
- プラグインマーケットプレイス更新後、`/reload-plugins` を実行しても変更が反映されない問題（macOS）。
- Research Hub の Routines でプラグインを使用している場合に影響する可能性あり。
- v2.1.196 以降での修正を待つか、workaround として Claude Code 再起動が必要な可能性。

**③ Claude Code 6月新機能 — ネストサブエージェント5段階 + /cd コマンド**
- Zenn/Qiita での解説記事が活発（kai_kou 氏 Qiita 記事）。ネストサブエージェントの5段階対応と `/cd` コマンドによる自律開発実現が主なトピック。
- Research Hub の deep-research-runner や auto-research-collect でサブエージェントを活用する場合の参考に。
- 参照: [Qiita 記事（Claude Code 6月新機能）](https://qiita.com/kai_kou/items/81cee59a85d82535e986)

#### 🟢 参考情報

**① Claude Corps — Anthropic $150M フェローシップ（2026-06-12〜17 発表）**
- Anthropic が非営利団体向けに 1,000人の AI フェローを配置する $150M フェローシップを開始。
- 報酬 $85,000/年（1年間）。初回 100 人は 2026-10-19 開始。応募締切 7/17。
- 対象: 18歳以上・フルタイム就業 2年未満。米国非営利団体への AI 実装支援。
- Research Hub や Tak 自身の AI 活用との直接接点は少ないが、Anthropic の社会的取り組みとして記録。
- 参照: [Anthropic Claude Corps](https://www.anthropic.com/news/claude-corps)

**② Claude Managed Agents — 自己ホスト型 Sandbox + MCP Tunnels（2026-05-26 Code with Claude London 発表）**
- 自己ホスト型 Sandbox（パブリックベータ）: エージェントループは Anthropic インフラ、ツール実行は自社環境。Cloudflare/Daytona/Modal/Vercel 等で管理可能。
- MCP Tunnels（リサーチプレビュー）: プライベートネットワーク内の MCP サーバーへ外部公開なしでアクセス可能。
- Research Hub の Worker/Supabase 構成でのセキュリティモデル強化に参考になる設計思想。
- 参照: [Anthropic ブログ](https://claude.com/blog/claude-managed-agents-updates)

**③ freee「AIおまかせ明細取得」β版提供開始（2026-03-26 発表）**
- PDF 等からの仕訳元データ（明細）を AI で自動作成するβ機能。
- マネーフォワード AI Cowork との比較軸として、freee の AI 戦略の方向性を示す。

**④ Zenn/Qiita 注目記事（2026年6月後半）**
- 「Claude Codeを"優秀な新卒部下"として使い倒す」（Zenn, yoshiaki0217）: 個人開発爆速化の全ワークフロー。
- 「Claude Codeと Zenn 執筆環境を一から育てた記録」（Zenn, shimo4228）: pre-commit hook から learnings スキルへの自動抽出フロー。
- 「コードを書けない私が、AIに『チーム』を持たせるまで」（Qiita, saitoko）: SE歴26年の管理職が Claude Code で 9体 AI 編集部を構成した実践録。

#### references.md 更新提案
変更なし。今回の外部情報は Claude Code のバグ修正・フェローシップ・会計系サービス更新が中心であり、Anthropic 公式ベストプラクティスドキュメントの変更は確認されていない。

#### 新規発見ソース候補
- [AI Agent Journal](https://ai-agent.platina-life.com/) — マネーフォワード AI Cowork 等の国内 AI エージェントニュースに詳しい。追加評価候補。評価目安: ⭐⭐⭐
- [AI/DX Media (image-pit.com)](https://media.image-pit.com/) — Claude Agent SDK × 国内ビジネス事例の解説記事あり。評価目安: ⭐⭐⭐

#### 次回リサーチ推奨日
2026-06-29（翌日）。マネーフォワード AI Cowork の正式提供開始状況（7月予定）と Fable 5 一般解除動向を引き続き監視。

---

## [2026-06-27] デイリーレポート

### 内部知見（機能A）
#### 新規・更新 ADR
- My-Profile-and-Memory/decisions/ → フォルダ未存在のためスキップ
- StudyMate, My-URAWA-LOG, tak-work, tak-family, tak-personal → アクセス可能リポジトリ外のためスキップ
- tak-best-practices/ → TBP-001（外部ツール導入審査）・TBP-002（実行環境英語パス）を確認（新規 ADR なし）
- **継続記録（6/22 提案から 5 日目）**:
  1. TBP-003 候補「着手前に実態（git）と文書（backlog）の一致を確認する」— Tak 確認待ち
  2. TBP-004 候補「不可逆性で安全方向を決めるが、カテゴリ丸ごとの保守化は目的を殺す」— Tak 確認待ち

#### TBP 昇格候補
なし（本日は新規 ADR なし）

#### 再検討トリガー該当
- **TBP-001（外部ツール導入審査）継続**: 課金体系変更・地政学的リスク・デストラクティブ操作自動防御・Agent deny rules 修正・sandbox.credentials・org-configured model restrictions の評価項目追記提案が未確認のまま継続（6/15〜6/26 提案、全 21 項目）。
- **TBP-001 新規照合①（Claude Mythos 5 US 限定解除 — 最重要）**: 6/26〜27 に米国政府（商務省）が Anthropic に対し Mythos 5 を 100+ 米国企業・政府機関へリリースすることを許可。6/12 の輸出規制指令（deemed export）による停止から 15 日目での部分解除。Fable 5（一般公開版）については政府レターに記載なし。関係者によれば解除に向けて交渉継続中だが timeline 未定。「外部 AI サービスは地政学的リスク・輸出規制による突然のサービス停止リスクを持つ」（6/16 提案の TBP-001 追記候補）の最新具体例として記録。
- **TBP-001 新規照合②（v2.1.195 hook matchers exact-match 変更）**: ハイフン含む識別子（`code-reviewer`, `mcp__brave-search` 等）の hook matcher が substring-match → exact-match に変更（v2.1.195, 6/26）。settings.json の deny/allow ルールで hyphenated ツール名を指定している場合、今まで substring で意図しない幅広マッチが発生していた可能性。v2.1.195 更新後に既存 hook 設定の挙動確認を推奨。TBP-001「最小権限で開始」の実効性評価項目に「バージョン毎の hook/deny 設定挙動確認」を追記する材料。
- **TBP-002（実行環境英語パス）**: 新規トリガーなし。

---

### 外部リサーチ（機能B）
#### 参照した情報源
- Claude Code 公式チェンジログ: https://code.claude.com/docs/en/changelog（WebFetch）
- anthropics/claude-code GitHub Issues: https://github.com/anthropics/claude-code/issues（WebFetch）
- WebSearch: Anthropic Claude Mythos 5 Fable 5 US institutions limited release June 27 2026
- WebSearch: Anthropic Claude new release announcement June 27 2026
- WebSearch: 会計 AI 経理 自動化 freee マネーフォワード バクラク 2026年6月27日
- WebSearch: Claude Code Zenn Qiita 新着記事 2026年6月27日
- WebSearch: マネーフォワード AI Cowork 2026年7月 freee MCP AI会計

#### 🔴 即座に適用すべき事項

**① Claude Mythos 5 — 米国政府が 100+ 機関への限定解除を承認（2026-06-26〜27 最新）**
- 米国政府（商務省）が Anthropic に対し、Claude Mythos 5 を 100 以上の米国企業・政府機関へリリースすることを許可。
- 背景: 6/12 の輸出規制指令（deemed export）による全面停止後 15 日目での部分解除。Amazon CEO アンディ・ジャシーが財務長官に Fable 5 のジェイルブレイク脆弱性を報告したことが停止の引き金。
- **Fable 5（一般公開版）の扱い**: 政府レターは Fable 5 について明示せず。関係者によれば Fable 5 解除に向けて交渉継続中だが、具体的な timeline は未定。
- **Research Hub への影響**: Fable 5 の一般解除は未確定のため、引き続き Opus 4.8 / Sonnet 4.6 が auto モードで使用される可能性が高い。復旧後の Agent SDK クレジット消費急増に備えた準備（org-configured model restrictions での一時ブロック等）を推奨。
- 参照: [9to5Mac](https://9to5mac.com/2026/06/26/anthropic-cleared-to-release-claude-mythos-5-to-over-100-us-institutions/) / [Semafor](https://www.semafor.com/article/06/27/2026/us-releases-powerful-anthropic-model-mythos-to-some-us-companies) / [CNN](https://edition.cnn.com/2026/06/26/tech/anthropic-mythos-release) / [CNBC](https://www.cnbc.com/2026/06/26/us-government-anthropic-claude-mythos5-ai.html)

**② Claude Code v2.1.195（2026-06-26 リリース）— hook matchers 修正 + voice 修正**
- **`CLAUDE_CODE_DISABLE_MOUSE_CLICKS` 設定追加**: フルスクリーンモードでマウスクリック/ドラッグ/ホバーを無効化しつつスクロールは維持。誤クリックによる意図しない操作を防げる。
- **hook matchers with hyphenated identifiers の修正（重要）**: `code-reviewer` や `mcp__brave-search` のようなハイフン含む識別子が substring-match → exact-match に変更。既存の hook/deny ルールの挙動確認が必要（↑再検討トリガー②参照）。
- **voice dictation auto-submit 修正（日本語・中国語・Thai 含む）**: スペースなしで書く言語での auto-submit が発動しなかったバグを修正。Routine での日本語音声入力がある場合に影響。
- **macOS voice dictation の長時間セッション修正**: 入力デバイス変更後に無音を録音するバグを修正。
- **external plugins の install consent 修正**: project `.claude/settings.json` のみで有効化された外部プラグインが明示的なインストール同意を要求するよう修正（セキュリティ強化）。
- **background jobs データ消失修正**: 新バージョンで書き込まれた background jobs が消失または データロスするバグを修正。
- **Remote session startup 改善**: provisioning checklist 追加により起動時の状態把握が容易に。
- **`claude agents` 完了リスト改善**: 利用可能な縦方向スペースを最大限活用するよう改善。
- **Research Hub への影響**: hook matchers の exact-match 変更が最も影響大。settings.json の既存 deny/allow ルール確認を推奨。

#### 🟡 近いうちに試したいこと（上位3件）

**① v2.1.195 hook matchers 変更後の既存設定確認**
- `code-reviewer`, `mcp__brave-search` 等のハイフン含む識別子を hook/deny ルールで使用している場合、exact-match 変更後の挙動が変わる可能性がある。
- Research Hub の Routine 設定で hyphenated ツール名を指定している箇所があれば動作確認を推奨。
- v2.1.178 の `Tool(param:value)` 構文と組み合わせて使用している場合も注意が必要。

**② マネーフォワード AI Cowork（2026年7月提供開始）の追跡と記事化**
- MCP サーバーの設定・運用が一切不要で、AI が自律的に経理・労務・法務等のバックオフィス業務を遂行するサービス。
- Anthropic Claude Agent SDK + MCP を技術基盤として採用した国内初の大型 SaaS 事例。複数の AI エージェントが並列かつ自律的に連携。
- 7 月提供開始後に Research Hub の auto-research-collect の「会計×AI 重要発表」枠で即時記事化推奨。
- 参照: [マネーフォワード公式](https://corp.moneyforward.com/news/release/service/20260407-mf-press-1/)

**③ Fable 5 一般解除への準備（Mythos 5 US 限定解除を受けて）**
- Mythos 5 の US 限定解除（6/26-27）確認済み。Fable 5 の解除も交渉継続中と報道。
- org-configured model restrictions（v2.1.187）で Fable 5 復旧直後の auto モード選択を一時ブロックするか、Agent SDK クレジット消費量の急増に備えた監視体制の準備を推奨。
- 復旧シグナルは isfableback.org 等で随時確認。

#### 🟢 参考情報

**GitHub Issues 新着（2026-06-27）**
- Issue #71923: Feature Request — Claude thinking の TUI 表示可視性向上（area:tui, enhancement, macos）
- Issue #71922: BUG — claude-in-chrome set_permission_mode storm が CLI セッション全体を起動時に wedge（area:chrome, area:mcp, bug, has repro, windows）
- Issue #71921: Feature Request — クリッカブルオプションの UX 改善（area:tui, area:ui, enhancement, linux, user-experience）
- Issue #71920〜71912: ドローン開発関連の safety block バグ複数件（area:model, area:security, bug, duplicate）— Research Hub への直接影響なし
- Issue #71914: BUG — Gmail integration fail（area:mcp, bug, external, windows）
- Issue #71913: FEATURE — `.worktreeinclude` に git-ignored でないファイルのサポート（area:cli, enhancement）
- **Research Hub の Routine 動作への直接影響**: #71922（chrome MCP wedge on Windows）・#71914（Gmail MCP fail on Windows）が関連するが、Research Hub の Routine は Linux sandbox で動作するため直接影響は軽微。

**Anthropic 新機能・発表（2026-06-27）**
- **Claude on Apple Foundation Models**: iOS 27 / iPadOS 27 / macOS 27 / visionOS 27 / watchOS 27 で Apple Foundation Models framework 経由で Claude が利用可能に。Apple AI との公式統合が実現。
- **Claude Managed Agents（詳細発表）**: ユーザーが管理する sandbox 内で動作し、プライベート MCP サーバーにも接続可能。エージェントが実行するツールの環境と接続先サービスを enterprise 境界内に収めることが可能。Research Hub アーキテクチャの将来的な発展オプションとして記録。
- **Trusted Devices for Remote Control Admins（Team/Enterprise）**: Remote Control セッション前にデバイス認証が可能に。セキュリティ強化。
- **Anthropic Economic Index レポート（2026年6月）**: AI の経済的影響に関する最新レポート公開。[Anthropic Research](https://www.anthropic.com/research/economic-index-june-2026-report)

**Fable 5 / Mythos 5 状況（2026-06-27 最新 — 15 日目）**
- Mythos 5: US 政府が 100+ 機関への限定解除を承認（6/26〜27）。一般公開ではなく、特定の US 企業・政府機関向け。
- Fable 5（一般公開版）: 政府レターに記載なし。交渉継続中。Timeline 未定。
- **Research Hub への影響**: Fable 5 の一般解除が確認されるまで、引き続き Opus 4.8 / Sonnet 4.6 が使用される状態が継続。

**会計×AI トレンド（2026-06-27 時点）**
- **マネーフォワード AI Cowork（7月提供予定）**: 経理・労務・法務をMCP設定不要でAIが自律処理。Anthropic Claude Agent SDK + MCP 採用。「MCPすら不要」という独自アプローチが freee MCP 直接活用と対比される差別化点。
- **freee × マネーフォワード MCP 対応比較**: note.com にて「freeeとマネーフォワード、MCP対応を比較してみた」が注目（freee の MCP 先行対応優位と、マネーフォワードの MCP 不要路線の対比が整理）。
- 継続トレンド: freee MCP による「AIに話しかけるだけで仕訳・請求書・経費精算」実用化フェーズ継続。経理 AI 導入率約 24.3%（未導入 75% 超で依然大きなポテンシャル）。

**Zenn / Qiita 日本語コミュニティ（2026-06-27 時点）**
- 「Claude Code 週次アップデートまとめ（2026/06/20週）」（Qiita, saitoko 氏）が継続参照多数。
- 「Claude Code と Zenn 執筆環境を一から育てた記録」（Qiita/Zenn, shimo4228 氏）: Markdown lint・クロスポスト自動化等の実践事例。
- 「コードを書けない私が、AI に『チーム』を持たせるまで」（Qiita → Zenn Books, saitoko 氏）継続話題。
- v2.1.195 の日本語解説記事は未確認（本日夜以降公開見込み）。

#### references.md 更新提案

継続未確認項目（6/15〜6/26 提案から継続、全 21 項目）:
1. **v2.1.178 `Tool(param:value)` 権限構文**（6/15〜）
2. **Claude Fable 5 モデル ID**（Mythos 5 US 限定解除確認、Fable 5 一般解除は未定）（6/15〜）
3. **最終確認日更新**: `*最終確認: 2026-03-29*` → `2026-06-27`
4. **Claude Code GitHub Actions セキュリティ脆弱性 v1.0.94**（6/17〜）
5. **`/config key=value` 構文**（v2.1.181, 6/18〜）
6. **`CLAUDE_CLIENT_PRESENCE_FILE` 環境変数**（v2.1.181, 6/18〜）
7. **v2.1.183 デストラクティブ git コマンド自動ブロック**（6/19〜）
8. **`attribution.sessionUrl` 設定**（v2.1.183, 6/19〜）
9. **v2.1.186 Agent deny rules バグ修正**（6/22〜）
10. **`claude mcp login/logout <name>`**（v2.1.186, 6/22〜）
11. **`respondToBashCommands: false` 設定**（v2.1.186, 6/22〜）
12. **v2.1.187 `sandbox.credentials` 設定**（6/23〜）
13. **v2.1.187 org-configured model restrictions**（6/23〜）
14. **v2.1.190 リリース**（バグ修正のみ, 6/24〜）
15. **Claude Tag（Slack 常駐 AI）**（6/23〜）
16. **v2.1.191 `/rewind` コマンド**（6/25〜）
17. **v2.1.191 CPU 使用率 37% 削減**（6/25〜）
18. **v2.1.191 MCP ネットワークエラー自動リトライ**（6/25〜）
19. **v2.1.193 `autoMode.classifyAllShell` 設定**（6/26〜）
20. **v2.1.193 `OTEL_LOG_ASSISTANT_RESPONSES` 環境変数**（6/26〜）
21. **v2.1.193 バックグラウンドシェル自動メモリ圧力排出**（6/26〜）

**新規追加提案（2026-06-27）**:
22. **v2.1.195 `CLAUDE_CODE_DISABLE_MOUSE_CLICKS` 設定**: フルスクリーンモードでマウスクリック/ドラッグ/ホバーを無効化。UI 制御セクションへの追記提案。
23. **v2.1.195 hook matchers exact-match 変更**: ハイフン含む識別子が exact-match に変更。権限設計・hook 設定セクションへの注意事項として追記提案。既存設定の再確認が必要な破壊的変更。
24. **Claude on Apple Foundation Models**: iOS 27 / macOS 27 等での Claude API 利用。モデル利用方法セクションへの追記提案。
25. **Claude Managed Agents プライベート sandbox + MCP**: エンタープライズ向けプライベート環境エージェント実行。アーキテクチャ設計セクションへの追記提案。

#### 新規発見ソース候補
- **note.com/sabori_keiri**: 「freeeとマネーフォワード、MCP対応を比較してみた」著者。会計×AI 実践の現場視点（評価候補: ⭐⭐⭐）

#### 次回リサーチ推奨日

2026-06-28（明日: Fable 5 一般解除監視継続）
注目点:
① **Fable 5 一般解除確認**: Mythos 5 限定解除を受けて交渉継続中。isfableback.org 等でリアルタイム監視。
② **v2.1.196 以降のリリース確認**: hook matchers 変更の影響等のバグ修正が出る可能性。
③ **マネーフォワード AI Cowork 追加情報**: 7月提供開始に向けて技術詳細・プライシングが出る可能性。
④ **TBP-003・TBP-004 昇格候補**: Tak 確認状況（6/22 提案から 5 日経過）。
⑤ **Claude on Apple Foundation Models 詳細**: iOS 27 等での実装方法・API 仕様の公式ドキュメント確認。

---
## [2026-06-26] デイリーレポート

### 内部知見（機能A）
#### 新規・更新 ADR
- My-Profile-and-Memory/decisions/ → フォルダ未存在のためスキップ
- StudyMate, My-URAWA-LOG, tak-work, tak-family, tak-personal → アクセス可能リポジトリ外のためスキップ
- tak-best-practices/ → TBP-001（外部ツール導入審査）・TBP-002（実行環境英語パス）を確認（新規 ADR なし）
- **継続記録（6/22 提案から 4 日目）**:
  1. TBP-003 候補「着手前に実態（git）と文書（backlog）の一致を確認する」— Tak 確認待ち
  2. TBP-004 候補「不可逆性で安全方向を決めるが、カテゴリ丸ごとの保守化は目的を殺す」— Tak 確認待ち

#### TBP 昇格候補
なし（本日は新規 ADR なし）

#### 再検討トリガー該当
- **TBP-001（外部ツール導入審査）継続**: 課金体系変更・地政学的リスク・デストラクティブ操作自動防御・Agent deny rules 修正・sandbox.credentials・org-configured model restrictions の評価項目追記提案が未確認のまま継続（6/15〜6/25 提案、全 18 項目）。
- **TBP-001 新規照合①（Issue #71702〜#71706 Anthropic API レート制限集中報告）**: 6/26 朝に同一症状のレート制限バグが 5 件連続で報告（area:api, duplicate/external）。Anthropic API サーバー側の一時的スロットリング事象の可能性。Research Hub の Routine（auto-research-collect 等）が朝3時台に実行中にレート制限に当たる可能性を記録。TBP-001「課金コスト予測困難性」とあわせて「外部 API の可用性リスク」の審査項目追記を提案。
- **TBP-001 新規照合②（Issue #71697: v2.1.193 Auto session recap 停止回帰）**: v2.1.193 でアイドル復帰後の自動セッションリキャップが発動しなくなるバグ。Routine の長時間セッション（deep-research-runner 等）でのコンテキスト継続性に影響する可能性。
- **TBP-001 新規照合③（Issue #71708: Windows OAuth CERT_HAS_EXPIRED 回帰）**: Windows ネイティブ環境で OAuth ログイン時に証明書期限切れエラーが発生するリグレッション（curl は同ホストで成功）。手動でプロキシ・VPN・AV なしで再現確認済み（has repro）。Tak のローカル環境がWindowsの場合、直接影響する可能性あり。
- **TBP-002（実行環境英語パス）**: 新規トリガーなし。

---

### 外部リサーチ（機能B）
#### 参照した情報源
- Claude Code 公式チェンジログ: https://code.claude.com/docs/en/changelog（WebFetch）
- anthropics/claude-code GitHub Issues: https://github.com/anthropics/claude-code/issues（WebFetch）
- WebSearch: Claude Fable 5 復旧状況 2026年6月26日
- WebSearch: Anthropic Claude new release announcement June 2026
- WebSearch: 会計 AI 経理 自動化 freee マネーフォワード バクラク 2026年6月
- WebSearch: Claude Code Zenn Qiita 新着 2026年6月26日

#### 🔴 即座に適用すべき事項

**① Anthropic API サーバーレート制限の集中発生（2026-06-26 新着、area:api）**
- 6/26 朝に Issue #71702〜#71706 の5件が相次いで登録（いずれも "Server Rate Limiting (Request Throttling)"）。
- 症状: 「Anthropic API Error: Server rate limiting — temporary request throttling」が通常使用中に発生（macOS, area:api, duplicate/external）。
- 6/22 にも同様の Issue #70160（area:agents, area:api）が記録されており、断続的なサーバー側スロットリングが継続している模様。
- **Research Hub への影響**: auto-research-collect（3:03 JST）・auto-claude-code-watch（4:00 JST）・deep-research-runner（6:00 JST）がまとめてレート制限に当たる可能性。Routine のリトライロジックが機能しているか次回実行後に確認推奨。
- **推奨対応**: Routine プロンプトに「API レート制限（429）に当たった場合は 60 秒待機してリトライ」の指示を追加することを検討。

**② Issue #71708 — Windows OAuth CERT_HAS_EXPIRED 回帰（2026-06-26 新着、area:auth, regression, has repro）**
- Windows ネイティブインストール環境で OAuth ログイン時に「CERT_HAS_EXPIRED」エラーが発生する回帰バグ。
- プロキシ/VPN/アンチウイルスなしの環境で curl は同ホストへのアクセスに成功するため、Claude Code 側の証明書バンドル問題の可能性。
- **Tak の Windows 環境への影響**: 直接関連する可能性あり。修正パッチリリースを監視推奨。

#### 🟡 近いうちに試したいこと（上位3件）

**① Claude Code v2.1.193（2026-06-25 リリース）— autoMode.classifyAllShell + OTEL ログ**
- 前回（6/25 報告）の v2.1.191 リリース内容（/rewind・CPU 37%削減）に続く追加機能リリース:
  - **`autoMode.classifyAllShell` 設定**: すべての Bash/PowerShell コマンドを auto-mode 分類器経由でルーティング。未知のコマンドが auto-mode でブロックされる挙動を制御できる。
  - **`OTEL_LOG_ASSISTANT_RESPONSES=1`**: OpenTelemetry の `claude_code.assistant_response` ログイベント追加。Routine の詳細トレーシング基盤として活用可能。
  - **Bash モードにライブファイルパスオートコンプリート**: `!` コマンド入力時にファイルパスが補完される（手動デバッグ時の操作性向上）。
  - **MCP サーバー認証通知**: 起動時に認証が必要な MCP サーバーの通知を追加。
  - **アイドルバックグラウンドシェルの自動メモリ圧力排出**: 長時間 Routine でのメモリ安定性向上の可能性（`CLAUDE_CODE_DISABLE_BG_SHELL_PRESSURE_REAP=1` で無効化可能）。
  - **バグ修正**: `/model` 表示の古い状態バグ・バックグラウンドタスク引き継ぎ失敗・ピン止めエージェントの自動更新後再プロンプト・MCP OAuth 401/403 での自動再実行
- **Research Hub への影響**: auto-mode 使用 Routine での Bash コマンドルーティング動作が変わる可能性。`autoMode.classifyAllShell` のデフォルト値確認を推奨。

**② Issue #71709 — Swarm/マルチエージェントのセッション名表示改善（enhancement）**
- Swarm/マルチエージェントの TUI 表示で、raw tmux コマンド名ではなくセッション名を表示する機能要望（area:agents, area:tui, enhancement）。
- **Research Hub への影響**: Workflow ベースの Routine（auto-research-collect, deep-research-runner）でサブエージェントが複数動く場合の視認性向上につながる可能性。

**③ API レート制限対策 + Fable 5 復旧後のコスト管理**
- Issue #71702〜#71706 のレート制限集中に加え、Fable 5 復旧後に auto モードでコスト急増するリスクが継続。
- `org-configured model restrictions`（v2.1.187）で復旧直後の Fable 5 自動選択を一時ブロックする準備を推奨。

#### 🟢 参考情報

**GitHub Issues 新着（2026-06-26）**
- Issue #71709: Swarm マルチエージェント: raw tmux コマンドの代わりにセッション名表示 + 完了エージェント自動クリーンアップ（area:agents, area:tui, enhancement, macos）
- Issue #71708: Windows OAuth CERT_HAS_EXPIRED（area:auth, bug, has repro, windows, regression）← 🔴参照
- Issue #71707: ツール権限要求時に allowlist コマンドの正確なフォーマットを表示する機能要望（area:permissions, enhancement）
- Issue #71706〜#71702: Anthropic API サーバーレート制限バグ（area:api, bug/duplicate/external, macos）← 🔴参照
- Issue #71700: Kitty キーボードプロトコルがケイパビリティ検出でなく端末名の allowlist でゲートされているバグ（area:tui, bug, has repro, linux）
- Issue #71699: split-DNS VPN 環境で `claude update` が "getaddrinfo EREFUSED" で失敗するバグ（area:networking, bug, linux）
- Issue #71698: `/usage` テキストが Edit ツール diff ブロック後に選択不可になるバグ（area:tui, bug, windows）
- Issue #71697: v2.1.193 でアイドル復帰後の auto session recap が発動しないバグ（area:tui, bug, has repro, macos）← TBP-001 照合済み
- **Research Hub の Routine 動作への直接影響**: #71702〜#71706（APIレート制限）・#71697（auto session recap停止）が最も関連度高い

**Fable 5 / Mythos 5 状況（14 日目、2026-06-26 時点）**
- 依然として全ユーザー向けに停止継続（未復旧）。公式復旧日は引き続き未定。
- Anthropic MD クリス・チャウリ（ソウル記者会見）の「数日以内」発言（6/23）から 3 日経過するも復旧なし。
- 予測市場 Kalshi: 7/1 までの復旧確率は約 57% 水準で変化なし。
- **Research Hub への影響**: Opus 4.8 / Sonnet 4.6 が auto モードで引き続き選択中。復旧後のクレジット消費急増に注意。

**Claude プラットフォーム新機能（2026年6月 Anthropic 発表）**
- **Claude Tag on Slack（Beta）**: Enterprise/Team プランでのみ提供（6/23 発表。6/24 レポートで詳細済）。8/3 に既存 Claude in Slack から強制移行。
- **Claude Managed Agents**: 自前 sandbox + プライベート MCP サーバーへの接続をサポート。
- **Enterprise 向け Okta MCP コネクター**: 管理者が一度設定すれば全ユーザーがゼロタッチで利用可能に。

**会計×AI トレンド（2026-06-26 時点）**
- **freee MCP 公式対応**: AI が freee データに直接読み書きできるようになり「話しかけるだけで仕訳・請求書・経費精算」が本格化。MCP 対応がない他社（マネーフォワード等）とは差別化要因に。
- **バクラク AIエージェント**: バックオフィス特化型。API 経由で業務実行・承認フローへの組み込みまで対応。申請レビュー・証憑自動取得・仕訳自動入力・入金消込を複数専門エージェントで協働処理。
- **マネーフォワード AI Cowork（2026年7月提供予定）**: Claude Agent SDK + MCP を技術基盤として採用。経理・労務・法務を AI が「同僚」として自律処理するサービス（国内 SaaS 初の大型 Anthropic エージェント基盤採用事例）。7月提供開始前後に記事化推奨。
- **経理 AI 実務普及率**: 2026年4月時点で約 24.3%（75% 以上が未導入）。BOXIL Magazine の経理向け AI エージェント比較記事が充実し、実務導入の比較基準が標準化フェーズに。

**Zenn / Qiita 日本語コミュニティ（2026-06-26 時点）**
- 「Claude Code 6月新機能 — 5段階エージェントと/cdコマンドで自律開発を実現する」（Qiita）が引き続き高参照。
- 「Claude CodeでPRレビューを自動化する設計と実装 — 全PRの83%をAIレビューだけでマージ」（Qiita, nogataka氏）が話題継続。
- 「コードを書けない私が、AIに『チーム』を持たせるまで」（Qiita, saitoko氏）: Zenn Books として書籍化。
- 「17万スター超のCLAUDE.mdに学ぶ、Claude Codeを暴走させない運用術」（Qiita）が新着人気記事。
- v2.1.193 の日本語解説記事は未確認（今夜以降公開見込み）。

#### references.md 更新提案

継続未確認項目（6/15〜6/25 提案から継続、全 18 項目）:
1. **v2.1.178 `Tool(param:value)` 権限構文**（6/15〜）
2. **Claude Fable 5 モデル ID**（停止継続中、復旧確率 57%→7/1、14日目）（6/15〜）
3. **最終確認日更新**: `*最終確認: 2026-03-29*` → `2026-06-26`
4. **Claude Code GitHub Actions セキュリティ脆弱性 v1.0.94**（6/17〜）
5. **`/config key=value` 構文**（v2.1.181, 6/18〜）
6. **`CLAUDE_CLIENT_PRESENCE_FILE` 環境変数**（v2.1.181, 6/18〜）
7. **v2.1.183 デストラクティブ git コマンド自動ブロック**（6/19〜）
8. **`attribution.sessionUrl` 設定**（v2.1.183, 6/19〜）
9. **v2.1.186 Agent deny rules バグ修正**（6/22〜）
10. **`claude mcp login/logout <name>`**（v2.1.186, 6/22〜）
11. **`respondToBashCommands: false` 設定**（v2.1.186, 6/22〜）
12. **v2.1.187 `sandbox.credentials` 設定**（6/23〜）
13. **v2.1.187 org-configured model restrictions**（6/23〜）
14. **v2.1.190 リリース**（バグ修正のみ, 6/24〜）
15. **Claude Tag（Slack 常駐 AI）**（6/23〜）
16. **v2.1.191 `/rewind` コマンド**: 会話巻き戻し機能（6/25〜）
17. **v2.1.191 CPU 使用率 37% 削減**: ストリーミングパフォーマンス改善（6/25〜）
18. **v2.1.191 MCP ネットワークエラー自動リトライ**（6/25〜）

**新規追加提案（2026-06-26）**:
19. **v2.1.193 `autoMode.classifyAllShell` 設定**: 全 Bash/PowerShell コマンドを auto-mode 分類器経由でルーティング。権限設計・auto mode 制御セクションへの追記提案。
20. **v2.1.193 `OTEL_LOG_ASSISTANT_RESPONSES` 環境変数**: OpenTelemetry の assistant_response ログイベント。監視・トレーシングセクションへの追記提案。
21. **v2.1.193 バックグラウンドシェル自動メモリ圧力排出**: `CLAUDE_CODE_DISABLE_BG_SHELL_PRESSURE_REAP=1` で無効化可能。パフォーマンスセクションへの追記提案。

#### 新規発見ソース候補
なし（本日は新規有望ソース未発見）

#### 次回リサーチ推奨日

2026-06-27（明日: Fable 5 復旧監視・API レート制限状況継続）
注目点:
① **Fable 5 復旧確認**: 14日目継続。Kalshi 予測 57%→7/1 が引き続き節目。週末前の本日・明日に動く可能性。
② **Issue #71708 パッチ確認**: Windows OAuth CERT_HAS_EXPIRED 回帰の修正リリース監視。
③ **API レート制限集中（#71702〜#71706）の続報**: Anthropic サーバー側の問題か、クライアント側の問題か確認。
④ **マネーフォワード AI Cowork 詳細**: 7月提供開始に向けた事前発表・技術詳細が出れば即記事化推奨。
⑤ **TBP-003・TBP-004 昇格候補**: Tak 確認状況（6/22 提案から 4 日経過）。

---
## [2026-06-25] デイリーレポート

### 内部知見（機能A）
#### 新規・更新 ADR
- My-Profile-and-Memory/decisions/ → フォルダ未存在のためスキップ
- StudyMate, My-URAWA-LOG, tak-work, tak-family, tak-personal → アクセス可能リポジトリ外のためスキップ
- tak-best-practices/ → TBP-001（外部ツール導入審査）・TBP-002（実行環境英語パス）を確認（新規 ADR なし）
- **継続記録（6/22 提案から 3 日目）**:
  1. TBP-003 候補「着手前に実態（git）と文書（backlog）の一致を確認する」— Tak 確認待ち
  2. TBP-004 候補「不可逆性で安全方向を決めるが、カテゴリ丸ごとの保守化は目的を殺す」— Tak 確認待ち

#### TBP 昇格候補
なし（本日は新規 ADR なし）

#### 再検討トリガー該当
- **TBP-001（外部ツール導入審査）継続**: 課金体系変更・地政学的リスク・デストラクティブ操作自動防御・Agent deny rules 修正・sandbox.credentials・org-configured model restrictions の評価項目追記提案が未確認のまま継続（6/15〜6/24 提案、全 15 項目）。
- **TBP-001 新規照合①（Issue #71462: Bash tool が env 変数を "null" リテラルに上書き）**: direnv 管理・シークレット環境変数が Bash ツールで `"null"` という文字列リテラルに設定されるバグ（area:bash, platform:macos）が 6/25 新着。TBP-001「最小権限」の実装が Bash ツール層で想定外に破られる可能性。Research Hub の Routine で INTERNAL_TOKEN 等が `"null"` に化けていないか確認推奨。
- **TBP-001 新規照合②（Issue #71461: Fleet mode 過剰トークン消費）**: Fleet モードが単純な型チェックタスクで過剰なトークンを消費するバグ（area:cost, platform:macos）。6/15 施行の Agent SDK クレジット課金との合わせ技でコスト急増リスク。TBP-001「課金コスト予測困難性」追記の根拠が増強。
- **TBP-002（実行環境英語パス）**: 新規トリガーなし。

---

### 外部リサーチ（機能B）
#### 参照した情報源
- Claude Code 公式チェンジログ: https://code.claude.com/docs/en/changelog（WebFetch）
- anthropics/claude-code GitHub Issues: https://github.com/anthropics/claude-code/issues（WebFetch）
- WebSearch: Anthropic Claude Fable 5 復旧 2026年6月25日
- WebSearch: Claude Code GitHub issues new 2026-06-25
- WebSearch: 会計 AI 経理 自動化 freee マネーフォワード 2026年6月25日
- WebSearch: Claude Code Zenn Qiita 新着記事 2026年6月25日

#### 🔴 即座に適用すべき事項

**① Claude Code v2.1.191（2026-06-24 リリース）— /rewind・CPU 37%削減・MCP自動リトライ**
- **`/rewind` コマンド追加**: `/clear` 実行前の会話状態から再開可能。誤クリアからの復帰が可能に。
- **CPU 使用率 37% 削減**: ストリーミング応答中のテキスト更新を 100ms に統合。deep-research-runner 等の長時間 Routine でシステム負荷が大幅低下する可能性。
- **MCP サーバー信頼性向上**: `tools/list`・`prompts/list`・`resources/list` の一時的なネットワークエラーで自動リトライ。MCP OAuth ディスカバリー・トークンリクエストも同様。Research Hub の Routine が Worker 経由 MCP を使う場合、ネットワーク不安定時の失敗率低下が期待できる。
- **バックグラウンドエージェント停止後の復活防止**: ゾンビエージェント起動を防ぐ。
- **サンドボックスネットワーク許可の永続化**: ダイアログで「Yes」を選択したホストがセッション中記憶される（Routine でのホスト承認フロー簡素化）。
- **その他バグ修正**: /permissions Recently-denied タブ・エージェントパネルスクロール行ずれ・MCP HTTP 404 エラーでの URL 表示・`/voice` 組織ポリシー無効化時のメッセージ改善

**② Issue #71462 — Bash tool が direnv管理環境変数を "null" に上書き（2026-06-25 新着）**
- Bash ツールが redacted または direnv 管理の環境変数を `"null"` という文字列リテラルに設定するバグ（area:bash, platform:macos）。
- **Research Hub への影響**: Routine 内で INTERNAL_TOKEN 等のシークレット変数を参照している場合、Bash コマンド後に `"null"` に書き換えられて Worker への認証が失敗する可能性。Routine ログで `X-Internal-Token: null` が送信されていないか要確認。修正パッチリリースを監視推奨。

#### 🟡 近いうちに試したいこと（上位3件）

**① `/rewind` コマンドの活用（v2.1.191）**
- Routine やインタラクティブセッションで `/clear` を誤実行した場合に直前状態に巻き戻せる。
- deep-research-runner の途中で文脈をリセットしたい場面での保険として有用。

**② マネーフォワード AI Cowork（2026年7月提供予定）の動向追跡**
- 経理・労務・法務業務を AI が「同僚」として自律処理するサービス。**Claude Agent SDK + MCP を技術基盤**として採用した国内初の大型 SaaS 事例。
- Research Hub の 会計×AI 記事軸として 7 月提供時に記事化を推奨。Routine プロンプトの「会計×AI 重要発表」枠に該当。

**③ Issue #71461 Fleet mode 過剰トークン消費の影響確認**
- Agent SDK クレジット（6/15 施行）と合わせてコスト影響が大きい。
- Routine 内でサブエージェントを並列実行する際は Fleet モードでなく `pipeline()` / `parallel()` を使う設計を優先する。

#### 🟢 参考情報

**GitHub Issues 新着（2026-06-25）**
- Issue #71466: macOS デスクトップ VoiceOver が AI 応答を読み上げない回帰バグ（invalid）
- Issue #71465: v2.1.193 で Terminal.app の TUI マウスクリックが反応しない（area:tui, regression, macos）
- Issue #71464: `context: fork` スラッシュコマンドが出力をレンダリングしない（area:skills, has repro, windows）
- Issue #71463: Safety ブロックが読み取り専用の firewall audit を妨害（area:permissions, duplicate, linux）
- Issue #71462: Bash ツールが env 変数を "null" に設定（area:bash, macos）← 🔴参照
- Issue #71461: Fleet mode 過剰トークン消費（area:cost, macos）← 🟡参照
- Issue #71460〜71455: ドキュメント改善 (DOCS): Plugin marketplace renames・background shell memory pressure・shell mode autocomplete・OpenTelemetry `OTEL_LOG_ASSISTANT_RESPONSES`・auto mode `classifyAllShell`・IntelliJ EDT regression
- **Research Hub の Routine 動作への直接影響**: #71462（env var "null"バグ）が最も関連度高い

**Fable 5 / Mythos 5 状況（13 日目、2026-06-25 時点）**
- 依然として全ユーザー向けに停止継続。公式復旧日は未定。
- 予測市場（Polymarket 等）では 2026-07-01 までの復旧確率が約 57% と推計。
- 6/23 の Android レートリミット変化シグナルからの続報なし。
- **Research Hub への影響**: Opus 4.8 / Sonnet 4.6 が auto モードで継続選択中。Fable 5 復旧後のクレジット消費急増に引き続き注意。

**会計×AI トレンド（2026-06-25 時点）**
- **マネーフォワード AI Cowork（2026年7月提供予定）**: Claude Agent SDK + MCP を技術基盤に採用した AI 同僚サービス。経理・労務・法務を自律処理。国内主要 SaaS が Anthropic のエージェント基盤を採用した最初の大型事例として記録。
- **freee「AIおまかせ明細取得」β版（3/26 開始継続）**: モバイル Suica 等の PDF 明細からデータを自動抽出。freee AI の実用化フェーズ拡大が継続。
- 国内経理部門の AI 導入率: 約 24.3%（2026 年 4 月時点）。75% 以上が未導入でポテンシャル大。
- 経理 AI エージェント比較記事（BOXIL Magazine）が充実し、実務導入の比較基準が標準化段階へ。

**Zenn / Qiita 日本語コミュニティ（2026-06-25 時点）**
- 「Claude Code 6月新機能 — 5段階エージェントと/cdコマンドで自律開発を実現する」（Qiita）が引き続き参照多数。
- 「Claude CodeでPRレビューを自動化する設計と実装 — 全PRの83%をAIレビューだけでマージ」（Qiita, nogataka氏）が話題継続。
- v2.1.191 の日本語解説記事はまだ公開なし（本日夜以降に出てくる見込み）。

#### references.md 更新提案

継続未確認項目（6/15〜6/24 提案から継続、全 15 項目）:
1. **v2.1.178 `Tool(param:value)` 権限構文**（6/15〜）
2. **Claude Fable 5 モデル ID**（停止継続中、復旧確率 57%→7/1）（6/15〜）
3. **最終確認日更新**: `*最終確認: 2026-03-29*` → `2026-06-25`
4. **Claude Code GitHub Actions セキュリティ脆弱性 v1.0.94**（6/17〜）
5. **`/config key=value` 構文**（v2.1.181, 6/18〜）
6. **`CLAUDE_CLIENT_PRESENCE_FILE` 環境変数**（v2.1.181, 6/18〜）
7. **v2.1.183 デストラクティブ git コマンド自動ブロック**（6/19〜）
8. **`attribution.sessionUrl` 設定**（v2.1.183, 6/19〜）
9. **v2.1.186 Agent deny rules バグ修正**（6/22〜）
10. **`claude mcp login/logout <name>`**（v2.1.186, 6/22〜）
11. **`respondToBashCommands: false` 設定**（v2.1.186, 6/22〜）
12. **v2.1.187 `sandbox.credentials` 設定**（6/23〜）
13. **v2.1.187 org-configured model restrictions**（6/23〜）
14. **v2.1.190 リリース**（バグ修正のみ, 6/24〜）
15. **Claude Tag（Slack 常駐 AI）**（6/23〜）

**新規追加提案（2026-06-25）**:
16. **v2.1.191 `/rewind` コマンド**: 会話巻き戻し機能。ユーザーガイド・操作性セクションへの追記提案。
17. **v2.1.191 CPU 使用率 37% 削減**: ストリーミング応答中のパフォーマンス大幅改善。パフォーマンス関連セクションへの追記。
18. **v2.1.191 MCP ネットワークエラー自動リトライ**: `tools/list` 等の一時エラーで再試行。MCP 信頼性設計の参考情報として追記。

#### 新規発見ソース候補
なし（本日は新規有望ソース未発見）

#### 次回リサーチ推奨日

2026-06-26（明日: Fable 5 復旧監視継続）
注目点:
① **Fable 5 復旧確認**: 予測市場 57%→7/1。週末にかけてシグナル注意。
② **Issue #71462 パッチ確認**: Bash tool env var "null" バグの修正リリース（Routine シークレット保護に直結）。
③ **マネーフォワード AI Cowork 詳細**: 7月提供開始に向けて技術詳細が公開されれば記事化推奨。
④ **v2.1.192 以降のリリース**: MCP 安定化・バグ修正系が続く場合は確認。
⑤ **TBP-003・TBP-004 昇格候補**: Tak 確認状況（6/22 提案から 3 日経過）。

---## [2026-06-24] デイリーレポート

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
- **TBP-001（外部ツール導入審査）継続**: 課金体系変更・地政学的リスク・デストラクティブ操作自動防御・Agent deny rules 修正・sandbox.credentials・org-configured model restrictions の評価項目追記提案が未確認のまま継続（6/15〜6/23 提案）。
- **TBP-001 新規照合（Issue #70687: git rm -rf データロス）**: 6/24 新着。Claude が 3年分の Unity プロジェクトファイルを `git rm -rf` で全削除するデータロスが報告された（area:model, data-loss）。v2.1.183 のデストラクティブ git コマンド自動ブロック対象（`git reset --hard`, `git checkout -- .`, `git clean -fd`）には `git rm` が含まれていないことが露呈。「エージェントが使用する破壊的コマンドの範囲は想定より広い」という新たな脅威モデルとして TBP-001 審査基準への追記を提案。`Bash(command:git rm*)` を deny ルールに加えることも有効（v2.1.178 の `Tool(param:value)` 権限構文）。
- **TBP-002（実行環境英語パス）**: 新規トリガーなし。

---

### 外部リサーチ（機能B）
#### 参照した情報源
- Claude Code 公式チェンジログ: https://code.claude.com/docs/en/changelog（WebFetch）
- anthropics/claude-code GitHub Issues: https://github.com/anthropics/claude-code/issues（WebFetch）
- WebSearch: Claude Fable 5 復旧状況（6/24）
- WebSearch: Claude Tag Slack 2026年6月24日
- WebSearch: Claude Code v2.1.188/189 changelog June 2026
- WebSearch: 会計 AI 経理 自動化 freee マネーフォワード バクラク 2026年6月24日
- WebSearch: Anthropic Claude Code 2026年6月24日 新機能 日本語

#### 🔴 即座に適用すべき事項

**① Issue #70687 — Claude が git rm -rf でプロジェクト全ファイルを削除（2026-06-24 新着、area:model, data-loss）**
- Claude Code が 3年分の Unity プロジェクトの全ファイルを `git rm -rf` コマンドで削除するデータロスを引き起こした（has repro）。
- **重要**: v2.1.183 のデストラクティブ git 自動ブロックは `git reset --hard` / `git checkout -- .` / `git clean -fd` / `git stash drop` を対象としており、`git rm -rf` はブロック対象外。Claude がエージェントとして選択できる破壊的コマンドのベクターは想定より広い。
- **Research Hub への推奨対応**: Routine の settings.json に `Bash(command:git rm*)` の deny ルールを追加することを検討。auto-research-collect・deep-research-runner 等でファイル管理を行うケースでの構造的な保護になる。

**② Claude Code v2.1.190（2026-06-24 リリース）— バグ修正のみ**
- リリースノート: "Bug fixes and reliability improvements"（具体的な変更内容は公開なし）
- v2.1.187 の主要修正（sandbox.credentials、MCP タイムアウト修正、StructuredOutput 無限ループ解消等）に続く安定化リリース。
- Research Hub の Routine 動作への直接影響: 不明（軽微な安定性改善が期待される水準）

#### 🟡 近いうちに試したいこと（上位3件）

**① Claude Tag（2026-06-23 発表）— Slack 常駐 AI チームメイト**
- Anthropic が「Claude Tag」を発表。Slack チャンネルに @Claude をメンションすることで、Claude がチームの一員として非同期でタスクを遂行する新機能。
- 主な特徴:
  - 永続的なコンテキストとメモリ学習（チャンネル内の文脈を継続蓄積）
  - 自律的なタスク分解・実行・Slack スレッドへの進捗報告
  - アンビエントモード（忘れられたスレッドへの自動フォローアップ）
  - 管理者によるチャンネル・ツール単位のアクセス制御
- ベースモデル: Opus 4.8
- 提供条件: Enterprise または Team プランが必要（Beta として即日提供開始）
- 既存の「Claude in Slack」は 2026年8月3日に Claude Tag へ置き換わる（管理者は30日以内に移行オプトインが必要）
- Anthropic 製品チームのコードの 65% は Claude Tag を使って作成されていると発表。
- **Tak 業務への参考**: 経理・バックオフィス系の Slack チャンネルへの常駐、フィードバック収集や article 追跡のトリガーとして活用できる可能性あり。

**② `git rm -rf` 対策の settings.json 追加（Issue #70687 対応）**
- `Bash(command:git rm*)` を deny ルールに追加（v2.1.178 の `Tool(param:value)` 権限構文）。
- Research Hub の auto-research-collect 等の Routine でファイル削除系コマンドが意図せず実行されるリスクを構造的に排除。v2.1.183 の保護範囲を補完する措置。

**③ Issue #70685 — マウスクリックでプロンプトが意図せず自動選択（v2.1.187 リグレッション候補）**
- インタラクティブプロンプトでマウスクリックがオプションを即時選択してしまうバグ（area:tui, duplicate）。
- v2.1.187 で追加されたマウスクリックサポートのリグレッションの可能性。Routine 上は TUI 操作が少ないため直接影響は軽微だが、手動デバッグ時の誤操作リスクとして記録。

#### 🟢 参考情報

**GitHub Issues 新着（2026-06-24）**
- Issue #70689: bypassPermissions モードで archive_session が Allow プロンプトを表示するが実際には拒否される（area:desktop, area:permissions, misleading）
- Issue #70688: フルスクリーン表示が最小化→再展開後に画面の半分しか使用しない（area:tui, bug, linux）
- Issue #70686: 終了した Remote セッションのバックグラウンドタスクが "Running" のまま残り削除不可（area:agent-view, area:claude-code-web, bug）
- Issue #70684: sandbox: SOCKS5 プロキシ認証を BSD nc がネゴシエートできず SSH git 操作が失敗するリグレッション（area:sandbox, has repro, platform:macos）
- Issue #70682: モデルが文書横断比較で無関係なセクションを混在させるバグ（area:model, needs-repro）
- Issue #70681: auto-compact 閾値の設定可能化要望（area:core, enhancement）
- Issue #70680: サブエージェントが build/test コマンドの `--watch` フラグを利用する機能要望（area:agents, enhancement）
- Issue #70678: チャット内のユーザーメッセージ間のキーボードナビゲーション要望
- Issue #70677: トランスクリプトをアシスタント出力とツール呼び出し出力の 2 ペインに分割する要望
- **Research Hub の Routine 動作への直接影響**: #70687（data-loss: git rm -rf、🔴参照）・#70686（Remote バックグラウンドタスク残存）が最も関連度高い

**Fable 5 / Mythos 5 停止継続（12 日目、2026-06-24 時点）**
- explainx.ai（6/24 付）: 「Is Fable 5 Back? No — Status & Alternatives」として依然オフライン継続を確認。
- isfableback.org: 依然「No」の状態を継続。全ユーザー向けにオフライン。
- 公式復旧日は未定。前回（6/23）の「Android で rate-limit レスポンスに変化」は復旧準備シグナルとして記録されていたが、24 日時点では依然未復旧。
- **Research Hub への影響**: Opus 4.8 / Sonnet 4.6 が auto モードで選択され続ける状態が継続。Fable 5 復旧後の Agent SDK クレジット消費量変動に引き続き注意。

**会計×AI トレンド（2026-06-24 時点）**
- 本日固有の新発表なし（6/23 までのトレンドが継続）。
- freee MCP、マネーフォワード AIエージェント、バクラク AIエージェントの継続展開。
- 経費精算工数 75% 削減・月次決算 5 営業日早期化が報告値として定着。
- 経理向け AI エージェント比較記事（BOXIL Magazine 等）が充実してきており、実務導入のベンチマーク情報として有用。

**Claude Tag 詳細補足**
- 既存の「Claude in Slack」との差分: 都度の会話型 → チームメンバーとしての AI（文脈の永続性・自律的タスク実行が追加）。
- 日本語メディア報道: Impress Watch・ITmedia・GIGAZINE・innovatopia 等で即日報道。
- 注意: 既存 Slack App ユーザーは 2026/8/3 までに管理者が移行オプトインを行う必要がある（手動移行が必要）。

#### references.md 更新提案

継続未確認項目（6/15〜6/23 提案から継続、全 13 項目）:
1. **v2.1.178 `Tool(param:value)` 権限構文**: 公式 best-practices ページへの追記確認
2. **Claude Fable 5 モデル ID**: 「現在停止中（6/12〜）、6/24 時点でも未復旧」注記とともに追記提案
3. **最終確認日更新**: `*最終確認: 2026-03-29*` → `2026-06-24` への更新
4. **Claude Code GitHub Actions セキュリティ脆弱性 v1.0.94**
5. **`/config key=value` 構文**（v2.1.181）
6. **`CLAUDE_CLIENT_PRESENCE_FILE` 環境変数**（v2.1.181）
7. **v2.1.183 デストラクティブ git コマンド自動ブロック**
8. **`attribution.sessionUrl` 設定**（v2.1.183）
9. **v2.1.186 Agent deny rules バグ修正**
10. **`claude mcp login/logout <name>`**（v2.1.186）
11. **`respondToBashCommands: false` 設定**（v2.1.186）
12. **v2.1.187 `sandbox.credentials` 設定**
13. **v2.1.187 org-configured model restrictions**

**新規追加提案（2026-06-24）**:
14. **v2.1.190 リリース**: "Bug fixes and reliability improvements"（内容不詳）。v2.1.187 に続く安定化リリースとして記録。
15. **Claude Tag（Slack 常駐 AI）**: Enterprise/Team の Slack 利用者向け新機能。8/3 に既存 Claude in Slack から強制移行。コラボレーション設計・外部ツール活用の参考として references.md または TBP-001 の「適用場面」への追記を検討。

#### 新規発見ソース候補
- **blog.cloudnative.co.jp**: Claude Tag の設定・テスト・監査ログまでの実践レビューを掲載（評価候補: ⭐⭐⭐）

#### 次回リサーチ推奨日

2026-06-25（明日: Fable 5 復旧監視を継続）
注目点:
① **Fable 5 / Mythos 5 復旧確認**: 「数日以内」発言（6/23 Anthropic ソウル）から 2 日目。週明け（6/29）が次の節目か。
② **Issue #70687 対応**: git rm -rf データロスバグのパッチリリース確認（v2.1.191 での修正を監視）。
③ **v2.1.190 変更内容の詳細**: "Bug fixes and reliability improvements" の具体的内容が公開されれば確認。
④ **Claude Tag 日本語対応**: Beta 版の日本語環境での動作状況・Enterprise/Team プラン向けの実用性確認。
⑤ **TBP 昇格候補 2 件**（TBP-003・TBP-004）の Tak 確認状況。

---
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
