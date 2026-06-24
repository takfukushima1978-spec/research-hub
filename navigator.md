# Research Hub Navigator

> プロジェクトの現状ダッシュボード。
> 仕様詳細は `CLAUDE.md`、Routine 詳細は `scheduled-tasks.md`、
> 横断的な学びは global memory (`C:\dev\.claude\projects\c--dev-research-hub\memory\`) を参照。

最終更新: 2026-06-20

---

## 📊 現状サマリー

| 項目 | 値 |
|---|---|
| パイプライン状態 | ✅ **稼働中** |
| 稼働中の Routine | **5つ**（auto-research-collect / auto-claude-code-watch / deep-research-runner / feedback-article-runner / auto-research-morning-discord）+ ローカル /loop（auto-basics-fill）|
| Worker | `research-hub-relay` デプロイ済（pass-through proxy。GET /rest/v1/tags 許可済）|
| Edge Function | `insert-article`（quality_override は X-Allow-Override ヘッダー必須）|
| タクソノミー | **8ジャンル**（accounting/keiri_dx/ai_tech/tools/business/security_risk/thinking_learning ＋ **glossary**=基礎用語・コマンド解説、2026-06-20追加）。曜日軸ローテーション |
| 好みフィードバック | ✅ クリップ→`get_preference_profile`→Step 1.7（好み/バランス/探索）稼働（ADR-LG-009）|
| 記事フィードバック | ✅ 記事末尾💬→`article_feedbacks`→feedback-article-runner（7:30 JST）で追加記事自動生成 |
| 学習マップ | 全8ジャンル `learning_topics`（**127トピック**=67＋glossary60）+ Claude Code 専属 `claude_code_topics`（36）|
| 基礎記事の充実 | ✅ **完走**。7ジャンル67/67（covered 63 + deep 4）＋ **glossary 60/60**（2026-06-20、初版17→増補23→仕上げ20で網羅~100%）。headless 自律バッチ（`claude -p` + `learning-cli.mjs`）で埋め切り。各バッチDB独立検証済（run log: `tmp/*-run-*.log`） |
| 思考学習マップ | ✅ `thinking-map.html`（**B1階層ナビ型**に作り替え 2026-06-18）。Level1マインドマップ大局図→領域ページ×4＋俗説補正/血肉化の単独ページ。**フェーズB完了**（Web調査で出典・効果量・再現性を検証→確証度再判定: メタ認知/認知バイアス🟢→🟡、自己説明🟡→🟢 等）。**フェーズC完了**（全17トピックを articles Edge Function の記事ビューワーへリンク、21リンク全200確認）。内容SSOT: `docs/thinking-learning-worldview.md` §7検証/§8記事マップ |
| 通知チャネル | Discord `#research-hub-notify` で稼働確認済 |
| 直近の問題 | DR 自動 completed 現象（要 Phase 2 調査）|

## 🎯 直近の重点

- **feedback-article-runner 初回稼働観察**（2026-06-13 7:30 JST〜）。記事末尾フィードバックが翌朝の追加記事生成に繋がるかエンドツーエンド確認
- **好みフィードバック・ループ稼働観察**。Step 8 サマリの系統分布（好み/バランス/探索）とジャンル占有上限40%が機能するか
- 不調が出なければ Phase 2 (UI スタンプラリー + Discord 進捗バー) に着手

## 📋 残タスク (Phase 2)

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

> ✅ 完了済み（履歴は [docs/session-history.md](docs/session-history.md)）: 思考学習マップ フェーズB/C ＋ B1作り替え（2026-06-18）／ glossary ジャンル新設・60トピック網羅（2026-06-20）／ **秘密設定ファイルを git 射程外（`C:\dev\.secrets\`）へ退避**（2026-06-21、[[secret-config-file-disappeared]] 恒久対策）／ **診断テスト記事（DIAGNOSTIC_* 計3件）を一括削除**（2026-06-25、migration `20260621000001`、シグネチャ一括削除で全件除去）／ **学習マップ スタンプラリーUI を index.html に実装**（2026-06-25、8ジャンル127件をアコーディオン+進捗バー+トピック→記事リンク。learning_topics を anon 遅延fetch・クライアント集計。スコープは learning_topics 全体を採用＝Claude Code 限定の原案から拡大）。

## 🔗 重要なリソース

| 種別 | URL / 場所 |
|---|---|
| Supabase Project | https://supabase.com/dashboard/project/swgdzytwyvkwvncaqjks |
| Cloudflare Workers (Dashboard) | https://dash.cloudflare.com → Workers → research-hub-relay |
| Worker URL | https://research-hub-relay.tak-fukushima1978.workers.dev |
| GitHub Pages ビューワー | https://takfukushima1978-spec.github.io/research-hub/ |
| Anthropic Scheduled Tasks 一覧 | https://claude.ai/code/scheduled |
| Discord 通知チャンネル | 個人サーバー `#research-hub-notify` |
| ローカル設定 (.supabase-config) | **`C:\dev\.secrets\.supabase-config`（正本・git 射程外）** / fallback: `C:\dev\tak-work\リサーチ\auto-research\.supabase-config` |
| ローカル設定 (.discord-config) | **`C:\dev\.secrets\.discord-config`（正本・git 射程外）** / fallback: `C:\dev\tak-work\リサーチ\auto-research\.discord-config` |

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
| `docs/session-history.md` | セッション履歴アーカイブ（navigator から退避した過去経緯）|
| `research-log.md` | daily-research Routine のデイリーレポート出力先（このプロジェクトとは別系統）|
| `trusted-sources.md` | 信頼ソース一覧（外部リサーチの参照基準）|
| `supabase-policy.md` | Supabase 利用ポリシー |
| グローバル memory | `C:\dev\.claude\projects\c--dev-research-hub\memory\` に学び 17 件 |

## 📝 セッション履歴サマリー

直近のみ。**それ以前の全履歴は [docs/session-history.md](docs/session-history.md) に退避**（さらに古い経緯は `git log --oneline`）。

- **2026-06-20**: glossary ジャンル新設（8ジャンル目）→ **17→60トピックに一括増補（網羅~100%）**。非エンジニア向け基礎用語・Claude Codeコマンド（承認注意点を R77 4層に紐づけ）。派生で tak-orchestrator R84（permission 挙動の版差ドリフト検証）起票
- **2026-06-18〜20**: 基礎記事の充実を **7ジャンル 67/67 完走**（headless 自律3バッチ）
- **2026-06-18**: 思考学習マップを **B1階層ナビ型に作り替え＋フェーズB/C完了**（Web検証で確証度再判定・記事リンク21）

## 📚 グローバルへの貢献（learnings）

このプロジェクトで得た学びのうち、グローバル設定（~/.claude/）や他プロジェクトに影響したもの。

| 日付 | 学び（project 側） | グローバル反映先 | 起点 commit |
|---|---|---|---|
| 2026-05-24 | [navigator.md は初期設定に組み込む](learnings/2026-05-24_new-project-phase2.md) | `~/.claude/skills/new-project/SKILL.md` Phase 2 追加 | `3f2d78b` |
| 2026-05-26 | [エージェント指示は破られる前提で構造的防御を組む](learnings/2026-05-26_claude-code-watch-launch.md) | `~/.claude/rules/design-patterns.md` 追加候補 | `2042d1b` |

> 集約フロー: project `learnings/` で `promote_to_global: true` のものを、夜間タスク (aggregate-learnings) でグローバル `My-Profile-and-Memory/learnings/` に集約する。

## 🛠 運用ルール（更新先の早見）

変更の種別 → 更新する正本（詳細はグローバル `doc-sync-map.md` / session-end スキル）:

| 変更 | 更新先 |
|---|---|
| 学び・気づき | グローバル memory（`...\projects\c--dev-research-hub\memory\` + MEMORY.md index）。型 = reference/project/feedback |
| プロジェクト現状（機能/Routine/残タスク/問題） | この `navigator.md`（履歴は `docs/session-history.md` へ退避） |
| 仕様（アーキ/Edge Function/RPC/設定） | `CLAUDE.md` |
| Routine の trigger/プロンプト | `scheduled-tasks.md` |
| 大きな設計判断 | `decisions/ADR-XXX.md`（現状未整備） |

> commit 前: secrets を含む `CONSOLE-READY-*.md` 等は絶対 commit しない（.gitignore 確認）。
