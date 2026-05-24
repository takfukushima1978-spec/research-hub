## [2026-05-24] デイリーレポート

---

### 内部知見（機能A）

#### 新規・更新 ADR

- My-Profile-and-Memory decisions/: ディレクトリが存在しない（tak-best-practices/ のみ確認）
- 他5プロジェクト（StudyMate / My-URAWA-LOG / tak-work / tak-family / tak-personal）: アクセス制限によりスキップ

**新規なし**

#### TBP 昇格候補

前回提案済みの ADR-001・ADR-003 が昇格待ち継続。新規候補なし。
（TBP-001・TBP-002 は 2026-04-07 以降変更なし）

#### 再検討トリガー該当

**TBP-001「外部ツール導入は審査→最小権限→段階拡張」 / 要注意**
- トリガー: TBP-001「最小権限で開始: allowlistで読み取り系のみに限定」
- 外部情報: Claude Code v2.1.149（5/22）で `allowAllClaudeAiMcps` 管理設定が追加。これは claude.ai cloud の全 MCP コネクタを一括ロードする「全部許可」設定であり、TBP-001 の「最小権限から始める」原則と逆方向
- 評価: TBP-001 の原則そのものは有効。ただし「エンタープライズ管理設定として意図的に全部許可する場合は別途審査が必要」という補足条項の追加を今後検討してもよい。**今すぐ変更は不要だが、認識しておく価値あり**

---

### 外部リサーチ（機能B）

#### 参照した情報源

- Claude Code 公式チェンジログ（code.claude.com/docs/en/changelog）— v2.1.150（5/23）が最新。v2.1.151 以降は本日時点で未リリース
- Anthropic 公式ニュース（anthropic.com/news）
- anthropics/claude-code GitHub releases
- Releasebot (releasebot.io) — Claude / Claude Code の更新まとめ
- Zenn（claude-code タグ）・note 5月最新記事
- 会計×AI: TOKIUM・luvina・renue・Deloitte/PwC/EY 税務 AI 記事
- 国税庁・弥生会計 AI 活用記事

#### 🔴 即座に適用すべき事項

**【継続】Claude Agent SDK / claude -p の課金体制が 2026-06-15 に変更（前回報告の継続確認）**
- 前回（5/23）から変更なし。2026-06-15 までの対応確認が引き続き必要
- 週次制限が 2026-05-14〜7-13 の期間 **50% 増加**（Zenn 記事 5/14 報告）。この限定緩和も確認のうえ計画に活かせる

#### 🟡 近いうちに試したいこと（上位3件）

