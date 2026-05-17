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
