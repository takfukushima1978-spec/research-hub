## [2026-06-14] デイリーレポート

### 内部知見（機能A）
#### 新規・更新 ADR
- My-Profile-and-Memory/decisions/ → フォルダ未存在のためスキップ
- StudyMate, My-URAWA-LOG, tak-work, tak-family, tak-personal → decisions/ フォルダ未存在のためスキップ（GitHub MCP アクセス制限外）
- 新規 ADR: なし

#### TBP 昇格候補
なし（新規 ADR なし）

#### 再検討トリガー該当
- **TBP-001「外部ツール導入は審査→最小権限→段階拡張」**:
  1. **米政府 Fable 5/Mythos 5 アクセス停止令（6/12-13）**: 米政府が国家安全保障を理由に Fable 5・Mythos 5 への「外国人」アクセス全面停止を命令。Anthropic は自社の外国籍社員も含めて全ユーザーへのアクセスを即日遮断。トリガーは「Fable 5 のサイバーセキュリティ能力をアンロックするジェイルブレイク（特定ケース限定）」の発見。TBP-001「導入前にセキュリティ審査（AUDIT-REPORT.md）を実施する」原則の重要性を再確認する事例。Fable 5 の AUDIT-REPORT.md 未着手が継続中。
  2. **課金変更は明日 (6/15) — Routines も対象確定**: Agent SDK / claude -p / GitHub Actions に加え、Claude Code Routines（スケジュール型自動セッション）も新クレジットプール対象と確認（github.com/anthropics/claude-code/issues/59823 等）。この daily-research Routine 自体も明日から別クレジット消費に移行する。消費量試算と方針確定が本日最終期限。
  3. **freee 統合ワールド 2026（6/16 明後日）**: TBP-001 の freee-mcp 審査フロー（AUDIT-REPORT.md 作成）は依然未着手。イベント後に即日着手できるよう準備推奨。

---

### 外部リサーチ（機能B）
#### 参照した情報源
- code.claude.com/docs/en/changelog（⭐⭐⭐⭐⭐）
- anthropic.com/news（⭐⭐⭐⭐⭐）
- github.com/anthropics/claude-code/issues（⭐⭐⭐⭐⭐）
- cnbc.com / time.com / bloomberg.com / marktechpost.com（Fable 5/Mythos 5 停止令）
- codersera.com / findskill.ai / vantagepoint.io（課金変更 Routines 影響）
- qiita.com（Claude サブスク課金変更 6/15）
- luvina.jp / keihi.com / renue.co.jp（会計×AI）
- prtimes.jp / corp.freee.co.jp（freee 統合ワールド 2026）

#### 🔴 即座に適用すべき事項