**① Opus 4.7 の `xhigh` effort レベルを Fast モードと組み合わせ評価**
- Opus 4.7（2026-04-16 リリース）に新しい effort 段階 `xhigh`（high と max の間）が追加。reasoning depth と latency のトレードオフをより細かく制御可能
- Fast モードが Opus 4.7 デフォルトになった（changelog 5月）ため、今のハーネスでの実感値を /fast + xhigh で検証する価値あり
- 参照: [Introducing Claude Opus 4.7](https://www.anthropic.com/news/claude-opus-4-7)

**② MCP tunnels を活用したオンプレ連携の評価検討**
- Anthropic が 2026-05-19 に「MCP tunnels」と「セルフホスト型サンドボックス」を Claude Managed Agents に追加
- Claude エージェントがオンプレサービスと安全に通信できる仕組み。社内システム（会計SaaS・ERPなど）との連携パスが広がった
- 本業（経理部長）での将来的な活用シナリオとして注目

**③ 国税庁 AI（相続税リスクスコアリング）の業務影響の把握**
- 2025年7月より全国税務署で相続税申告をAIがリスクスコアリング開始（弥生会計・EY等が報告）
- 経理部長として税務調査リスク管理や内部統制へのインパクトを確認しておく価値あり

#### 🟢 参考情報

**Claude Code / Anthropic**
- v2.1.150（2026-05-23）: 内部インフラ改善のみ。ユーザー向け変更なし。本日時点で最新
- **アンドレイ・カルパシー、Anthropic に参加（2026-05-19）**: プレトレーニングチームに加わりつつ、Claude を使ったプレトレーニング研究加速チームを新設。長期的なモデル品質向上に影響
- **Anthropic 初の黒字四半期が見込まれる（Bloomberg 2026-05-20）**: Q2 売上高 $109億（前四半期比 2倍超）見込み。Anthropic の事業継続性・モデル投資持続の観点から肯定的
- Opus 4.7: 解像度上限 1568px/1.15MP → **2576px/3.75MP**（約3倍）に拡張。スライド・設計図・財務資料の画像入力精度が向上

**会計×AI**
- **国税庁 AI（相続税）**: 全国一斉導入（2025年7月〜）。過去の不正パターンとの比較によるリスクスコアリングを全申告書に適用済み
- **PwC Japan × 第一法規「Tax Guidance Assistant」**: 日本の税務データベースに特化した生成AI。税務部門での生成AI活用が大手監査法人主導で本格化
- **EY「販売税バーチャルアシスタント」**: 税務調査サイクルを4年→1ヶ月に短縮した実績。日本の税務部門でも同様のAI適用が加速する見込み
- **freee × Claude Cowork MCP 連携**: claude.ai の MCP コネクタ経由で freee データに直接アクセス可能に（2026年5月時点）。経理業務 AI の統合が進む
- **マネーフォワード AI Cowork（7月リリース予定）**: 前回報告の継続。経費精算・請求書処理を自律 AI で処理。「ドラフト＆アプローブ」ガバナンス機能搭載

**Zenn / note（Claude Code 関連、5月）**
- 「Claude Code 全社導入までの意思決定と歴史」（Zenn/gemcook）: 中規模開発チームの全社導入プロセス。ハーネス設計やオンボーディングの参考に
- 「Claude Code 使い放題は終わるのか？6月改定の全容」（Zenn/sanpi34）: 前回も引用。日本語コミュニティで最も引用されている課金変更解説記事

#### references.md 更新提案

今回の調査で公式ベストプラクティスに直接変更はなし。ただし以下の追記を検討:
- `allowAllClaudeAiMcps`（v2.1.149）: エンタープライズ管理設定の新フラグ。TBP-001 との関係でリファレンスに補足メモを加えてもよい

**更新は不要（Tak の確認後に必要であれば対応）**

#### 新規発見ソース候補

- **EY Japan 税務 AI 記事**（ey.com/ja_jp/insights/tax）: 日本の税務AIの実務影響を精度よくカバー。会計×AIセクションへの追加候補（⭐⭐⭐）
- **弥生会計公式ブログ**（yayoi-kk.co.jp/shinkoku/oyakudachi）: AI×確定申告・国税庁AI対策を実務視点で解説。中小企業経理に近い視点（⭐⭐⭐）

#### 次回リサーチ推奨日

2026-05-31（1週間後）  
注目点: ① 6/15 課金変更まで3週間—利用形態の事前確認 ② マネーフォワード AI Cowork 先行受付の状況 ③ Opus 4.7 `xhigh` effort の実感評価 ④ ADR-001・ADR-003 のTBP昇格提案（Tak へ）

---

## [2026-05-23] デイリーレポート

---

### 内部知見（機能A）

#### 新規・更新 ADR

- My-Profile-and-Memory decisions/: 2026-05-22以降の新規・更新コミットなし（計4件: ADR-001〜004 のまま）
- 他5プロジェクト（StudyMate / My-URAWA-LOG / tak-work / tak-family / tak-personal）はローカルに存在しない → スキップ

**新規なし**

#### TBP 昇格候補

前回提案済みの ADR-001・ADR-003 が昇格待ち継続。新規候補なし。

#### 再検討トリガー該当

**CLAUDE.md 基本方針「コスト意識」/ 要確認（6月15日課金体制変更）**
- トリガー: CLAUDE.md「コスト意識: サブエージェントはhaiku優先、ツール呼び出し最小限」と直接接続
- 外部情報: Anthropic が 2026-06-15 よりプログラマティック利用（Agent SDK・`claude -p`・GitHub Actions連携・サードパーティアプリ）を別クレジットプールに移行。Pro $20/月・Max 5x $100/月・Max 20x $200/月
- 評価: デイリーリサーチスキル・各種スキルがサブエージェントやclaude -pを多用している場合、6月以降のコスト構造が変わる可能性。現在の使い方がどのクレジットプールに該当するか確認を推奨。**ADR・TBP の改定は不要だが、Tak の利用形態確認が先決**

---

### 外部リサーチ（機能B）

#### 参照した情報源

- Claude Code 公式チェンジログ（code.claude.com/docs/en/changelog）— v2.1.150（本日 5/23 リリース）確認
- Anthropic 公式ニュース検索（5/22以降）
- anthropics/claude-code GitHub issues（#61882〜#61888 本日新規）
- マネーフォワード CONNECT with AI カンファレンス（5/25〜26）情報
- 会計×AI / freee / バクラク 新着情報
- Zenn（claude-code タグ）5月最新記事

#### 🔴 即座に適用すべき事項

**【最重要】Claude Agent SDK / claude -p の課金体制が 2026-06-15 に変更**
- Anthropic が 2026-06-15 より、プログラマティック利用（Agent SDK・`claude -p`・GitHub Actions・サードパーティアプリ）をサブスクリプション枠と**別の月額クレジットプール**に移行
- クレジット額: Pro $20/月・Max 5x $100/月・Max 20x $200/月（フル API 料金で消費）
- インタラクティブな Claude Code（ターミナル・IDE）は従来通りサブスクリプション枠を使用
- デイリーリサーチスキルはサブエージェントを多用しており、スキル単体が `claude -p` 経由で呼ばれる場合は新クレジットプールから消費される可能性あり
- **アクション**: 6月15日前に自分の利用形態を確認し、必要に応じてスキル設計を見直す

#### 🟡 近いうちに試したいこと（上位3件）

**① マネーフォワード AI Cowork 先行受付の申し込み検討（7月リリース予定）**
- Claude Agent SDK のオーケストレーターを採用したバックオフィス自律型AIサービス
- 「ドラフト＆アプローブ」（AI操作前に人間確認）のガバナンス機能搭載
- 本業（経理部長）でのパイロット活用検討価値あり。先行受付中
- 参照: [マネーフォワード AI Cowork プレスリリース](https://corp.moneyforward.com/news/release/service/20260407-mf-press-1/)

**② 課金体制変更（6/15）前に `/usage` でコスト構造を可視化**
- v2.1.149 で追加された `/usage` のカテゴリー別内訳（スキル・サブエージェント・MCP別）で、現在どのコンポーネントがどれだけトークンを消費しているか確認
- 6月以降のコスト変化を事前試算できる

**③ freee 高精度モード（生成AI β版）の評価**
- PDFの証憑情報をOCRより高精度で読み取る新機能。本業の経費精算・請求書処理に活用検討
- freee Agent Hub（チャット指示で会計業務を段階的自動化）との組み合わせも注目

#### 🟢 参考情報

**Claude Code / Anthropic**
- v2.1.150（2026-05-23 本日リリース）: 内部インフラ改善のみ。ユーザー向け変更なし
- Anthropic × ゲイツ財団 $2億パートナーシップ（5/14）: グローバルヘルス・教育・農業へのAI活用。グローバル規模でのAI医療・農業への展開事例として参考
- GitHub Issues（本日 2026-05-23 新規）:
  - #61884: Windows TUI エリアのデータ損失バグ
  - #61883: macOS 認証エリアのバグ
  - #61882: Claude Code Web（claude.com/code）エリアのバグ
  - #61888: TUI エリアの機能要望
  - #61887: macOS エージェントエリアのバグ
  - #61886: VS Code IDE エリアの機能要望

**会計×AI**
- 経理AI全体（2026年5月）: 入力・確認工数75%削減・月次精算締切2営業日短縮の事例が増加。「AIが判断を支援する段階」への移行が加速
- freee: 山陰合同銀行と協業し地域企業向けBPaaS事業を5月より本格開始
- バクラク: 2026年5月時点で特記すべき新機能発表なし

**Zenn（Claude Code関連、5月新着）**
- 「Claude Code『使い放題』は終わるのか？6月改定の全容と開発者がやるべきこと」: 課金変更を詳細解説。日本語コミュニティで話題
- 「技術調査 - Claude Code /goal コマンド」（v2.1.139〜）: 繰り返しコスト解消の新コマンド解説
- 「Codex vs Claude Code 2026」: 2026年時点の使い分け判断軸（対話性/ベンチマーク/コスト/エコシステム/セキュリティ）の比較記事

#### references.md 更新提案

前回（計16件）に追加:

17. **Agent SDK / `claude -p` の課金分離（2026-06-15〜）**: プログラマティック利用が別クレジットプール（フルAPI料金）に移行。「コスト意識: サブエージェントはhaiku優先」のCLAUDE.md方針に直接影響。ハーネス設計において「スキル経由のサブエージェント呼び出しがプログラマティック扱いになるか」の確認を推奨

#### 新規発見ソース候補

- **[the-decoder.com](https://the-decoder.com)**: Anthropicの課金変更を早期に正確に報じた英語メディア。AI業界ニュースの速報性が高い。⭐⭐⭐ 評価候補として追記を提案
- **[codersera.com](https://codersera.com)**: Claude Code課金変更について開発者向けに詳細解説。⭐⭐⭐ 評価候補

#### 次回リサーチ推奨日

2026-05-26（マネーフォワード CONNECT with AI カンファレンス最終日）または 2026-05-28（週明け）

注目点:
① **マネーフォワード CONNECT with AI（5/25〜26）のリアルタイム情報**（AI Cowork 詳細・ソニーグループ経理AI活用事例）
② **6月15日課金変更への対応確認**（Tak の利用形態 × 新クレジット枠の試算）
③ ADR-001・ADR-003 TBP昇格の Tak 確認（継続）
④ freee AI Cowork 先行受付の申し込み判断

---

## [2026-05-22] デイリーレポート

---

### 内部知見（機能A）

#### 新規・更新 ADR

- My-Profile-and-Memory decisions/: ADR-001〜004 の4件。最後のコミットは 2026-04-09。5/21以降の更新なし。
- 他5プロジェクト（StudyMate / My-URAWA-LOG / tak-work / tak-family / tak-personal）は decisions/ なし → スキップ

**新規なし**

#### TBP 昇格候補

前回提案済みの ADR-001・ADR-003 が昇格待ち継続。新規候補なし。

#### 再検討トリガー該当

**TBP-001（外部ツール審査）/ 該当（freee-MCP freeeサイン対応）**
- トリガー: TBP-001「適用場面」の「新しいMCPサーバーの導入時」に準じる（既存MCPの機能拡張も同等）
- 外部情報: freee-MCP が 2026/4/10 に **freeeサイン（電子契約）** 領域へ対応し、対応APIが約270本→約330本に拡張
- 評価: freeeサインは「契約の締結・変更・解除」を含む重大操作が可能。TBP-001 の「書き込み系API（post/put/patch/delete）全deny」の原則をfreeeサイン関連APIにも適用すべき。freee-MCP を更新する際は新規追加の約60本について TBP-001 の審査フロー（審査→最小権限→段階拡張）を再適用すること。**TBP-001 自体の変更は不要だが、「元になった経験」セクションへ将来追記する候補として記録**

---

### 外部リサーチ（機能B）

#### 参照した情報源

- Claude Code 公式チェンジログ（code.claude.com/docs/en/changelog）— v2.1.148〜149（本日リリース）確認
- Claude Code What's New ページ（week 19〜20）
- Anthropic 公式ニュース（anthropic.com/news）
- anthropics/claude-code GitHub issues（#61554〜#61560 本日新規）
- freee 公式プレスリリース（freeeサイン MCP対応）
- マネーフォワード・バクラク（AI Cowork・AIエージェント動向）
- 経理AI関連（keihi.com・luvina.jp・renue.co.jp）

#### 🔴 即座に適用すべき事項

**v2.1.149: PowerShell 権限昇格バイパス修正（セキュリティ修正）**
- `cd..`・`cd\` などの記法が Bash サンドボックスのディレクトリ変更検知を回避できていた問題を修正
- Windows ユーザー（Tak の環境）に関連する可能性。Claude Code を最新版（v2.1.149）に更新推奨
- 参照: [Claude Code Changelog](https://code.claude.com/docs/en/changelog)

**v2.1.148: Bash tool exit code 127 修正**
- 一部ユーザーで Bash tool が常に終了コード 127 を返す問題（v2.1.147 のリグレッション）を修正
- デイリーリサーチスキル・ハーネス全般の Bash 実行に影響する可能性。v2.1.149 で解消済み

#### 🟡 近いうちに試したいこと（上位3件）

**① v2.1.149: `/usage` コマンドのカテゴリー別コスト内訳表示**
- スキル・サブエージェント・プラグイン・MCPサーバーごとのコスト内訳が表示可能に
- コスト意識が高い Tak のワークフローに直結。どのコンポーネントがトークンを消費しているか可視化できる
- 参照: [Claude Code Changelog v2.1.149](https://code.claude.com/docs/en/changelog)

**② freee-MCP freeeサイン対応（2026/4/10）の詳細確認と導入審査**
- freeeサインにより AIエージェントから電子契約の締結・管理が操作可能に。本業（経理・内部統制）への活用可能性大
- ただしTBP-001に従い、freeeサイン関連APIを全deny でスタートし必要なものだけ段階追加する
- 参照: [freee-MCP freeeサイン対応プレスリリース](https://corp.freee.co.jp/news/20260410freee_mcp.html)

**③ Anthropic「Agents for Financial Services」（2026/5/4 発表）の内容把握**
- 金融サービス向けエージェントの公式リリース。会計・財務領域のAI活用に直結する一次情報
- Tak の本業（組織内会計士）および副業（業務改善コンサル）のユースケースと照合する価値あり
- 参照: [Anthropic News](https://www.anthropic.com/news)

#### 🟢 参考情報

**Claude Code / Anthropic**
- v2.1.149（2026-05-22 本日リリース）主な変更（上記以外）:
  - `/diff` 詳細ビューがキーボード操作（矢印キー・j/k・Space・Home/End）でスクロール可能に
  - Markdown GFM タスクリストチェックボックス（`- [ ] todo` / `- [x] done`）レンダリング対応 → リサーチレポートのTODO表示に活用できる
  - Enterprise 向け: `allowAllClaudeAiMcps` マネージド設定でクラウドMCPコネクタをロード
  - Git ワークツリーのサンドボックス書き込み許可リスト修正（メインリポジトリ全体でなく共有 `.git` ディレクトリのみ対象に）
  - `/feedback` レポートがコンテキストコンパクション前の会話を含むように改善
  - `/ultraplan` とリモートセッション作成の「未コミット変更キャプチャ失敗」エラー修正
  - その他 15件以上のバグ修正
- KPMG × Anthropic グローバル戦略提携（5/19）: 276,000人以上のスタッフへ Claude を展開する「Digital Gateway Powered by Claude」発表
- PwC × Anthropic（5/14）: テクノロジー構築・取引実行・企業変革へ Claude 活用。Big4 での大規模展開が続く
- Claude for Small Business（5/13）: 中小企業向けプラン。副業コンサルの業務ツールとして将来検討の余地あり

**会計×AI**
- freee-MCP: freeeサイン対応で合計約330本のAPIをMCPツール化。Claude Desktop・Claude Code・Claude.ai Web・Cursor から操作可能
- マネーフォワード AI Cowork: 7月リリース予定継続。本日〜5/25（月）の CONNECT with AI カンファレンスで詳細発表見込み
- 経理AI全体のトレンド（2026年）: 定型取引で90%以上の精度の自動仕訳、入力工数75%削減事例が増加。「AIが判断まで支援する段階」への移行期

**GitHub Issues（本日 2026-05-22 新規）**
- #61560: Windows 上での cowork/desktop バグ
- #61558: permissions 領域の機能要望（Enhancement）
- #61557: Anthropic API/モデル関連バグ
- #61555: a11y・TUI 領域のバグ（duplicate）

#### references.md 更新提案

前回提案（15件）に追加:

16. **`/usage` カテゴリー別コスト内訳（v2.1.149〜）**: スキル・サブエージェント・MCP ごとのコスト分解が可能。ハーネスの「コスト意識: サブエージェントは haiku 優先」という方針の効果測定ツールとして活用候補（CLAUDE.md 基本方針と接続）

#### 新規発見ソース候補

新規なし（前回提案の claude.com/blog が未追記の場合は引き続き追記を推奨）

#### 次回リサーチ推奨日

2026-05-26（マネーフォワード CONNECT with AI カンファレンス最終日）

注目点:
① **マネーフォワード CONNECT with AI（5/25〜26）のリアルタイム情報**（AI Cowork 詳細・ソニーグループ経理AI活用事例）
② ADR-001・ADR-003 TBP昇格の Tak 確認（継続）
③ freee-MCP freeeサイン対応の導入検討・TBP-001 審査フロー再適用
④ Anthropic「Agents for Financial Services」の詳細把握
⑤ Claude Code を v2.1.149 に更新済みか確認

---

## [2026-05-21] デイリーレポート

---

### 内部知見（機能A）

#### 新規・更新 ADR

- My-Profile-and-Memory decisions/: 前回（2026-05-20）以降の新規・更新コミットなし（計4件: ADR-001〜004 のまま）
- 他5プロジェクト（StudyMate / My-URAWA-LOG / tak-work / tak-family / tak-personal）は decisions/ なし → スキップ

**新規なし**

#### TBP 昇格候補

前回提案済みの ADR-001・ADR-003 が昇格待ち継続。新規候補なし。

#### 再検討トリガー該当

**TBP-001（外部ツール審査）/ 部分該当（MCP tunnels）**
- トリガー: TBP-001「適用場面」の「新たなMCPサーバーの導入時」に準じる
- 外部情報: Code with Claude London（5/19〜21）で **MCP tunnels** が発表。パブリックインターネットを経由せず社内システムへアクセスできるMCPトンネル機能。内部システムへの接続チャンネルを外部MCPとして扱う新たな形態
- 評価: TBP-001 の審査フロー（審査→最小権限→段階拡張）は引き続き有効。ただし「MCP tunnel 経由でアクセスする社内リソース」の審査では「接続先が信頼できる社内システムか」という追加確認軸が有用になりうる。**現時点でのTBP-001 の再検討は不要だが、MCPトンネルを採用する際に審査4軸に「tunnel先エンドポイントの信頼性確認」を追加することを将来の更新候補として記録**

その他:
- ADR-001（スキル読み込みモデル変更トリガー）: v2.1.146 の変更（`/code-review` リネーム、AskUserQuestion修正）はスキルの読み込みモデル自体の変更ではない。前回評価を維持
- ADR-002（指示遵守能力向上トリガー）: 新モデルリリースなし。監視継続
- TBP-002（英語パス）: 該当外部情報なし

---

### 外部リサーチ（機能B）

#### 参照した情報源

- Claude Code 公式チェンジログ（code.claude.com/docs/en/changelog）— v2.1.146（本日リリース）確認
- anthropics/claude-code GitHub issues（#61256〜#61262）
- claude.com/blog（Managed Agents: Dreaming・Outcomes・Multi-agent orchestration）
- fortune.com / tech.yahoo.com（Code with Claude London 報道）
- Anthropic 公式ニュース（anthropic.com/news）
- マネーフォワード 公式（CONNECT with AI カンファレンス最終確認）
- 会計×AI: boxil.jp / ai-revolution.co.jp / bakuraku.jp（バクラク AIエージェント）/ freee 公式

#### 🔴 即座に適用すべき事項

**なし**

前回（2026-05-20）通知済みの事項（VS Code 使用量スパイク issue #58557 等）から新たな緊急事項なし。

#### 🟡 近いうちに試したいこと（上位3件）

**① v2.1.146: `/code-review` コマンド（本日リリース）**
- `/simplify` が `/code-review` にリネームされ、努力レベルの指定が可能に（例: `/code-review high`）
- デイリーリサーチ後のレポート確認・ハーネス設計ドキュメントの品質チェックに応用できる
- AskUserQuestion が auto モードで抑制されなくなった修正も含む。スキルの対話フローが auto モード中に正しく動作するようになった（要確認）
- 参照: [Claude Code Changelog v2.1.146](https://code.claude.com/docs/en/changelog)

**② マネーフォワード CONNECT with AI（5/25〜26）— 明後日開催**
- 5月25日（月）・26日（火）12:00〜18:00 オンライン無料開催（申込締切: 5/26 17:00）
- 登壇: ソニーグループ グローバル経理センター統括部長 林 尚史 氏、NSV Wolf Capital 柴田 尚樹 氏 他
- マネーフォワード AI Cowork（7月リリース予定）の最新情報が得られる可能性大。申込推奨
- 参照: [CONNECT with AI カンファレンス](https://bizevent.moneyforward.com/connect-with-ai/)

**③ バクラク AIエージェント（複数専門AIエージェント協調型）の詳細把握**
- 申請内容リアルタイムレビュー・メールからの証憑自動取得・最適仕訳自動入力・入金消込を複数専門AIエージェントが協調して処理するアーキテクチャ
- マネーフォワード AI Cowork の自然言語オーケストレーション型と比較すると、バクラクは「専門AIの協調チーム型」。会計SaaSのAIアーキテクチャを比較把握しておく価値あり
- 参照: [バクラク AIエージェント](https://bakuraku.jp/)

#### 🟢 参考情報

**Claude Code / Anthropic**
- v2.1.146（2026-05-21 本日リリース）主な変更:
  - `/simplify` → `/code-review`（effort レベル付き: `/code-review high` 等）
  - Auto モードで AskUserQuestion が抑制されなくなった（スキル・ユーザーが明示的に依存する場合）
  - Windows PowerShell「command line is invalid」バグ修正（v2.1.124 以降のリグレッション）
  - MCP pagination: resources/list・templates/list・prompts/list のページ2以降が消える問題修正
  - Windows Terminal でのバックグラウンドセッション全画面ちらつき修正
- Code with Claude London（5/19〜21）: Fortune 誌が「Anthropic lands in London as AI-powered coding—and the anxieties around it—go mainstream」と報道。5/6 SF イベント発表（Dreaming・Outcomes・Agent Teams）の続報・デモが中心。London 固有の新発表は本日時点で未確認
- Managed Agents 3機能（5/6 SF 発表の再確認）:
  - **Dreaming**（研究プレビュー）: 夜間セッションレビューで記憶更新・自己改善。Harvey の事例で完了率約6倍
  - **Outcomes**（公開ベータ）: 成功基準ルーブリックを書き、別コンテキストのグレーダーが評価・反復
  - **Agent Teams / Multi-agent orchestration**（公開ベータ）: リードエージェントが複数 Teammate を統括、並列処理・専門分担

**会計×AI**
- freee Agent Hub: 認定アドバイザー向けに「資料回収 → 決算申告」を自動化するAPIセット提供中
- freee AIヘルプデスク: 従業員からの会計質問に AIが自動応答（3/16 リリース済み）
- バクラク AIエージェント: 複数専門AIエージェント協調型。バックオフィス業務を分業・協調処理するアーキテクチャ
- マネーフォワード AI Cowork: 7月リリース予定のまま。CONNECT with AI（5/25〜26）での詳細発表に期待

**GitHub Issues（本日 2026-05-21 新規）**
- #61257: claude.com/code（area:cowork）のバグ（needs-info）— Web 版 Claude Code + AI Cowork 連携に関連する可能性
- #61256: CLI + Plugins のバグ（再現手順あり）
- #61258〜#61262: macOS・モデル・エージェント関連のバグ複数

**Zenn/Qiita**
- 引き続き Claude Code 実践記事が増加中。Code with Claude London 参加レポートは週明け以降に出揃う見込み

#### references.md 更新提案

前回までの提案（1〜14件）に追加：

15. **`/code-review` コマンド（v2.1.146〜、旧: `/simplify`）**: effort レベル指定（low/medium/high/max）が可能。ハーネスのコードレビュー・ドキュメントレビュー工程への組み込み候補として記録候補

#### 新規発見ソース候補

| ソース | URL | 種別 | 評価候補 | 発見日 |
|--------|-----|------|--------|--------|
| claude.com/blog | https://claude.com/blog | Anthropic 公式ブログ（Managed Agents・新機能詳細）| ⭐⭐⭐⭐⭐ | 2026-05-21 |

※ anthropic.com/news とは別に claude.com/blog に製品詳細記事が掲載されている。trusted-sources.md の「公式・一次情報源」セクションへの追加を提案。

#### 次回リサーチ推奨日

2026-05-25（マネーフォワード CONNECT with AI カンファレンス初日）

注目点:
① **マネーフォワード CONNECT with AI（5/25〜26）のリアルタイム情報**（AI Cowork 詳細・ソニーグループ経理 AI 活用事例）
② Code with Claude London（5/19〜21）の発表内容 詳細まとめ記事（週明け以降）
③ ADR-001・ADR-003 TBP昇格の Tak 確認（継続）
④ VS Code 使用量スパイク（issue #58557）の Anthropic 公式対応状況
⑤ v2.1.146 の AskUserQuestion auto モード修正がデイリーリサーチスキルに与える影響確認
⑥ Code with Claude Tokyo（6/10）ライブストリーム登録（未済の場合）

---

## [2026-05-20] デイリーレポート

---

### 内部知見（機能A）

#### 新規・更新 ADR

- My-Profile-and-Memory decisions/: 前回（2026-05-19）以降の新規・更新コミットなし（計4件: ADR-001〜004 のまま）
- 他5プロジェクト（StudyMate / My-URAWA-LOG / tak-work / tak-family / tak-personal）は decisions/ なし → スキップ

**新規なし**

#### TBP 昇格候補

前回提案済みの ADR-001・ADR-003 が昇格待ち継続。新規候補なし。

#### 再検討トリガー該当

**なし**

各 ADR・TBP のトリガー照合結果：
- ADR-001（スキルモデル変更）: 本日の外部情報にスキル読み込みモデルの変更なし。前回「要ウォッチ」の issue #56710（skill description truncation）は未解決情報のまま継続監視。
- ADR-002（指示遵守向上）: 新モデルリリースなし。
- ADR-003・ADR-004: 該当外部情報なし。
- TBP-001（外部ツール審査）: KPMG × Anthropic 提携は TBP-001 の審査フロー自体には影響しない。ただし「Anthropic 公式パートナーが提供するツール」の位置づけが今後変わる可能性あり（要ウォッチ）。
- TBP-002（英語パス）: 該当外部情報なし。

---

### 外部リサーチ（機能B）

#### 参照した情報源

- Claude Code 公式チェンジログ（code.claude.com/docs/en/changelog）— v2.1.144・v2.1.145 確認（前回からの更新なし）
- anthropics/claude-code GitHub issues（issue #58557, #60334, #60423）
- Anthropic 公式ニュース（anthropic.com/news）
- resultsense.com / accountingtoday.com / kpmg.com / anthropic.com（KPMG提携）
- Zenn / Qiita（ClaudeCode タグ）
- 会計×AI Web 検索（経理AI, 自動仕訳, マネーフォワード AI）

#### 🔴 即座に適用すべき事項

**① VS Code での Claude Code 使用量スパイク（issue #58557）— 要確認**
- 2026-05-06 の変更以降、VS Code での Claude Code セッション 1回（5時間）で週制限の約 25% を消費する事例が報告
- Pro プランでは 4セッション前後で週制限に達する計算。従来より大幅な消費増
- **対応**: VS Code で Claude Code を使っている場合、`/usage` コマンドで週の残量を確認すること。CLI（ターミナル）での利用の方が安定している場合はそちらを優先検討
- 参照: [GitHub issue #58557](https://github.com/anthropics/claude-code/issues/58557)

#### 🟡 近いうちに試したいこと（上位3件）

**① KPMG × Anthropic グローバル提携の会計実務への含意を把握（本業直結）**
- 2026-05-19 発表: KPMG がグローバル 276,000 人の全社員に Claude アクセスを付与。Tax & Legal 部門から展開開始
- 技術構成: Claude Cowork + Managed Agents を KPMG の Digital Gateway（Microsoft Azure 上）に統合。2026年9月に全面実装予定
- KPMG Blaze: Claude Code を IT モダナイゼーションに組み込んだ新サービスも発表
- **会計実務への意味**: Big Four が全社導入したことで、会計・税務領域の AI 活用が「試験運用」から「業界標準」フェーズへ移行するシグナル。組織内会計士としての AI リテラシーが差別化要因になりつつある
- 参照: [Anthropic 公式発表](https://www.anthropic.com/news/anthropic-kpmg) / [Accounting Today](https://www.accountingtoday.com/news/kpmg-enters-alliance-with-anthropic)

**② Code w/ Claude London（本日 5/20〜21）の成果確認**
- 本日開催中。新機能・エージェントインフラのライブデモが発表される可能性あり
- Tokyo（6月5〜6日予定）参加前の事前予習として、London 発表内容を把握しておく価値あり

**③ 画像処理エラーによるトークン無駄消費への対策（issue #60334）**
- スクリーンショット等の画像を会話に含めた場合、処理失敗時に 5時間ウィンドウの 70% 前後を消費するケースが報告
- **対応**: 画像を多用するセッション前に `/usage` で残量確認。画像は必要最小限に絞ること

#### 🟢 参考情報

**Claude Code / Anthropic**
- v2.1.144・v2.1.145（2026-05-19）: 前回レポートで詳細済み。本日時点で新バージョンリリースは確認できず
- `context: fork` 無限ループ修正（v2.1.145）: 前回「動作確認推奨」のまま継続。デイリーリサーチスキルで `context: fork` を使う場合は確認を推奨
- Anthropic Code w/ Claude: London（本日 5/20〜21）→ Tokyo（6/5〜6）の2都市開催
- Anthropic × Gates Foundation $200M 提携（前回既報）: 医療・教育・経済的流動性への AI 活用を4年間支援

**会計×AI**
- **KPMG × Anthropic（本日の最注目）**: 税務・法務から展開し 2026年9月に監査・財務アドバイザリー等全部門へ拡大。規制コンプライアンスエージェントの構築が数週間 → 数分に短縮されると報告。PwC Japan の Tax AI Assistant（前回既報）と合わせて、Big Four の AI 活用が本格化
- マネーフォワード AI Cowork（2026年7月リリース予定）: 続報なし。CONNECT with AI カンファレンス（5/25〜26）での情報開示に期待
- 経理 AI の現状（2026年版概観）: 仕訳自動化 7割が現実的。OCR + 生成 AI で「請求書受領 → 仕訳起票 → 会計入力 → 確認依頼」の全自動化が実用段階。人間の役割は例外処理・判断・戦略的ファイナンスへシフト中

**Zenn/Qiita**
- 「Claude Code 使い放題は終わるのか？6月改定の全容」（Zenn: sanpi34）: 前回紹介済み。6月15日 Agent SDK 別課金の日本語解説として引き続き参照価値あり
- 「0から分かる Claude Code 完全ガイド」（Zenn: 書籍形式）: 体系的入門ガイドが公開中
- コードを書かない人による Zenn Book 公開事例（Qiita: saitoko）: Claude Code がリポジトリ作成〜公開設定まで実行し、手動操作は 1回のみという実録。非エンジニアの参考事例として価値あり

#### references.md 更新提案

前回までの提案（1〜14件）から変更なし。本日の公式ドキュメント変更は確認できず。新規提案なし。

#### 新規発見ソース候補

| ソース | URL | 種別 | 評価候補 | 発見日 |
|--------|-----|------|--------|--------|
| Accounting Today | https://www.accountingtoday.com | 会計×AI 英語専門メディア。KPMG提携等の会計業界AI動向をリアルタイム報道。Big Four の AI 導入情報が厚い | ⭐⭐⭐⭐ | 2026-05-20 |

#### 次回リサーチ推奨日

2026-05-25（マネーフォワード CONNECT with AI カンファレンス初日）
注目点: ① **マネーフォワード CONNECT with AI（5/25〜26）のリアルタイム情報** ② Code w/ Claude London（5/20〜21）の発表内容確認 ③ ADR-001・ADR-003 TBP昇格の Tak 確認（継続） ④ VS Code 使用量スパイク（issue #58557）の Anthropic 公式対応状況 ⑤ skill description truncation（#56710）の修正状況 ⑥ Code w/ Claude Tokyo（6/5〜6）参加登録確認

---

## [2026-05-19] デイリーレポート

---

### 内部知見（機能A）

#### 新規・更新 ADR

- My-Profile-and-Memory decisions/: 前回（2026-05-18）以降の新規・更新コミットなし（計4件: ADR-001〜004 のまま）
- 他5プロジェクト（StudyMate / My-URAWA-LOG / tak-work / tak-family / tak-personal）は decisions/ なし → スキップ

**新規なし**

#### TBP 昇格候補

前回提案済みの ADR-001・ADR-003 が昇格待ち継続。新規候補なし。

#### 再検討トリガー該当

**TBP-001（外部ツール審査4軸）/ 部分該当**
- トリガー: TBP-001 には明示的なトリガー条件はないが「新たなセキュリティ脅威情報」として記録
- 外部情報: **Bash permission bypass 脆弱性（v2.1.145 本日修正）** — 50件超のサブコマンドチェーン（&&、||、;）を含む bash コマンドで deny ルールが全て迂回される問題。`bashPermissions.ts` のパフォーマンス最適化（50件上限）が原因。攻撃ベクター: 攻撃者制御のリポジトリをクローンするだけで SSH 秘密鍵・AWS 認証情報・GitHub トークン等が漏洩リスク。High severity と評価
- 評価: TBP-001 の「settings.json の deny で二重ガードレール」の有効性が、この脆弱性期間中は部分的に損なわれていた。v2.1.145 で修正済み。**Claude Code を v2.1.145 以降に即時更新することを強く推奨**。TBP-001 の原則（最小権限・deny ガードレール）は引き続き有効

**ADR-001（スキル読み込みモデル変更トリガー）/ 要ウォッチ**
- トリガー: 「Claude のルーティング精度が大幅に向上/低下した場合」に準じる
- 外部情報: GitHub issue #56710「Skill descriptions truncated due to context budget constraints」を確認 — スキルの description が context budget 制約で切り詰められる問題が報告されている
- 評価: ADR-001 の前提「スキル選択はメタデータ（name + description）のみで判断される」に直接影響する可能性。description が切り詰められるとルーティング精度低下が起きうる。**v2.1.145 での修正状況は未確認。次回確認推奨**。今回は再検討発動とせず「要ウォッチ」として記録

---

### 外部リサーチ（機能B）

#### 参照した情報源

- Claude Code 公式チェンジログ（code.claude.com/docs/en/changelog）— v2.1.145（本日リリース）確認
- anthropics/claude-code GitHub releases / issues
- Anthropic 公式ニュース（anthropic.com/news）
- adversa.ai（Bash bypass 脆弱性解説）
- Zenn・Qiita（ClaudeCode タグ）
- 会計×AI Web 検索（freee, マネーフォワード, バクラク, Sansan Bill One）
- gist.github.com（Agent SDK 価格変更数値解析）

#### 🔴 即座に適用すべき事項

**① Claude Code を v2.1.145 に即時更新（セキュリティ修正）**
- Bash permission bypass 脆弱性（50件超コマンドチェーンで deny ルール全迂回）が本日修正
- `claude update` または `npm update -g @anthropic-ai/claude-code` で更新
- 更新前に信頼できないリポジトリのクローン・実行は避けること

**② 2026-06-15 までの Agent SDK / claude -p 利用確認とオプトイン**
- 2026-05-13 発表: 6月15日から Agent SDK・`claude -p`・GitHub Actions・サードパーティエージェントが subscription の rate-limit バケットから分離され、別枠クレジット制に移行
- 月額クレジット: Pro $20、Max 5x $100、Max 20x $200（使い切り後は標準 API 従量課金）。クレジットは翌月繰越不可・譲渡不可
- 実質値上げ幅: ワークロードにより 12〜175 倍の効果的コスト増になる計算あり
- **対応**: 自プロジェクトで `claude -p` や Agent SDK を自動化目的で使っているか確認し、6月15日前にアカウントでオプトインすること（クレジット付与は opt-in 後から）
- インタラクティブな Claude Code 利用・claude.ai 通常利用は従来通り影響なし

#### 🟡 近いうちに試したいこと（上位3件）

**① Code with Claude Tokyo（2026-06-10）ライブストリーム登録**
- 東京開催（6月10日）のライブストリームは無料・登録受付中。抽選の対面参加は締切済みだがストリームは今からでも申込可能
- 6月11日はデベロッパー・スタートアップ向け Extended イベント（ハンズオン込み）
- 最新のエージェントインフラ・スキル・Routines の生デモが見られる可能性大
- 参照: [claude.com/code-with-claude/tokyo](https://claude.com/code-with-claude/tokyo)

**② v2.1.145: `claude agents --json`（本日リリース）**
- ライブセッションを JSON 形式でリスト表示。tmux-resurrect・ステータスバー・セッションピッカーとの連携対応
- デイリーリサーチの複数サブエージェント実行時のセッション管理が改善できる
- OTEL スパンに `agent_id` / `parent_agent_id` が追加 → 分散トレーシングとの連携が可能に

**③ v2.1.144: `/model` のセッション限定変更と `d` キーでデフォルト設定**
- `/model` がセッション限定変更になった（以前はデフォルト変更だった）。`d` キー押下でデフォルト設定
- セッションごとにモデルを試しやすくなった。Claude Haiku 4.5 をコスト抑制用に使い分ける運用が簡単に

#### 🟢 参考情報

**Claude Code / Anthropic**
- v2.1.145（本日 2026-05-19 リリース）主な変更:
  - `claude agents --json` でライブセッション JSON 出力（tmux/ステータスバー連携）
  - OTEL スパンに `agent_id` / `parent_agent_id` 追加
  - `/plugin browse/discover` にコマンド・エージェント・スキル・フック・MCP/LSP サーバー一覧表示
  - ステータスライン JSON に GitHub リポジトリ・PR 情報を含める
  - `context: fork` スキルの無限ループを修正（デイリーリサーチスキルへの影響要確認）
  - Read ツールがトークン制限超過時に切り詰め表示（エラーなし）
  - Bash コマンドの権限プロンプトバイパス脆弱性を修正 ← 🔴
  - v2.1.144: `/resume` でバックグラウンドセッションも一覧表示（bg マーク付き）
  - v2.1.144: "extra usage" → "usage credits" へリネーム（`/extra-usage` → `/usage-credits`）
- Anthropic × Gates Foundation $200M パートナーシップ（向こう4年・医療/生命科学/教育/経済的流動性）
- Anthropic × Amazon: 最大 5GW の算力確保（Trainium2 前半投入・Trainium3 は 2026年末計 1GW）
- Anthropic 年換算収益: $300億超（前年末 $90億から急増）

**会計×AI**
- マネーフォワード AI Cowork: 2026年7月リリース予定のまま。自然言語指示で経理業務を自律実行、ガバナンス機能（承認フロー・AI監査ログ）装備。ARR 150億円超（2030年目標）
- freee「AIおまかせ明細取得」β版: PDF 明細データも自動変換可能に
- Sansan Bill One: 請求書と発注データの AI 自動照合機能（2026年追加）
- 中堅企業での AI 活用事例: 月 400〜600 件仕訳で 8 割自動化、仕訳入力工数 80%削減・請求書処理時間 70%短縮・月次決算 5 営業日早期化を報告

**Zenn/Qiita**
- 「Claude Code 使い放題は終わるのか？6月改定の全容」（Zenn: sanpi34）— 6月15日改定の日本語解説
- `context: fork` スキルの無限ループ問題（GitHub issue #19751）が v2.1.145 で修正済み → デイリーリサーチスキルで `context: fork` を使う場合は更新後に動作確認を

#### references.md 更新提案

今回の公式情報を踏まえた追記提案（Tak 確認後に実施）:

13. **Bash permission bypass 脆弱性の記録（v2.1.145 修正済み）**: deny ルールは 50件超コマンドチェーンで迂回可能だった（修正済み）。「Claude Code は常に最新版に保つこと」をセキュリティ注意事項として記録候補。TBP-001 の審査4軸に「使用ツールのバージョン管理（最新版維持）」を補足提案
14. **`context: fork` スキルの無限ループ修正（v2.1.145）**: スキル設計ベストプラクティスとして「`context: fork` 使用時は v2.1.145 以降が必要」を記録候補

#### 新規発見ソース候補

| ソース | URL | 種別 | 評価候補 | 発見日 |
|--------|-----|------|--------|--------|
| marckrenn/claude-code-changelog | https://github.com/marckrenn/claude-code-changelog | Claude Code リリースのプロンプト・フィーチャーフラグ・メタデータ追跡 | ⭐⭐⭐⭐ | 2026-05-19 |

#### 次回リサーチ推奨日

2026-05-20（明日）
注目点: ① **マネーフォワード CONNECT with AI（5/25〜26）事前最終確認** ② ADR-001・ADR-003 TBP昇格の Tak 確認（継続） ③ Skill description truncation bug（#56710）の v2.1.145 修正状況確認 ④ 6月15日 Agent SDK クレジット移行の自プロジェクトへの影響最終確認 ⑤ Code with Claude Tokyo（6/10）ライブストリーム登録

---

## [2026-05-18] デイリーレポート

---

### 内部知見（機能A）

#### 新規・更新 ADR

- My-Profile-and-Memory decisions/: 前回（2026-05-17）以降の新規・更新コミットなし（計4件: ADR-001〜004 のまま）
- 他5プロジェクト（StudyMate / My-URAWA-LOG / tak-work / tak-family / tak-personal）は decisions/ なし → スキップ

**新規なし**

#### TBP 昇格候補

前回提案済みの ADR-001・ADR-003 が昇格待ち継続。新規候補なし。

#### 再検討トリガー該当

**なし**

ADR-001（スキル読み込みモデル変更トリガー）: 機能B で確認した新機能（`claude agents --cwd`・rewind「Summarize up to here」等）はスキルの読み込みモデル自体の変更ではない。前回評価を維持。
ADR-002（Claude 指示遵守能力向上トリガー）: 新モデルリリースなし（Opus 4.7 のまま）。監視継続。
TBP-001（審査→最小権限→段階拡張）: 新たなセキュリティ脅威情報なし。前回評価を維持。

---

### 外部リサーチ（機能B）

#### 参照した情報源

- Claude Code 公式チェンジログ（code.claude.com/docs/en/changelog）
- anthropics/claude-code GitHub releases（最新リリース情報）
- Anthropic 公式ニュース（anthropic.com/news）
- Releasebot（releasebot.io/updates/anthropic）
- Zenn・Qiita（ClaudeCode タグ）
- マネーフォワード 公式（CONNECT with AI カンファレンス続報）
- 会計×AI Web 検索（freee, マネーフォワード, バクラク 2026年5月）

#### 🔴 即座に適用すべき事項

**なし**

前回（2026-05-17）以降、新たな緊急事項なし。

#### 🟡 近いうちに試したいこと（上位3件）

**① Claude Code 新バージョン（v2.1.144 相当）: rewind「Summarize up to here」**
- 5月16〜17日頃のリリース（正確なバージョン番号は未確認）に以下が含まれると推定
- rewind メニューに「Summarize up to here」追加 → 現在位置より前のコンテキストを圧縮可能
- 長時間リサーチセッションで会話が長くなりすぎた際の手動コンパクションに活用できる
- 参照: [anthropics/claude-code Releases](https://github.com/anthropics/claude-code/releases)

**② Claude Code 新バージョン: バックグラウンドエージェントの権限モード保持**
- `/bg` または ←← で起動したバックグラウンドエージェントが、現在の権限モードをそのまま引き継ぐように変更
- 従来はデフォルト権限モードに戻っていたため、意図しない権限での実行リスクがあった
- デイリーリサーチのバックグラウンド実行設計時に考慮すべき改善点
- 参照: [anthropics/claude-code Releases](https://github.com/anthropics/claude-code/releases)

**③ マネーフォワード CONNECT with AI カンファレンス（5/25〜26）直前確認**
- 5月25日（月）・26日（火）12:00〜18:00 オンライン開催、参加費無料
- 対象: 経理・管理部門の部門長・担当者、経営者
- 内容: 生成AI実務活用・内部統制×AI・AI時代の人材育成・組織論
- マネーフォワード AI Cowork の最新情報が得られる可能性が高い
- 参照: [マネーフォワード CONNECT with AI](https://corp.moneyforward.com/news/release/service/20260416-mf-press-1/)

#### 🟢 参考情報

**Claude Code / Anthropic**
- v2.1.143（2026-05-15）が引き続き最新確認バージョン。ただし 5/16〜17 頃に追加リリースの可能性（検索結果で「2日前のリリース」を確認。バージョン番号未特定）
- 追加リリース（未確認版）の主な変更点:
  - `CLAUDE_CODE_PLUGIN_PREFER_HTTPS`: GitHub プラグインを SSH ではなく HTTPS でクローン
  - `ANTHROPIC_WORKSPACE_ID` 環境変数: ワークロードアイデンティティフェデレーション対応
  - `claude agents --cwd <path>`: セッション一覧を特定ディレクトリにスコープ絞り込み
  - `/feedback` 改善: 複数セッションにまたがる問題の報告に対応（最近のセッションを含む）
  - IDE 接続時にファイル編集の権限プロンプトで「IDE でdiff表示」オプションが復活
  - 長い思考中のスピナーフィードバック改善
- Claude Platform on AWS 正式ローンチ確認（Code with Claude 2026 発表分の再確認）: AWS billing + IAM 認証で Messages API・Files API・Managed Agents 等が利用可能
- Code with Claude 2026 の意図: 新モデル発表を意図的に見送り、エージェントインフラ（Managed Agents・Routines・Skills・Remote Agents）に集中（前回確認情報の再確認）

**会計×AI**
- 新規情報なし（前回から変化なし）
- 継続確認中: マネーフォワード AI Cowork（7月リリース予定）・freee MCP リモート版（270種類操作対応）
- バクラク × マネーフォワード クラウド会計 Plus の仕訳 API 連携（ワンクリック同期）は引き続き注目

**Zenn/Qiita**
- 2026-05-18 時点で ClaudeCode タグの本日固有の新着記事は確認できず
- トレンド: Claude Code を使った Zenn/Qiita 記事の自動生成・自動転載スキルの事例が増加中

#### references.md 更新提案

前回（2026-05-17）提案（9・10件）に追加：

11. **バックグラウンドエージェントの権限モード保持（最新版〜）**: `/bg`・←← で起動したエージェントが現在の権限モードを引き継ぐようになった。ハーネス設計でバックグラウンド実行を検討する際の参考情報として記録候補
12. **`claude agents --cwd <path>`（最新版〜）**: セッション一覧のディレクトリスコープ絞り込みが可能に。複数プロジェクトを並列で扱う際のエージェント管理に有用

#### 新規発見ソース候補

なし（前回提案の biz-ai.moneyforward.com が評価待ち）

#### 次回リサーチ推奨日

2026-05-20（前回推奨日のまま）
注目点: ① **マネーフォワード CONNECT with AI（5/25〜26）事前最終確認** ② 未確認バージョン（v2.1.144?）の正式確認 ③ ADR-001・ADR-003 TBP昇格の Tak 確認 ④ Claude Platform on AWS の実務利用シナリオ確認

---

## [2026-05-17] デイリーレポート

---

### 内部知見（機能A）

#### 新規・更新 ADR

- My-Profile-and-Memory decisions/: 前回（2026-05-16）以降の新規・更新コミットなし（計4件: ADR-001〜004 のまま）
- 他5プロジェクト（StudyMate / My-URAWA-LOG / tak-work / tak-family / tak-personal）は decisions/ なし → スキップ

**新規なし**

#### TBP 昇格候補

前回提案済みの ADR-001・ADR-003 が昇格待ち。新規候補なし。

#### 再検討トリガー該当

**なし**

ADR-001（スキル読み込みモデル変更トリガー）: 新バージョンリリースなし（v2.1.143 のまま）。前回評価を維持。
ADR-002（Claude 指示遵守能力向上トリガー）: 新モデル発表なし（Code with Claude 2026 では意図的にモデル発表を見送り、インフラ・オーケストレーション重視と判明）。監視継続。
TBP-001（審査4軸へのコスト分類追記提案）: 2026-05-14 提案済み。Tak 確認待ち。

---

### 外部リサーチ（機能B）

#### 参照した情報源

- Claude Code 公式チェンジログ（code.claude.com/docs/en/changelog）— v2.1.143 が最新（2026-05-17 時点）
- Anthropic 公式ニュース（anthropic.com/news、anthropic.com/events）
- anthropics/claude-code GitHub releases
- Releasebot（releasebot.io/updates/anthropic）
- Zenn・Qiita（ClaudeCode タグ）
- 会計×AI Web 検索（マネーフォワード、freee、税務AI、KSK2）

#### 🔴 即座に適用すべき事項

**なし**

前回（2026-05-16）以降、新たな緊急事項なし。

#### 🟡 近いうちに試したいこと（上位3件）

**① マネーフォワード CONNECT with AI カンファレンス（2026年5月25〜26日）参加検討**
- マネーフォワードが「経理とAIで描く、未来への第一歩。-CONNECT with AI-」をオンライン開催
- AI Cowork（2026年7月リリース予定）の詳細情報が得られる可能性が高い
- 経理・バックオフィス×AI の最前線が把握できる。本業（組織内会計士）への応用価値大
- 参照: [マネーフォワード CONNECT with AI カンファレンス](https://corp.moneyforward.com/news/release/service/20260416-mf-press-1/)

**② Anthropic The Briefing: Financial Services（バーチャルイベント）内容確認**
- Anthropic が金融サービス向けに特化したブリーフィングイベントを開催予定
- 公認会計士・経理職への Claude 活用事例が含まれる可能性あり
- 詳細ページは 403 で取得できず。次回 anthropic.com/events を直接確認することを推奨
- 参照: [Anthropic Events](https://www.anthropic.com/events)

**③ マネーフォワード AI Cowork ARR 目標と詳細仕様の把握**
- ARR 150億円超（2030年度）を目標と公表。事業規模が確定
- ガバナンス機能: ガードレール・人間確認・承認プロセス・権限管理・AI監査ログを装備（企業導入に耐える設計）
- 自然言語指示でオーケストレーターが意図を解釈 → 最適な専門エージェントへ業務を振り分けるアーキテクチャ
- 参照: [マネーフォワード AI Cowork 発表](https://corp.moneyforward.com/news/release/service/20260407-mf-press-1/)

#### 🟢 参考情報

**Claude Code / Anthropic**
- v2.1.143（2026-05-15）が 2026-05-17 時点での最新。新バージョンリリースなし
- Code with Claude 2026 の設計意図が明確に: 新モデルを意図的に発表せず「エージェントインフラ・オーケストレーション」に集中したイベントだった（Anthropic CPO Ami Vora が明言）
- Claude Mythos Preview（red.anthropic.com/2026/mythos-preview/）: セキュリティ特化モデルファミリー。前回既知情報の再確認。

**会計×AI**
- 国税庁: 2025年7月から相続税申告書の AI スコアリング審査を本格運用中（再確認）
- KSK2（次世代国税総合管理システム）: 2026年9月全面移行確定。AI中心の調査先選定を将来的に本格化（再確認）
- freee AI 機能（再確認）: 印刷レシート OCR 精度 90%超、銀行明細自動仕訳推測 85〜90%
- Bill One（2026年版）: 請求書と発注データの AI 自動照合機能を追加

**Zenn/Qiita**
- 2026-05-17 時点で ClaudeCode タグの注目新着記事は確認できず。前回紹介済みの記事群が引き続き上位

#### references.md 更新提案

前回（2026-05-16）提案の9・10件から変更なし。Tak 確認待ち。

#### 新規発見ソース候補

| ソース | URL | 種別 | 評価候補 | 発見日 |
|--------|-----|------|--------|--------|
| biz-ai.moneyforward.com | https://biz-ai.moneyforward.com/ | マネーフォワード AI 公式ポータル（AI Cowork・AI関連製品一覧） | ⭐⭐⭐⭐ | 2026-05-17 |

#### 次回リサーチ推奨日

2026-05-20（前回推奨日のまま）
注目点: ① **マネーフォワード CONNECT with AI（5/25〜26）事前確認** ② v2.1.144+ リリース内容 ③ Anthropic Financial Services Briefing 詳細 ④ ADR-001・ADR-003 TBP昇格の Tak 確認 ⑤ マネーフォワード AI Cowork の本格発表情報

---

## [2026-05-16] デイリーレポート

---

### 内部知見（機能A）

#### 新規・更新 ADR

- My-Profile-and-Memory decisions/: 前回（2026-05-15）以降の新規・更新コミットなし（計4件: ADR-001〜004 のまま）
- 他5プロジェクト（StudyMate / My-URAWA-LOG / tak-work / tak-family / tak-personal）は decisions/ なし → スキップ

**新規なし**

#### TBP 昇格候補

前回提案済みの ADR-001・ADR-003 が昇格待ち。新規候補なし。

#### 再検討トリガー該当

**なし**

ADR-001（スキル読み込みモデル変更トリガー）: v2.1.143 以降の新バージョンなし。前回評価を維持。
ADR-002（Claude 指示遵守能力向上トリガー）: Claude 5 のリリース・性能情報なし（Qiita に「2月リリース」リーク記事あるが 5月時点で未公式）。監視継続。

---

### 外部リサーチ（機能B）

#### 参照した情報源

- Claude Code 公式チェンジログ（code.claude.com/docs/en/changelog）— v2.1.143 が最新（2026-05-16 時点）
- Anthropic 公式ニュース（anthropic.com/news）
- Qiita（kotaro_ai_lab: Claude Code 5月ニュースまとめ）
- Zenn（gemcook: Claude Code全社導入事例 / sanpi34: 6月改定解説）
- 会計×AI: keihi.com / renue.co.jp / fastaccounting.jp / funnel-ai.jp

#### 🔴 即座に適用すべき事項

**なし**

前回（2026-05-15）通知済みのAnthropicサブスク変更（6月15日施行）以外、新たな緊急事項なし。

#### 🟡 近いうちに試したいこと（上位3件）

**① Anthropic × Amazon 大規模連携拡大（新規）**
- 向こう10年間で $1,000億以上を AWS 技術に投資、最大 5GW の新規算出キャパシティ確保
- Claude の可用性・コスト安定化に貢献する可能性。大規模コンテキスト作業（Claude Code でのリポジトリ全読み込み等）がさらに安定化か
- 参照: [anthropic.com/news/anthropic-amazon-compute](https://www.anthropic.com/news/anthropic-amazon-compute)

**② Code with Claude 2026 の主要成果（2026-05-06 イベント）**
- レート制限が2倍に拡大（ピーク時制限も撤廃）。SpaceX Colossus 1 との連携でコンピュート増強
- Claude Code の実作業量上限が実質拡大。長時間・大規模エージェント作業の阻害要因が一つ減少
- 参照: [Qiita: kai_kou - Code with Claude 2026 完全解説](https://qiita.com/kai_kou/items/ba88f403caf78fe5242b)

**③ Claude Cowork Finance × 経理実務ガイド（note 記事）**
- 上場企業AI責任者による「Claude Cowork Finance で経理業務を劇的に効率化」実践ガイドが公開
- 経費精算・仕訳自動化・月次決算の具体的なプロンプト設計まで踏み込んだ内容。本業（経理部長）に直結
- 参照: [note.com/ai_sales](https://note.com/ai_sales/n/nd1379898eec3)

#### 🟢 参考情報

**Claude Code / Anthropic**
- v2.1.143（2026-05-15）が 2026-05-16 時点での最新。新バージョンリリースなし
- Anthropic: 年間換算売上 $300億超（年末 2025 時点の $90億から急増）
- Anthropic: 米国 AI インフラへ $500億投資を発表（クラウド・データセンター拡張）
- 国内企業 Claude Code 全社導入事例: Gemcook（2026年2月）— 一部メンバーが導入数日で数万行を生成

**会計×AI**
- 経理・財務業務への AI 導入率 71%（2026年時点）、その半数以上が生成 AI 本格運用フェーズ
- マネーフォワード AI Cowork: 続報なし（7月リリース予定のまま）。MCP サーバー接続機能も予告済み
- funnel-ai.jp に「Claude Cowork × freee / マネーフォワード MCP 対応状況と設定の違い【2026年4月版】」が公開。実務設定の差分を整理した参考記事

#### references.md 更新提案

**なし**（前回提案9件・10件に変更なし。Tak 確認待ち）

#### 新規発見ソース候補

| ソース | URL | 種別 | 評価候補 | 発見日 |
|--------|-----|------|--------|--------|
| funnel-ai.jp | https://funnel-ai.jp/media/ | Claude Cowork × 会計SaaS MCP 実践記事 | ⭐⭐⭐ | 2026-05-16 |
| claudeupdates.dev | https://www.claudeupdates.dev/update | Claude Code 更新トラッカー | ⭐⭐⭐ | 2026-05-16 |

#### 次回リサーチ推奨日

2026-05-20（変更なし）
注目点: ① マネーフォワード AI Cowork 詳細（7月リリース前続報） ② v2.1.144+ リリース内容 ③ ADR-001・ADR-003 TBP昇格の Tak 確認 ④ Code with Claude 2026 の詳細続報 ⑤ Claude Cowork Finance 記事の実ハーネスへの応用検討

---

## [2026-05-15] デイリーレポート

---

### 内部知見（機能A）

#### 新規・更新 ADR

- My-Profile-and-Memory decisions/: 前回（2026-05-14）以降の新規・更新コミットなし（計4件: ADR-001〜004 のまま）
- 他5プロジェクト（StudyMate / My-URAWA-LOG / tak-work / tak-family / tak-personal）は decisions/ なし → スキップ

**新規なし**

#### TBP 昇格候補

前回提案済みの ADR-001・ADR-003 が昇格待ち。新規候補なし。

#### 再検討トリガー該当

**なし**

ADR-001（スキル読み込みモデル変更トリガー）: v2.1.143 はプラグイン依存関係管理の追加であり、スキルの読み込みモデル自体の変更ではない。再検討不要。
ADR-002（Claude 指示遵守能力向上トリガー）: Opus 4.7 の公式ベンチマーク新情報なし。監視継続。

---

### 外部リサーチ（機能B）

#### 参照した情報源

- Claude Code 公式チェンジログ（code.claude.com/docs/en/changelog）— v2.1.143 が最新（2026-05-15 時点）
- Anthropic 公式ブログ（anthropic.com/news）
- ITmedia / Ledge.ai / WEEL / XenoSpectrum（Claude for Small Business 各解説）
- Qiita（creolab_dev: 5月アップデート総括 / ennagara128: CLAUDE.md鉄板5行）
- Zenn（yoshiaki0217: Claude Code新卒部下ワークフロー）
- 会計×AI Web 検索（keihi.com, renue.co.jp, fastaccounting.jp 等）
- freee MCP / マネーフォワード AI Cowork 続報確認

#### 🔴 即座に適用すべき事項

**なし**

前回（2026-05-14）に通知済みの Anthropic サブスク変更（6月15日施行）以外に新たな緊急事項なし。

#### 🟡 近いうちに試したいこと（上位3件）

**① Claude for Small Business の会計ワークフロー（2026-05-13 発表）**
- Anthropic が中小企業向けに 15 種類のアジェンティックワークフロー＋15スキルを発表
- 会計領域: QuickBooks × PayPal の 30日キャッシュフロー予測・月次決算（取引照合・差異検出・P&Lサマリー）
- 7つのコネクタ: QuickBooks・PayPal・HubSpot・Canva・Docusign・Google Workspace・Microsoft 365
- 追加費用なし（既存 Claude ライセンス内でトグルON）
- 本業（経理・組織内会計士）への直接応用価値あり。国内会計SaaS（freee / マネーフォワード）との連携状況を引き続き確認
- 参照: [ITmedia](https://www.itmedia.co.jp/enterprise/articles/2605/15/news046.html) / [Ledge.ai](https://ledge.ai/articles/claude_for_small_business_workflows)

**② v2.1.143: `worktree.bgIsolation: "none"` 設定（2026-05-15 本日リリース）**
- バックグラウンドセッションが `EnterWorktree` なしで作業コピーを直接編集可能に
- ハーネスのバックグラウンドエージェント設計に影響する可能性。将来的にデイリーリサーチの自動化設計を見直す際に確認
- 参照: [Claude Code 公式チェンジログ v2.1.143](https://code.claude.com/docs/en/changelog)

**③ v2.1.143: Plugin marketplace への予測コンテキストコスト表示**
- `/plugin` マーケットプレイスに「ターンごと・実行ごとのトークン推定値」が追加
- ADR-001 の「スキル固定コスト監視」に直接使える。スキル追加前の事前コスト確認が可能に
- 既存 `claude plugin details <name>`（v2.1.139〜）と組み合わせると固定コスト把握が完結

#### 🟢 参考情報

**Claude Code / Anthropic**
- v2.1.143（2026-05-15）主な変更:
  - プラグイン依存関係管理: `plugin disable` が依存プラグインある場合は拒否（コピー可ヒント付き）、`plugin enable` が推移的依存を自動解決
  - PowerShell ツール: `-ExecutionPolicy Bypass` をデフォルト渡し（Windows 環境向け）
  - バックグラウンドセッション: アイドル復帰後にモデル・effortレベルを保持
  - Shift+Tab: 付属エージェントセッションのオートモードを含むサイクルに対応
  - バグ修正: `.credentials.json` 非配列 scopes 値でのCLI起動ハング・WSLの右クリックペースト等
- Anthropic × Gates Foundation 提携: 向こう4年間で $2億拠出（AI×ヘルスケア・教育等）
- Anthropic 資金調達: 評価額 $9,000億超・調達規模 $300億以上の協議進行中（2026年5月時点）

**会計×AI**
- freee MCP リモート版（2026-03-27 正式リリース）: 約270種類の会計操作が AI から直接実行可能。ローカル環境構築不要で使い始められる
- マネーフォワード AI Cowork（2026年7月リリース予定）: バックオフィス業務自動化エージェント。引き続き注目
- 国税庁: 2025年7月から相続税申告書の AI スコアリング審査を本格運用中
- PwC Japan: 日本税法特化の Tax AI Assistant を提供中。税務調査リスクの事前チェック等に活用
- 「請求書受取→仕訳起票→会計入力→担当者確認依頼」の全自動化が 2026年5月時点で実用水準に到達

**Zenn/Qiita**
- [CLAUDE.md / AGENTS.md の鉄板5行テンプレ（Qiita: ennagara128）](https://qiita.com/ennagara128/items/5852549551333bf1b721): AI出力品質を底上げする実用テンプレ。ハーネス改善のヒントとして確認価値あり
- [Claude Code を「優秀な新卒部下」として使い倒す（Zenn: yoshiaki0217）](https://zenn.dev/yoshiaki0217/articles/9dd7a3666d475f): 個人開発爆速化の全ワークフロー。非エンジニアにも参考になる設計パターン

#### references.md 更新提案

前回（2026-05-14）提案の8件に追加：

9. **Plugin dependency management（v2.1.143〜）**: `plugin enable` が推移的依存を自動解決し、`plugin disable` が依存チェーンを警告するようになった。ハーネスでプラグインを増やす際の依存関係管理指針として記録候補
10. **Claude for Small Business の位置づけ**: Anthropic ネイティブの会計ワークフローツール（QuickBooks等と統合）が登場。TBP-001 の「適用場面」に「Anthropic ネイティブの Business ツール」の扱いを補足するか、Tak との確認を推奨

#### 新規発見ソース候補

| ソース | URL | 種別 | 評価候補 | 発見日 |
|--------|-----|------|--------|--------|
| WEEL（メディア） | https://weel.co.jp/media/innovator/claude-for-small-business/ | Claude for Small Business 日本語解説 | ⭐⭐⭐ | 2026-05-15 |
| Uravation（メディア） | https://uravation.com/media/claude-code-accounting-finance-guide-2026/ | Claude Code × 経理活用ガイド2026 | ⭐⭐⭐ | 2026-05-15 |

#### 次回リサーチ推奨日

2026-05-20（5日後）
注目点: ① Claude for Small Business の国内会計SaaS（freee / マネーフォワード）との連携状況 ② マネーフォワード AI Cowork 詳細（7月リリース前の続報） ③ ADR-001・ADR-003 の TBP 昇格確認（Tak への提案継続） ④ v2.1.144+ リリース内容 ⑤ CLAUDE.md 鉄板5行テンプレの自ハーネスへの適用検討

---

## [2026-05-14] デイリーレポート

---

### 内部知見（機能A）

#### 新規・更新 ADR

- My-Profile-and-Memory decisions/: 前回（2026-05-13）以降の新規・更新コミットなし（計4件: ADR-001〜004 のまま）
- 他5プロジェクト（StudyMate / My-URAWA-LOG / tak-work / tak-family / tak-personal）は decisions/ なし → スキップ

**新規なし**

#### TBP 昇格候補

前回提案済みの ADR-001・ADR-003 が昇格待ち。新規候補なし。

#### 再検討トリガー該当

**TBP-001 / 部分該当（コスト変動リスク）**
- トリガー: TBP-001 の審査4軸に「コスト分類」の観点が含まれていない
- 外部情報: Anthropicが 2026-06-15 から Agent SDK / `claude -p` の利用を別枠クレジット制に変更（Pro: $20/月、Max 5x: $100/月、Max 20x: $200/月。使い切り後はAPI従量課金）
- 評価: 外部ツール（Agent SDK連携）を採用する際、継続コストが「Claude Codeインタラクティブ利用」とは別枠になることを審査フェーズで確認する必要がある。**TBP-001 の審査4軸に「コスト分類（インタラクティブ/Agent SDK/API）の確認」を追記提案**（Tak 確認後）

---

### 外部リサーチ（機能B）

#### 参照した情報源

- Claude Code 公式チェンジログ（code.claude.com/docs/en/changelog）— v2.1.142 が最新（2026-05-14 時点）
- テクノエッジ、ITmedia、gihyo.jp（Anthropicサブスク変更）
- Qiita（creolab_dev: 5月アップデート総括、yurukusa: claude -p クレジット分離解説）
- Zenn / Qiita 新着記事（ClaudeCode タグ）
- 会計×AI Web 検索（kaikei-ai.jp, keihi.com 等）

#### 🔴 即座に適用すべき事項

**Anthropicサブスクリプション変更（2026-06-15 施行）**
- Agent SDK および `claude -p` コマンド等の自動化利用が、6月15日から別枠クレジット制に移行
- 付与クレジット: Pro $20/月、Max 5x $100/月、Max 20x $200/月（使い切り後はAPI従量課金レート）
- 対象外: Claude Code のインタラクティブ利用・claude.ai 通常利用は従来通り
- **対応**: 自プロジェクトで `claude -p` / Agent SDK をスクリプトや自動化目的で使っているか確認し、6月15日以降のコスト増を把握しておく
- 参照: [テクノエッジ](https://www.techno-edge.net/article/2026/05/14/5064.html) / [ITmedia](https://www.itmedia.co.jp/aiplus/articles/2605/14/news078.html) / [gihyo.jp](https://gihyo.jp/article/2026/05/claude-agent-sdk-credit)

#### 🟡 近いうちに試したいこと（上位3件）

**① HTTP hooks / async hooks の活用（v2.1.141/142）**
- PostToolUse hooks に `async: true` フラグと HTTP hooks が追加。フックから外部 Web サーバーへ POST できる
- 応用: 特定ツール実行をトリガーに Slack 通知・Webhook 送信などが実現可能
- 参照: [Claude Code 5月アップデート総括 — Qiita](https://qiita.com/creolab_dev/items/5f058d93b1f88c43f339)

**② Fast mode の Opus 4.7 デフォルト切り替え確認（v2.1.142）**
- `/fast` モードが Opus 4.6 → Opus 4.7 デフォルトに変更
- 4.6 に固定したい場合: `CLAUDE_CODE_OPUS_4_6_FAST_MODE_OVERRIDE=1` 環境変数で固定可能
- 参照: Claude Code チェンジログ v2.1.142

**③ Issue→Done 自動化フロー設計パターン**
- Issue → 実装 → レビュー → デプロイを Claude Code Routines + Skills + Hooks で自動化する設計パターン
- 個人開発や業務改善コンサルのタスク管理に応用できる可能性あり
- 参照: [Claude Code Routines Issue→Done設計パターン — Qiita](https://qiita.com/ennagara128/items/d9aa953aaa0c125b3fe6)

#### 🟢 参考情報

**Claude Code / Anthropic**
- v2.1.141（2026-05-13）: terminalSequence フィールド（デスクトップ通知・ウィンドウタイトル・ベルのフック制御）追加、`CLAUDE_CODE_PLUGIN_PREFER_HTTPS` でGitHubプラグインHTTPSクローン対応
- v2.1.142（2026-05-14）: `claude agents` に --add-dir / --settings / --mcp-config 等フラグ追加、MCP_TOOL_TIMEOUT の60秒制限解除、macOS sleep/wake後のデーモン再接続バグ修正
- Anthropic × SpaceX 提携（Colossus 1 データセンター、GPU 22万基超）。Claude Code 利用上限が5時間あたり2倍に増加
- OpenAI Codex CLI が「ゴール永続化」（MultiAgentV2）追加。Claude Code との競合激化

**会計×AI**
- 2026年5月時点で「請求書受領→AI-OCR→仕訳起票→承認フロー」の一気通貫自動化ツールが実用化済み
- 経理の仕事は「なくなる」のではなく「ルーティンから戦略的ファイナンスへ再定義」という方向性が国内外で明確化
- 参照: [経理の仕事はAIでなくなる？2026年の生存戦略](https://taxjudge.com/2026/04/26/keiri-ai-nakunaru/)

#### references.md 更新提案

前回（2026-05-13）提案の6件に追加：

7. **HTTP hooks / async hooks の記録**: PostToolUse hooks の `async: true`、HTTP hooks の追加（v2.1.141/142）。ハーネス設計のベストプラクティスとして、フック設計パターンに HTTP hooks を追記候補
8. **Fast mode Opus 4.7 デフォルト化の記録**: `/fast` が Opus 4.7 デフォルトになった事実と、固定変数 `CLAUDE_CODE_OPUS_4_6_FAST_MODE_OVERRIDE=1` を合わせて記録候補

#### 新規発見ソース候補

| ソース | URL | 種別 | 評価候補 | 発見日 |
|--------|-----|------|--------|--------|
| Kaikei AI Daily | https://www.kaikei-ai.jp | 会計×AI 専門メディア（CPA 視点で freee/弥生/バクラクをレビュー） | ⭐⭐⭐⭐ | 2026-05-14 |

#### 次回リサーチ推奨日

2026-05-19（5日後）
注目点: ① 6月15日サブスクリプション変更の自プロジェクトへの影響確認 ② マネーフォワード AI Cowork の詳細（7月リリース予定） ③ ADR-001・ADR-003 の TBP 昇格確認（Tak への提案） ④ v2.1.143+ リリース内容

---

## [2026-05-13] デイリーレポート

---

### 内部知見（機能A）

#### 新規・更新 ADR

- decisions/ が存在するのは My-Profile-and-Memory のみ（計4件: ADR-001〜004）
- 他5プロジェクト（StudyMate / My-URAWA-LOG / tak-work / tak-family / tak-personal）は decisions/ なし → スキップ
- **2026-05-12 以降の decisions/ への新規・更新コミットなし → 新規ADRなし**

#### TBP 昇格候補

前回（2026-05-12）提案済みの ADR-001・ADR-003 が昇格待ち。新規候補なし。

#### 再検討トリガー該当

**TBP-001 / 部分該当（注意喚起）**
- トリガー：明示的な記載はないが「外部ツール審査基準の更新」に準じる
- 外部情報：Claude Code プラグインの exit-2 stderr チャンネル経由インジェクション脆弱性が報告（Anthropic Hackathon 2026 プロジェクト）。プラグインが Claude の推論に任意のコンテンツを注入でき、ファイル読み取りやサブエージェント起動まで実行させられる
- 評価：TBP-001 の「審査4軸チェック」の中に「フックシステムのexit-2インジェクションリスク」が明示されていない。**TBP-001 の審査基準に追記を提案**（Tak 確認後）

---

### 外部リサーチ（機能B）

#### 参照した情報源

- Claude Code 公式チェンジログ（code.claude.com/docs/en/changelog）— v2.1.140 が最新
- Anthropic 公式ブログ（anthropic.com/news）
- anthropics/claude-code GitHub releases
- Zenn（claude-code タグ）
- 会計×AI Web 検索（keihi.com, freee.co.jp, moneyforward.com, bakuraku.jp, yayoi-kk.co.jp 等）

#### 🔴 即座に適用すべき事項

なし（前日 v2.1.139/v2.1.140 のセキュリティポリシー変更は前回対応済み）

#### 🟡 近いうちに試したいこと（上位3件）

**① Claude Code プラグイン exit-2 インジェクション脆弱性への対応確認**
- 概要：プラグインのフックシステム（exit-2 stderr）経由で任意のコンテンツを Claude の推論に注入できる設計上の脆弱性
- Claude はこれを権威ある指示として扱い、ファイル読み取り・サブエージェント起動まで実行してしまう
- **対応**: 導入済みプラグインを TBP-001 の審査フロー（4軸チェック）で再確認。信頼できるソース以外のプラグインは導入しない方針を継続
- 参照：[Anthropic Hackathon 2026: Claude Code Canary](https://github.com/geoffrey-young/anthropic-hackathon-2026)

**② CVE-2026-2796 エクスプロイト分析記事（red.anthropic.com）の確認**
- Anthropic の Red Team が公開した実エクスプロイトのリバースエンジニアリング記事
- セキュリティリスクの実態把握と自プロジェクトのリスク評価に活用できる
- 参照：[Reverse engineering Claude's CVE-2026-2796 exploit](https://red.anthropic.com/2026/exploit/)

**③ KSK2（国税庁次世代システム）2026年9月移行への準備確認**
- 次世代国税総合管理システム「KSK2」が 2026年9月から本格稼働予定
- コンセプト「データ中心の事務処理」は電子帳簿保存法と完全連動
- 本業（経理・組織内会計士）として電帳法対応の自社状況を再確認する価値あり
- 参照：[KSK2導入ガイド 2026年9月](https://www.fas-calm.co.jp/blog/2025/12/11/ksk2-ai-tax-audit-guide-2026/)

#### 🟢 参考情報

**Claude Code / Anthropic**
- v2.1.140 が最新版（2026-05-12 リリース）。v2.1.141+ は本日時点で未確認
- The Anthropic Institute (TAI) が 2026-05-07 に設立。Economic diffusion・Threats & resilience・AI systems in the wild・AI-driven R&D の4領域を研究
- Anthropic のインド進出（Bengaluru オフィス開設予定。APAC 2拠点目）
- Claude 年換算収益が $300億超（前年末 $90億から急増）
- 企業向け AI サービス会社の設立（Blackstone・Hellman & Friedman・Goldman Sachs と共同、2026-05-04）

**会計×AI**
- freee OCR 精度：印刷レシート 90%超、手書き領収書 75%前後（2026年版）。自動仕訳推測精度は銀行明細 85〜90%（前回確認済み）
- マネーフォワード AI Cowork（バックオフィス業務自動化エージェント）を 2026年7月リリース予定。引き続き注目
- バクラク：「インテリジェント支出管理プラットフォーム」を標榜。AI・データ分析による経営インサイト提供・業務完全自動化へ
- AI搭載型経理ツール導入補助金（補助率最大 80%）。2026年度1次締切（5/12）は終了済み。次回締切に備えて freee/MF/弥生の検討を推奨
- AI経理エージェントが「請求書受取→仕訳起票→会計入力→担当者確認依頼」を人手なし実行できる水準に達しつつある（2026年5月時点）

**Zenn/技術記事**
- [Codex vs Claude Code 2026 — 判断軸とやらない判断](https://zenn.dev/miyan/articles/ai-code-codex-vs-claude-code-2026)：5軸（対話性・ベンチマーク信頼度・コスト・エコシステム統合・セキュリティ）で比較
- [Claude Code Routines で週次生成AIトレンド記事を自動生成](https://zenn.dev/tm_dev/articles/2026-05-06-zenn-auto-publish-schedule)（2026-05-06）
- AWS Japan: Claude Code 入門ワークショップを公開（AWS MCP Server の Plugin 経由インストール手順含む）

#### references.md 更新提案

前回（2026-05-12）提案の5件に追加：

6. **プラグインセキュリティ注意事項の追記**: スキル設計ベストプラクティスとして「フックシステム（exit-2 stderr）経由のインジェクションリスク」を記録候補。信頼できるソース以外のプラグインを導入しないことを明記

#### 新規発見ソース候補

| ソース | URL | 種別 | 評価候補 | 発見日 |
|--------|-----|------|--------|--------|
| red.anthropic.com | https://red.anthropic.com | Anthropic Red Team 公式ブログ（CVE・エクスプロイト解析） | ⭐⭐⭐⭐⭐ | 2026-05-13 |

※ red.anthropic.com は Anthropic 一次情報のため最高評価候補。trusted-sources.md の「公式・一次情報源」セクションへの追加を提案。

#### 次回リサーチ推奨日

2026-05-18（5日後）  
注目点: ① マネーフォワード AI Cowork の詳細（7月リリース予定、続報確認） ② v2.1.141+ リリース内容 ③ ADR-001・ADR-003 の TBP 昇格確認（Tak への提案） ④ KSK2 / 電帳法対応の進捗

---

## [2026-05-10] デイリーレポート

---

### 内部知見（機能A）

#### 新規・更新 ADR

※ 本日は初回実行のため、全ADRを対象に確認。  
他プロジェクト（StudyMate / My-URAWA-LOG / tak-work / tak-family / tak-personal）には decisions/ が存在しないためスキップ。

| ADR | タイトル | 作成日 |
|-----|---------|--------|
| ADR-001 | スキル階層は 2-3 階層を実用上限とする | 2026-03-31 以前 |
| ADR-002 | Layer 0 を Core と Detail に分離する | 2026-03-31 以前 |
| ADR-003 | 固定行数上限は設けず監査ルールとする | 2026-03-31 以前 |
| ADR-004 | 汎用知見は My-Profile-and-Memory 内に仮配置する | 2026-03-31 以前 |

#### TBP 昇格候補

**ADR-001「スキル階層は 2-3 階層を実用上限とする」**
- ①他プロジェクトでも同じ判断をするか？ → YES（Claude Code を使うすべてのプロジェクトに適用）
- ②知見がないと問題が起きるか？ → YES（深い階層を作ってしまい読み込みコストが増大する）
- ③Tak の作業スタイル全般に適用されるか？ → YES（スキル設計は全プロジェクト共通の判断）
- **→ TBP昇格推奨**。既存 TBP-001/002 と同レベルの汎用性あり

**ADR-003「固定行数上限は設けず監査ルールとする」**
- ①他プロジェクトでも同じ判断をするか？ → YES（どのプロジェクトでも rules/ 管理の方針として）
- ②知見がないと問題が起きるか？ → YES（固定上限を設けると管理が形骸化しやすい）
- ③Tak の作業スタイル全般に適用されるか？ → YES（ドキュメント管理全般の判断軸として）
- **→ TBP昇格推奨**

**ADR-002「Layer 0 を Core と Detail に分離する」**
- ①③は YES だが、②は「Layer 0 という設計が存在するプロジェクト」に限定される
- **→ TBP昇格候補（条件付き）**。「CLAUDE.md / rules/ の Core-Detail 分離」として普遍化できるか要検討

**ADR-004「汎用知見は My-Profile-and-Memory 内に仮配置する」**
- ①このリポジトリ固有の配置判断 → NO
- **→ TBP昇格不適**

#### 再検討トリガー該当

**ADR-001 / 部分該当**
- トリガー：「Claude Code のスキル読み込みモデルが変更された場合」
- 外部情報：v2.1.121 で MCP に `alwaysLoad` オプション追加（tool-search deferral をスキップ可能に）
- 評価：スキルの読み込みモデル自体の根本変更ではなく、MCP ツールの追加設定。現時点では ADR-001 を覆すほどの変化なし。**再検討不要**だが次回も監視。

**ADR-002 / 部分該当**
- トリガー：「Claude の指示遵守能力が大幅に向上し、固定読み込み量の上限が緩和された場合」
- 外部情報：Claude Opus 4.7 リリース（v2.1.111）。`xhigh` effort レベル追加で能力向上。
- 評価：定量的なベンチマークで指示遵守上限が緩和されたかは未確認。**現時点では再検討不要**。Opus 4.7 の公式ベンチマーク出次第、再評価を推奨。

---

### 外部リサーチ（機能B）

#### 参照した情報源

- Claude Code 公式チェンジログ（code.claude.com/docs/en/changelog）
- anthropics/claude-code GitHub issues
- Anthropic 公式ブログ（anthropic.com/news）
- Zenn（claude-code タグ）
- 会計×AI Web 検索（freee, マネーフォワード, バクラク）

#### 🔴 即座に適用すべき事項

**① セキュリティ脆弱性: v2.1.126 で修正済み**
- `allowManagedDomainsOnly` / `allowManagedReadPathsOnly` が無視される脆弱性が発覚・修正
- **対応**: Claude Code を最新版（v2.1.138 以降）に更新すること（`claude update` または `npm update -g @anthropic-ai/claude-code`）

**② プロンプトキャッシュ TTL の暗黙変更（issue #46829）**
- 2026年3月初旬に TTL が 1時間 → 5分 に暗黙変更。キャッシュ作成コストが 20-32% 増加
- **対応**: 環境変数 `ENABLE_PROMPT_CACHING_1H=1` で 1時間 TTL に opt-in 可能（v2.1.108 以降）
- このプロジェクトでキャッシュコストを気にする場合は設定を検討

**③ 使用量上限ドレイン問題（issue #41930）**
- 2026年3月23日以降、全課金プランで使用量の異常消費が報告中
- 1プロンプトで使用量の 3-7% が消費、5時間ウィンドウが19分で枯渇するケースも
- **対応**: `/usage` コマンドで使用量を定期確認。異常を感じたら Anthropic サポートへ報告

#### 🟡 近いうちに試したいこと（上位3件）

**① Claude Code Routines（スケジュール自動実行）**
- このデイリーリサーチエージェント自体を Routines で自動化できる有力候補
- スケジュール・GitHub イベント・API の3種トリガー。PC オフでもクラウドで実行
- Pro: 1日5回、Max: 15回、Team/Enterprise: 25回
- 起動: `/schedule` コマンドまたは claude.ai/code/routines
- 公式ドキュメント: code.claude.com/docs/ja/routines

**② /ultrareview（並列マルチエージェントコードレビュー）**
- v2.1.111 追加。複数エージェントが並列でレビューを実施
- 既存の harness や スキルの品質チェックに活用できる可能性
- CLI から `claude ultrareview`（CI 向け非対話モード）でも利用可能

**③ /usage コマンド（v2.1.118-119 で刷新）**
- `/cost` と `/stats` が `/usage` に統合
- 週次使用量と 5時間使用量を即座に表示。コスト管理に活用

#### 🟢 参考情報

**Claude/Anthropic 関連**
- Claude Opus 4.7 GA: Sonnet 4.6 → Opus 4.7 への移行が選択肢に。`xhigh` effort レベル追加。Auto mode（Max プラン）で利用可能
- Claude Mythos Preview: セキュリティタスクに特化した新モデルファミリー。Project Glasswing（重要ソフトウェアのセキュリティ強化）に活用予定
- SpaceX との計算資源提携により Anthropic の処理能力が大幅増。利用上限が 2倍に緩和予定
- Claude 新コンスティテューション（2026年1月）: Claude の価値観・行動規範の大幅改訂

**会計×AI**
- freee「AIおまかせ明細取得」β版（2026年3月）: PDF等から自動仕訳の元データ作成。OCR精度も向上（手書き領収書: 60%台 → 75%前後）
- バクラク AI エージェント: バックオフィス特化の複数専門AIエージェントが協力して業務自動化
- マネーフォワード AI エージェント: 既存業務フローを変えずにバックオフィス業務を自律実行
- freee × Claude Code 実践例: 月数百件の仕訳を AI で自動チェックする方法の記事あり（firecracker.jp）
- 自動仕訳推測精度: 銀行明細 85-90%、クレジット明細 80%（2026年3月時点）

**Zenn/技術記事**
- Claude Code が 23年もの Linux カーネルバグを発見（zenn.dev/yokoi_ai）
- Codex vs Claude Code 2026 比較（zenn.dev/miyan）: 成熟期に入った2ツールの判断軸整理
- Claude Code Routines 実録レポート（Qiita: nogataka）: 3日運用の料金・事故・止め方

#### references.md 更新提案

現在の references.md は 2026-03-29 最終確認。以下の更新を提案：

1. **スキル設計のドキュメント URL 確認**: `platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices` が `code.claude.com` に移行している可能性。実際のリンク確認を推奨
2. **Routines 公式ドキュメント追記**: `code.claude.com/docs/ja/routines` — スキル・hooks に並ぶ重要な自動化機能として参照元に追加候補
3. **プロンプトキャッシュガイド更新**: TTL 変更（1h → 5m）と opt-in 方法（ENABLE_PROMPT_CACHING_1H）を記録

#### 新規発見ソース候補

| ソース | URL | 種別 | 評価候補 | 発見日 |
|--------|-----|------|--------|--------|
| Kaikei AI Daily | https://www.kaikei-ai.jp | 会計×AI専門メディア（freee・弥生のAI機能を CPA 視点でレビュー） | ⭐⭐⭐⭐ | 2026-05-10 |
| beagleworks/ccclog | https://beagleworks.github.io/ccclog/2026/ | Claude Code CHANGELOG ビューア（既存候補、正式評価推奨） | ⭐⭐⭐ | 2026-05-10 |

#### 次回リサーチ推奨日

2026-05-17（1週間後）  
注目点: ① Opus 4.7 の公式ベンチマーク（ADR-002 再検討トリガー） ② Routines の実運用レポート ③ 使用量上限ドレイン問題（#41930）の Anthropic 公式対応状況

---

## [2026-05-11] デイリーレポート

---

### 内部知見（機能A）

#### 新規・更新 ADR

全ADRの最終更新日は 2026-05-05（前回レビュー日 2026-05-10 より前）。新規・更新 ADR なし。  
他プロジェクト（StudyMate / My-URAWA-LOG / tak-work / tak-family / tak-personal）には decisions/ が存在しないためスキップ。

#### TBP 昇格候補

前回（2026-05-10）提案済みの ADR-001・ADR-003 が昇格待ち。新規候補なし。

#### 再検討トリガー該当

**ADR-001 / 部分該当（監視継続）**
- トリガー：「スキル数が増えすぎてメタデータプリロードのコストが問題になった場合」
- 外部情報：v2.1.139 で `claude plugin details <name>` コマンド追加。プラグイン・スキルごとのトークンコストを表示可能に
- 評価：トリガーが「発火した」わけではなく、トリガー条件を検知する手段が生まれた。**ADR-001 の再検討は不要**だが、このコマンドでスキル増加時のコストを定量監視できる。

---

### 外部リサーチ（機能B）

#### 参照した情報源

- Claude Code 公式チェンジログ（code.claude.com/docs/en/changelog）— v2.1.139 確認
- anthropics/claude-code GitHub issues
- Anthropic 公式ブログ（anthropic.com/news）
- Zenn / Qiita（claude-code タグ）
- 会計×AI Web 検索

#### 🔴 即座に適用すべき事項

**① v2.1.139 セキュリティポリシー変更（2026-05-11）**
- APIキー環境変数が設定されている場合、Remote Control・`/schedule`・claude.ai MCP コネクタ・通知が自動的に無効化される
- 背景: Claude.ai ログインがあっても API キーが優先される環境では、クラウド実行機能が誤作動するリスクがあった
- **対応**: API キー運用 + Routines/Remote Control を使う予定がある場合、環境変数の設定方法を確認すること

#### 🟡 近いうちに試したいこと（上位3件）

**① Agent view（Research Preview）: `claude agents`（v2.1.139）**
- 実行中・ブロック中・完了済みの全セッションを一覧表示するコマンドが追加
- 並列サブエージェントを走らせる作業時に特に有用。`claude agents` コマンドで即試せる

**② `/goal` コマンド（v2.1.139）**
- 完了条件を設定すると Claude が条件を満たすまで複数ターン自律作業を継続
- Routines との組み合わせで「起動 → 目標達成まで自律実行」のループが実現可能
- このデイリーリサーチエージェント自体への活用を検討価値あり

**③ `claude plugin details <name>`（v2.1.139）**
- プラグイン/スキルのコンポーネント一覧とトークンコストを表示
- ADR-001 の監視ツールとして活用。スキル数が増えた際の固定コスト定点観測に

#### 🟢 参考情報

**Claude Code / Anthropic**
- SpaceX との計算資源提携で Claude Code のレート制限が全プランで2倍に（2026-05-06〜）
- Anthropic が Blackstone・Goldman Sachs 等と企業向けAIサービス会社を設立予定（5月初旬発表）
- Anthropic の年換算収益が $300億超（前年末 $90億から急増）
- v2.1.139: コンパクション（会話圧縮）時にユーザーの機密指示が保持されるよう修正。重要指示が圧縮で消える問題が解消
- v2.1.139: Hook の `args: string[]` フィールド（exec形式）追加。シェルを経由せずコマンドを直接実行でき、クォーティング問題が解消
- v2.1.139: `PostToolUse` フックに `continueOnBlock` 設定追加。ツール拒否理由を Claude にフィードバック可能に
- v2.1.133 既報バグ: MCP ツールがモデルに渡らない問題（issue #57315）→ v2.1.139 で修正済みの可能性あり（正式確認推奨）

**会計×AI**
- AIエージェントが「請求書受取 → 仕訳起票 → 会計システム入力 → 担当者確認依頼」を人手なしで実行する水準に到達しつつある（2026年5月時点）
- 経費精算自動化の工数削減事例: 入力・確認工数75%削減、月次締切2営業日前倒し
- PEPPOL 普及による請求書フォーマット標準化が加速。PDF/XML/EDI のいずれも AI-OCR または構造化取込みで対応可能な環境へ

**Zenn/Qiita**
- Claude Code Routines で Zenn に毎週自動投稿するパイプライン構築事例（2026-05-06、zenn.dev/tm_dev）
- 「コードを書けない私が、AIに『チーム』を持たせるまで」— 非エンジニア管理職が Claude Code で9体の編集部AIを構成（Zenn Books/Qiita）

#### references.md 更新提案

昨日提案済み（① Routines 公式ドキュメント追記、② スキル設計URL確認、③ キャッシュTTL記録）に加え、以下を追加：

4. **`claude plugin details` コマンドの記録**: スキル設計ベストプラクティスの参照情報として「スキルのトークンコストは `claude plugin details <name>` で確認可能」を追記候補（v2.1.139〜）

#### 新規発見ソース候補

なし（前回提案の Kaikei AI Daily が評価待ち）

#### 次回リサーチ推奨日

2026-05-18（1週間後）  
注目点: ① v2.1.139 の Agent view・/goal コマンドの実運用事例 ② APIキー+Routines環境でのセキュリティポリシー変更の影響確認 ③ Opus 4.7 の公式ベンチマーク（ADR-002 再検討トリガー、監視継続）

---

## [2026-05-12] デイリーレポート

### 内部知見（機能A）

#### 新規・更新 ADR

- decisions/ が存在するのは My-Profile-and-Memory のみ（計4件: ADR-001〜004）
- 他5プロジェクト（StudyMate / My-URAWA-LOG / tak-work / tak-family / tak-personal）は decisions/ なし → スキップ
- **2026-05-11 以降の decisions/ への新規・更新コミットなし → 新規ADRなし**

#### TBP 昇格候補

前回（2026-05-11）提案済みの ADR-001・ADR-003 が昇格待ち。新規候補なし。

#### 再検討トリガー該当

**ADR-001 / 部分該当（監視継続）**
- トリガー：「スキル数が増えすぎてメタデータプリロードのコストが問題になった場合」
- 前回提案済み：`claude plugin details <name>` でコストを可視化可能（v2.1.139〜）
- 追記：v2.1.140 で `subagent_type` のケース・セパレータ非依存マッチングが追加。Agent ツール呼び出しの柔軟性は向上したが、スキル読み込みモデル自体の変更ではないため ADR-001 再検討の必要なし。

---

### 外部リサーチ（機能B）

#### 参照した情報源

- Claude Code 公式チェンジログ（code.claude.com/docs/en/changelog）— v2.1.140・v2.1.139 確認
- Anthropic 公式ニュース（anthropic.com/news）
- Releasebot（releasebot.io/updates/anthropic）
- Zenn / Qiita（claude-code タグ）
- 会計×AI Web 検索（keihi.com, fastaccounting.jp, kaikei-ai.jp 等）

#### 🔴 即座に適用すべき事項

なし（前回の v2.1.139 セキュリティポリシー変更は対応済みまたは確認中）

#### 🟡 近いうちに試したいこと（上位3件）

**① v2.1.140: `subagent_type` がケース・セパレータ非依存に（2026-05-12 本日リリース）**
- `"Code Reviewer"` → `code-reviewer` に自動解決。大文字・スペース・ハイフンの違いを吸収
- ハーネスの Agent ツール呼び出しで subagent_type の記法ミスが発生しにくくなった
- 既存の呼び出しコードの厳密さを少し緩めても動作するため、CLAUDE.md / スキルの記述を見直す価値あり

**② v2.1.140: `/goal` コマンドのバグ修正（`disableAllHooks`/`allowManagedHooksOnly` との競合解消）**
- 前回🟡で紹介した `/goal` コマンドがhook設定と組み合わせると止まる問題が解消
- このデイリーリサーチエージェントへの活用（「目標達成まで自律実行」）が現実的になった

**③ v2.1.140: `/loop` のスケジューリング修正（冗長ウェイクアップ解消）**
- loop スキルを定期実行に使う場合の安定性が向上
- 「5分おきにリサーチ実行」系の Routine 設計時に再評価する価値あり

#### 🟢 参考情報

**Claude Code / Anthropic**
- Anthropic が SpaceX（220,000+ Nvidia GPU）・Akamai（18億ドル）・Google Cloud（5年・200億ドル）と相次ぎ大型計算資源契約を締結。Claude のレート制限緩和（5時間上限撤廃）が既に実施済み（Pro/Max/Team/Enterprise）
- 「Code w/ Claude 2026」イベント（5月6日、Simon Willison がライブブログ記録）
- Anthropic が Alphabet（Google）との収益連動協力で投資家向け好材料との報道（2026-05-11）
- v2.1.140: `claude --bg` の接続切断問題修正。バックグラウンドエージェント運用の安定性向上
- v2.1.140: settings.local.json を symlink で管理している環境での hot-reload 修正。運用設定の symlink 化が安全になった
- v2.1.1xx (2026-05-04): `claude project purge [path]` コマンド追加（プロジェクトの Claude Code 状態を全削除）。不要プロジェクト整理時に有用
- v2.1.1xx (2026-05-06): `--plugin-url <url>` フラグ追加（URLから zip アーカイブをセッション限定で取得）

**会計×AI**
- freee: 自動仕訳精度 85〜90%（銀行明細）、印刷レシート OCR 精度 90%超に到達（2026年版）
- **マネーフォワード: AI Cowork（バックオフィス業務自動化）を 2026年7月リリース予定**。経理・財務の自動化エージェント機能。注目度高い
- バクラク: 「インテリジェント支出管理プラットフォーム」へ進化中。支出データによる経営インサイト提供・業務完全自動化を標榜
- KPMG Japan 調査：経理・財務業務に AI 導入済み企業が 71%、うち半数超が生成 AI を本格運用（2024年調査）

**Zenn/Qiita**
- 新着記事の傾向：Agent view（`claude agents`）・`/goal` コマンドの実践レポートが増加傾向

#### references.md 更新提案

前回（2026-05-11）提案の4件に加えて：

5. **`subagent_type` ケース非依存マッチング（v2.1.140〜）**: Agent ツールのベストプラクティスとして「subagent_type は case/separator-insensitive」を記録候補

#### 新規発見ソース候補

**Kaikei AI Daily（kaikei-ai.jp）— 評価昇格を提案**
- 前回から評価中。今回の検索で freee AI・弥生会計 AI の独自 CPA レビュー記事を確認
- 会計 SaaS の AI 機能を実務視点で検証している数少ない日本語専門メディア
- trusted-sources.md の「会計×AI」セクションへの追記を提案（⭐⭐⭐⭐ 候補）

#### 次回リサーチ推奨日

2026-05-18（1週間後）  
注目点: ① マネーフォワード AI Cowork の詳細（7月リリース予定）② v2.1.140 の `/goal`+ハーネス組み合わせ実例 ③ ADR-001・ADR-003 の TBP 昇格確認（Tak への提案）
