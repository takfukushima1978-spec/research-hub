# Research Hub Navigator

> プロジェクトの現状ダッシュボード。
> 仕様詳細は `CLAUDE.md`、Routine 詳細は `scheduled-tasks.md`、
> 横断的な学びは global memory (`C:\dev\.claude\projects\c--dev-research-hub\memory\`) を参照。

最終更新: 2026-06-18

---

## 📊 現状サマリー

| 項目 | 値 |
|---|---|
| パイプライン状態 | ✅ **稼働中** |
| 稼働中の Routine | **5つ**（auto-research-collect / auto-claude-code-watch / deep-research-runner / feedback-article-runner / auto-research-morning-discord）+ ローカル /loop（auto-basics-fill）|
| Worker | `research-hub-relay` デプロイ済（pass-through proxy。GET /rest/v1/tags 許可済）|
| Edge Function | `insert-article`（quality_override は X-Allow-Override ヘッダー必須）|
| タクソノミー | 確定7ジャンル（accounting/keiri_dx/ai_tech/tools/business/security_risk/thinking_learning）。曜日軸ローテーション |
| 好みフィードバック | ✅ クリップ→`get_preference_profile`→Step 1.7（好み/バランス/探索）稼働（ADR-LG-009）|
| 記事フィードバック | ✅ 記事末尾💬→`article_feedbacks`→feedback-article-runner（7:30 JST）で追加記事自動生成 |
| 学習マップ | 全7ジャンル `learning_topics`（67トピック）+ Claude Code 専属 `claude_code_topics`（36）|
| 基礎記事の充実 | 🟢 着手 ~30/67（2026-06-14時点）。**thinking_learning 17/17 完成＋コア4topに発展編(deep)**。残りは ai_tech/keiri_dx/tools/business/security を自律ループ＆/loopで継続 |
| 思考学習マップ | ✅ `thinking-map.html`（**B1階層ナビ型**に作り替え 2026-06-18）。Level1マインドマップ大局図→領域ページ×4＋俗説補正/血肉化の単独ページ。**フェーズB完了**（Web調査で出典・効果量・再現性を検証→確証度再判定: メタ認知/認知バイアス🟢→🟡、自己説明🟡→🟢 等）。**フェーズC完了**（全17トピックを articles Edge Function の記事ビューワーへリンク、21リンク全200確認）。内容SSOT: `docs/thinking-learning-worldview.md` §7検証/§8記事マップ |
| 通知チャネル | Discord `#research-hub-notify` で稼働確認済 |
| 直近の問題 | DR 自動 completed 現象（要 Phase 2 調査）|

## 🎯 直近の重点

- **feedback-article-runner 初回稼働観察**（2026-06-13 7:30 JST〜）。記事末尾フィードバックが翌朝の追加記事生成に繋がるかエンドツーエンド確認
- **好みフィードバック・ループ稼働観察**。Step 8 サマリの系統分布（好み/バランス/探索）とジャンル占有上限40%が機能するか
- 不調が出なければ Phase 2 (UI スタンプラリー + Discord 進捗バー) に着手

## 📋 残タスク (Phase 2)

0. **【保守・次回優先】秘密設定ファイルを git 射程外へ退避**（2026-06-13 中断）
   - 真因確定: `.supabase-config` 消失は OneDrive ではなく **tak-work（git リポ）内の gitignore 秘密ファイルが backup 無し**だったため（git clean 等で消えうる）。memory [[secret-config-file-disappeared]] 参照
   - 対応: `.supabase-config` / `.discord-config` を `C:\dev\.secrets\` 等（どの git リポにも属さないパス）へ移動
   - **要・全参照更新**: `scripts/generate-console-ready.mjs`（ハードコードパス）/ `CLAUDE.md` 設定ファイル表 / `scheduled-tasks.md` ローカル予備節 / navigator 本ファイル / **tak-work 側 `05_gmail_to_supabase.py`（別リポ・要編集）**
   - 移動後に `node scripts/generate-console-ready.mjs auto-research-collect` で疎通確認

0b. **テスト記事 `DIAGNOSTIC_TEST_REJECTED` のクリーンアップ**（2026-06-13 中断・未着手）
   - id=`baab732f-81b3-4e9f-a814-8d2b4eb86287`、summary="test"。ビューワーに表示され続ける残骸
   - 削除前に中身確認 → status を archived 化 or 削除（articles の RLS / 削除手段を要確認。専用 RPC 無し）

1. **学習マップ スタンプラリー UI**
   - `index.html` に「🎯 学習マップ」タブ追加
   - 領域別カードで進捗バー表示、サブトピックは clickable で関連記事リンク
   - 関連 RPC: `get_claude_code_coverage_summary`

2. **Discord 通知に学習マップ進捗バー埋め込み**
   - `auto-research-morning-discord` の embed に「🎯 X/36 (Y%)」表示
   - 領域別の差分も提示（前日 → 今日の覆い率）

3. **Discord フィードバックループ復活**
   - Discord メッセージに 1-5 reaction を Bot で自動付与
   - Reaction Events を Cloudflare Workers Bot で受信 → `user_feedback` テーブルに記録
   - auto-research-collect の翌朝リサーチで feedback を読み取って優先度反映
   - 関連 memory: [[discord-webhook-notification-pattern]]

4. **ビューワー index.html を URL hash 対応に**
   - `index.html#article=<slug>` で個別記事ページに直リンク可能にする
   - Discord embed の `url` フィールドを slug ベースに切替
   - メール / Discord から記事を1タップで開けるようにする

5. **DR 自動 completed 現象の調査**
   - auto-research-collect が `action=request` した直後、同セッション内で DR が completed になっている
   - 関連 memory: [[dr-self-completion-mystery]]
   - Run 詳細ログ + `supabase/functions/deep-research/index.ts` ソース再読
   - 必要ならプロンプトに「complete アクションは呼ぶな」を明示

6. ~~**思考学習マップ フェーズB/C**~~ → ✅ **完了（2026-06-18）**
   - **フェーズB完了**: research サブエージェント4並列で各トピックの出典・効果量・再現性をWeb検証→確証度を再判定（SSOT §7）。主な変更: メタ認知/認知バイアス🟢→🟡（再現危機・debiasing困難）、システム思考🔵→🟡、自己説明🟡→🟢（g=0.66）、Zettelkasten手法は🟡に分離。俗説補正を6件に強化
   - **フェーズC完了**: 全17トピックを `articles` Edge Function ビューワー（`?slug=`）へリンク（基礎17＋発展編4＝21リンク、全200確認）
   - 同時に **B1階層ナビ型へ作り替え**（最新 tak-html-note 準拠）。整理は一般用語のみ・自分語は血肉化レイヤー限定の原則を厳守
   - 残: フェーズB で確証度を🟡🔵に下げたトピック（特にメンタルモデル/システム思考/音声外化）は、必要なら個別に追加調査して根拠を厚くする余地あり

## 🔗 重要なリソース

| 種別 | URL / 場所 |
|---|---|
| Supabase Project | https://supabase.com/dashboard/project/swgdzytwyvkwvncaqjks |
| Cloudflare Workers (Dashboard) | https://dash.cloudflare.com → Workers → research-hub-relay |
| Worker URL | https://research-hub-relay.tak-fukushima1978.workers.dev |
| GitHub Pages ビューワー | https://takfukushima1978-spec.github.io/research-hub/ |
| Anthropic Scheduled Tasks 一覧 | https://claude.ai/code/scheduled |
| Discord 通知チャンネル | 個人サーバー `#research-hub-notify` |
| ローカル設定 (.supabase-config) | `C:\dev\tak-work\リサーチ\auto-research\.supabase-config` |
| ローカル設定 (.discord-config) | `C:\dev\tak-work\リサーチ\auto-research\.discord-config` |

### Trigger ID 一覧

- auto-research-collect: `trig_01M35mr4nxRZZVWjFrtRdZyf`
- auto-claude-code-watch: `trig_015mNBjdX8Uyq9av2FSRTa2T`
- deep-research-runner: `trig_01C2e5bSQA4xqznQ3oY3QgQU`
- feedback-article-runner: `trig_01MYmCzYp5uGNEncchErp2vX`（7:30 JST）
- auto-research-morning-discord: `trig_01849zsAtA2CXcHwXoVwyKhv`

## 📚 関連ドキュメント

| ファイル | 役割 |
|---|---|
| `CLAUDE.md` | プロジェクト仕様（アーキテクチャ / Edge Functions / RPC / 設定 / Routines / 開発メモ）|
| `scheduled-tasks.md` | Routine の詳細（trigger ID / cron / プロンプト同期日 / 更新履歴 / 既知の問題）|
| `prompts/*-CONSOLE.md` | Routines プロンプトテンプレ（Console 貼り付け用、プレースホルダ含む）|
| `prompts/CONSOLE-READY-*.md` | 実値埋め込み済みローカル専用版（.gitignore 済、絶対 commit 禁止）|
| `worker/` | Cloudflare Workers (`research-hub-relay`) のソース |
| `research-log.md` | daily-research Routine のデイリーレポート出力先（このプロジェクトとは別系統）|
| `trusted-sources.md` | 信頼ソース一覧（外部リサーチの参照基準）|
| `supabase-policy.md` | Supabase 利用ポリシー |
| グローバル memory | `C:\dev\.claude\projects\c--dev-research-hub\memory\` に学び 13 件 |

## 📝 セッション履歴サマリー

- **2026-06-18**: **思考学習マップを B1階層ナビ型に作り替え＋フェーズB/C完了**。①最新 tak-html-note 準拠で B2(1枚図解)→B1(Level1マインドマップ大局図→領域ページ×4＋俗説/血肉化の単独ページ、パンくず・navigate)。②フェーズB: research 4並列でWeb検証し確証度を誠実に再判定（メタ認知/認知バイアス🟢→🟡、自己説明🟡→🟢 等、俗説補正6件）。③フェーズC: 全17トピックを articles Edge Function ビューワーへリンク（21リンク全200確認）。SSOT に §7検証・§8記事マップを追記。JS構文・リンク疎通を検証済
- **2026-06-14**: **思考学習 世界観マップ**（`thinking-map.html`）をフェーズA完成。要望は ①思考資産フレーム図をポータルから参照 ②thinking_learning を細分化＋科学的根拠で裏付け＋マインドマップ的俯瞰。tak-html-note B2（1枚図解）で生成。**重要な軌道修正**：当初「自分語フレームを中心に束ねる」設計→ Tak 指示で「リサーチ整理＝一般用語、自分語＝血肉化レイヤー（個人）」と**層を分離**。4領域×17トピックを一般用語＋確証度で整理、関係線SVG、俗説補正ボックス、図は参考枠に分離。コミット `852d037`
- **2026-06-10〜12**: **好みフィードバック・ループ**（ADR-LG-009）と**記事フィードバック→フォローアップ記事**の2機能を実装。
  - 好み: クリップ記事を recency weighting（半減期30日）集計する `get_preference_profile` RPC + auto-research-collect Step 1.7（好み/バランス/探索の3系統ミックス・ジャンル占有上限40%・コールドスタート）。実DB検証で total_clips=80・上位タグ mcp/hooks/claude_code を確認。Console 貼り直し済（2026-06-11）
  - 記事FB: `article_feedbacks` テーブル + RPC 3本（submit/get_pending/complete）+ index.html 記事末尾💬欄 + 新 Routine `feedback-article-runner`（7:30 JST, `trig_01MYmCzYp5uGNEncchErp2vX`）。migration 適用 + RPC ラウンドトリップ検証済（送信→pending取得→complete）。コネクターは最小権限（Gmail/Calendar 不使用）
  - コミット: `f296db5`/`1814a93`/`1eb7a9b`/`44f940d`（好み）、`f6869f4`/`ecf17bb`/`acf2d7b`/`39bd93d`（記事FB）
- **2026-06-10（前セッション）**: タクソノミー7ジャンル再編 + 演出レイヤー + 全7ジャンル学習マップ（67トピック）+ ローカル /loop 基礎面埋め（auto-basics-fill）。詳細は `git log` 参照（navigator 未追記分）
- **2026-05-26**: auto-claude-code-watch Phase1 導入（学習マップ駆動の毎日記事化 + スタンプラリー方式）。新規 Routine + テーブル + 4 RPC + seed スクリプト + CONSOLE-READY 生成スクリプト追加。Worker の RPC ルート Accept-Profile バグを構造的に修正。Edge Function に X-Allow-Override 防御追加（quality_override 悪用防止）。コミット4本（`e83a60b` / `43ad174` / `ccc5fd1` / `2042d1b`）。詳細 → [learnings/2026-05-26_claude-code-watch-launch.md](learnings/2026-05-26_claude-code-watch-launch.md)
- **2026-05-24**: navigator.md / 文書役割分担の後付け失敗を踏まえ、グローバル new-project スキルに Phase 2「文書体系の整備」を追加。詳細 → [learnings/2026-05-24_new-project-phase2.md](learnings/2026-05-24_new-project-phase2.md)
- **2026-05-23**: 大規模復旧セッション。5週間沈黙していたパイプラインを v2.2 設計（曜日別軸・公式ニュース最優先・自動DR・Worker 中継・Discord 通知）で完全復旧。memory に学び 9件追加（新規4+前回5）。コミット3本（`f128ed4` / `beeaff8` / `de27490`）。詳細は git log と memory を参照
- それ以前: `git log --oneline` で確認

## 📚 グローバルへの貢献（learnings）

このプロジェクトで得た学びのうち、グローバル設定（~/.claude/）や他プロジェクトに影響したもの。

| 日付 | 学び（project 側） | グローバル反映先 | 起点 commit |
|---|---|---|---|
| 2026-05-24 | [navigator.md は初期設定に組み込む](learnings/2026-05-24_new-project-phase2.md) | `~/.claude/skills/new-project/SKILL.md` Phase 2 追加 | `3f2d78b` |
| 2026-05-26 | [エージェント指示は破られる前提で構造的防御を組む](learnings/2026-05-26_claude-code-watch-launch.md) | `~/.claude/rules/design-patterns.md` 追加候補 | `2042d1b` |

> 集約フロー: project `learnings/` で `promote_to_global: true` のものを、夜間タスク (aggregate-learnings) でグローバル `My-Profile-and-Memory/learnings/` に集約する。

## 🛠 運用ルール

### 学び・気づきを得たとき

→ **グローバル memory** に書く（`C:\dev\.claude\projects\c--dev-research-hub\memory\`）

書く基準:
- 他プロジェクトでも応用できる技術的知見 → reference type
- このプロジェクト固有の運用判断・既知の罠 → project type
- ユーザー（Tak）から受けた指示・修正 → feedback type
- 外部システムへの参照（URL・場所） → reference type

### プロジェクト現状が変わったとき

→ この `navigator.md` を更新（新機能追加 / Routine 追加削除 / 残タスク変動 / 大きな問題発覚時）

### 仕様が変わったとき

→ `CLAUDE.md` を更新（アーキテクチャ図・Edge Functions・RPC・設定一覧）

### Routine の trigger / プロンプトを変更したとき

→ `scheduled-tasks.md` を更新（trigger ID・最終同期日・更新履歴・既知の問題）

### 大きな設計判断を行ったとき

→ `decisions/ADR-XXX.md` を新規作成（現状未整備。必要になれば形式を決めて作る）

### セッション末尾のチェックリスト

1. 学びがあれば memory 追加（MEMORY.md index も更新）
2. プロジェクト現状が変わったら navigator.md 更新
3. 仕様変更があれば CLAUDE.md 更新
4. git status クリーンになるよう commit
5. CONSOLE-READY-*.md など secrets を含むファイルは絶対 commit しない（.gitignore 確認）
