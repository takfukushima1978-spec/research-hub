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
- 例: `Agent(model:opus)` で Opus サブエージェントのスポーンをブロック、`Bash(command:rm*)` で特定コマンドを弾く。
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