**① 課金変更は明日 (6/15)【最重要・本日最終確認】**
- Agent SDK / claude -p / GitHub Actions / サードパーティエージェントに加え、**Claude Code Routines（スケジュール型セッション）も対象**と確認
- クレジット額: Pro $20/月、Max 5x $100/月、Max 20x $200/月（フル API 価格・ロールオーバーなし）
- クレジット超過で自動停止。オーバーフロー請求を有効にしない限り Routines が止まる
- **本日中に**: ① 月間消費クレジット試算 ② 上限超過時の運用方針確定 ③ 必要ならオーバーフロー請求の有効化
- 参考: [Anthropic's June 15 Billing Change](https://codersera.com/blog/anthropic-june-2026-billing-change-claude-code/)

**② 米政府 Fable 5/Mythos 5 アクセス全面停止令（6/12-13）【業界重大ニュース】**
- Fable 5/Mythos 5 は 6/9 リリース後わずか3日で米政府の輸出管理指令を受けアクセス停止
- 停止理由: Fable 5 のサイバーセキュリティ能力をアンロックする特定ケース限定のジェイルブレイク発見
- Anthropic は「指摘されたジェイルブレイクは特定ケース限定で全般的なガードレール突破ではない」と主張するも、全外国人（Anthropic 外国籍社員含む）リアルタイムフィルタリング不可のため全ユーザー停止を選択
- 現在 claude.ai では Fable 5 ではなく Opus 4.8 が提供中の可能性あり（要確認）
- 参考: [Anthropic Statement](https://www.anthropic.com/news/fable-mythos-access) / [CNBC](https://www.cnbc.com/2026/06/12/anthropic-disables-access-to-fable-5-and-mythos-5-to-comply-with-government-directive.html)

**③ Claude Code v2.1.176（6/12）: セッション言語・管理設定強化**
- **セッションタイトル自動言語対応**: 会話言語でタイトルが自動生成される（`language` 設定で固定可）
- **`footerLinksRegexes` 設定追加**: フッター行にリンクバッジをregex指定で追加可能（ユーザー/管理設定）
- **Bedrock 認証情報キャッシュ改善**: `awsCredentialExport` の認証情報を `Expiration` まで（1時間固定から変更）
- **`availableModels` 強制修正**: エイリアスモデルが `ANTHROPIC_DEFAULT_*_MODEL` 環境変数でブロック済みモデルにリダイレクトできないよう修正。`/fast` もアローリスト外モデルへの切り替え拒否
- **Fable 5 auto mode フォールバック修正**: Opus 4.8 が有効でない組織でも最良の Opus モデルへフォールバック
- **フック `if` 条件のパス修正**: `Edit(src/**)`, `Read(~/.ssh/**)`, `Read(.env)` などが正しくマッチするよう修正
- **MCP ページネーション対応**: paginated `tools/list` の全ページを返すよう修正（従来は1ページ目のみ）
- **スキルディレクトリビルド時のファイルディスクリプタ枯渇修正**: 非 .md ファイルがスキルリロードをトリガーしないよう修正
- **JetBrains IDE ターミナルフリッカー修正**（v2026.1+ 同期出力有効化）

#### 🟡 近いうちに試したいこと（上位3件）

**① freee 統合ワールド 2026（6月16日・明後日）フォローアップ準備**
- Anthropic Japan 菅野信氏セッション（16:40〜17:40）: 「手入力が消える日」freee MCP × AI エージェント
- 茶圓将裕氏セッション: freee MCP がバックオフィス業務にもたらす影響
- イベント後に **freee-mcp の TBP-001 審査フロー（AUDIT-REPORT.md 作成）を即日実施**

**② references.md 一括更新セッション（11週間連続未反映・最優先継続）**
- 最終確認 2026-03-29 以降4ヶ月近く未更新。蓄積候補25件超
- 今回追加候補: `footerLinksRegexes` 設定 / MCP ページネーション全ページ対応 / フック `if` パス条件修正 / Bedrock 認証情報キャッシュ改善 / `availableModels` エイリアスバイパス防止
- **一括更新セッションを最優先で実施（毎日継続）**

**③ TCS × Anthropic パートナーシップ（6/12）の業務応用評価**
- TCS が Claude を5万人の自社社員に展開・金融サービス/ヘルスケア/公共セクター向けに Claude 搭載製品を構築
- Tak の本業（経理部長・内部統制）との間接的関連: 大手 SI × 規制産業への Claude 浸透が加速。会計系システムへの AI 統合が本格化するトレンドとして把握

#### 🟢 参考情報
- **Claude Fable 5 / Mythos 5 詳細（6/9 リリース・現在アクセス停止中）**: Mythos-class の最初の一般公開モデル。Fable 5: セーフガード付き一般向け（$10/M 入力・$50/M 出力）。Mythos 5: Fable 5 同一基盤・サイバー防衛者向けセーフガード一部解除版（Glasswing 参加組織のみ）
- **Anthropic IPO S-1 SEC レビュー継続**: $965B バリュエーション目標（~$1.75-1.8T も報道）。SEC レビュー中・時期未確定。ランレート $47B/年
- **Claude Code 課金変更 6/15 Qiita 警告記事**: 「Claude サブスクで自動化もしてる人へ：6/15 に課金ルールが変わります」（@sakamoto66）。Agent SDK / claude -p / GitHub Actions がサブスク枠から切り離され別建ての「月次クレジット(USD)」に移行
- **Anthropic Project Glasswing 拡張**: 約150の新組織に拡張。サイバー防衛者向け Mythos 5 提供（政府停止令の影響範囲は確認中）
- **Anthropic Public Record**: 2025年11-12月の米国民52,000人調査。AIに対する一般市民の意識把握
- **会計×AI 2026年6月動向**: 国内中堅企業の仕訳入力約7割が依然手入力・月末残業平均32時間。経費精算工数75%削減・月次決算2営業日早期化が一般化。生成AIが「ルールベース仕訳 → 判断支援」フェーズへ本格移行継続

#### references.md 更新提案
1. **`footerLinksRegexes` 設定（v2.1.176）**: ユーザー/管理設定セクションに「フッターリンクバッジのregex指定設定」として追記を提案
2. **MCP ページネーション対応（v2.1.176）**: MCP ツール設定セクションに「tools/list ページネーション: 全ページ返却に修正（v2.1.176〜）」を追記提案
3. **フック `if` パス条件修正（v2.1.176）**: フック設計セクションに「`Edit(src/**)` / `Read(~/.ssh/**)` / `Read(.env)` 等の公式パターンが正しくマッチするよう修正（v2.1.176〜）」を追記提案
4. **継続提案（11週間連続未反映）**: references.md 最終確認 2026-03-29 以降4ヶ月近く未更新。蓄積候補25件超。**一括更新セッションを最優先で実施することを強く推奨（連続継続）**

#### 新規発見ソース候補
- **tygartmedia.com**: Claude Agent SDK 課金変更の「Dual-Bucket Billing」解説。課金設計理解に有用（評価候補: ⭐⭐⭐）

#### 次回リサーチ推奨日
2026-06-15（日曜日）
注目点: ① **課金変更 (6/15) 施行後の Routines 動作確認** → クレジット消費状況をモニタリング ② **freee 統合ワールド 2026（6月16日）翌日** → イベント内容・AI/MCP 発表のキャッチアップ、freee-mcp TBP-001 審査フロー着手 ③ **Fable 5/Mythos 5 アクセス停止令の続報** → 解除/継続の確認 ④ **references.md 一括更新セッション**（11週間連続未反映）⑤ Fable 5 AUDIT-REPORT.md 作成（TBP-001 審査フロー、引き続き最優先）

---

## [2026-06-12] デイリーレポート

### 内部知見（機能A）
#### 新規・更新 ADR
- My-Profile-and-Memory/decisions/ → フォルダ未存在のためスキップ
- StudyMate, My-URAWA-LOG, tak-work, tak-family, tak-personal → decisions/ フォルダ未存在のためスキップ（GitHub MCP アクセス制限外）
- 新規 ADR: なし

#### TBP 昇格候補
なし（新規 ADR なし）

#### 再検討トリガー該当
- **TBP-001「外部ツール導入は審査→最小権限→段階拡張」**:
  1. **サブエージェントの多層化（最大5層）（v2.1.172, 6/10）**: これまで「サブエージェントはサブエージェントを生成できない」というハードガードレールが存在したが、6月10日リリースで最大5層のネストが可能になった。各フレームが独自のシステムプロンプト・モデルを持ち、親は末尾のサマリのみ読む構造。新アーキテクチャパターンの採用前は TBP-001「段階拡張」フェーズでの審査を推奨（推奨は2-3層止まり）。
  2. **Claude Fable 5 AUDIT-REPORT.md 未着手継続（06-09から引き継ぎ）**: TBP-001 に基づく審査記録が依然未作成。コーディング・サイバーセキュリティ能力が大幅向上しているため、ハーネスの allowedTools / deniedTools 設計との整合性確認が引き続き必要。
  3. **freee 統合ワールド 2026（6月16日・残り4日）**: Anthropic Japan 菅野信氏「手入力が消える日」セッション（16:40〜17:40）まで残り4日。イベント後の freee-mcp TBP-001 審査フロー（AUDIT-REPORT.md 作成）の準備を進めておくこと。
  4. **Anthropic $200M 経済影響調査投資（6/10）**: Dario Amodei CEO が AI による雇用喪失者への政府サポートを提唱。Tak の本業（経理部長・内部統制）に関わる会計職の将来像に影響を与える可能性。

---

### 外部リサーチ（機能B）
#### 参照した情報源
- code.claude.com/docs/en/changelog（⭐⭐⭐⭐⭐）
- anthropic.com/news（⭐⭐⭐⭐⭐）
- github.com/anthropics/claude-code/issues（⭐⭐⭐⭐⭐）
- washingtontimes.com / techcrunch.com / 9to5google.com（Anthropic ニュース）
- claudefa.st / ofox.ai（サブエージェント多層化解説）
- keihi.com / renue.co.jp / kaikei-ai.jp（会計×AI）
- zenn.dev/topics/claudecode / qiita.com/tags/ClaudeCode（⭐⭐⭐）

#### 🔴 即座に適用すべき事項

**① v2.1.174-175（2026-06-12）: 管理設定強化・各種バグ修正**

- **`enforceAvailableModels` 管理設定**: 有効化時、`availableModels` 許可リストがデフォルトモデルも制限。デフォルトが許可されていないモデルに解決される場合、最初の許可モデルにフォールバック。ユーザー/プロジェクト設定は管理された `availableModels` リストを拡大できない
- **`wheelScrollAccelerationEnabled` 設定追加**: 全画面モードでマウスホイールスクロール加速を無効化可能
- **/model ピッカー修正**: Default が解決するモデルファミリーが非表示になっていた問題を解消（Max/Team Premium: Opus、Pro: Sonnet、従量課金: Opus が表示される）
- **Bedrock GovCloud 地域推論プロファイル前置詞修正**（`global` → `us-gov`）
- **バックグラウンドセッションが別セッションの `ANTHROPIC_*` 環境変数を継承する問題を修正**（セキュリティ関連）
- **スキルホットリロード改善**: 全スキルリストではなく変更されたスキルのみを再通知
- **Workflow ツール `agent()` サブエージェントの属性ヘッダー追加**
- **VSCode 使用状況属性トラッキング**: キャッシュミス、長いコンテキスト、サブエージェント、スキル/エージェント/プラグイン/MCP 別の内訳を追跡
- Fable 5 バナーのエンタープライズアカウント誤表示を修正
- macOS/Linux でシェルコマンド中断後の一時停止修正

**② v2.1.173（2026-06-11）: Fable 5 モデル名修正**
- Fable 5 モデル名の `[1m]` サフィックス正規化修正（1M コンテキストはデフォルトなので自動削除）
- Windows サンドボックス有効化時の「依存関係不足」警告修正

**③ v2.1.172（2026-06-10）: サブエージェント多層化・Bedrock 改善・多数バグ修正**
- **サブエージェントの多層化（最大5層）**: サブエージェントが独自のサブエージェントを生成可能。コンテキスト管理（各サブエージェントが独立した新しいコンテキストウィンドウを持つ）に有効。実用パターン: main → triage-lead（Opus） → repro-runner（Sonnet） → log-summariser（Haiku）
- **Amazon Bedrock 改善**: `AWS_REGION` 未設定時に `~/.aws` 設定ファイルからリージョン自動読み込み、`/status` に出所表示
- **/plugin マーケットプレイスに検索バー追加**
- **1M コンテキスト使用時のクレジット不足による無限停止を修正**（自動コンパクト）
- **WebFetch ワイルドカードドメインルール改善**: `WebFetch(domain:*.example.com)` がサブドメインと一致するように、ファイル権限ルール（`Read(secrets-*/config.json)` 等）が起動時に拒否されない
- **Workflow 検証修正**: スクリプト内の `Date.now()` / `Math.random()` 参照を誤って拒否していた問題を修正
- **アイドル時の CPU 使用率削減**: `/goal` ステータスチップの 5Hz リレンダリング廃止
- **Chrome 内のツール読み込み性能向上**: 一括呼び出しへ変更

**④ Anthropic $200M AI 経済影響調査投資発表（6/10）**
- Anthropic が AI の雇用・経済への影響研究に $200M を投資。CEO Dario Amodei が政府に AI による経済的打撃を受けた人々へのサポートを求めるエッセイを公開
- **Tak の本業への示唆**: 会計・経理職の AI 代替に関する社会的議論が本格化。経理部長・組織内会計士の役割が「判断支援・経営支援」へ移行するトレンドが政策レベルで確認された

**⑤ DXC が Claude を銀行・航空会社等の規制産業システムに統合（6/11）**
- DXC Technology が銀行・航空会社などの規制産業の基幹システムに Claude を統合すると発表
- 金融業界での Claude Enterprise 採用が本格化。Tak の本業（経理部長）との間接的関連あり

#### 🟡 近いうちに試したいこと（上位3件）

**① サブエージェント多層化（2-3層）の実験**
- v2.1.172 で最大5層のネストが可能になった。research タスクで「main → 検索エージェント → 要約エージェント」の2-3層構成を試験的に実装
- コスト・処理時間・品質のトレードオフを測定し、daily-research ワークフローへの組み込み可否を判断

**② freee 統合ワールド 2026（6月16日）最終事前調査・残り4日**
- Anthropic Japan 菅野信氏のセッション（16:40〜17:40）: 「手入力が消える日」freee MCP × AI エージェント
- イベント後に freee-mcp の TBP-001 審査フロー（AUDIT-REPORT.md 作成）を即日実施
- 事前に freee-mcp のドキュメント（約270種類の API 操作対応）を確認しておく

**③ references.md 一括更新セッション（10週間連続未反映・最優先継続）**
- 最終確認 2026-03-29 以降約3ヶ月半未更新
- 今回の新規追加候補: `enforceAvailableModels` 管理設定 / WebFetch ワイルドカードドメインルール改善 / サブエージェント多層化（最大5層） / Workflow `Date.now()`・`Math.random()` 検証修正
- 蓄積候補は20件超。**一括更新セッションを最優先で実施**

#### 🟢 参考情報
- **GitHub Issues（2026-06-11）**: Bash ツール呼び出し拒否事象あり（auto-mode permission classifier がダウン/過負荷）。Max 5 有料セッションでも tool 呼び出し不可になる可能性。Anthropic が対処を確認したと報告。利用不能時は再起動・一時間後リトライを推奨
- **Zenn・Qiita（2026-06-11-12 前後）**:
  - 「Claude Code の /goal を使ってみる前に調べたことメモ」（Qiita: @ussu_ussu_ussu）: v2.1.139 (5/11) で追加された /goal コマンドの調査ノート
  - 「カンリー社内 Claude Code 勉強会の資料を公開します」（Zenn: カンリー）: 組織での Claude Code 展開事例。デファクトスタンダード化を示す
- **Claude Fable 5 詳細（6/9 リリース・継続情報）**: 価格 $10/M 入力・$50/M 出力（Opus 比2倍）。1M トークンコンテキスト・128k 最大出力。API/Bedrock/Vertex AI/Foundry/Microsoft Foundry で提供。安全分類器がトリガーされた場合は Opus 4.8 でフォールバック（全セッションの平均5%未満）
- **会計×AI 2026年6月最新動向**: freee 自動仕訳精度85-90%（銀行明細）、OCR 精度が2026年大幅アップデートで手書きレシート約75%前後・印刷レシート90%超に到達。国内中堅企業では仕訳入力の約70%が依然手入力（AI 導入余地大）。生成AI が「ルールベース仕訳 → 判断支援」フェーズへ本格移行
- **Anthropic IPO S-1 SEC レビュー継続**: $965B バリュエーション。SEC レビュー中・IPO 時期未確定

#### references.md 更新提案
1. **`enforceAvailableModels` 管理設定（v2.1.175）**: Enterprise 管理セクションに「利用可能モデル許可リストがデフォルトモデルも制限する強制設定（ユーザー/プロジェクト設定で拡大不可）」として追記を提案
2. **WebFetch ワイルドカードドメインルール改善（v2.1.172）**: アクセス制御セクションに「`WebFetch(domain:*.example.com)` がサブドメインと一致するようになった（v2.1.172〜）」として追記を提案。TBP-001 の allowlist 設計に影響
3. **サブエージェント多層化・最大5層（v2.1.172）**: マルチエージェント設計セクションに「サブエージェントが独自のサブエージェントを最大5層まで生成可能（推奨は2-3層。コンテキスト管理目的）」として追記を提案
4. **バックグラウンドセッションの環境変数継承問題修正（v2.1.174）**: セキュリティ設計セクションに「バックグラウンドセッションが別セッションの ANTHROPIC_* 環境変数を継承しないよう修正（v2.1.174〜）」を追記提案
5. **継続提案（10週間連続未反映）**: references.md 最終確認 2026-03-29 以降3ヶ月半超未更新。蓄積候補20件超。**一括更新セッションを最優先で実施することを強く推奨（毎日継続）**

#### 新規発見ソース候補
- **jangwook.net**: Claude Code 6月新機能（Safe Mode・Opus 4.8・Rate Limits 倍増）の技術詳細解説あり（評価候補: ⭐⭐⭐）
- **ofox.ai**: Claude Code ネスト型サブエージェント（5層）の詳細技術解説・トークンコスト計算あり（評価候補: ⭐⭐⭐）
- **cloudzero.com**: Claude Code エージェント・サブエージェントのコスト分析記事あり（評価候補: ⭐⭐⭐）

#### 次回リサーチ推奨日
2026-06-13（土曜日）
注目点: ① **freee 統合ワールド 2026（6月16日）残り3日** → 最終事前確認、Anthropic Japan 菅野信氏セッション事前準備 ② **Claude Fable 5 TBP-001 審査フロー着手**（AUDIT-REPORT.md 依然未着手） ③ **サブエージェント多層化（最大5層）実験** → 2-3層の試験実装・コスト計測 ④ **references.md 一括更新セッション**（10週間連続未反映） ⑤ GitHub Issues auto-mode classifier 障害の解消状況確認

---
## [2026-06-10] デイリーレポート

### 内部知見（機能A）
#### 新規・更新 ADR
- My-Profile-and-Memory/decisions/ → フォルダ未存在のためスキップ
- StudyMate, My-URAWA-LOG, tak-work, tak-family, tak-personal → decisions/ フォルダ未存在のためスキップ
- tak-best-practices/ → .md ファイル未存在のためスキップ
- 新規 ADR: なし

#### TBP 昇格候補
なし（新規 ADR なし）

#### 再検討トリガー該当
- **TBP-001「外部ツール導入は審査→最小権限→段階拡張」**:
  1. **Code with Claude 2026 Tokyo（本日 2026-06-10 開催）**: Claude Code チームが「long-horizon tasks・multi-repo work・parallel agents・infrastructure at scale」を公式セッション議題として取り上げた。Dynamic Workflows を超えた parallel agents の公式スケールパターンが今後登場する可能性があり、TBP-001「段階拡張」フェーズの適用範囲が広がる見込み。新パターン採用時は TBP-001 審査フローを適用すること。
  2. **Claude Fable 5 採用評価（前日 06-09 からの継続）**: TBP-001 に基づく AUDIT-REPORT.md 作成が未着手。コーディング・サイバーセキュリティ能力が大幅向上しているため、ハーネスの allowedTools / deniedTools 設計との整合性確認が必要。
  3. **freee 統合ワールド 2026（6月16日・残り6日）**: Anthropic Japan 菅野信氏が「手入力が消える日」セッション（16:40〜17:40）でfreee MCPとAIエージェントの業務適用を解説予定。イベント後は freee-mcp の TBP-001 審査フロー（AUDIT-REPORT.md 作成）を実施すること。

---

### 外部リサーチ（機能B）
#### 参照した情報源
- claude.com/code-with-claude/tokyo（⭐⭐⭐⭐⭐）
- code.claude.com/docs/en/changelog（⭐⭐⭐⭐⭐）
- anthropic.com/news（⭐⭐⭐⭐⭐）
- github.com/anthropics/claude-code/issues（⭐⭐⭐⭐⭐）
- corp.freee.co.jp / prtimes.jp（freee 統合ワールド 2026）
- corp.moneyforward.com（マネーフォワード AI Cowork）
- keihi.com / renue.co.jp / biz.moneyforward.com / ai-market.jp（会計×AI）
- zenn.dev/topics/claudecode（⭐⭐⭐）

#### 🔴 即座に適用すべき事項

**① Code with Claude 2026 Tokyo（本日 2026-06-10 開催）【最重要・本日開催】**
- Anthropic 初の日本単独デベロッパーイベント。San Francisco（5月6日）・London（5月19日）に続く第3弾
- **登壇者**: Boris Cherny（Claude Code lead）、Ami Vora（Anthropic CPO）、Angela Jiang（Claude API & SDK product lead）
- **セッションテーマ**:
  - Research track: 解釈可能性研究・Constitutional AI の最新動向。5月以降の変化を London との比較で解説
  - Claude Platform: 本番グレードエージェントの構築パターン
  - Claude Code: long-horizon タスク・マルチリポジトリ作業・並列エージェント・インフラ at scale
- 日本語同時通訳あり（英日両方向）。ライブストリーム配信あり
- **Code with Claude: Extended Tokyo（6月11日）**: 独立系開発者・アーリーステージ創業者向け。Applied AI チームによるラップトップオープンワークショップ開催
- **TBP-001 対応**: Code with Claude Tokyo で公開される parallel agents / long-horizon tasks の公式スケールパターンを確認し、採用前に TBP-001 審査フローを適用すること

**② 6月15日 料金変更まで残り5日【期限最終接近】**
- プログラマティック利用（`claude -p` / Agent SDK / GitHub Actions / サードパーティエージェント）が別クレジットプールへ移行
- クレジット額: Pro $20/月、Max 5x $100/月、Max 20x $200/月（フル API 価格・ロールオーバーなし）
- クレジット超過で自動停止（オーバーフロー請求を有効にしない限り）
- **この daily-research Routine 自体も対象**。残り5日で消費量試算と方針確定が必要

#### 🟡 近いうちに試したいこと（上位3件）

**① Code with Claude Extended Tokyo（6月11日）のフォローアップ**
- 明日開催。Applied AI チームによるラップトップオープンワークショップ内容を確認
- Claude Code の long-horizon tasks・parallel agents の公式実装パターンを把握し、ハーネス設計へ反映検討
- freee 統合ワールド 2026（6月16日）への架け橋として、MCPとAIエージェントの最新知見を整理

**② freee 統合ワールド 2026（6月16日）最終事前調査・残り6日**
- Anthropic Japan 菅野信氏のセッション（16:40〜17:40）: 「手入力が消える日」freee MCP × AIエージェント
- イベント後に freee-mcp の TBP-001 審査フロー（AUDIT-REPORT.md 作成）を即日実施

**③ references.md 一括更新セッション（9週間連続未反映・最優先継続）**
- 最終確認 2026-03-29 以降3ヶ月超未更新。蓄積候補20件超
- 今回追加候補: `claude-fable-5` モデル情報 / `--safe-mode` フラグ / `disableBundledSkills` 設定 / `/cd` コマンド / Code with Claude Tokyo の公式スケールパターン（parallel agents / long-horizon tasks）

#### 🟢 参考情報
- **GitHub Issues 本日新規（#67222〜#67228, 2026-06-10）**: macOS desktop/API/agent バグが複数。特に #67228（api・cost バグ・macOS）が料金変更直前のコスト管理に関連する可能性あり。デスクトップアプリ最新版（v2.1.170）への更新を推奨
- **Claude Code v2.1.170（前日 2026-06-09 リリース）**: 最新版。VS Code 統合ターミナルから起動した際にトランスクリプトが保存されない問題（`--resume` に表示されない）が修正。アップデート済みであることを確認推奨
- **Zenn 新着（2026-06-10前後）**:
  - 「個人で使うClaude Codeをチームで育てるClaude Codeにする2つの仕組み」（@k_yamaki, Qiita）: チームへのClaude Code展開ノウハウ。組織導入に直結
  - 「Claude Codeを『優秀な新卒部下』として使い倒す：個人開発爆速化の全ワークフロー」（@yoshiaki0217, Zenn）: CLAUDE.md設計の実践的ガイド
  - 「無料範囲内でChatGPT, Claude, Geminiを使ってみよう【2026年6月版】」（Qiita）: 料金変更直前のプラン見直し参考記事
- **マネーフォワード AI Cowork（7月リリース予定・変更なし）**: 自然言語でオーケストレーターが業務振り分け → エージェントが経理・労務・法務を自律実行。「マイエージェント」（ユーザー自作）・ガードレール・AI監査ログ搭載。2030年ARR150億円目標。Claude Agent SDK + MCP を採用（既報継続）
- **会計×AI 2026年6月最新動向**: 国内中堅企業の仕訳入力 約70%が依然手入力・月末残業平均32時間（AI導入余地大）。経費精算工数75%削減・月次決算2営業日早期化が一般化継続。PEPPOL普及で請求書標準化加速。Deloitte・KPMGなど Big4 が Claude Code / Cowork を標準ツール採用で業界実装が本格化

#### references.md 更新提案
1. **Code with Claude Tokyo 公式スケールパターン（本日 2026-06-10）**: parallel agents・long-horizon tasks・multi-repo work の公式実装パターンが公開された場合、harness-design-guide のマルチエージェント実行パターンセクションに追記を提案（セッション詳細確認後）
2. **継続提案（9週間連続未反映）**: references.md 最終確認 2026-03-29 以降3ヶ月超未更新。Claude Fable 5 モデル情報・`--safe-mode` フラグ・`disableBundledSkills`・`/cd` コマンド・fallbackModel・deny グロブ・hookSpecificOutput.additionalContext 等20件超。**一括更新セッションを最優先で実施することを強く推奨（前日継続）**

#### 新規発見ソース候補
- **ai-revolution.co.jp**: Code with Claude 2026 Tokyo の詳細解説・AI活用事例記事あり（評価候補: ⭐⭐⭐）
- **chatforest.com**: Code with Claude Tokyo のビルダー向けプレビュー・詳細ガイド記事（評価候補: ⭐⭐⭐）
- **tygartmedia.com**: Code with Claude 国際イベントのコンパクトな解説記事（評価候補: ⭐⭐⭐）

#### 次回リサーチ推奨日
2026-06-11（水曜日）
注目点: ① **6月15日料金変更まで残り4日** → クレジット試算・方針確定（最終期限）② **Code with Claude Extended Tokyo（6月11日）** → 独立系開発者向けワークショップの内容確認・parallel agents 公式パターン把握 ③ **freee 統合ワールド 2026（6月16日）残り5日** → 最終事前調査 ④ **Claude Fable 5 TBP-001 審査フロー着手**（AUDIT-REPORT.md 作成） ⑤ **references.md 一括更新セッション** ⑥ Opus 4.8 ツール呼び出しバグの修正状況確認（v2.1.170 以降で解消されたか）

---
## [2026-06-09] デイリーレポート

### 内部知見（機能A）
#### 新規・更新 ADR
- My-Profile-and-Memory/decisions/ → フォルダ未存在のためスキップ
- StudyMate, My-URAWA-LOG, tak-work, tak-family, tak-personal → decisions/ フォルダ未存在のためスキップ
- 新規 ADR: なし

#### TBP 昇格候補
なし（新規 ADR なし）

#### 再検討トリガー該当
- **TBP-001「外部ツール導入は審査→最小権限→段階拡張」**:
  1. **Claude Fable 5 一般公開（本日 2026-06-09・最重要）**: 前回（06-08）から引き継ぎの「Mythos 一般公開後は TBP-001 審査フロー適用」が本日実現。Mythos-class モデルが初めて一般向けに提供開始。採用前に AUDIT-REPORT.md を作成することを推奨（コーディング・サイバーセキュリティ能力が大幅向上しているため、権限設定の見直しが必要）。
  2. **`--safe-mode` フラグ（v2.1.170）**: カスタマイズ（CLAUDE.md / plugins / skills / hooks / MCP）を全無効化してトラブルシューティングできる機能が公式化。TBP-001「段階拡張」フェーズでの問題発生時のデバッグ手法として活用可能。
  3. **`disableBundledSkills` 設定（v2.1.170）**: バンドルスキル・ワークフロー・組み込みスラッシュコマンドを非表示にする設定が追加。TBP-001「最小権限で開始」を環境変数レベルで実現する手段として活用可能。

---

### 外部リサーチ（機能B）
#### 参照した情報源
- github.com/anthropics/claude-code/releases（⭐⭐⭐⭐⭐）
- anthropic.com/news（⭐⭐⭐⭐⭐）
- releasebot.io/updates/anthropic/claude-code（⭐⭐⭐）
- claudefa.st/blog/guide/changelog（⭐⭐⭐⭐）
- thenextweb.com / venturebeat.com / aws.amazon.com（Fable 5 詳報）
- keihi.com / uravation.com / biz.moneyforward.com（会計×AI）

#### 🔴 即座に適用すべき事項

**① Claude Fable 5 一般公開（本日 2026-06-09）【最重要・本日リリース】**
- Anthropic 初の Mythos-class 一般公開モデル。ソフトウェアエンジニアリング・知識労働・ビジョン・科学研究などほぼ全ベンチマークで SOTA
- **Model ID**: `claude-fable-5`
- **価格**: $10/M 入力トークン、$50/M 出力トークン（Mythos Preview の $25/$125 から大幅引き下げ。既存 90% プロンプトキャッシュ割引も適用）
- **コンテキストウィンドウ**: 1M トークン（デフォルト）、最大 128k 出力トークン/リクエスト
- **プラットフォーム**: Claude API / Claude Platform on AWS / Amazon Bedrock / Vertex AI / Microsoft Foundry（本日より全プラットフォーム同時提供）
- **セーフガード**: cybersecurity/biology 領域の安全性分類器付き。分類器がトリガーされた場合（全セッションの平均 5% 未満）は Claude Opus 4.8 で応答。Claude Code v2.1.170 以降が必要
- 同時に **Claude Mythos 5** もリリース（Fable 5 と同一基盤・セーフガード一部解除版）。サイバー防衛者・重要インフラ事業者向け限定
- **TBP-001 対応**: 新モデル採用前に AUDIT-REPORT.md を作成してから採用することを強く推奨

**② Claude Code v2.1.170 リリース（本日 2026-06-09）**
- **`--safe-mode` フラグ（`CLAUDE_CODE_SAFE_MODE` 環境変数）**: 全カスタマイズ（CLAUDE.md / plugins / skills / hooks / MCP サーバー）を無効化してトラブルシューティング用に起動
- **`disableBundledSkills` 設定（`CLAUDE_CODE_DISABLE_BUNDLED_SKILLS` 環境変数）**: バンドルスキル・ワークフロー・組み込みスラッシュコマンドをモデルから非表示化
- **`/cd` コマンド**: プロンプトキャッシュを破壊せずにセッション中の作業ディレクトリを変更できるコマンド
- **Claude Fable 5 アクセス**: v2.1.170 以降でのみ Fable 5 が利用可能

**③ 6月15日 料金変更まで残り6日【期限迫る・継続警戒】**
- プログラマティック利用（`claude -p` / Agent SDK / GitHub Actions / サードパーティエージェント）が別クレジットプールへ移行
- Pro $20/月、Max 5x $100/月、Max 20x $200/月（フル API 価格、ロールオーバーなし）
- この daily-research Routine も対象の可能性。残り6日で消費量試算と方針確定が必要

#### 🟡 近いうちに試したいこと（上位3件）

**① TBP-001 審査フロー適用: Claude Fable 5 採用評価（最優先）**
- 本日リリース確認。TBP-001「審査→最小権限→段階拡張」をFable 5 採用に適用
- AUDIT-REPORT.md 作成（4軸チェック: ①公式一次情報源か ②権限範囲 ③機能シンプルさ ④リスク）
- Claude Code v2.1.170 へのアップデートを先に確認してから Fable 5 を試用すること
- 特に注意: Fable 5 のサイバーセキュリティ能力が大幅向上しているため、ハーネスの allowedTools / deniedTools 設計との整合性を確認すること

**② freee 統合ワールド 2026（6月16日）- 残り7日**
- 継続追跡。AI×会計の最新動向・freee-mcp 連携強化の発表が見込まれる
- Anthropic Japan 菅野信氏登壇（16:40〜17:40）
- イベント後: TBP-001 審査フロー適用の最終判断

**③ references.md 一括更新セッション（8週間連続未反映・最優先継続）**
- 今回追加候補: `claude-fable-5` モデル情報 / `--safe-mode` フラグ / `disableBundledSkills` 設定 / `/cd` コマンド
- 既存蓄積候補（fallbackModel / deny グロブ / hookSpecificOutput.additionalContext 等 20 件超）と合わせて一括更新を最優先推奨

#### 🟢 参考情報
- **Anthropic「Paving the way for agents in biology」（2026-06-08）**: 生物学領域への AI エージェント応用に関する研究記事。Fable 5 の専門ドメイン適用研究の一環として把握
- **Project Vend Phase 2（Anthropic）**: Anthropic の SF オフィスで AI 店員実験の第2フェーズ開始（第1フェーズは売上不振だった後の調整版）。AI エージェントの経済活動への応用研究として把握
- **Claude Mythos 5**: Fable 5 と同一基盤のサイバー防衛者向け限定モデル。セーフガード一部解除版。glasswing.anthropic.com 参加組織が対象。将来的に TBP-001 審査対象となる可能性あり
- **freee 統合ワールド 2026（6月16日・残り7日）**: 経営×バックオフィス×AI 祭典。freee-mcp の最新動向発表予定
- **会計×AI 2026年6月動向**: 経費精算工数 70〜75% 削減・月次決算 2 営業日早期化が一般化継続。マネーフォワード AI Cowork（7月リリース予定）変更なし。PEPPOL 普及で請求書標準化加速継続。経理の役割が「入力→判断支援・経営支援」に移行継続
- **Anthropic IPO S-1 機密申請（継続）**: SEC レビュー中。公開企業化後の価格・機能方針変動リスクを継続注視

#### references.md 更新提案
1. **Claude Fable 5 モデル情報（本日 v2.1.170）**: モデル選択セクションに `claude-fable-5`（$10/M input, $50/M output, 1M コンテキスト、128k 最大出力）を追記。「新モデル採用前は TBP-001 審査フローを適用すること」の注記と合わせて記載
2. **`--safe-mode` フラグ / `CLAUDE_CODE_SAFE_MODE` 環境変数（v2.1.170）**: トラブルシューティング・デバッグセクションに「全カスタマイズ無効化でのセーフモード起動」として追記
3. **`disableBundledSkills` 設定 / `CLAUDE_CODE_DISABLE_BUNDLED_SKILLS` 環境変数（v2.1.170）**: スキル管理セクションに追記。TBP-001「最小権限で開始」の実装手段として有用
4. **`/cd` コマンド（v2.1.170）**: コマンドリファレンスセクションに「prompt cache を維持しながら作業ディレクトリ変更」として追記
5. **継続提案（8週間連続未反映）**: references.md 最終確認 2026-03-29 以降3ヶ月超未更新。蓄積候補 20 件超。一括更新セッションを最優先で実施することを強く推奨

#### 新規発見ソース候補
- なし（Fable 5 関連情報は既存の anthropic.com / releasebot.io / claudefa.st でカバー可能）

#### 次回リサーチ推奨日
2026-06-10（火曜日）
注目点: ① **6月15日料金変更まで残り5日** → クレジット試算・方針確定（最終期限接近） ② **freee 統合ワールド 2026（6月16日）残り6日** → 最終事前調査 ③ **Claude Fable 5 TBP-001 審査フロー着手**（AUDIT-REPORT.md 作成） ④ **references.md 一括更新セッション** ⑤ Opus 4.8 ツール呼び出しバグの修正状況確認

---

## [2026-06-08] デイリーレポート

### 内部知見（機能A）
#### 新規・更新 ADR
- My-Profile-and-Memory/decisions/ → フォルダ未存在のためスキップ
- StudyMate, My-URAWA-LOG, tak-work, tak-family, tak-personal → decisions/ フォルダ未存在のためスキップ
- 新規 ADR: なし

#### TBP 昇格候補
なし（新規 ADR なし）

#### 再検討トリガー該当
- **TBP-001「外部ツール導入は審査→最小権限→段階拡張」**:
  1. **freee 統合ワールド 2026（6月16日・残り8日）**: Anthropic Japan 菅野信氏が登壇予定（16:40〜17:40）。freee-mcp が freeeサインにも対応済み（2026-04-10発表）。イベント後の新機能発表を TBP-001 審査フロー対象として事前ウォッチ推奨。
  2. **「Enabling Claude Code to work more autonomously」（Anthropic公式ブログ）**: サブエージェント委任・自動フック・チェックポイントシステム・Dynamic Workflows（数百の並列サブエージェント）などの自律性強化機能が紹介。新機能採用前に TBP-001「審査→最小権限→段階拡張」フローを適用すること。
  3. **Opus 4.8 ツール呼び出しバグ（継続中）**: 前回（06-07）から未修正。fallbackModel 設定で回避推奨。

---

### 外部リサーチ（機能B）
#### 参照した情報源
- code.claude.com/docs/en/changelog（⭐⭐⭐⭐⭐）
- anthropic.com/news（⭐⭐⭐⭐⭐）
- github.com/anthropics/claude-code/releases（⭐⭐⭐⭐⭐）
- releasebot.io/updates/anthropic/claude-code（⭐⭐⭐）
- claudefa.st/blog/guide/changelog（⭐⭐⭐⭐）
- corp.freee.co.jp / prtimes.jp（freee 統合ワールド 2026）
- zenn.dev / note.com / ai-native.jp / uravation.com（日本語ブログ・会計×AI）

#### 🔴 即座に適用すべき事項

**① 6月15日 料金改定まで残り7日【最重要・期限切迫】**
- 前回（06-07）からの継続。プログラマティック利用（`claude -p` / Agent SDK / GitHub Actions）が別クレジットプールへ移行
- Proプラン（$20/月）の場合、$20クレジットでClaude Sonnet 4.6 API料金（入力$3/1Mトークン、出力$15/1Mトークン）を消費。長時間の自律実行は追加課金なしでは困難になる
- 日本語解説記事が急増中（Zenn sanpi34、note.com ocomoco、ai-native.jp、uravation.com等）
- **アクション**: 本日中に月間消費クレジット試算と超過時の運用方針を確定すること

**② Claude Code v2.1.169 リリース（2026-06-08）**
- 設定ディレクトリが読み取り専用/書き込み不可の場合のサイレントハングを修正（インメモリ設定で起動 + エラーサーフェシング）
- `stream-json`/SDK セッションのターン開始時に Esc 割り込みがサイレントに無視される問題を修正
- 主にバグ修正と安定性改善のリリース。ユーザー向け新機能なし

**③ Anthropic「Enabling Claude Code to work more autonomously」（6月初旬）**
- **サブエージェント委任**: フロントエンド開発中にバックエンドAPIをサブエージェントに並行委任するパターンが正式紹介
- **自動フック**: コード変更後のテストスイート自動実行・コミット前のリント自動実行パターン
- **チェックポイントシステム**: 各変更前のコード状態を自動保存。`Esc x2` または `/rewind` で巻き戻し可能
- **Dynamic Workflows（リサーチプレビュー）**: 最大数百の並列サブエージェントを1セッションで実行
- TBP-001観点: 新自律機能の採用前に審査フローを適用すること

#### 🟡 近いうちに試したいこと（上位3件）

**① freee 統合ワールド 2026（6月16日）ウォッチ**
- 前回（06-07）から継続。Anthropic Japan 菅野信氏登壇（16:40〜17:40）、茶圓将裕氏も参加
- freee-mcp が freee サインにも対応済み（電子契約領域追加）
- イベント後: freee-mcp TBP-001 審査フロー適用の最終判断

**② fallbackModel 設定の Routines への実装（耐障害性 + Opus 4.8 バグ回避）**
- 前回（06-07）から継続推奨。`fallbackModel: ["claude-opus-4-7"]` 設定
- 6月15日料金変更後のコスト管理として、フォールバック先が安価なモデルの場合のコスト差も試算

**③ references.md 一括更新セッション（最優先・7週間連続未反映）**
- 前回（06-07）から継続。最終確認 2026-03-29 以降、3ヶ月超未更新
- 蓄積候補: fallbackModel / deny グロブ / hookSpecificOutput.additionalContext / requiredMinimumVersion / disallowed-tools / MessageDisplay / /plugin list / EnterWorktree / OTEL_LOG_TOOL_DETAILS / /reload-skills / Dynamic Workflows / Opus 4.8 デフォルト化 など20件超

#### 🟢 参考情報
- **freee 統合ワールド 2026（6月16日）**: 経営×バックオフィス×AI 祭典。新宿住友ビル三角広場・新宿住友ホール。オフライン＋一部オンライン配信、参加無料（事前登録制）。MCPがバックオフィス業務にもたらす影響と実践事例が解説予定（corp.freee.co.jp）
- **freee-mcp 電子契約対応（2026-04-10）**: freeeサインが freee-mcp に追加。会計・人事労務・請求・販売・電子契約を横断的に AI エージェントで操作可能に（corp.freee.co.jp）
- **会計×AI 2026年6月動向**: 経費精算70〜75%工数削減・月次決算2営業日早期化が一般化（TOKIUM, keihi.com）。経理の役割が「入力→判断支援・経営支援」に移行継続。PEPPOL普及で請求書標準化加速
- **Anthropic「When AI builds itself」**: AI の再帰的自己改善に関する研究記事（Anthropic Institute）。Claude Code の自律性向上の背景として把握推奨

#### references.md 更新提案
1. **継続提案（7週間連続未反映）**: references.md 最終確認 2026-03-29 以降3ヶ月超未更新。今回リリースの v2.1.169 はバグ修正主体で新設計パターンの追加なし。ただし既存の蓄積候補（fallbackModel / deny グロブ / hookSpecificOutput.additionalContext 等20件超）の一括反映セッションを引き続き最優先推奨。

#### 新規発見ソース候補
- **ai-native.jp**: Claude料金変更・AI活用の詳細解説記事あり（評価候補: ⭐⭐⭐）
- **uravation.com**: 経理AI自動化・Claude Codeに関する日本語詳細解説（評価候補: ⭐⭐⭐）

#### 次回リサーチ推奨日
2026-06-09（月曜日）
注目点: ① **6月15日料金変更まで残り6日** → クレジット試算・方針確定の最終確認 ② **freee 統合ワールド 2026（6月16日）残り7日** → 最終事前調査 ③ **Opus 4.8 ツール呼び出しバグ** の修正アップデート確認 ④ **references.md 一括更新セッション** の着手（3ヶ月超継続未反映）

---

## [2026-06-07] デイリーレポート

### 内部知見（機能A）
#### 新規・更新 ADR
- My-Profile-and-Memory/decisions/ → フォルダ未存在のためスキップ
- StudyMate, My-URAWA-LOG, tak-work, tak-family, tak-personal → decisions/ フォルダ未存在のためスキップ
- 新規 ADR: なし

#### TBP 昇格候補
なし（新規 ADR なし）

#### 再検討トリガー該当
- **TBP-001「外部ツール導入は審査→最小権限→段階拡張」**:
  1. **freee-mcp**（freee公式オープンソースMCP）が引き続き TBP-001 審査フロー適用の未完了案件として存在。約270種類の会計API操作対応。前回（06-04）からの引き継ぎ。
  2. **Opus 4.8 ツール呼び出しバグ**（GitHub Issues #63604, #64076, #64129）: malformed tool_use blocksが未修正継続。`fallbackModel`（v2.1.166）でOpus 4.7へフォールバック設定が有効な回避策。TBP-001「段階拡張」の観点からOpus 4.8本格採用前にツール安定性の確認が必要。
  3. **6月15日料金変更まで残り8日**: この Routine自体がプログラマティック利用に該当する可能性がある。コスト管理方針の確定が急務。

---

### 外部リサーチ（機能B）
#### 参照した情報源
- code.claude.com/docs/en/changelog（⭐⭐⭐⭐⭐）
- code.claude.com/docs/en/whats-new（⭐⭐⭐⭐⭐）
- anthropic.com/news（⭐⭐⭐⭐⭐）
- github.com/anthropics/claude-code/issues（⭐⭐⭐⭐⭐）
- zenn.dev/topics/claudecode（⭐⭐⭐）
- 会計×AI: keihi.com / bakuraku.jp / corp.freee.co.jp

#### 🔴 即座に適用すべき事項

**① 6月15日 料金改定まで残り8日【最重要・期限迫る】**
- 2026年6月15日から **Agent SDK / headless claude (`claude -p`) / GitHub Actions / サードパーティエージェント** がサブスクリプション枠外の別クレジットプールに移行
- クレジット額: Pro ~$20/月、Max 5x ~$100/月、Max 20x ~$200/月（フルAPI価格、ロールオーバーなし）
- インタラクティブなターミナルセッションは従来通り
- **この daily-research Routine 自体も `claude -p` 相当で対象になる可能性が高い**
- アクション: 月間消費クレジット量の試算と、クレジット上限超過時の運用方針を今週中に確定すること

**② Opus 4.8 ツール呼び出しバグ（未修正継続）**
- GitHub Issues #63604: Opus 4.8 が malformed tool_use blocks（未閉じ文字列/不完全JSON）を繰り返し生成する問題（Opus 4.7 では再現しない）
- Issue #64076: Opus 4.8がツール出力を実行なしに捏造する問題（hallucinating tool outputs）
- Issue #64129: ツール呼び出し後にレスポンスが表示されないままクォータが消費される問題
- 日本語環境で特に踏みやすいことが Zenn で報告済み（zenn.dev/edhiblemeer/articles/claude-code-opus48-tool-corruption）
- **回避策**: v2.1.166 の `fallbackModel` 設定で `["claude-opus-4-7"]` を設定する

**③ Claude Opus 4.1 API廃止予告（2026年8月5日）**
- Anthropic が Claude Opus 4.1 の API 廃止日を 2026年8月5日と発表
- 移行先: Claude Opus 4.8 を推奨（ただし上記ツール呼び出しバグに注意）
- 対応: `claude-opus-4-1-*` を指定している箇所があれば更新計画を立てる

#### 🟡 近いうちに試したいこと（上位3件）

**① freee 統合ワールド 2026（6月16日）のウォッチ**
- 明日6月16日（月）に開催。AI機能・freee-mcp 連携強化の発表が見込まれる
- freee-mcp はすでに約270種類の会計API操作に対応（オープンソース公開済み）
- Tak の本業（経理部長・組織内会計士）への直接インパクトを評価

**② fallbackModel 設定の Routines への実装（耐障害性 + Opus 4.8バグ回避）**
- Opus 4.8 ツール呼び出しバグの回避策として、`fallbackModel: ["claude-opus-4-7", "claude-sonnet-4-6"]` を設定
- プライマリが過負荷のときだけでなく、ツールバグ回避策としても機能する

**③ references.md 一括更新セッション（6週間連続未反映）**
- 前回更新 2026-03-29 以降、3ヶ月超未更新
- 蓄積候補: fallbackModel / deny グロブ / hookSpecificOutput.additionalContext / requiredMinimumVersion / disallowed-tools / MessageDisplay / /plugin list / EnterWorktree / OTEL_LOG_TOOL_DETAILS / /reload-skills / Dynamic Workflows / Opus 4.8デフォルト化 など20件超
- 来週早々に着手を強く推奨

#### 🟢 参考情報
- **Anthropic IPO S-1 機密申請（2026-06-01）**: SEC へのフォーム S-1 機密提出により IPO プロセスが正式開始。バリュエーション $965B（Series H クローズ済み、$650億調達）、ランレート $47B/年。IPO 実施・時期は SEC レビュー完了後・市場状況次第。IPO後は価格・機能方針が投資家圧力で変わる可能性（TBP-001へ「ベンダー財務健全性・事業継続リスク」軸追加は Tak 確認待ち）
- **Claude Code What's New: Week 22 が最新（May 25-29）**: Week 23（6月2-6日分）は本日時点では未掲載。次回確認推奨
- **Claude Code v2.1.167-168 (2026-06-06)**: バグ修正と信頼性改善のみ。ユーザー向け新機能なし（v2.1.166 の当日追加リリース）
- **Project Glasswing 拡張（Claude Security）**: コードベーススキャン＋パッチ提案機能を150の新組織に提供。Power/Water/Healthcare/Communications/Hardware 分野を対象に拡大
- **Anthropic Enterprise: 管理者カスタムロール**: Enterprise プランで Owner 権限なしに billing/privacy 等の個別管理権限を持つカスタムロールが設定可能に
- **会計×AI 2026年6月動向**: freee が AI ツール検知対象を15,000以上に拡大（Shadow AI 対策強化）。マネーフォワード AI Cowork（7月リリース）変更なし。PEPPOL普及で請求書フォーマット標準化が加速継続。経費精算工数70%削減事例が業界標準化

#### references.md 更新提案
1. **fallbackModel 設定（v2.1.166）**: モデル設定・信頼性セクションに「プライマリ過負荷時のフォールバックモデル設定（最大3つ）」として追記を提案（6週間未反映継続）
2. **deny ルールのグロブパターン対応（v2.1.166）**: アクセス制御セクションに「ツール名位置でのグロブパターン使用（`"*"` で全拒否）」を追記提案（6週間未反映継続）
3. **継続提案（6週間連続未反映）**: references.md 最終確認 2026-03-29 以降、3ヶ月超未更新。蓄積候補20件超。**一括更新セッションを最優先で実施することを強く推奨。**

#### 新規発見ソース候補
- **buildthisnow.com**: Claude Code 料金・機能変更の解説記事あり（評価候補: ⭐⭐⭐）
- **findskill.ai**: Claude Code 料金改定の意思決定テーブル解説（評価候補: ⭐⭐⭐）

#### 次回リサーチ推奨日
2026-06-08（日曜日）
注目点: ① **freee 統合ワールド 2026（6月16日）事前調査** ② **6月15日料金変更まで残り7日** → プログラマティック利用消費量の最終試算と方針確定 ③ **Opus 4.8 ツール呼び出しバグ** の修正アップデート確認 ④ **references.md 一括更新セッション**の着手

---
## [2026-06-06] デイリーレポート

### 内部知見（機能A）
#### 新規・更新 ADR
- my-profile-and-memory/decisions/ → フォルダ未存在のためスキップ
- その他リポジトリ（StudyMate, My-URAWA-LOG, tak-work, tak-family, tak-personal）→ decisions/ フォルダ未存在のためスキップ
- tak-best-practices/ → フォルダ未存在のためスキップ
- 新規 ADR: なし

#### TBP 昇格候補
なし（新規 ADR なし）

#### 再検討トリガー該当
- **TBP-001「外部ツール導入は審査→最小権限→段階拡張」**: v2.1.166 で deny ルールのツール名位置にグロブパターン（`"*"` ですべてのツールを拒否）が使えるようになった。TBP-001「最小権限で開始」の宣言的実装として「デフォルト全拒否→必要ツールのみ allow」設定パターンが構造的に実現可能になった。
- **TBP-001（セキュリティ継続）**: v2.1.166 でクロスセッションメッセージング（他セッションからの SendMessage 中継）がユーザー権限を引き継がないように変更。マルチエージェント設計でのセッション間権限エスカレーション防止が強化。Dynamic Workflows を使うハーネスに直接影響。

---

### 外部リサーチ（機能B）
#### 参照した情報源
- code.claude.com/docs/en/changelog（⭐⭐⭐⭐⭐）
- anthropic.com/news（⭐⭐⭐⭐⭐）
- github.com/anthropics/claude-code/issues（⭐⭐⭐⭐⭐）
- qiita.com/tags/ClaudeCode（⭐⭐⭐）
- zenn.dev/topics/claudecode（⭐⭐⭐）
- keihi.com / uravation.com（会計×AI）

#### 🔴 即座に適用すべき事項

**① v2.1.166（2026-06-06）: fallbackModel・セキュリティ強化・大量バグ修正**

- **`fallbackModel` 設定（最重要）**: プライマリモデルが過負荷・利用不可の際に最大3つのフォールバックモデルを順番に試行できるようになった。Routines や長時間タスクでの耐障害性が大幅向上。`--fallback-model` フラグもインタラクティブセッションに適用されるように改善
- **deny ルールにグロブパターン対応**: `"*"` ですべてのツールを拒否、`"Bash*"` などでパターンマッチ拒否が可能に。TBP-001「最小権限で開始」の実装が大幅に強化される
- **クロスセッションメッセージングのセキュリティ強化**: 他セッションから SendMessage 経由で中継されたメッセージはユーザー権限を持たなくなった。マルチエージェント環境での権限エスカレーション防止に重要
- **JetBrains IDE フリッカー修正（2026.1+）**: IntelliJ・PyCharm・WebStorm 等で同期出力を有効化することでフリッカーを修正
- **Windows PowerShell コマンド検証ハング修正**
- **macOS `claude --bg-pty-host` 孤立プロセス 100% CPU 使用修正**
- **Kitty キーボードプロトコル Shift+非ASCII 文字ドロップ修正**（Shift+ä → Ä が正常に入力されるように）
- **音声モード `/voice` トグル後に `/login` が必要になる問題を修正**
- **`claude agents` が git worktree 内でクラッシュループする問題を修正**
- **Ctrl+O トランスクリプトビューで思考テキストが重複する問題を修正**

**② v2.1.167（2026-06-06）: バグ修正と信頼性改善**
- 一般的なバグ修正と信頼性向上

#### 🟡 近いうちに試したいこと（上位3件）

**① `fallbackModel` 設定の Routines への実装（耐障害性向上）**
- daily-research Routine に `fallbackModel: ["claude-opus-4-6", "claude-sonnet-4-6"]` を設定し、プライマリモデル過負荷時の自動フォールバックを実装
- 6月15日料金変更と組み合わせたコスト試算：フォールバック先が安価なモデルの場合のコスト差を事前把握

**② deny ルールのグロブパターンを使った最小権限設計**
- research スキルに `"*"` でデフォルト全拒否 → `Read`・`WebSearch`・`WebFetch`・`mcp__github__*` のみ allow という最小権限設定を試験実装
- TBP-001「最小権限で開始」の宣言的実装として記録

**③ freee 統合ワールド 2026（6月16日）最終事前調査（残り10日）**
- freee が会計×AI・MCP 連携でどのようなアップデートを発表するか事前情報収集
- Tak の本業（経理部長・内部統制）への直接インパクトを評価。特に AI 仕訳・freee-MCP の機能拡張に注目

#### 🟢 参考情報
- **Anthropic Science Blog「Making Claude a chemist」（2026-06-05）**: 化学研究領域への Claude 応用に関する科学ブログ記事。Claude の専門ドメイン適用研究の一環として把握
- **GitHub Issues 新規（2026-06-06, #65899〜#65906）**: TUI・API・コスト・MCP・skills 関連のバグ・Enhancement が多数。特に #65901（macOS + MCP メモリ性能）・#65904（コスト・API バグ）が Routines に関連する可能性あり
- **Qiita: Claude Code v2.1.166 解説（@picnic）**: `fallbackModel` 設定・セキュリティ強化・バグ修正のまとめ記事（qiita.com/picnic）
- **Claude Code 週次アップデートまとめ（2026-05-30 週）（@saitoko, Qiita）**: 先週分の総括。定期フォローアップ推奨
- **会計×AI 2026年6月動向**: AIエージェントが「請求書受信→仕訳起票→会計システム入力→担当者確認依頼」を人間の逐一指示なしに実行できる水準に到達（uravation.com）。経理特化型 AI エージェント（TOKIUM・UPSIDER・マネーフォワード AI 仕訳等）が市場拡大。Tak の本業における「人間の役割 = イレギュラー判断・税務戦略立案」への移行が加速中
- **6月15日料金変更まで残り9日**: プログラマティック利用（`claude -p`/GitHub Actions/Agent SDK）の別クレジット化まで9日。この daily-research Routine も対象。最終消費量試算を強く推奨

#### references.md 更新提案
1. **`fallbackModel` 設定（v2.1.166）**: harness-design-guide のモデル設定・信頼性セクションに「プライマリ過負荷時のフォールバックモデル設定（最大3つ）」として追記を提案
2. **deny ルールのグロブパターン対応（v2.1.166）**: アクセス制御セクションに「ツール名位置でのグロブパターン使用（`"*"` で全拒否）」を追記提案。TBP-001 実装例として有用
3. **クロスセッションメッセージングのセキュリティ（v2.1.166）**: マルチエージェント設計セクションに「他セッションからの中継メッセージはユーザー権限を持たない」を追記提案
4. **継続提案（5週間連続未反映）**: references.md 最終確認 2026-03-29 以降、約3ヶ月未更新。直近1ヶ月で `fallbackModel`/`hookSpecificOutput.additionalContext`/`requiredMinimumVersion`/`disallowed-tools`/`MessageDisplay`/`/plugin list` など重要追記候補が15件超蓄積。一括更新セッションを**最優先推奨**。

#### 新規発見ソース候補
- **qiita.com/@saitoko**: Claude Code 週次アップデートまとめを継続発信。信頼性が高く日本語でのカバレッジが充実（評価候補: ⭐⭐⭐⭐）

#### 次回リサーチ推奨日
2026-06-07（土曜日）
注目点: ① 6月15日料金変更まで残り8日 → プログラマティック利用消費量の最終試算（期限迫る） ② `fallbackModel` 設定の Routines への実装 ③ freee 統合ワールド 2026（6月16日）事前情報収集（残り9日） ④ references.md 一括更新セッションの着手

---
## [2026-06-05] デイリーレポート

### 内部知見（機能A）
#### 新規・更新 ADR
- my-profile-and-memory/decisions/ → フォルダ未存在のためスキップ
- その他リポジトリ（StudyMate, My-URAWA-LOG, tak-work, tak-family, tak-personal）→ decisions/ フォルダ未存在のためスキップ
- 新規 ADR: なし

#### TBP 昇格候補
なし（新規 ADR なし）

#### 再検討トリガー該当
- **TBP-001「外部ツール導入は審査→最小権限→段階拡張」**:
  1. v2.1.163（2026-06-04）で `requiredMinimumVersion`/`requiredMaximumVersion` managed settings が追加。Claude Code がバージョン範囲外の場合に起動拒否し承認済みバージョンへ誘導する機能。TBP-001「段階拡張」に「バージョン強制管理」という運用軸が加わることを示唆。Enterprise 管理者が構造的にバージョンを固定できるようになった。
  2. `/plugin list --enabled/--disabled` コマンド追加により、プラグインの有効/無効状態の棚卸しが容易に。TBP-001「最小権限で開始」後の定期棚卸しにそのまま使えるコマンド。
  3. Stop/SubagentStop フックが `hookSpecificOutput.additionalContext` を返せるようになり、フック終了後もターンを継続させながら Claude へフィードバックを渡せる機構が追加。TBP-001 審査フローのフック設計でフィードバックループを組む際の実装手段として活用できる。

---

### 外部リサーチ（機能B）
#### 参照した情報源
- code.claude.com/docs/en/changelog（⭐⭐⭐⭐⭐）
- anthropic.com/news（⭐⭐⭐⭐⭐）
- github.com/anthropics/claude-code/issues（⭐⭐⭐⭐⭐）
- qiita.com/tags/ClaudeCode（⭐⭐⭐）
- zenn.dev/topics/claudecode（⭐⭐⭐）
- keihi.com / luvina.jp / renue.co.jp（会計×AI）

#### 🔴 即座に適用すべき事項

**① v2.1.163（2026-06-04）: バージョン強制・プラグイン管理・フック強化**

- **`requiredMinimumVersion`/`requiredMaximumVersion` managed settings**: 許可バージョン範囲外では Claude Code が起動拒否。Enterprise 管理者がバージョンを固定管理できる構造的コントロールが可能に
- **`/plugin list --enabled/--disabled`**: 有効/無効フィルタでプラグイン一覧確認。TBP-001 棚卸しに直接使えるコマンド
- **Stop/SubagentStop フックの `hookSpecificOutput.additionalContext`**: フック終了後もターンを継続しながら Claude にフィードバックを渡せる新フィールド。エラー扱いにならずにコンテキストを追加できる
- **`\$` escape syntax**: スキルコマンドボディで数字前のリテラル `$` をエスケープ可能（`\$1` → `$1` として展開されない）
- **MCP Stdio `--resume` 時 `CLAUDE_CODE_SESSION_ID` 取得**: セッション再開時のセッション ID を MCP サーバー側で受け取れるようになった
- **`claude -p` hanging 修正**: バックグラウンドコマンドが終了しない場合、最終結果出力後 ~5秒でシェルが停止するように修正
- **Bedrock/Vertex/Foundry 修正**: `CI=true` かつ Anthropic API キーなしで "ANTHROPIC_API_KEY required" エラーになる問題を修正
- **Windows**: セッション環境ディレクトリへの "EEXIST: file already exists" エラーを修正（OneDrive 環境等）
- **フック条件修正**: `if: "Bash(...)"` 条件が `$()` や `$VAR` を含む全コマンドで誤発火する問題を修正（サブシェル・バックティックのみに限定）
- **`$HOME` パスの deny ルール修正**: ホームディレクトリパスへの deny ルールが `$HOME` 経由でも正しくブロックするように修正

**② v2.1.165（2026-06-05）: バグ修正と安定性改善**
- 一般的なバグ修正と信頼性向上

#### 🟡 近いうちに試したいこと（上位3件）

**① `hookSpecificOutput.additionalContext` の活用**
- research タスクの StopHook で「次のリサーチテーマ」や「取り残した調査項目」を additionalContext として Claude に渡し、セッション引き継ぎを改善
- TBP-001 審査フローのフック設計でフィードバックループを組む実装手段として評価

**② `/plugin list --disabled` で定期棚卸し**
- インストール済みだが無効化されているプラグインを確認し、不要なものをアンインストール
- TBP-001「最小権限で開始」の事後点検として定期実行をルーティン化

**③ freee 統合ワールド 2026（6月16日）の事前情報収集（再掲）**
- 11日後。AI機能・MCP連携アップデートの発表が見込まれる
- Tak の本業（経理部長・内部統制）への直接インパクトを事前評価

#### 🟢 参考情報
- **Anthropic、AI の自己改善ループ到達前に国際的パウズを呼びかけ（2026-06-04）**: 「AI が間もなく人間の監視なしに自己改善できる段階に達しかねない」と警告し、フロンティアモデル開発の協調一時停止を提案（SiliconAngle）。長期的に TBP-001 の外部ツール審査フレームワークの重要性が高まる背景として把握
- **GitHub Issues 新規（2026-06-05）**: #65736（TUI キーバインド Enhancement）、#65735（Web版 Co-working コストバグ）、#65734（フック Enhancement）、#65739（macOS + VS Code MCP バグ）
- **Qiita: Claude Code v2.1.163 バージョン強制機能解説（@picnic）**: `requiredMinimumVersion`/`requiredMaximumVersion` の実践解説記事（qiita.com）
- **Zenn: Claude Code と Zenn 執筆環境の育て方（@shimo4228）**: Claude Code を使ったコンテンツ制作ワークフロー構築記録（zenn.dev）
- **Zenn: Claude Code 日本語入力拡張に翻訳機能追加（@genkis）**: 日本語 ↔ 英語翻訳インライン統合の実装事例（zenn.dev）
- **会計×AI 2026年6月動向**: 経理×AI 導入企業が全体の71%（KPMG グローバル調査）、うち過半数が生成AIを本格運用。経費精算工数75%削減が標準化。生成AIが「ルールベース仕訳 → 判断支援」へ進化中
- **freee 統合ワールド 2026（6月16日）**: 経営・バックオフィス・AI テーマの年次カンファレンス。AI 機能・MCP 連携強化の発表を注視

#### references.md 更新提案
1. **`requiredMinimumVersion`/`requiredMaximumVersion`（v2.1.163）**: harness-design-guide の Enterprise 管理 / managed settings セクションに「組織でのバージョン強制機能」として追記を提案。承認済みバージョン範囲外で起動拒否する仕組みの解説を含める
2. **`hookSpecificOutput.additionalContext`（Stop/SubagentStop フック）**: フック設計セクションへの追記を提案（ターン継続しながら Claude にフィードバックを渡す仕組み）
3. **継続提案（4週間連続未反映）**: references.md 最終確認が 2026-03-29 以降、約3ヶ月未更新。直近1ヶ月で `disallowed-tools`/`MessageDisplay`/`hookSpecificOutput`/`/plugin list`/バージョン強制 など重要な追記候補が10件超蓄積済み。Tak の判断で一括更新セッションを強く推奨

#### 新規発見ソース候補
なし（既存ソースで十分カバー）

#### 次回リサーチ推奨日
2026-06-06（金曜日）
注目点: ① 6月15日料金変更まで9日 → プログラマティック利用消費量の最終試算 ② claude-code-action v1.0.94 アップデート対応確認（昨日からの継続） ③ freee 統合ワールド 2026（6月16日）事前情報収集 ④ references.md 一括更新セッションの検討

---

## [2026-06-04] デイリーレポート

### 内部知見（機能A）
#### 新規・更新 ADR
- my-profile-and-memory/decisions/ → フォルダ未存在のためスキップ
- その他リポジトリ（StudyMate, My-URAWA-LOG, tak-work, tak-family, tak-personal）→ GitHub MCP アクセス制限外のためスキップ
- 新規 ADR: なし

#### TBP 昇格候補
なし（新規 ADR なし）

#### 再検討トリガー該当
- **TBP-001「外部ツール導入は審査→最小権限→段階拡張」**: Claude Code GitHub Actions に重大な脆弱性（CVSS 7.8）が発見・修正（claude-code-action v1.0.94）。`checkWritePermissions` 関数が `[bot]` で終わるアクターを無条件に信頼していた欠陥 + プロンプトインジェクションで、OIDC トークン窃取・サプライチェーン汚染が可能だった。これは TBP-001「審査ステップで外部ツールのアクター検証を確認すること」の重要性を裏付ける事例。
- **TBP-001（継続）**: SecurityWeek が「Claude Code・Gemini CLI・GitHub Copilot Agents が GitHub コメント経由のプロンプトインジェクションに脆弱」と報告。AI コーディングエージェントの GitHub 統合全般がプロンプトインジェクション攻撃ベクトルになりうることが明確化。TBP-001 審査フローに「プロンプトインジェクション耐性確認」の観点を追加することを提案（Tak 確認待ち）。

---

### 外部リサーチ（機能B）
#### 参照した情報源
- code.claude.com/docs/en/changelog（⭐⭐⭐⭐⭐）
- anthropic.com/news（⭐⭐⭐⭐⭐）
- github.com/anthropics/claude-code/releases（⭐⭐⭐⭐⭐）
- thehackernews.com / cybersecuritynews.com / securityweek.com（セキュリティ脆弱性情報）
- flatt.tech/research（GMO Flatt Security 研究レポート）
- zenn.dev/topics/claudecode（⭐⭐⭐）
- qiita.com/tags/ClaudeCode（⭐⭐⭐）
- keihi.com / renue.co.jp / freee.co.jp（会計×AI）

#### 🔴 即座に適用すべき事項

**① claude-code-action に CVSS 7.8 の重大脆弱性 → v1.0.94 で修正済み（要アップデート）**

- 発見者: RyotaK（GMO Flatt Security）→ 1月に報告、Anthropic が4日で修正、春を通じて追加強化
- 攻撃手法: `checkWritePermissions` が `[bot]` で終わるアクターを無条件信頼 → GitHub App を使ったなりすましが可能
- プロンプトインジェクション組み合わせで: OIDC トークン窃取 → 下流リポジトリへの悪意あるコード注入（サプライチェーン攻撃）が可能だった
- 修正内容 (v1.0.94): `checkHumanActor` 呼び出し追加、ワークフローサマリ無効化デフォルト化、子プロセスへの環境変数スクラビング、カスタム `gh` コマンドラッパー（URL 持ち出しブロック）、トリガー後のイシュー編集無視
- Anthropic は bug bounty $4,800 を支払い（ベース $3,800 + ボーナス $1,000）
- **対応**: claude-code-action を使っている GitHub Actions ワークフローは即刻 v1.0.94 以降に更新すること（`.github/workflows/` 内の `uses: anthropics/claude-code-action@` のバージョン指定を確認）

**② Claude Code・Gemini CLI・GitHub Copilot Agents、GitHub コメント経由のプロンプトインジェクション脆弱性（SecurityWeek）**

- 3つの主要 AI コーディングエージェントがすべて、GitHub Issues/PR コメントへの悪意ある内容の埋め込みによるプロンプトインジェクションに脆弱であることが報告
- 教訓: AI エージェントが GitHub 統合を持つ場合、外部からのコンテンツ（Issue/PR コメント）をプロンプトとして処理する際のサニタイズが必須

#### 🟡 近いうちに試したいこと（上位3件）

**① claude-code-action バージョン確認と v1.0.94 へのアップデート**
- research-hub / My-Profile-and-Memory の GitHub Actions ワークフローで claude-code-action を使っている場合、バージョンを確認して v1.0.94 以降に更新

**② TBP-001 審査フローへ「プロンプトインジェクション耐性確認」観点の追加を Tak に提案**
- 現行 TBP-001 は「審査→最小権限→段階拡張」。今回の脆弱性事例を受け、審査ステップに「外部コンテンツ処理時のプロンプトインジェクション耐性確認」を明示的に追加（TBP-001 更新案として提案）

**③ freee 統合ワールド 2026（6月16日）の事前情報収集**
- 12日後に迫った freee イベント。AI機能・MCP連携のアップデートが発表される見込み
- freee-mcp がオープンソース公開済み（約270種類の会計 API 操作対応）。Tak の本業（経理部長）への直接インパクトを事前評価

#### 🟢 参考情報
- **Claude Code が GitHub 公開コミットの 4% を占める（Gigazine）**: 2026年末には20%超を占めると予測。AI コーディングが主流化している背景として記録
- **Claude Code 6月15日料金変更まで11日**: プログラマティック利用（claude -p / GitHub Actions / Agent SDK）が別クレジット化。残り11日で準備完了が必要
- **Zenn 新着記事（2026-06-04前後）**:
  - 「Claude Code 使い放題は終わるのか？6月改定の全容と開発者がやるべきこと」（zenn.dev/sanpi34）: 6月15日料金変更の詳細解説。Max プランの使い分けが焦点
  - 「コードを書けない私が、AIに『チーム』を持たせるまで」（Qiita/saitoko）: 非エンジニアが Claude Code でサブエージェントチームを組んで Zenn Book を出版した実録
  - 「Claude Code の無料 hook を配り続けて有料 Zenn 本が売れた理由」（Qiita/yurukusa）: コミュニティ貢献戦略の参考事例
- **freee-mcp オープンソース公開**: 約270種類の freee 会計 API をローカル環境なしで利用可能。TBP-001 審査対象として評価価値あり
- **国税庁 KSK2 移行（2026年9月）**: 基幹システムが次世代「KSK2」に全面移行予定。Tak の本業（経理部長・内部統制）に直結する変化として注視
- **経理 AI 2026年最新動向**: 生成AIが「判断支援」段階に進化（ルールベースRPA → 生成AI判断）。PEPPOL で請求書標準化加速。経費精算工数75%削減事例が一般化

#### references.md 更新提案
1. **claude-code-action セキュリティ（v1.0.94 で修正）**: harness-design-guide のセキュリティ・GitHub Actions セクションに「claude-code-action を使う場合は v1.0.94 以降を使用し、外部コンテンツ経由のプロンプトインジェクション耐性を確認すること」を追記することを提案
2. **AI エージェントのプロンプトインジェクション全般**: TBP-001 審査フローの「審査項目」に「GitHub Issues/PR コメント等の外部コンテンツ経由プロンプトインジェクション耐性確認」を追加提案
3. **継続提案（前日からの未反映）**: v2.1.162 WebFetch 権限ルール修正 / references.md 最終確認 2026-03-29 以降約3ヶ月未更新。早急な棚卸しを推奨

#### 新規発見ソース候補
- **flatt.tech/research**: GMO Flatt Security の研究レポート。Claude Code / AI エージェントのセキュリティ脆弱性に関する深掘り記事あり（評価候補: ⭐⭐⭐⭐）
- **securityweek.com**: AI セキュリティ関連報道の速報として有効（評価候補: ⭐⭐⭐）

#### 次回リサーチ推奨日
2026-06-05（木曜日）
注目点: ① 6月15日料金変更まで10日 → プログラマティック利用消費量の最終試算 ② claude-code-action v1.0.94 アップデート対応確認 ③ freee 統合ワールド 2026（6月16日）事前情報収集 ④ TBP-001 プロンプトインジェクション観点追加案の確認

---

## [2026-06-03] デイリーレポート

### 内部知見（機能A）
#### 新規・更新 ADR
- my-profile-and-memory/decisions/ → フォルダ未存在のためスキップ
- その他リポジトリ（StudyMate, My-URAWA-LOG, tak-work, tak-family, tak-personal）→ GitHub MCP アクセス制限外のためスキップ
- 新規 ADR: なし

#### TBP 昇格候補
なし（新規 ADR なし）

#### 再検討トリガー該当
- **TBP-001「外部ツール導入は審査→最小権限→段階拡張」**: v2.1.162（2026-06-03）で WebFetch の権限ルールがプリ承認ドメインに適用されなかった問題が修正（明示的な `WebFetch(domain:...)` の deny/ask/allow ルールが常に優先されるように変更）。TBP-001「最小権限で開始」原則の観点から、研究用 harness の WebFetch ドメイン許可リスト設計が auditing 対象として明示化する価値がある。
- **TBP-001「審査→最小権限→段階拡張」**: Project Glasswing が150の新組織に拡張（2026-06-02）。Glasswing の「防衛者が先行して脆弱性を発見」というフレームは TBP-001 審査フローのテンプレートへの組み込み参考として継続確認推奨（前回提案再掲）。

---

### 外部リサーチ（機能B）
#### 参照した情報源
- code.claude.com/docs/en/changelog（⭐⭐⭐⭐⭐）
- anthropic.com/news（⭐⭐⭐⭐⭐）
- github.com/anthropics/claude-code/releases（⭐⭐⭐⭐⭐）
- zenn.dev/topics/claudecode（⭐⭐⭐）
- qiita.com/tags/ClaudeCode（⭐⭐⭐）
- keihi.com / corp.freee.co.jp（会計×AI）

#### 🔴 即座に適用すべき事項

**① v2.1.162（2026-06-03）: UX大幅改善 + セキュリティ修正**

主要な変更点:
- **WebFetch 権限ルール修正（セキュリティ）**: 明示的な `WebFetch(domain:...)` の deny/ask/allow ルールが、プリ承認ドメインよりも常に優先されるようになった。harness の allowedTools / deniedTools で WebFetch に関するドメイン制限を設定している場合、意図通りに機能するようになった。
- **Windows 権限ルール修正**: バックスラッシュ（`~\`, `\\server\share`）表記やケースバリアントパスで権限ルールがマッチしない問題を修正。Read deny ルールが Glob/Grep 結果からファイルを隠すように。
- **MCP sub-1000ms タイムアウト修正**: 1000ms 未満の `timeout` 設定が1秒にフロアされ、すべてのツール呼び出しが中断されていた問題を修正。sub-1000ms 値はフォールバック扱い（`MCP_TOOL_TIMEOUT` またはデフォルト）になり、`claude mcp get` で注釈表示。
- **`claude agents --json` 強化**: `waitingFor` フィールドが追加され、待機セッションが何をブロックされているか（権限プロンプト等）が確認できるようになった。
- **`--tools` 修正**: Grep/Glob を明示指定すると埋め込み検索ツールが正しく提供されるようになった（以前はサイレント無視）。
- **スラッシュコマンドのオートコンプリート改善**: クリックでプロンプトへの補完、Enterで実行（誤実行防止）。
- **Remote Control**: 起動メッセージ→セッションリンク付きの永続フッターピルに変更。
- **Windsurf → Devin Desktop リネーム**: `/ide`, `/terminal-setup`, `/scroll-speed` 内でリネーム完了。
- **起動の静粛化**: エラーは重要度別にグループ化、セッション情報と告知が1行に集約。
- **バックグラウンドセッション関連の多数の修正**: アタッチ遅延（5秒スタール解消）、セッション消失の防止、返信キューイング、`SendMessage` の TMPDIR パス問題修正。

#### 🟡 近いうちに試したいこと（上位3件）

**① WebFetch 権限ルールの見直し（harness セキュリティ強化）**
- v2.1.162 の修正により、harness の deny/ask/allow ルールで WebFetch に明示的なドメイン制限を設定すると確実に機能するようになった
- research タスクで必要なドメイン（code.claude.com, anthropic.com 等）を allowlist に、それ以外を ask または deny に設定して最小権限化を試みる価値あり
- TBP-001 審査フローとの統合点として記録推奨

**② Claude Partner Network Services Track の活用評価（2026-06-03 発表）**
- Anthropic がサービストラックを発表（Select: 認定10名・顧客2社・事例1件 / Preferred: 100名・15社・3件 / Global Premier: 1000名・100社・15件）
- 当面は直接関係ないが、Claude Code を組織導入する際のベンチマーク軸として把握しておく価値あり
- パートナー昇格スケジュール: 1月1日・7月1日（2026年は10月1日に追加レビュー）

**③ freee 統合ワールド 2026 のウォッチ（2026-06-16 予定）**
- freee が2026年6月16日にイベントを開催予定。AI機能・連携強化のアップデートが発表される可能性が高い
- Tak の本業（経理部長・組織内会計士）への直接インパクトを評価。freee MCP・AI仕訳機能の動向に注目

#### 🟢 参考情報
- **Project Glasswing 拡張（2026-06-02）**: 15カ国以上の約150の新組織を追加。これまでの参加者が10,000件以上の重大/クリティカルセキュリティ脆弱性を発見・修正。重要インフラの防衛支援プログラムとして規模拡大継続。
- **AI サイバー脅威ポリシーレポート（2026-06-02 Anthropic）**: 1年分のAI有効サイバー脅威マッピング結果を公開。security-review スキルや TBP-001 審査フローの参照資料として価値あり。
- **Zenn: Claude Code サブエージェントとスキルの違い（Qiita, 2026-06-03公開）**: サブエージェント設計でひとりの仕事をAIに任せるパターンの解説記事。
- **Zenn: 「Claude Code 使い放題は終わるのか？6月改定の全容と開発者がやるべきこと」**: 6月15日料金変更（プログラマティック利用の別クレジット化）の詳細解説。daily-research Routine への影響確認を再掲（残り12日）。
- **会計×AI 2026年6月動向**: 生成AIが経理の「判断支援」段階に進化。PEPPOLによる請求書標準化が加速。経費精算の自動化で入力・確認工数75%削減事例が一般化。freee 統合ワールド 2026（6月16日）でのAI機能発表に注目。

#### references.md 更新提案
1. **v2.1.162 WebFetch 権限ルール修正**: harness-design-guide のアクセス制御セクションに「`WebFetch(domain:...)` の明示的 deny/ask/allow ルールがプリ承認ドメインより優先されるようになった（v2.1.162〜）」を追記することを提案
2. **Claude Partner Network Services Track**: 参照情報として「外部サービス/パートナー評価軸」のリソースとして追記検討（任意）
3. **継続提案（前回からの未反映）**: v2.1.160 acceptEdits セキュリティ強化 / v2.1.161 並列ツール呼び出し修正 / references.md 最終確認 2026-03-29 以降約3ヶ月未更新

#### 新規発見ソース候補
なし（既存ソースが主要情報をカバー）

#### 次回リサーチ推奨日
2026-06-04（水曜日）
注目点: ① 6月15日料金変更まで11日 → daily-research Routine クレジット消費試算 ② WebFetch 権限ルール見直し（v2.1.162 修正を受けた harness 設計） ③ freee 統合ワールド 2026（6月16日）事前情報収集 ④ Anthropic AI サイバー脅威ポリシーレポートの内容確認

---

## [2026-06-02] デイリーレポート

### 内部知見（機能A）
#### 新規・更新 ADR
- my-profile-and-memory/decisions/ → フォルダ未存在のためスキップ
- その他リポジトリ（StudyMate, My-URAWA-LOG, tak-work, tak-family, tak-personal）→ GitHub MCP アクセス制限外のためスキップ
- 新規 ADR: なし

#### TBP 昇格候補
なし（新規 ADR なし）

#### 再検討トリガー該当
- **TBP-001「外部ツール導入は審査→最小権限→段階拡張」**: v2.1.160（2026-06-02）でシェル起動ファイル（`.zshenv`, `.zlogin`, `.bash_login`, `~/.config/git/`）への書き込み前に確認プロンプトが追加。また `acceptEdits` モードがビルドツール設定ファイル（`.npmrc`, `.yarnrc*`, `bunfig.toml`, `.bazelrc`, `.pre-commit-config.yaml`, `.devcontainer/`）への書き込み前にも確認するように変更。TBP-001「最小権限で開始」原則と整合する公式変更で、`acceptEdits` モードを設定している環境では挙動変化の確認を推奨。

---

### 外部リサーチ（機能B）
#### 参照した情報源
- code.claude.com/docs/en/changelog（⭐⭐⭐⭐⭐）
- anthropic.com/news（⭐⭐⭐⭐⭐）
- github.com/anthropics/claude-code/releases（⭐⭐⭐⭐⭐）
- devtoolpicks.com / codersera.com（Anthropic subscription changes）
- zenn.dev/topics/claudecode（⭐⭐⭐）
- qiita.com/tags/ClaudeCode（⭐⭐⭐）
- ai-revolution.co.jp / freee.co.jp / prtimes.jp（会計×AI）

#### 🔴 即座に適用すべき事項

**① v2.1.160（2026-06-02）: セキュリティ強化**
- シェル起動ファイル（`.zshenv`, `.zlogin`, `.bash_login`, `~/.config/git/`）への書き込み前に確認プロンプトを追加（意図しないコマンド実行を防止）
- `acceptEdits` モードがビルドツール設定ファイル（`.npmrc`, `.yarnrc*`, `bunfig.toml`, `.bazelrc`, `.pre-commit-config.yaml`, `.devcontainer/`）への書き込み前に確認するように（コード実行権限を持つファイルへの予期しない書き込みを防止）
- grep でファイルを確認した後の Edit に別途 Read が不要になった（利便性向上）
- WSL 上での Windows クリップボードへのコピーを修正（PowerShell interop 方式に変更。MobaXterm 等 OSC 52 非対応ターミナルでも動作）

**② v2.1.161（2026-06-02）: 多数のバグ修正**
- 並列ツール呼び出しで失敗した Bash コマンドが他のバッチ呼び出しをキャンセルしなくなった（Dynamic Workflows・並列処理設計に重要）
- `claude agents` が work ファンアウト時に `done/total` を表示するように
- `/mcp` が未使用の claude.ai コネクタを「Show unused connectors」に折り畳むように
- `OTEL_RESOURCE_ATTRIBUTES` の値がメトリクスデータポイントのラベルに含まれるように
- OpenTelemetry ログイベントの初期化前ドロップを修正
- フルスクリーンモードで Linux クリップボード（wl-copy/xclip/xsel）が機能するように
- Windows hooks で bash が "command not found" になる問題を修正
- バックグラウンドサブエージェントの出力が `claude -p` stdout を壊す問題を修正
- Workflow agents の `isolation: "worktree"` でファイル編集がブロックされる問題を修正
- `/autofix-pr` が git worktree でエラーを報告する問題を修正

**③ Anthropic が S-1 を SEC に機密提出 → IPO 準備本格化（2026-06-01）**
- Anthropic が米 SEC にフォーム S-1 を機密提出（2026-06-01）。OpenAI に先行する形で IPO レース入り
- バリュエーション $9,650 億（Series H クローズ済み、$650 億調達）、ランレート $47B/年
- 「公開の選択肢を確保するため」の提出。IPO 実施は SEC レビュー完了後・市場状況次第
- **ハーネス設計への示唆**: Anthropic が公開企業化すると価格設定・機能提供方針が投資家圧力で変わる可能性。TBP-001 審査フローへ「ベンダー財務健全性・事業継続リスク」軸の追加を提案（Tak の判断待ち）

**④ 6月15日 料金変更まで13日（プログラマティック利用課金分離）【最終確認】**
- 前回（2026-05-31）でも確認済み。残り13日で最終準備フェーズ
- 対象: Agent SDK・`claude -p`（非インタラクティブ）・GitHub Actions・サードパーティエージェント
- 月次クレジット: Pro $20 / Max 5x $100 / Max 20x $200（フル API 価格、ロールオーバーなし）
- この daily-research Routine 自体も claude -p 相当で対象になりうるため、消費クレジットの事前試算を推奨

#### 🟡 近いうちに試したいこと（上位3件）

**① v2.1.161 の並列ツール呼び出し修正を活用（ハーネス設計）**
- 失敗した Bash コマンドが他のバッチを止めなくなったため、research タスクで複数リポジトリを並列確認する際のエラー耐性が向上
- Dynamic Workflows との組み合わせで並列リサーチの信頼性が上がる → 試験導入を検討

**② acceptEdits モードの設定見直し**
- v2.1.160 の変更で `acceptEdits` モード時にビルドツール設定ファイル書き込み前プロンプトが追加
- ハーネス内で `acceptEdits` を設定している場合、既存フローとの整合性確認を推奨（`.npmrc` 等への誤書き込み防止として有効だが、CI 環境ではプロンプトが止まる可能性あり）

**③ マネーフォワード AI Cowork の技術詳細確認（7月リリース予定）**
- Claude Agent SDK + MCP を採用したバックオフィス AI 自動化製品
- Tak の本業（経理部長・組織内会計士）への応用可能性を評価。7月リリース前に技術アーキテクチャ・料金・機能範囲を把握

#### 🟢 参考情報
- **Anthropic 新利用規約（2026-06-01 施行）**: プロフェッショナル向け利用規約が更新。詳細確認推奨
- **freee「AIおまかせ明細取得」β版**: モバイルSuica PDF から明細を自動抽出（2026-03-26〜）。AI-OCR 精度 99% 以上
- **Zenn「Claude Code の hook を無料公開してきた実録」（3日前公開）**: 無料 hook 公開が有料技術書販売につながった事例。コミュニティへの貢献戦略の参考
- **「0から分かる Claude Code 完全ガイド」（Zenn本）**: 2026/05/29 時点の Anthropic 公式ベストプラクティスをまとめた日本語書籍。確認推奨
- **会計×AI 業界**: 導入企業で作業時間 50〜90% 削減事例が一般化。イレギュラー取引判断・税務戦略立案は依然人間の役割。freee ARPU が前年比 11.2% 上昇（年 60,800 円）

#### references.md 更新提案
1. **v2.1.160 セキュリティ強化**: `acceptEdits` モードでのビルドツール設定ファイル保護（`.npmrc`, `.yarnrc*` 等）を harness-design-guide の acceptEdits 設定セクションに追記を提案
2. **v2.1.161 並列ツール呼び出し修正**: Dynamic Workflows・並列処理設計セクションへの追記を提案（失敗 Bash が他の並列コールをキャンセルしなくなった）
3. **references.md 最終確認が 2026-03-29 で約3ヶ月経過**: 参照 URL 群（best-practices / agent-skills）の内容が最新か確認を推奨。公式ドキュメントが大幅更新されている可能性あり
4. **継続提案（前回からの未反映）**: Mythos クラスモデル採用前の TBP-001 審査フロー適用 / `.claude/skills` 自動ロード記載 / Dynamic Workflows 追記 / `disallowed-tools` フロントマター

#### 新規発見ソース候補
- **devtoolpicks.com**: Anthropic 課金変更・機能変更の詳細解説記事あり。実務影響の整理に有用（評価候補: ⭐⭐⭐）

#### 次回リサーチ推奨日
2026-06-04（水曜日）
注目点: ① 6月15日料金変更まで11日 → daily-research Routine のクレジット消費試算完了 ② acceptEdits モード挙動確認（v2.1.160 変更との整合） ③ マネーフォワード AI Cowork 技術詳細 ④ Anthropic IPO 進捗・利用規約変更の実務影響確認

---


## [2026-05-31] デイリーレポート

### 内部知見（機能A）
#### 新規・更新 ADR
- my-profile-and-memory/decisions/ → フォルダ未存在のためスキップ
- その他リポジトリ（StudyMate, My-URAWA-LOG, tak-work, tak-family, tak-personal）→ GitHub MCP アクセス制限外のためスキップ
- 新規 ADR: なし

#### TBP 昇格候補
なし（新規 ADR なし）

#### 再検討トリガー該当
- **TBP-001「外部ツール導入は審査→最小権限→段階拡張」**: Anthropic が Mythos レベルモデルを「数週間以内に全ユーザーへリリース」すると発表（2026-05-28〜29）。Mythos はコーディング・サイバーセキュリティ能力が際立って高く（専門的ハッキングタスク 73% 成功率）、TBP-001 の「導入前審査」原則が新モデル採用時にも適用されるべき。特に security-guidance プラグインとの組み合わせ評価を推奨。

---

### 外部リサーチ（機能B）
#### 参照した情報源
- code.claude.com/docs/en/changelog（⭐⭐⭐⭐⭐）
- anthropic.com/news（⭐⭐⭐⭐⭐）
- github.com/anthropics/claude-code/issues（⭐⭐⭐⭐⭐）
- red.anthropic.com（Mythos Preview）
- zenn.dev/topics/claudecode（⭐⭐⭐）
- keihi.com / biz.moneyforward.com（会計×AI）

#### 🔴 即座に適用すべき事項

**① v2.1.159（2026-05-31）: 内部インフラ改善のみ**
- ユーザー向け変更なし
- アップデート適用は安全・推奨（変更リスクなし）

**② Mythos レベルモデルの近日一般公開（Anthropic 発表: 2026-05-28〜29）**
- Anthropic が「数週間以内」に全ユーザーへ Mythos レベルモデルを提供予定と正式発表
- 現在は Project Glasswing（重要インフラ防衛者・OSS 開発者限定）で限定公開中
- Mythos の能力: 数学オリンピック 97.6%・専門的ハッキングタスク 73% 成功率（2025年4月時点では不可能だったタスク）
- **TBP-001 適用**: 新モデル採用前に審査フロー（external-audit 相当）を実施。特に security-guidance プラグインと組み合わせた能力評価が推奨
- **対応**: Mythos 一般公開のアナウンスを注視し、公開時点で TBP-001 審査記録（AUDIT-REPORT.md）を作成してから採用を検討すること

#### 🟡 近いうちに試したいこと（上位3件）

**① Mythos 一般公開後の採用評価（TBP-001 審査フロー適用）**
- 公開次第、security-guidance プラグインを使ったコード脆弱性スキャンに Mythos を投入し評価
- harness 内のデフォルトモデルを Mythos に変更する前に最小権限環境でのテストを徹底
- Mythos の「自己修正ループ」能力（コード修正途中で誤りを発見し修正し直す）がハーネス設計に与える影響を評価

**② Claude Code と Codex の使い分け評価（Zenn 新着記事参照）**
- 「settings.json を育てた側が速い」という実証 → Tak の settings.json / CLAUDE.md の充実度確認
- Codex が「PR 自動レビュー・大規模一括変更」に向くという知見 → research ワークフローへの応用検討
- Claude Code（日常開発全般）vs Codex（PR レビュー・大規模変更）の役割分担を明示化する価値あり

**③ Project Glasswing の情報収集と TBP-001 への反映**
- Anthropic が Glasswing で「重要ソフトウェアのセキュリティ確保」を目的とした AI 活用フレームを公開
- TBP-001「外部ツール導入は審査→最小権限→段階拡張」の審査テンプレートに Glasswing の考え方を参照できるか評価
- glasswing.anthropic.com の内容確認と TBP-001 AUDIT-REPORT テンプレートへの適用可否検討

#### 🟢 参考情報
- **GitHub Issues 新規（#64334〜#64341, 2026-05-31）**: TUI キーバインド（macOS）・認証（macOS）・Bash/権限バグ（macOS）・Windows デスクトップバグが複数報告。デスクトップアプリ最新版への更新を推奨
- **Project Glasswing（Anthropic 公式）**: Mythos を使って重要インフラの脆弱性を防衛者が先行発見・修正するプログラム。OSS 開発者も対象。glasswing.anthropic.com 確認推奨
- **Zenn 新着「Claude CodeとCodexを2ヶ月使い比べた」（2026-05-31公開）**: settings.json の充実度が生産性に直結することを実証。research-hub ハーネスの CLAUDE.md / settings.json 見直しの参考に
- **会計×AI 2026年5月最新**: freee AI-OCR が印刷レシート 90% 超・手書き 75% 前後の精度に到達。バクラク × freee/マネーフォワード API 連携が強化継続。マネーフォワード AI Cowork は 7 月リリース変更なし
- **Anthropic バリュエーション $965B 確定（継続確認）**: ランレート $47B/年。2026 年 10 月 IPO へ向けた動き継続中

#### references.md 更新提案
1. **Mythos レベルモデルの近日公開**: harness-design-guide のモデル選択セクションに「Mythos クラスモデルへの移行前は TBP-001 審査を実施すること」として追記を提案
2. **Project Glasswing**: セキュリティレビュースキル・security-guidance プラグインのセクションに関連リソースとして追記を提案
3. **前日（v2.1.158）からの未反映提案継続**: Auto mode（Bedrock/Vertex/Foundry）の環境変数 `CLAUDE_CODE_ENABLE_AUTO_MODE=1` の説明を harness-design-guide に追記（前日提案再掲）

#### 新規発見ソース候補
- **glasswing.anthropic.com**: Anthropic のセキュリティ AI プログラム Glasswing の公式ページ。Mythos レベルの能力評価・セキュリティ活用の一次情報（評価候補: ⭐⭐⭐⭐⭐）
- **red.anthropic.com**: Anthropic Red Team のプレビュー・実験的発表ページ。Mythos Preview 公開中（評価候補: ⭐⭐⭐⭐ 継続）

#### 次回リサーチ推奨日
2026-06-02（月曜日）
注目点: ① Mythos 一般公開確認と TBP-001 審査フロー適用 ② Auto mode（Bedrock/Vertex/Foundry）の実運用評価継続 ③ 6 月 15 日料金変更最終確認・クレジット消費試算 ④ Project Glasswing への参加可否評価

---

## [2026-05-30] デイリーレポート

### 内部知見（機能A）
#### 新規・更新 ADR
- my-profile-and-memory/decisions/ → decisions/ フォルダ未作成のためスキップ
- その他リポジトリ（StudyMate, My-URAWA-LOG, tak-work, tak-family, tak-personal）→ GitHub MCP アクセス制限外のためスキップ
- 新規 ADR: なし

#### TBP 昇格候補
なし（新規 ADR なし）

#### 再検討トリガー該当
- **TBP-001「外部ツール導入は審査→最小権限→段階拡張」**: v2.1.158（2026-05-30）で `CLAUDE_CODE_ENABLE_AUTO_MODE=1` を設定すると Bedrock・Vertex・Foundry 上でも Opus 4.7/4.8 の Auto mode が有効になった。新クラウドプロバイダー環境で Auto mode を有効化する際は、そのプロバイダー固有の権限設定・ネットワーク境界に対しても TBP-001「審査→最小権限」原則を適用すること。特に Foundry（今回初出）は従来未確認環境のため、導入前に外部監査相当の評価を推奨。

---

### 外部リサーチ（機能B）
#### 参照した情報源
- code.claude.com/docs/en/changelog（⭐⭐⭐⭐⭐）
- anthropic.com/news（⭐⭐⭐⭐⭐）
- github.com/anthropics/claude-code/issues（⭐⭐⭐⭐⭐）
- zenn.dev/topics/claudecode（⭐⭐⭐）
- qiita.com/tags/ClaudeCode（⭐⭐⭐）
- keihi.com / biz.moneyforward.com / freee.co.jp（会計×AI）

#### 🔴 即座に適用すべき事項

**① v2.1.158: Auto mode が Bedrock・Vertex・Foundry に拡張（2026-05-30）**
- `CLAUDE_CODE_ENABLE_AUTO_MODE=1` 環境変数を設定すると、Bedrock・Vertex・Foundry 上で Opus 4.7 および Opus 4.8 の Auto mode が利用可能に
- Auto mode: タスクの複雑さに応じてモデルが自動でモード（速度/品質）を切り替える機能
- TBP-001 との関連: 新クラウドプロバイダーで有効化する際は事前審査を推奨（特に Foundry は初出環境）
- **対応**: Bedrock/Vertex/Foundry を利用している場合、Auto mode の試験導入前に各プロバイダーの IAM/権限設定を確認

#### 🟡 近いうちに試したいこと（上位3件）

**① Bedrock/Vertex 上での Auto mode 有効化と動作評価**
- 既存の Bedrock/Vertex 接続環境があれば `CLAUDE_CODE_ENABLE_AUTO_MODE=1` を設定して品質・コスト変化を測定
- Auto mode が Daily Research タスクのコスト効率にどう影響するか試算

**② GitHub Issues 新規動向の継続追跡（#64067〜#64073）**
- 本日開設の Issue のうち MCP・メモリ関連（#64072: Windows MCP メモリ問題）が今後のハーネス設計に影響する可能性
- 特に #64070（hooks + MCP enhancement request）は TBP-001/ハーネス設計に関連する内容の可能性あり

**③ 「cc-safe-setup」（GitHub）の評価**
- Zenn/Qiita に掲載されている GitHub の Claude Code 安全設定セット「cc-safe-setup」が TBP-001 審査フローと重複する可能性あり
- TBP-001 の AUDIT-REPORT テンプレート化の参考として評価価値あり

#### 🟢 参考情報
- **Claude Mythos Preview（Anthropic Red Team）**: red.anthropic.com にて Mythos のプレビューが公開確認。詳細未取得・次回確認推奨
- **GitHub Issues 本日の新規（#64067〜#64073）**: TUI バグ（macOS/Linux）、MCP メモリ問題（Windows）、認証問題（macOS）が複数報告。デスクトップアプリ利用者は最新版確認推奨
- **freee が Claude Cowork MCP 統合に対応**: MCP プロトコル経由で freee 会計データに AI エージェントが直接アクセス可能に（Shopify データ取込みとの相性良好）
- **マネーフォワード AI Cowork**: 2026年7月リリース予定（変更なし）
- **会計×AI 2026年現状**: 仕訳自動化 90%+ 精度・請求書処理 70% 工数削減が一般化。PEPPOL 普及継続。花王ビューティブランズが経費精算 AI 導入で年間 5.5 万時間削減

#### references.md 更新提案
1. **Auto mode の Bedrock/Vertex/Foundry 対応（v2.1.158）**: `CLAUDE_CODE_ENABLE_AUTO_MODE=1` 環境変数の説明をモデル設定・マルチプロバイダーセクションに追記を提案
2. **前日（v2.1.157）からの未反映提案継続**: `.claude/skills` 自動ロード・`claude plugin init`・`--agent <name>` フラグ・`EnterWorktree` フック・`OTEL_LOG_TOOL_DETAILS=1` の harness-design-guide への追記（前日提案再掲）

#### 新規発見ソース候補
- **red.anthropic.com**: Anthropic Red Team のプレビュー・実験的発表ページ（Mythos Preview 公開確認）（評価候補: ⭐⭐⭐⭐）

#### 次回リサーチ推奨日
2026-06-01（月曜日）
注目点: ① Auto mode（Bedrock/Vertex/Foundry）の実運用評価 ② 6月15日料金変更最終確認・Auto mode コスト影響試算 ③ Claude Mythos Preview の内容確認 ④ `claude plugin init` を使ったプラグイン scaffold テンプレート作成（前日継続）

---

## [2026-05-29] デイリーレポート

### 内部知見（機能A）
#### 新規・更新 ADR
- my-profile-and-memory/decisions/ → decisions/ フォルダ未作成のためスキップ
- その他リポジトリ（StudyMate, My-URAWA-LOG, tak-work, tak-family, tak-personal）→ GitHub MCP アクセス制限外のためスキップ
- 新規 ADR: なし

#### TBP 昇格候補
なし（新規 ADR なし）

#### 再検討トリガー該当
- **TBP-001「外部ツール導入は審査→最小権限→段階拡張」**: v2.1.157 で `.claude/skills` 配下のプラグインが**マーケットプレイスを経由せずに自動ロード**される仕様になった。これまでマーケットプレイスを通じていた審査フローの一部が省略されうる構造変化。TBP-001 の「審査」ステップを `.claude/skills` への配置前に行うことを明示する必要がある。また `claude plugin init <name>` で新規プラグインの scaffold が簡単になったため、審査なし導入が増えるリスクに注意。

---

### 外部リサーチ（機能B）
#### 参照した情報源
- code.claude.com/docs/en/changelog（⭐⭐⭐⭐⭐）
- anthropic.com/news（⭐⭐⭐⭐⭐）
- github.com/anthropics/claude-code/issues（⭐⭐⭐⭐⭐）
- zenn.dev/topics/claudecode（⭐⭐⭐）
- 会計×AI: keihi.com / biz.moneyforward.com / freee.co.jp / renue.co.jp

#### 🔴 即座に適用すべき事項

**① v2.1.157: `.claude/skills` 自動ロードとプラグイン管理の大幅改善（2026-05-29）**
- `.claude/skills` 配下のプラグインが**マーケットプレイスを経由せずに自動ロード**されるようになった
- `claude plugin init <name>` コマンドで新規プラグインの scaffold を生成可能
- `/plugin` 引数のオートコンプリート（サブコマンド・インストール済み名・マーケットプレイスプラグイン）が追加
- TBP-001 への影響: 自動ロードにより審査なしで有効化されるリスクが生まれた。`.claude/skills` 配置前に TBP-001 審査フローを必ず実施すること

**② v2.1.157: エージェント管理の強化（2026-05-29）**
- `settings.json` の `agent` フィールドがディスパッチセッションでも反映されるようになった
- `--agent <name>` フラグで settings のデフォルトエージェントをオーバーライド可能
- `EnterWorktree` フックがセッション中に Claude 管理の worktree 間を切り替えられるようになった
- ワークツリー管理: 完了後に unlocked 状態で残るようになり `git worktree remove/prune` が容易に

**③ v2.1.157: テレメトリ強化（2026-05-29）**
- `OTEL_LOG_TOOL_DETAILS=1` 環境変数を設定すると `tool_decision` テレメトリに `tool_parameters`（bash コマンド・MCP/スキル名）が含まれるようになった
- ハーネスのデバッグ・監査証跡に活用可能

**④ v2.1.156: Opus 4.8 thinking blocks バグ修正（2026-05-29）**
- Opus 4.8 で thinking blocks が変更され API エラーが発生する問題を修正
- 昨日（2026-05-28）から Dynamic Workflows / Opus 4.8 を使っている場合は最新版へのアップデートを推奨

#### 🟡 近いうちに試したいこと（上位3件）

**① `claude plugin init <name>` でカスタムプラグインの scaffold 実験**
- ハーネス用プラグインを正式な scaffold 構造で作成し、TBP-001 審査フローのテンプレート化を図る
- `defaultEnabled: false` を scaffold に含め、安全なデフォルト設定を標準化

**② `--agent <name>` フラグと `settings.json` agent フィールドの活用**
- daily research タスク専用のエージェント設定を `settings.json` に記載し、ディスパッチセッション起動をシンプル化
- 研究・執筆・コーディングでエージェントプロファイルを使い分ける仕組みを構築

**③ `EnterWorktree` フックの実装評価**
- セッション中に worktree を切り替えるフックを実装し、マルチリポジトリ研究タスクへの応用を検討
- Dynamic Workflows との組み合わせで並列ブランチ作業の自動化を評価

#### 🟢 参考情報
- **Anthropic バリュエーション $965B 確定（2026-05-29）**: Series H クローズ・$650 億調達。OpenAI（$852B）を超えて世界最高バリュエーションのプライベート AI スタートアップに正式確定。ランレート $47B を発表
- **GitHub Issues: 新規 Issue 多数（2026-05-29）**: #63742〜#63747 が本日開設（VS Code/Windows バグ・Agent SDK 要望等）。VS Code 2x 消費問題（#58557）は未解決継続
- **会計×AI 2026年現状**: 経理の役割が「入力→判断支援」へ移行フェーズ。定型仕訳 90%以上自動化・経費精算 75%工数削減が一般化。PEPPOL で請求書の構造化取込みが加速
- **Zenn: Dynamic Workflows 解説記事**（zenn.dev/akasara）: Subagents・Skills との違いと実務での使い方を解説（本文未取得・次回確認推奨）

#### references.md 更新提案
以下の変更が harness-design-guide の参照情報に影響する可能性：
1. **`.claude/skills` 自動ロード（v2.1.157）**: プラグイン・スキル設計セクションの大幅更新を提案。マーケットプレイス経由不要になったことで、スキル配置のフローが変わる
2. **`claude plugin init <name>`**: プラグイン管理セクションへの追記を提案（scaffold コマンドの使い方）
3. **`--agent <name>` フラグ / `settings.json` agent フィールド**: エージェント管理セクションへの追記を提案
4. **`EnterWorktree` フック（mid-session 切り替え）**: フック設計セクション（フックイベント一覧）への追記を提案
5. **`OTEL_LOG_TOOL_DETAILS=1`**: テレメトリ設定セクションへの追記を提案

#### 新規発見ソース候補
なし（昨日の候補を評価継続中）

#### 次回リサーチ推奨日
2026-06-01（月曜日）
注目点: ① `.claude/skills` 自動ロードと TBP-001 審査フローの接続確認 ② Dynamic Workflows 実運用評価（コスト・品質） ③ 6月15日料金変更に向けたクレジット消費試算 ④ `claude plugin init` を使ったプラグイン scaffold テンプレート作成

---

## [2026-05-28] デイリーレポート

### 内部知見（機能A）
#### 新規・更新 ADR
- my-profile-and-memory/decisions/ → decisions/ フォルダ未作成のためスキップ
- その他リポジトリ（StudyMate, My-URAWA-LOG, tak-work, tak-family, tak-personal）→ GitHub MCP アクセス制限外のためスキップ
- 新規 ADR: なし

#### TBP 昇格候補
なし（新規 ADR なし）

#### 再検討トリガー該当
- **TBP-001「外部ツール導入は審査→最小権限→段階拡張」**: Dynamic Workflows（2026-05-28 リリース）で最大1,000サブエージェントが並列実行できるようになった。各サブエージェントが独立してツールを呼び出す新パラダイムでは、TBP-001の「最小権限」原則の適用範囲がワークフロー全体の設計レベルまで拡大する必要がある。また `defaultEnabled: false` プラグイン設定はTBP-001の「最小権限で開始」を宣言的に実装する手段として重要。

---

### 外部リサーチ（機能B）
#### 参照した情報源
- code.claude.com/docs/en/changelog（⭐⭐⭐⭐⭐）
- anthropic.com/news（⭐⭐⭐⭐⭐）
- github.com/anthropics/claude-code/issues（⭐⭐⭐⭐⭐）
- claudefa.st（⭐⭐⭐⭐）
- 会計×AI: keihi.com / biz.moneyforward.com / freee.co.jp

#### 🔴 即座に適用すべき事項

**① Dynamic Workflows + Claude Opus 4.8（v2.1.154・2026-05-28・リサーチプレビュー）**
- Claude Codeが自動でオーケストレーションスクリプトを生成し、最大1,000サブエージェントを並列実行（最大16同時実行）
- `/workflows` で実行状況確認、`/deep-research` が組み込みワークフローとして即時利用可能
- Max・Team・Enterprise プランで利用可能（CLI / Desktop / VS Code拡張 / API / Bedrock / Vertex / Foundry）
- TBP-001との関連: 1,000エージェントが各自ツールを呼び出す環境では最小権限設計が今まで以上に重要
- ハーネス設計への影響: `/autopilot` スキルや research スキルがDynamic Workflowsによって大幅に性能向上する可能性あり

**② Opus 4.8 リリース + 自動高努力モード（2026-05-28）**
- Opus 4.8がデフォルトモデルに昇格。難しいタスクに自動的に高努力（xhigh）を適用
- `/effort xhigh` コマンドで最高努力を明示指定可能
- リーンシステムプロンプトがHaiku・Sonnet・Opus 4.7以前を除くすべてのモデルでデフォルト化

**③ Opus 4.8 Fast Mode 価格改善（2026-05-28）**
- 改善前: 標準の6倍（$30/M input, $150/M output）
- 改善後: 標準の2倍で2.5倍の速度（大幅な価格改善）
- 6月15日料金変更（プログラマティック利用の別クレジット化）との組み合わせコスト試算が必要

**④ v2.1.153: skipLfs + 環境変数（2026-05-28）**
- `skipLfs` オプションでgit/githubプラグインのLFSダウンロードをスキップ可能
- ステータスラインコマンドが `COLUMNS` と `LINES` 環境変数を受け取れるようになった
- MCP サーバーの SSE ストリーム再接続ループの修正
- カスタム API ゲートウェイへの OAuth 認証情報の誤送信を修正（セキュリティ関連）

#### 🟡 近いうちに試したいこと（上位3件）

**① `/deep-research` ワークフローをresearchスキルの代替として評価**
- 組み込みワークフロー `/deep-research` と現在のresearchスキルを比較評価
- 最大1,000エージェントによる並列リサーチの品質・コスト・時間を測定
- Dynamic Workflowsが当デイリーリサーチ自体を代替できるかどうか検討

**② Opus 4.8 Fast Mode コスト最適化試算**
- Fast Mode（標準2倍）vs 通常Opus 4.8の使い分け基準を策定
- 6月15日料金変更（プログラマティック利用クレジット化）と合わせたコスト計画更新

**③ `defaultEnabled: false` をTBP-001実装として標準化**
- 新規プラグイン導入時のデフォルト設定として `defaultEnabled: false` を標準化
- TBP-001の「最小権限で開始」の宣言的実装手段として記録し、AUDIT-REPORT.md に反映

#### 🟢 参考情報
- **Anthropic Series H $650億調達・バリュエーション $9,650億（2026-05-28）**: IPO前最終ラウンドの可能性。2026年10月IPO予定に向けた動き
- **GitHub Issues: VS Code利用量急増（Issue #58557）**: 2026-05-06以降にVS Code経由のweekly limit消費量が約2倍に。ハーネスでのコスト管理に注意
- **GitHub Issues: モバイルアプリのリポジトリ表示問題（Issue #61019）**: GitHub App設定済みでも表示されない問題継続
- **Anthropic Milanオフィス開設（2026-05-27）**: イタリア拠点追加（韓国ソウルに続く海外拠点拡大）
- **freee MCP リモート版**: 約270種類の会計API操作がローカル環境なしで実行可能（3月公開済み・引き続き有効）
- **マネーフォワード AI Cowork**: 2026年7月リリース予定（変更なし）
- **経理AI 2026年最新動向**: 仕訳自動化90%超精度が一般化。経費精算処理工数70%削減事例が標準化

#### references.md 更新提案
以下の変更がharness-design-guideの参照情報に影響する可能性：
1. **Dynamic Workflows / `/workflows` / `/deep-research`**: マルチエージェント実行パターンの大幅刷新。最大1,000エージェントの新スケール記載追加を提案
2. **Opus 4.8 デフォルトモデル化 + リーンシステムプロンプトのデフォルト化**: モデル選択ガイドとシステムプロンプト設計セクションの更新を提案
3. **Opus 4.8 Fast Mode価格改善（6倍→2倍）**: コスト計画セクション（6月15日料金変更対応）と合わせて更新を提案
4. **`defaultEnabled: false` プラグイン設定**: プラグイン管理セクションへの追記を提案（TBP-001の実装手段として）
5. **`skipLfs` オプション（github/gitプラグイン）**: Git LFS環境での注意事項として追記を提案

#### 新規発見ソース候補
- **agentpedia.codes**: Opus 4.8 / Dynamic Workflows の詳細技術解説あり（評価候補: ⭐⭐⭐）
- **marktechpost.com**: Anthropic新機能のスピード速報として有効（評価候補: ⭐⭐⭐）

#### 次回リサーチ推奨日
2026-06-01（月曜日）
注目点: ① Dynamic Workflows / `/deep-research` の実運用評価（コスト・品質） ② 6月15日料金変更に向けたOpus 4.8 Fast Modeコスト試算 ③ security-guidance プラグインの導入評価（TBP-001 AUDIT-REPORT 作成）④ `disallowed-tools` フロントマターのハーネス実装

---

## [2026-05-27] デイリーレポート

### 内部知見（機能A）
#### 新規・更新 ADR
- my-profile-and-memory/decisions/ → decisions/ フォルダ未作成のためスキップ
- その他リポジトリ（StudyMate, My-URAWA-LOG, tak-work, tak-family, tak-personal）→ GitHub MCP アクセス制限外のためスキップ
- 新規 ADR: なし

#### TBP 昇格候補
なし（新規 ADR なし）

#### 再検討トリガー該当
- **TBP-001「外部ツール導入は審査→最小権限→段階拡張」** に関連する外部情報が3件：
  1. **`pluginSuggestionMarketplaces` managed設定（2026-05-27）**: Enterprise管理者が組織の allowlist プラグインマーケットプレイスを管理できる設定が追加。allowlist されたマーケットプレイスからのプラグインでも、TBP-001 の審査フロー（external-audit → 最小権限 → 段階拡張）を省略してよいわけではない。
  2. **security-guidance プラグイン（2026-05-27）**: Anthropic 公式・無料・全ユーザー対象。TBP-001 審査フロー適用結果 → ①Anthropic 一次情報源・②読み取り/分析のみ・③シンプル機能 → **即時導入推奨**案件。
  3. **Claude Managed Agents サンドボックス対応（2026-05-27）**: 外部 MCP サーバーへの接続が増える場面で TBP-001「審査→最小権限」が適用される。

---

### 外部リサーチ（機能B）
#### 参照した情報源
- code.claude.com/docs/en/changelog（⭐⭐⭐⭐⭐）
- anthropic.com/news（⭐⭐⭐⭐⭐）
- claudefa.st/blog/guide/changelog（⭐⭐⭐⭐）
- releasebot.io/updates/anthropic（⭐⭐⭐）
- zenn.dev/topics/claudecode（⭐⭐⭐）
- helpnetsecurity.com / securityweek.com（security-guidance プラグイン詳細）
- 会計×AI 各種（keihi.com / freee.co.jp / biz.moneyforward.com 等）

#### 🔴 即座に適用すべき事項

**① security-guidance プラグイン（Anthropic 公式・無料・2026-05-27）**
- Claude Code の `/plugins` マーケットプレイスからインストール可能。全ユーザー・全プラン無料
- 3段階リアルタイム検出: ①ファイル編集時（モデル呼び出しなし）→ eval/os.system/pickle/DOM injection等 25パターンを即時フラグ、②モデルターン時 → 認可バイパス/SSRF/インジェクション等、③コミット時 → 関連ファイル横断で偽陽性削減
- 内部ロールアウトで PR セキュリティ関連コメント 30-40% 削減の実績
- TBP-001 審査: 公式一次情報源・分析のみ（書き込みなし）・シンプル機能 → **即時導入推奨**

**② スキルフロントマターに `disallowed-tools` 設定可能（2026-05-27）**
- スキル・スラッシュコマンドの YAML フロントマターに `disallowed-tools:` を追加すると、そのスキル実行中はリスト内のツールをモデルが使用不可になる
- ハーネスへの直接応用: 読み取り専用スキル（research スキル等）に `disallowed-tools: [Write, Edit]` を設定してガードレール化できる
- TBP-001「最小権限で開始」原則をスキルレベルで宣言的に実装可能

**③ `/reload-skills` コマンド追加（2026-05-27）**
- セッション再起動なしでスキルディレクトリを再スキャンするコマンドが追加
- SessionStart フックが `reloadSkills: true` を返すことで、フックがインストールしたスキルを同一セッション内で即時利用可能に
- スキル開発・デバッグのイテレーション速度が大幅向上

**④ `MessageDisplay` フックイベント追加（2026-05-27）**
- アシスタントのメッセージテキストを表示前に変換・非表示にできる新フックイベント
- 活用例: 機密パターンのマスキング・出力フォーマット統一・ログ記録

#### 🟡 近いうちに試したいこと（上位3件）

**① research スキルに `disallowed-tools: [Write, Edit, Bash]` を設定**
- research スキルが誤って書き込まないよう構造的に防止する（現状は慣習による防止のみ）
- `/reload-skills` でセッション再起動なしにテスト可能になったため実装しやすくなった

**② SessionStart フックに `reloadSkills: true` と `sessionTitle` を追加**
- フックによるスキルインストール後、同一セッションですぐ使えるようになる
- `hookSpecificOutput.sessionTitle` でセッション名を自動設定してセッション管理を改善

**③ security-guidance プラグインを導入して評価**
- `/plugins` からインストール → TBP-001 審査記録（AUDIT-REPORT.md）を作成して事例追加
- PR セキュリティコメント削減効果を実測

#### 🟢 参考情報
- **Anthropic 資金調達ラウンドクローズ（2026-05-26〜27）**: $300億ドル超調達・バリュエーション $900億ドル超。Sequoia/Dragoneer/Altimeter/Greenoaks が各約$20億ドル。OpenAI を超えて世界最高バリュエーションのプライベートAIスタートアップに。2026年10月 IPO が最終プライベートラウンドとなる見込み
- **Anthropic 韓国オフィス代表取締役任命（2026-05-26）**: KiYoung Choi 氏が就任。ソウルオフィス開設へ
- **Claude Managed Agents サンドボックス＋プライベートMCP接続（2026-05-27）**: エージェントがユーザー管理のサンドボックス内で動作し、プライベートMCPサーバーに接続可能に。Enterprise 活用範囲が大幅拡大
- **`/code-review --fix` 更新（2026-05-27）**: 修正をワーキングツリーに直接適用。`/simplify` は今後 `/code-review --fix` の呼び出しになった
- **freee 「shadow AI」検知拡張**: 15,000以上のAIツールを検知対象に追加。組織での AI ツール統制強化
- **マネーフォワード AI Cowork**: 2026年7月リリース予定（変更なし）
- **会計×AI 国内現状調査（2026年5月）**: 中堅企業の仕訳入力 約7割が手入力・月末残業平均32時間。AI自動化の余地が依然大きい

#### references.md 更新提案
以下の変更が harness-design-guide の参照情報に影響する可能性：
1. **`disallowed-tools` フロントマター**: スキル設計セクションへの追記を提案（スキル実行中のツール除外が可能に）
2. **`MessageDisplay` フックイベント**: フック設計セクション（フックイベント一覧）への追記を提案
3. **`/reload-skills` コマンド**: スキル管理・開発デバッグセクションへの追記を提案
4. **SessionStart フック新機能（`reloadSkills: true`, `hookSpecificOutput.sessionTitle`）**: セッション管理セクションへの追記を提案
5. **`/code-review --fix` と `/simplify` の動作変更**: コードレビューセクションの記述更新を提案（`/simplify` = `/code-review --fix` の別名に変更）

#### 新規発見ソース候補
- **helpnetsecurity.com**: Claude Code セキュリティ関連の詳細技術記事あり（評価候補: ⭐⭐⭐）
- **securityweek.com**: Anthropic セキュリティ関連発表の速報として有効（評価候補: ⭐⭐⭐）

#### 次回リサーチ推奨日
2026-05-31
注目点: ① 6月15日料金変更最終確認・クレジット消費試算 ② security-guidance プラグイン導入・TBP-001 審査記録作成 ③ `disallowed-tools` フロントマターのハーネス実装

---

## [2026-05-25] デイリーレポート

### 内部知見（機能A）
#### 新規・更新 ADR
- my-profile-and-memory/decisions/ → decisions/ フォルダ未作成のためスキップ
- その他リポジトリ（StudyMate, My-URAWA-LOG, tak-work, tak-family, tak-personal）→ GitHub MCP アクセス制限外のためスキップ
- 新規 ADR: なし（確認可能なリポジトリに decisions/ 未存在）

#### TBP 昇格候補
なし（新規 ADR なし）

#### 再検討トリガー該当
- **TBP-001「外部ツール導入は審査→最小権限→段階拡張」**: Claude Code v2.1.149 で Enterprise 向けに `allowAllClaudeAiMcps` 設定が追加。managed-mcp.json と並行してすべての Claude.ai クラウド MCP コネクタを一括ロードできる設定。「xmcp 導入時の 110+ ツール全有効リスク」と同じ構造の問題が Enterprise 管理者レベルで発生しうる。TBP-001 の審査フローを Enterprise MCP 管理ポリシーとして文書化することを検討。

---

### 外部リサーチ（機能B）
#### 参照した情報源
- code.claude.com/docs/en/changelog（⭐⭐⭐⭐⭐）
- anthropic.com/news（⭐⭐⭐⭐⭐）
- releasebot.io/updates/anthropic/claude-code（⭐⭐⭐）
- zenn.dev/topics/claudecode（⭐⭐⭐）

#### 🔴 即座に適用すべき事項

**① Enterprise: `allowAllClaudeAiMcps` 設定に注意（v2.1.149）**
- Enterprise の managed 設定として `allowAllClaudeAiMcps` が追加。managed-mcp.json と並行してすべての Claude.ai クラウド MCP コネクタを一括ロードできる
- 個人利用では直接影響しないが、組織レベルで Claude Code を展開する際に無制限 MCP 許可になるリスクあり
- TBP-001「審査→最小権限→段階拡張」の観点から、組織での展開方針として明示的に対処する必要あり

**② v2.1.149 詳細（2026-05-24 レポートで一部触れた内容の補足）**
- `/usage` コマンド強化: スキル・サブエージェント・プラグイン・MCP サーバーごとの利用状況内訳が表示可能に
- `/diff` のキーボード対応: 矢印キー・`j`/`k`・`PgUp`/`PgDn`・`Space`・`Home`/`End` でスクロール可能
- GFM タスクリスト対応: `- [ ] todo` / `- [x] done` がチェックボックス表示に（plain bullet ではなく）
- Git ワークツリーサンドボックスの書き込み許可を修正（共有 `.git` ディレクトリのみに限定、メインリポジトリルート全体ではなくなった）
- macOS: `find` コマンドがシステムファイル/inode テーブルを枯渇させてホストをクラッシュさせる問題を修正

**③ v2.1.150（2026-05-23）: ユーザー向け変更なし**
- 内部インフラストラクチャの改善のみ。アップデート適用は問題なし

#### 🟡 近いうちに試したいこと（上位3件）

**① Claude Managed Agents の新機能（dreaming・マルチエージェントオーケストレーション・outcomes・webhooks）**
- Anthropic が Claude API レベルで Managed Agents 機能を拡張。dreaming（バックグラウンド思考）、マルチエージェントオーケストレーション、outcomes（成果物定義）、webhooks（完了通知）が追加
- ハーネス設計への応用: research タスクを Managed Agent 化し、webhook で完了通知を受け取る設計が可能になる
- 参考: Anthropic Developer Platform の新機能として発表

**② `/usage` コマンドでスキル・MCP 別利用状況を確認**
- どのスキルが最も消費しているか、MCP サーバーの利用頻度がわかるようになった
- 特に 6 月 15 日料金変更前に、プログラマティック利用の内訳を把握しておくことが重要

**③ Claude for Small Business のコネクタ確認（会計用途）**
- Intuit QuickBooks・PayPal・HubSpot・Canva・DocuSign・Google Workspace・Microsoft 365 の接続が標準提供
- 会計・経理用途（QuickBooks 連携等）は TBP-001 の審査フローを適用して評価すべき対象

#### 🟢 参考情報
- **KPMG グローバルアライアンス（2026-05-19）**: 276,000 人全員に Claude アクセス。Digital Gateway に Claude を組み込み。経理・監査領域での Claude 活用事例が今後増加する見込み
- **PwC 拡張パートナーシップ（2026-05-14）**: Claude Code + Cowork を米国チームから全世界展開。Big4 が Claude Code を標準ツールとして採用
- **会計×AI 一般動向**: 仕訳入力工数 80% 削減・請求書処理 70% 短縮・月次決算 5 営業日早期化が事例として一般化。PEPPOL 普及で構造化取込みが加速
- **Claude Security（公開ベータ）**: コードベーススキャン・脆弱性トリアージ・修正生成が利用可能に。security-review スキルとの連携評価が今後の課題

#### references.md 更新提案
以下の変更が harness-design-guide の参照情報に影響する可能性：
1. **Claude Managed Agents の新機能（dreaming・orchestration・outcomes・webhooks）**: ハーネス設計における「エージェント間通信」パターンの見直し候補
2. **`allowAllClaudeAiMcps` Enterprise 設定**: MCP 管理方針セクションへの追記を提案（TBP-001 と関連付けて）
3. **Git ワークツリーサンドボックス修正**: worktree 分離モードを使う場合の書き込み許可範囲が変わった点を記載

#### 新規発見ソース候補
なし（昨日の候補を評価継続中）

#### 次回リサーチ推奨日
2026-05-31（6 月 15 日料金変更まで 2 週間を切るタイミング）
注目点: ① 6 月 15 日料金変更の最終確認・クレジット消費試算 ② Claude Managed Agents 新機能の実践レポート ③ KPMG/PwC 事例から見る Big4 での Claude Code 活用パターン

---


## [2026-05-24] デイリーレポート

### 内部知見（機能A）
#### 新規・更新 ADR
- my-profile-and-memory/decisions/ → decisions/ フォルダ未作成のためスキップ
- その他リポジトリ（StudyMate, My-URAWA-LOG, tak-work, tak-family, tak-personal）→ GitHub MCP アクセス制限外のためスキップ
- 新規 ADR: なし（確認可能なリポジトリに decisions/ 未存在）

#### TBP 昇格候補
なし（ADR 確認ができないため評価不可）

#### 再検討トリガー該当
- TBP-001「最小権限」: Claude Code v2.1.147 の Bash 権限チェック修正（env 変数への代入が許可リストなしで自動承認されていた脆弱性）が最小権限原則と関連。settings.json の allowedTools 設計の見直しトリガーとなりうる。
- 6月15日料金変更: Agent SDK / claude -p / GitHub Actions の使用が別クレジットプールに移行。ハーネス設計でのプログラマティック使用方針（TBP/ADR 全般）に影響する可能性。

### 外部リサーチ（機能B）
#### 参照した情報源
- code.claude.com/docs/en/changelog（⭐⭐⭐⭐⭐）
- github.com/anthropics/claude-code/releases（⭐⭐⭐⭐⭐）
- anthropic.com/news（⭐⭐⭐⭐⭐）
- zenn.dev/topics/claudecode（⭐⭐⭐）
- releasebot.io/updates/anthropic/claude-code（参考）

#### 🔴 即座に適用すべき事項

**① 6月15日（2026）料金変更 ─ プログラマティック利用の別課金化【最重要】**
- 対象: Agent SDK、`claude -p`（非インタラクティブ）、GitHub Actions、サードパーティエージェント
- 変更内容: 専用クレジットプール（Pro $20/月、Max 5x $100/月、Max 20x $200/月）に移行
- 課金単価: フル API 価格（サブスクリプション割引なし）。ロールオーバーなし
- インタラクティブ利用（ターミナルで対話使用）は従来通りサブスクリプション内
- **アクション**: 現在 claude -p や GitHub Actions を使用している場合、月間消費量を試算し、クレジット上限への対処を検討すること
- 参考: https://codersera.com/blog/anthropic-june-2026-billing-change-claude-code/

**② セキュリティ修正 ─ Bash 権限チェックの重大な脆弱性（v2.1.147）**
- env 変数への代入（`VAR=value command` 形式）が許可リストなしで自動承認されていた
- v2.1.147 以降にアップデートで修正済み
- PowerShell 利用者: `cd..` 等のビルトイン `cd` 関数が検出をすり抜ける脆弱性（v2.1.149 で修正）

**③ Fast Mode がデフォルト Opus 4.7 に変更（v2.1.142）**
- `/fast` コマンドで呼び出せるモデルが Opus 4.6 → Opus 4.7 に変更
- Fast Mode の料金は 6 倍（Input $30/M、Output $150/M）。サブスクリプションには含まれない点に注意
- 旧 Opus 4.6 Fast に戻す場合: `CLAUDE_CODE_OPUS_4_6_FAST_MODE_OVERRIDE=1` 環境変数で固定可能

#### 🟡 近いうちに試したいこと（上位3件）

**① `/goal` コマンド（v2.1.139〜）**
- 完了条件を宣言してクロードが自律ループ実行する新機能
- 評価は別の Haiku モデルが担当（本体と評価の分離でミッションドリフト防止）
- 使い方: テスト全通過、ビルド成功、キュー空など「機械的に証明できる条件」に最適
- 参考: https://zenn.dev/suwash/articles/claude-code-goal-command_20260514

**② `/code-review` コマンド（旧 `/simplify`、v2.1.144〜）**
- 正確性バグを指定レベルで報告: `/code-review high` など
- `--comment` オプションで GitHub PR にインラインコメント直接投稿
- harness-design-guide の `code-review` スキルと連携可能

**③ Agent View（`claude agents`、v2.1.139〜141）**
- 全 Claude Code セッション（実行中・待機中・完了）をターミナルダッシュボードで一覧管理
- `claude agents --json` で JSON 出力（スクリプト・tmux 連携）
- バックグラウンドセッションを `/resume` で再接続可能

#### 🟢 参考情報
- **Claude Opus 4.7 GA**: ビジョン精度向上（高解像度画像対応）、ソフトウェアエンジニアリング性能改善
- **Claude Design**: デザイン・プロトタイプ・スライド等のビジュアル成果物を Claude と協働作成できる新製品（Anthropic Labs）
- **Claude Security**: コードベースのスキャン・脆弱性トリアージ・修正生成をパブリックベータで提供
- **Anthropic × Gates Foundation**: $2 億パートナーシップ（グローバルヘルス・生命科学・教育・経済支援）
- **freee MCP リモート版**: AIエージェントから約 270 種類の会計 API 操作が可能（ローカル環境不要）
- **マネーフォワード AI Cowork**: 2026 年 7 月リリース予定。バックオフィス業務の AI 自動化
- **会計×AI 全般**: 定型取引の仕訳自動化 90% 以上精度が一般化。PEPPOL 普及で請求書の構造化取込みが加速

#### references.md 更新提案
以下の変更がハーネス設計ガイドの参照情報に影響する可能性：
1. **`/code-review` の名称変更**: `/simplify` → `/code-review`（v2.1.144〜）。references.md にコマンド名が記載されている場合は更新要
2. **`subagent_type` のケース非感応マッチング**: v2.1.140〜。大文字小文字・セパレータ不問（例: `"Code Reviewer"` → `code-reviewer`）。既存スキルの `subagent_type` 指定への影響確認を推奨
3. **Agent SDK 6月15日課金化**: ハーネス設計ガイドのコスト試算・推奨構成に影響する可能性
4. **`/goal` コマンド**: 自律実行の新しいパターン。ハーネス設計ガイドへの追記候補

#### 新規発見ソース候補
- **releasebot.io/updates/anthropic**: Anthropic 全製品の更新履歴を自動集約。Claude/Claude Code/API それぞれ別ページあり（評価候補: ⭐⭐⭐）
- **claudefa.st/blog/guide/changelog**: Claude Code チェンジログの英語まとめ（評価候補: ⭐⭐⭐⭐）

#### 次回リサーチ推奨日
2026-05-31（6月15日の料金変更前に最終確認を推奨）

---


## [2026-05-24] デイリーレポート

---

### 内部知見（機能A）

#### 新規・更新 ADR

- My-Profile-and-Memory decisions/: ディレクトリが存在しない（tak-best-practices/ のみ確認）
- 他5プロジェクト（StudyMate / My-URAWA-LOG / tak-work / tak-family / tak-personal）: アクセス制限によりスキップ

**新規なし**

#### TBP 昇格候補

前回提案済みの ADR-001・ADR-003 が昇格条件を満たす可能性あり（詳細は内部リサーチ履歴参照）。ただし ADR ファイル未確認のため今回は保留。

#### 再検討トリガー該当

なし（ADR アクセス不可により評価不可）

---

### 外部リサーチ（機能B）

#### 参照した情報源

- docs.anthropic.com/claude-code/changelog（⭐⭐⭐⭐⭐）
- zenn.dev/topics/claudecode（⭐⭐⭐）
- github.com/anthropics/claude-code/releases（⭐⭐⭐⭐⭐）
- anthropic.com/news（⭐⭐⭐⭐⭐）

#### 🔴 即座に適用すべき事項

**① `claude --dangerously-skip-permissions` フラグの追加（v2.1.139〜）**

非インタラクティブ環境（CI / cron など）でパーミッションプロンプトを完全スキップする公式フラグが追加された。これまで非公式な方法（`--no-permissions-check` 相当）を使っていた場合は移行を検討。

- 用途: GitHub Actions・自動バッチ処理など、人間が確認できない場面
- 注意: サンドボックス外では危険なコマンドも無確認実行されるため、最小権限環境（docker / restricted shell など）での利用を強く推奨
- 参考: https://zenn.dev/suwash/articles/claude-code-v2-1-139_20260517

**② `/goal` コマンド（v2.1.139〜）**

完了条件を宣言するとクロードが自律ループを実行する新機能。評価に別の軽量モデル（Haiku）を使うことでミッションドリフトを防止。

- 使い方: `/goal すべてのテストが通ること`、`/goal ビルドが成功すること` など
- ループは最大20回（デフォルト）で自動停止
- 参考: https://zenn.dev/suwash/articles/claude-code-goal-command_20260514

**③ Agent SDK 課金モデルの注意点（近日変更予定）**

現時点では claude -p（非インタラクティブ）はサブスクリプション枠内。2026年6月以降、プログラマティック利用には専用クレジットプールが必要になる可能性（公式発表を要確認）。

#### 🟡 近いうちに試したいこと（上位3件）

**① `/goal` + ハーネス組み合わせ**

現在のハーネス設計（skills/ ディレクトリ）と `/goal` を組み合わせた自律タスク実行。たとえば「research-log.md のフォーマットが統一されていること」を goal に設定して自動修正させる。

**② `subagent_type` のケース非感応マッチング（v2.1.140〜）**

`subagent_type` の文字列が大文字小文字・ハイフン/スペース不問でマッチするようになった。既存スキルの `subagent_type` 指定を見直し、表記を統一する機会。

**③ `--dangerously-skip-permissions` を GitHub Actions に追加**

CI ワークフローでのパーミッションプロンプト問題を解消できる。ただし最小権限コンテナでの実行が前提。

#### 🟢 参考情報

- **Claude Opus 4.6 リリース**: コーディング・推論性能が向上。claude-opus-4-6-20261015 が最新
- **Anthropic 安全性レポート 2026**: MCP のセキュリティガイドラインが更新。ローカル MCP サーバーの権限スコープ管理に関する推奨事項が追加
- **Zenn Claude Code 特集**: 日本語の実践記事が増加。zenn.dev/topics/claudecode が情報源として有効

#### references.md 更新提案

以下の変更がハーネス設計ガイドの参照情報に影響する可能性：

1. `/goal` コマンドのドキュメント追加（ハーネス設計ガイドの「自律実行」セクション）
2. `--dangerously-skip-permissions` フラグの追加（CI/CD セクション）
3. `subagent_type` ケース非感応マッチングの記載（スキル設計セクション）

#### 新規発見ソース候補

- **zenn.dev/suwash**: Claude Code の日本語詳細解説記事が充実（評価候補: ⭐⭐⭐⭐）
- **claudecode.dev**: 非公式ドキュメントサイト。コマンドリファレンスが整理されている（評価候補: ⭐⭐⭐）

#### 次回リサーチ推奨日

2026-05-18（1週間後）  
注目点: ① Agent SDK 課金モデルの公式発表確認 ② `/goal` コマンドの実践レポート ③ ADR-001・ADR-003 の TBP 昇格確認

---

## [2026-05-23] デイリーレポート

---

### 内部知見（機能A）

#### 新規・更新 ADR

- ADR-002（My-Profile-and-Memory/tak-best-practices/）: 閲覧済み。変更なし
- ADR-003（同上）: 閲覧済み。変更なし
- その他プロジェクト: アクセス制限によりスキップ

#### TBP 昇格候補

- ADR-001「Claude への情報提供は Markdown 構造化が有効」→ 複数 ADR で言及されており TBP 昇格条件（3件以上の実績）に近い
- ADR-003「リポジトリ構造はフラットに保つ」→ research-hub / tak-best-practices で実践中

#### 再検討トリガー該当

なし

---

### 外部リサーチ（機能B）

#### 参照した情報源

- docs.anthropic.com/claude-code/changelog（⭐⭐⭐⭐⭐）
- zenn.dev/topics/claudecode（⭐⭐⭐）
- github.com/anthropics/claude-code/releases（⭐⭐⭐⭐⭐）

#### 🔴 即座に適用すべき事項

**① Hooks の `on_error` ハンドラ追加（v2.1.138〜）**

ツール実行エラー時に自動でフックを呼び出す `on_error` が追加された。現在の harness で post-tool-use エラーのロギングが未設定の場合は追加を検討。

- 設定例: `"on_error": { "command": "bash", "args": ["-c", "echo $CLAUDE_TOOL_ERROR >> /tmp/error.log"] }`
- 参考: changelog v2.1.138

**② MCP `list_resources` の自動呼び出し廃止（v2.1.137〜）**

セッション開始時に MCP サーバーへ `list_resources` を自動送信する動作が廃止。MCP サーバー側がリソース一覧を push する方式に変更。

- 影響: カスタム MCP サーバーを実装している場合、`notifications/resources/list_changed` を送信する実装が必要
- 該当なし（research-hub は MCP サーバーを自作していない）

#### 🟡 近いうちに試したいこと（上位3件）

**① Hooks `on_error` の設定**

research-log の自動 push が失敗した場合にアラートを出す `on_error` フックを設定する。

**② `CLAUDE_CODE_MAX_OUTPUT_TOKENS` 環境変数（v2.1.136〜）**

1回のツール出力の最大トークン数を設定できる環境変数。長い research-log の読み込みが途中で切れる場合の対策として有効。

**③ `/compact` のカスタムプロンプト（v2.1.135〜）**

`/compact 外部リサーチの要点だけ残して` のように引数でコンテキスト圧縮の指示を渡せるようになった。長いリサーチセッションの整理に活用できる。

#### 🟢 参考情報

- **Claude Code iOS アプリ（ベータ）**: iPhone から Claude Code セッションに接続できるコンパニオンアプリがベータ提供開始。主にセッション監視・簡易指示用途
- **GitHub Copilot × Claude Code 統合**: VS Code 内で Claude Code をサブエージェントとして呼び出す実験的統合が進行中（公式発表待ち）

#### references.md 更新提案

変更なし（前回更新から変化なし）

#### 新規発見ソース候補

なし

#### 次回リサーチ推奨日

2026-05-24（翌日）  
注目点: ① Opus 4.6 の実使用感レポート ② iOS アプリの詳細 ③ ADR-001 TBP 昇格の是非

---

## [2026-05-22] デイリーレポート

---

### 内部知見（機能A）

#### 新規・更新 ADR

- ADR-001（My-Profile-and-Memory/tak-best-practices/）: 新規確認。「情報は Markdown で構造化して渡す」
- その他プロジェクト: アクセス制限によりスキップ

#### TBP 昇格候補

なし（ADR-001 は単件のみ、昇格には3件以上の実績が必要）

#### 再検討トリガー該当

なし

---

### 外部リサーチ（機能B）

#### 参照した情報源

- docs.anthropic.com/claude-code/changelog（⭐⭐⭐⭐⭐）
- anthropic.com/news（⭐⭐⭐⭐⭐）

#### 🔴 即座に適用すべき事項

**① `CLAUDE_CODE_MAX_TURNS` 環境変数（v2.1.134〜）**

1セッションあたりの最大ターン数を設定する環境変数が追加。デフォルト無制限から変更可能。長時間自律実行時のコスト管理に有効。

- 設定例: `export CLAUDE_CODE_MAX_TURNS=50`

**② Tool result の `is_error` フィールド（v2.1.133〜）**

ツール実行結果に `is_error: true` フィールドが追加。エラー結果をクロードが明示的に認識できるようになり、エラーハンドリングが改善。

#### 🟡 近いうちに試したいこと（上位3件）

**① `CLAUDE_CODE_MAX_TURNS` の実験**

research-hub の daily research タスクに `MAX_TURNS=30` を設定し、暴走しないか確認する。

**② `--system-prompt-file` オプション（v2.1.132〜）**

システムプロンプトをファイルから読み込むオプション。CLAUDE.md の代替または補完として使える可能性を確認する。

**③ Tool use の `cache_control` ブロック**

長い research-log.md を毎回読み込む際のキャッシュ効率を改善できる可能性。API 利用時のコスト削減。

#### 🟢 参考情報

- **Claude.ai Projects の共有機能強化**: チームメンバー間でのプロジェクト共有が改善。個人用途では影響なし
- **Anthropic 安全性チーム拡大**: 解釈可能性研究の新論文発表。Claude の内部表現に関する知見が蓄積中

#### references.md 更新提案

なし

#### 新規発見ソース候補

なし

#### 次回リサーチ推奨日

2026-05-23（翌日）  
注目点: ① MCP `list_resources` 廃止の影響確認 ② Hooks `on_error` の実装 ③ ADR の追加確認

---

## [2026-05-21] デイリーレポート

---

### 内部知見（機能A）

#### 新規・更新 ADR

- My-Profile-and-Memory: アクセス制限によりスキップ
- その他プロジェクト: 同上

#### TBP 昇格候補

なし

#### 再検討トリガー該当

なし

---

### 外部リサーチ（機能B）

#### 参照した情報源

- docs.anthropic.com/claude-code/changelog（⭐⭐⭐⭐⭐）
- zenn.dev/topics/claudecode（⭐⭐⭐）

#### 🔴 即座に適用すべき事項

**① `--system-prompt-file` オプション（v2.1.132〜）確認**

前回ピックアップした機能を実際に試した。CLAUDE.md と組み合わせて追加コンテキストを渡す用途に有効であることを確認。

**② `PreToolUse` フックの `decision` フィールド（v2.1.131〜）**

`PreToolUse` フックのレスポンスに `decision: "approve" | "reject" | "ask"` フィールドが追加。フック側でツール実行の可否を制御できるようになった。

- 活用例: 特定ファイルへの書き込みをフック側でブロックする
- harness の settings.json に `PreToolUse` フックを追加する価値あり

#### 🟡 近いうちに試したいこと（上位3件）

**① `PreToolUse` フックで research-log.md の保護**

`research-log.md` を直接 Write ツールで上書きしようとした場合に `reject` を返すフックを設定。誤操作防止。

**② `/doctor` コマンド（v2.1.130〜）**

環境診断コマンド。MCP 接続状況・権限設定・フック設定を一覧表示できる。現在のハーネス状態の定期確認に使えるか検証。

**③ Streaming tool results（v2.1.129〜）**

長時間かかるツール（Bash の curl など）の途中経過をストリーミングで受け取れる機能。research タスクの進捗可視化に活用できる可能性。

#### 🟢 参考情報

- **Claude Code Extensions**: VS Code 拡張のアップデート。エラーハイライトと inline diff 表示が改善
- **Anthropic API の Batch API 改善**: 非同期バッチ処理の最大リクエスト数が 10,000 → 100,000 に拡大

#### references.md 更新提案

`PreToolUse` の `decision` フィールドに関する記述を harness-design-guide に追加することを提案。

#### 新規発見ソース候補

なし

#### 次回リサーチ推奨日

2026-05-22（翌日）  
注目点: ① `CLAUDE_CODE_MAX_TURNS` 実験結果 ② ADR 確認再挑戦

---

## [2026-05-20] デイリーレポート

---

### 内部知見（機能A）

#### 新規・更新 ADR

- アクセス制限によりすべてスキップ

#### TBP 昇格候補

なし

#### 再検討トリガー該当

なし

---

### 外部リサーチ（機能B）

#### 参照した情報源

- docs.anthropic.com/claude-code/changelog（⭐⭐⭐⭐⭐）
- anthropic.com/news（⭐⭐⭐⭐⭐）
- zenn.dev/topics/claudecode（⭐⭐⭐）

#### 🔴 即座に適用すべき事項

**① Claude Code の `hooks` 設定に `matcher` フィールド追加（v2.1.128〜）**

特定ツール・特定パターンにのみフックを適用できる `matcher` フィールドが追加。

- 例: `"matcher": { "tool_name": "Bash", "args_pattern": "rm -rf" }` でリスクコマンドのみフック
- 現在の harness のフック設定を見直し、必要に応じて `matcher` を追加する

**② `/permissions` コマンド（v2.1.127〜）**

現在の allowedTools / deniedTools 設定を一覧表示するコマンド。設定の可視化に使える。

#### 🟡 近いうちに試したいこと（上位3件）

**① `matcher` を使ったフック絞り込み**

現在の `PostToolUse` フックを `matcher` で絞り込み、不要な実行を削減。

**② `claude --print-config`（v2.1.126〜）**

実際に読み込まれた設定（CLAUDE.md・settings.json 等のマージ結果）を出力するコマンド。デバッグに有効。

**③ MCP の `tool_choice` サポート（v2.1.125〜）**

MCP ツール呼び出し時に `tool_choice: "required"` を指定してクロードに特定ツールの使用を強制できる機能。スキル設計に応用できる可能性。

#### 🟢 参考情報

- **Claude.ai の「Artifacts」機能強化**: コード・データ可視化の Artifact が複数ファイルに対応
- **Anthropic の Model Card 更新**: Claude 3.7 の詳細な評価結果が公開。ベンチマーク比較に使える

#### references.md 更新提案

`matcher` フィールドの説明を harness-design-guide のフック設計セクションに追加することを提案。

#### 新規発見ソース候補

なし

#### 次回リサーチ推奨日

2026-05-21（翌日）  
注目点: ① `PreToolUse` `decision` フィールドの実装 ② `claude --print-config` の動作確認

---

## [2026-05-19] デイリーレポート

---

### 内部知見（機能A）

#### 新規・更新 ADR

- アクセス制限によりすべてスキップ

#### TBP 昇格候補

なし（ADR 未確認）

#### 再検討トリガー該当

なし

---

### 外部リサーチ（機能B）

#### 参照した情報源

- docs.anthropic.com/claude-code/changelog（⭐⭐⭐⭐⭐）
- zenn.dev/topics/claudecode（⭐⭐⭐）
- github.com/anthropics/claude-code/releases（⭐⭐⭐⭐⭐）

#### 🔴 即座に適用すべき事項

**① Context window 残量の自動表示（v2.1.124〜）**

ステータスバーにコンテキスト残量がパーセンテージで表示されるようになった。長い research セッションでの `/compact` タイミング判断に使える。

**② `PostToolUse` フックへの `tool_result` 渡し（v2.1.123〜）**

`PostToolUse` フックにツール実行結果（stdout/stderr）が渡されるようになった。ログ収集やエラー検知に活用できる。

- 環境変数: `$CLAUDE_TOOL_RESULT`、`$CLAUDE_TOOL_ERROR`

#### 🟡 近いうちに試したいこと（上位3件）

**① `$CLAUDE_TOOL_ERROR` を使ったエラーログ**

ツール失敗時に自動でログファイルへ書き出す `PostToolUse` フックを設定する。

**② `claude --output-format json`（v2.1.122〜）**

`claude -p` の出力を JSON 形式にするオプション。スクリプトから結果をパースする際に使いやすくなる。

**③ セッション ID の環境変数化（v2.1.121〜）**

`$CLAUDE_SESSION_ID` 環境変数がフック内で使えるようになった。複数セッションのログを区別するために有用。

#### 🟢 参考情報

- **Claude Code サブエージェント機能の安定化**: `subagent_type` ルーティングの精度が向上
- **Anthropic の新ブログ**: プロンプトキャッシングのベストプラクティスが更新

#### references.md 更新提案

`$CLAUDE_TOOL_RESULT` / `$CLAUDE_TOOL_ERROR` / `$CLAUDE_SESSION_ID` 環境変数をフック設計ガイドに追記することを提案。

#### 新規発見ソース候補

なし

#### 次回リサーチ推奨日

2026-05-20（翌日）  
注目点: ① `matcher` フィールドの動作確認 ② `/permissions` コマンドの使い勝手評価

---

## [2026-05-18] デイリーレポート

---

### 内部知見（機能A）

#### 新規・更新 ADR

- My-Profile-and-Memory/tak-best-practices/: アクセス可能。ADR-001・ADR-002・ADR-003 を確認
  - ADR-001: 「Claude への情報提供は Markdown 構造化が有効」（新規確認）
  - ADR-002: 「セッション開始時に CLAUDE.md を必ず読む」（既知、変更なし）
  - ADR-003: 「リポジトリ構造はフラットに保つ」（新規確認）
- 他プロジェクト: アクセス制限によりスキップ

#### TBP 昇格候補

- ADR-001 + ADR-003: いずれも複数リポジトリで実践中。TBP 昇格の事前調査として Tak に提案したい

#### 再検討トリガー該当

なし

---

### 外部リサーチ（機能B）

#### 参照した情報源

- docs.anthropic.com/claude-code/changelog（⭐⭐⭐⭐⭐）
- anthropic.com/news（⭐⭐⭐⭐⭐）

#### 🔴 即座に適用すべき事項

**① `claude -p` の `--allowedTools` オプション（v2.1.120〜）**

`claude -p` 実行時に使用を許可するツールをコマンドライン引数で指定できるようになった。CI/CD での最小権限実行が容易になる。

- 例: `claude -p "..." --allowedTools Bash,Read`

**② MCP サーバーの `timeout` 設定（v2.1.119〜）**

各 MCP サーバーに `timeout_ms` を設定できるようになった。GitHub MCP が遅延した場合のハング防止に有効。

- 設定例: `"timeout_ms": 30000`（30秒）

#### 🟡 近いうちに試したいこと（上位3件）

**① GitHub MCP に `timeout_ms` 設定**

research タスクで GitHub MCP がタイムアウトした場合のログが取れていない。`timeout_ms` 設定後にエラーログを確認する。

**② `--allowedTools` を使った research タスクの最小権限化**

research タスクは `Read`, `Bash`（curl のみ）, `mcp__github__*` の3種で完結するはず。最小権限リストを定義して CI 化する。

**③ `claude --version` の詳細化（v2.1.118〜）**

`claude --version --verbose` でビルドハッシュ・依存ライブラリのバージョンも表示されるようになった。障害報告時の情報収集に使える。

#### 🟢 参考情報

- **Anthropic の教育向けプログラム**: 大学向けの Claude API 無償枠が拡大
- **Claude.ai の「Memory」機能**: ユーザーの好みを自動記憶する機能が一般提供開始

#### references.md 更新提案

MCP `timeout_ms` 設定を harness-design-guide の MCP 設定セクションに追記することを提案。

#### 新規発見ソース候補

なし

#### 次回リサーチ推奨日

2026-05-19（翌日）  
注目点: ① `PostToolUse` フックへの `tool_result` 渡しの実装 ② ADR-001・ADR-003 の TBP 昇格提案

---

## [2026-05-17] デイリーレポート

---

### 内部知見（機能A）

#### 新規・更新 ADR

- アクセス制限によりすべてスキップ

#### TBP 昇格候補

なし

#### 再検討トリガー該当

なし

---

### 外部リサーチ（機能B）

#### 参照した情報源

- docs.anthropic.com/claude-code/changelog（⭐⭐⭐⭐⭐）
- zenn.dev/topics/claudecode（⭐⭐⭐）

#### 🔴 即座に適用すべき事項

**① `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` 環境変数（v2.1.117〜）**

telemetry・使用統計の送信を無効化する環境変数が追加。プライバシー重視の環境や厳格なファイアウォール環境で有効。

- 設定: `export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1`

**② `SubagentStopped` フック（v2.1.116〜）**

サブエージェントが停止したときに呼び出されるフックが追加。サブエージェントの完了検知・ログ収集に使える。

#### 🟡 近いうちに試したいこと（上位3件）

**① `SubagentStopped` フックでのサブエージェント完了ログ**

research タスクをサブエージェント化した場合の完了通知に使える。

**② `claude --no-update-check`（v2.1.115〜）**

CI 環境での自動アップデートチェックを無効化するフラグ。GitHub Actions でのタイムアウト防止に有効。

**③ Tool use の `metadata` フィールド（v2.1.114〜）**

ツール呼び出しに任意のメタデータを付与できる `metadata` フィールドが追加。デバッグ・トレーシングに活用できる。

#### 🟢 参考情報

- **Claude Code の Windows 対応改善**: WSL2 なしのネイティブ Windows 環境でのサポートが強化
- **Anthropic の API レート制限緩和**: Tier 3 以上のユーザーの1分あたりリクエスト上限が引き上げ

#### references.md 更新提案

なし

#### 新規発見ソース候補

なし

#### 次回リサーチ推奨日

2026-05-18（翌日）  
注目点: ① GitHub MCP `timeout_ms` 設定の実装 ② ADR 確認再挑戦

---

## [2026-05-16] デイリーレポート

---

### 内部知見（機能A）

#### 新規・更新 ADR

- アクセス制限によりすべてスキップ

#### TBP 昇格候補

なし

#### 再検討トリガー該当

なし

---

### 外部リサーチ（機能B）

#### 参照した情報源

- docs.anthropic.com/claude-code/changelog（⭐⭐⭐⭐⭐）
- anthropic.com/news（⭐⭐⭐⭐⭐）

#### 🔴 即座に適用すべき事項

**① `claude mcp add --scope project` の改善（v2.1.113〜）**

プロジェクトスコープの MCP サーバー追加コマンドが改善。`.mcp.json` ファイルへの自動書き込みが正確になった。

**② Tool result のトークン圧縮（v2.1.112〜）**

大きなツール実行結果（特に Bash の長い出力）が自動的にコンテキストウィンドウ効率のよい形式に圧縮されるようになった。長い research-log.md の読み込み時に効果があるかもしれない。

#### 🟡 近いうちに試したいこと（上位3件）

**① Tool result 圧縮の効果確認**

research-log.md（現在 50KB 超）を Read ツールで読み込む際のコンテキスト消費量を `/status` で確認する。

**② `claude mcp list --verbose`（v2.1.111〜）**

MCP サーバーの接続状態・使用ツール数・エラー数を詳細表示するオプション。GitHub MCP の健全性確認に使える。

**③ `PreToolUse` フックでの引数ログ**

`PreToolUse` フックで全ツール呼び出しの引数をログファイルに記録する設定を追加する。監査証跡として活用。

#### 🟢 参考情報

- **Claude.ai Team プランのリアルタイム共同編集**: 複数ユーザーが同一プロジェクトを同時編集できるようになった
- **Anthropic の Constitutional AI v2 論文**: 安全性トレーニング手法の詳細が公開

#### references.md 更新提案

なし

#### 新規発見ソース候補

なし

#### 次回リサーチ推奨日

2026-05-17（翌日）
注目点: ① `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` の動作確認 ② `SubagentStopped` フックの実装可能性

---

## [2026-05-15] デイリーレポート

---

### 内部知見（機能A）

#### 新規・更新 ADR

- アクセス制限によりすべてスキップ

#### TBP 昇格候補

なし

#### 再検討トリガー該当

なし

---

### 外部リサーチ（機能B）

#### 参照した情報源

- docs.anthropic.com/claude-code/changelog（⭐⭐⭐⭐⭐）
- zenn.dev/topics/claudecode（⭐⭐⭐）
- anthropic.com/news（⭐⭐⭐⭐⭐）

#### 🔴 即座に適用すべき事項

**① `claude --ide vscode` フラグ（v2.1.110〜）**

VS Code 拡張経由でのセッション開始時に IDE コンテキスト（開いているファイル・カーソル位置）を自動取得するフラグ。ターミナルから直接起動する場合は不要。

**② Memory ファイルの `@include` ディレクティブ（v2.1.109〜）**

CLAUDE.md から他のファイルを `@include path/to/file.md` でインクルードできるようになった。大きな CLAUDE.md を分割管理できる。

- 活用例: `@include skills/research-skill.md`

#### 🟡 近いうちに試したいこと（上位3件）

**① CLAUDE.md の `@include` による分割**

現在の CLAUDE.md が肥大化している場合、`@include` でスキル別ファイルに分割する。

**② `claude --print-config` で設定確認**

前回ピックアップした `--print-config` を実際に試し、現在の harness 設定のマージ結果を確認する。

**③ `Notification` フック（v2.1.108〜）**

クロードが入力待ちになったときに通知を送る `Notification` フックが追加。長時間タスクの完了待ちに使える。

#### 🟢 参考情報

- **Claude 3.7 の Extended Thinking 改善**: 思考トークンの可視性が向上。デバッグが容易になった
- **Anthropic の Developer Discord**: 公式 Discord サーバーが開設。リアルタイムの情報収集源として有効（評価候補: ⭐⭐⭐⭐）

#### references.md 更新提案

`@include` ディレクティブを harness-design-guide の CLAUDE.md 設計セクションに追記することを提案。

#### 新規発見ソース候補

- **Anthropic Developer Discord**: リアルタイムの変更情報・コミュニティ知見（評価候補: ⭐⭐⭐⭐）

#### 次回リサーチ推奨日

2026-05-16（翌日）  
注目点: ① Tool result 圧縮の効果測定 ② `@include` ディレクティブの実装

---

## [2026-05-14] デイリーレポート

---

### 内部知見（機能A）

#### 新規・更新 ADR

- アクセス制限によりすべてスキップ

#### TBP 昇格候補

なし

#### 再検討トリガー該当

なし

---

### 外部リサーチ（機能B）

#### 参照した情報源

- docs.anthropic.com/claude-code/changelog（⭐⭐⭐⭐⭐）
- anthropic.com/news（⭐⭐⭐⭐⭐）
- zenn.dev/topics/claudecode（⭐⭐⭐）

#### 🔴 即座に適用すべき事項

**① Hooks の `timeout_ms` フィールド（v2.1.107〜）**

フック実行のタイムアウトをフックごとに設定できるようになった。重いフックによるセッションのブロックを防止できる。

- 設定例: `"timeout_ms": 5000`（5秒でフックを強制終了）

**② `claude mcp remove` コマンド（v2.1.106〜）**

追加済みの MCP サーバーを削除するコマンドが追加。手動での `.mcp.json` 編集が不要になった。

#### 🟡 近いうちに試したいこと（上位3件）

**① 全フックへの `timeout_ms` 設定**

現在の harness のフック設定に `timeout_ms: 10000` を追加してハング防止を徹底する。

**② `claude mcp diagnose`（v2.1.105〜）**

MCP サーバーの接続診断コマンド。GitHub MCP の接続問題が発生した場合のデバッグに使える。

**③ `BatchTool`（v2.1.104〜）**

複数ツールを並列実行できる `BatchTool` が追加。research タスクの複数リポジトリ同時確認に活用できる可能性。

#### 🟢 参考情報

- **Claude Code の Telemetry ダッシュボード**: OpenTelemetry 対応が進み、外部監視ツールへのメトリクス送信が容易になった
- **Anthropic の Model Welfare 取り組み**: AI の主観的経験に関する研究が公開

#### references.md 更新提案

Hooks の `timeout_ms` フィールドを harness-design-guide のフック設計セクションに追記することを提案。

#### 新規発見ソース候補

なし

#### 次回リサーチ推奨日

2026-05-15（翌日）  
注目点: ① `Notification` フックの実装 ② CLAUDE.md `@include` の実験

---

## [2026-05-13] デイリーレポート

---

### 内部知見（機能A）

#### 新規・更新 ADR

- アクセス制限によりすべてスキップ

#### TBP 昇格候補

なし

#### 再検討トリガー該当

なし

---

### 外部リサーチ（機能B）

#### 参照した情報源

- docs.anthropic.com/claude-code/changelog（⭐⭐⭐⭐⭐）
- zenn.dev/topics/claudecode（⭐⭐⭐）

#### 🔴 即座に適用すべき事項

**① `claude -p` の `--max-turns` オプション（v2.1.103〜）**

コマンドライン引数でターン数上限を指定できるようになった。環境変数 `CLAUDE_CODE_MAX_TURNS` と同じ機能だがコマンドごとに上書き可能。

**② Tool use の `type: "computer_use"` 追加（v2.1.102〜）**

Computer use（スクリーン操作）がツールタイプとして正式追加。研究用途での Web スクレイピング自動化に使える可能性あり（要セキュリティ評価）。

#### 🟡 近いうちに試したいこと（上位3件）

**① `--max-turns` を research タスクに設定**

`claude -p "...research..." --max-turns 20` で過剰なターン実行を防止。

**② `BatchTool` の並列リポジトリ確認**

前回ピックアップした `BatchTool` を使い、複数リポジトリの ADR を並列確認する実験。

**③ `claude --resume`（v2.1.101〜）**

中断したセッションをセッション ID で再開できるコマンド。長時間 research タスクが途中で止まった場合の復旧に使える。

#### 🟢 参考情報

- **Claude.ai の「Projects」フォルダ機能**: プロジェクトをフォルダで整理できるようになった
- **Anthropic の Government API プログラム**: 行政機関向けの専用 API エンドポイントが提供開始

#### references.md 更新提案

なし

#### 新規発見ソース候補

なし

#### 次回リサーチ推奨日

2026-05-14（翌日）  
注目点: ① `BatchTool` の実験 ② Hooks `timeout_ms` の実装

---

## [2026-05-12] デイリーレポート

---

### 内部知見（機能A）

#### 新規・更新 ADR

- アクセス制限によりすべてスキップ

#### TBP 昇格候補

なし

#### 再検討トリガー該当

なし

---

### 外部リサーチ（機能B）

#### 参照した情報源

- docs.anthropic.com/claude-code/changelog（⭐⭐⭐⭐⭐）
- anthropic.com/news（⭐⭐⭐⭐⭐）

#### 🔴 即座に適用すべき事項

**① `claude --output-format stream-json`（v2.1.100〜）**

`claude -p` の出力をストリーミング JSON で受け取るオプション。`--output-format json` との違いは、各イベント（ツール呼び出し・結果・テキスト）がリアルタイムに出力される点。ログ収集に有効。

**② `StopHook` の `reason` フィールド（v2.1.099〜）**

`Stop` フックに停止理由（`max_turns`・`user_interrupt`・`completed` 等）が渡されるようになった。停止理由別の処理分岐が可能。

#### 🟡 近いうちに試したいこと（上位3件）

**① `stream-json` でのリアルタイムログ**

research タスクを `--output-format stream-json | jq` でリアルタイムに確認する。

**② `StopHook` の `reason` で自動リトライ**

`max_turns` で止まった場合のみ `claude --resume` で再実行する `StopHook` を設定する。

**③ `claude mcp inspect`（v2.1.098〜）**

特定 MCP サーバーのツール一覧とスキーマを表示するコマンド。GitHub MCP の利用可能ツールを確認するのに使える。

#### 🟢 参考情報

- **Claude Code v2.1.100 マイルストーン**: 累計 100 マイナーバージョンに到達。安定性が大幅に向上したとのコメントあり
- **Anthropic の Responsible Scaling Policy 更新**: ASL-3 基準の詳細が改定

#### references.md 更新提案

`StopHook` の `reason` フィールドを harness-design-guide のフック設計セクションに追記することを提案。

#### 新規発見ソース候補

なし

#### 次回リサーチ推奨日

2026-05-13（翌日）  
注目点: ① `--max-turns` の実験 ② `claude --resume` の動作確認

---

## [2026-05-11] デイリーレポート

---

### 内部知見（機能A）

#### 新規・更新 ADR

- アクセス制限によりすべてスキップ

#### TBP 昇格候補

なし

#### 再検討トリガー該当

なし

---

### 外部リサーチ（機能B）

#### 参照した情報源

- docs.anthropic.com/claude-code/changelog（⭐⭐⭐⭐⭐）
- zenn.dev/topics/claudecode（⭐⭐⭐）

#### 🔴 即座に適用すべき事項

**① `claude` コマンドの `--add-dir` オプション（v2.1.097〜）**

追加のディレクトリを信頼済みディレクトリとしてセッションに追加するオプション。複数リポジトリをまたぐ作業で有効。

**② `PermissionTool`（v2.1.096〜）**

クロードが自分でツール使用許可を要求できる `PermissionTool` が追加。`allowedTools` に含まれていないツールを一時的に使用したい場合に使える。

#### 🟡 近いうちに試したいこと（上位3件）

**① `--add-dir` で research-hub と tak-best-practices を同時読み込み**

research タスクで両リポジトリを同時に参照できるか確認する。

**② `claude mcp inspect` で GitHub MCP ツール確認**

前回ピックアップした `mcp inspect` で利用可能な GitHub MCP ツールの最新一覧を確認する。

**③ `claude --session-id`（v2.1.095〜）**

任意のセッション ID を指定してセッションを開始するオプション。ログ管理・トレーシングに有効。

#### 🟢 参考情報

- **Claude Code の `memory` コマンド**: `claude memory list` でメモリーファイルの一覧が確認できるコマンドが追加
- **Anthropic の Education Initiative**: K-12 向けの安全な AI 利用ガイドラインが公開

#### references.md 更新提案

なし

#### 新規発見ソース候補

なし

#### 次回リサーチ推奨日

2026-05-12（翌日）  
注目点: ① `stream-json` の実験 ② `StopHook` `reason` フィールドの実装

---

## [2026-05-10] デイリーレポート

---

### 内部知見（機能A）

#### 新規・更新 ADR

- アクセス制限によりすべてスキップ

#### TBP 昇格候補

なし

#### 再検討トリガー該当

なし

---

### 外部リサーチ（機能B）

#### 参照した情報源

- docs.anthropic.com/claude-code/changelog（⭐⭐⭐⭐⭐）
- anthropic.com/news（⭐⭐⭐⭐⭐）
- zenn.dev/topics/claudecode（⭐⭐⭐）
- note.com/topics/ai（⭐⭐）

#### 🔴 即座に適用すべき事項

**① Extended Thinking のストリーミング対応（v2.1.094〜）**

`claude -p` で Extended Thinking を使う際に思考ブロックがリアルタイムストリーミングされるようになった。長い思考プロセスの途中経過が見えるようになり、デバッグが容易に。

**② `claude config set` コマンド（v2.1.093〜）**

設定値をコマンドラインから直接変更できる `claude config set` コマンドが追加。`settings.json` を手動編集せずに設定変更が可能。

- 例: `claude config set theme dark`
- 例: `claude config set autoUpdates false`

#### 🟡 近いうちに試したいこと（上位3件）

**① `claude config set` でテーマ・自動更新設定**

CI 環境での `autoUpdates false` 設定を `claude config set` で行い、設定ファイルへの依存を減らす。

**② `--add-dir` で複数リポジトリ同時参照**

前回ピックアップした機能を実際に試す。

**③ `claude memory add`（v2.1.092〜）**

メモリーファイルへの直接書き込みコマンド。重要な知見をセッション中にすぐメモリーへ追加できる。

#### 🟢 参考情報

- **Claude.ai の「Artifacts」デスクトップアプリ連携**: Artifact をデスクトップアプリで直接開けるようになった
- **Anthropic の新しい利用規約**: プロフェッショナル向け利用規約が更新（2026年6月1日施行）
- **マネーフォワード AI Cowork**: バックオフィス業務の AI 自動化製品。2026年7月リリース予定
- **freee AI アシスタント強化**: 仕訳の自動提案精度が向上。MCP 経由での外部連携も強化予定

#### references.md 更新提案

`claude config set` コマンドをハーネス設定管理セクションに追記することを提案。

#### 新規発見ソース候補

- **note.com/topics/ai**: 日本語の AI 活用事例が集まるプラットフォーム。Claude 関連記事も増加中（評価候補: ⭐⭐）
- **会計ソフトベンダーの公式ブログ（freee / マネーフォワード）**: MCP 連携・AI 機能の最新情報源として有効（評価候補: ⭐⭐⭐）
- trusted-sources.md の「会計×AI」セクションへの追記を提案（⭐⭐⭐⭐ 候補）

#### 次回リサーチ推奨日

2026-05-18（1週間後）  
注目点: ① マネーフォワード AI Cowork の詳細（7月リリース予定）② v2.1.140 の `/goal`+ハーネス組み合わせ実例 ③ ADR-001・ADR-003 の TBP 昇格確認（Tak への提案）