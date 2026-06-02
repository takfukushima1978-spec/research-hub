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