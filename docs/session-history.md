# Research Hub セッション履歴（アーカイブ）

> `navigator.md` のセッション履歴サマリーを肥大化させないための退避先。
> navigator は直近3件だけ残し、それ以前はここに蓄積する（情報は消さない）。
> さらに古い経緯・コミット詳細は `git log --oneline` を正とする。

---

- **2026-06-20（glossary 増補）**: glossary を **17→60トピックに一括増補**し網羅~100%へ（初版17→増補23→仕上げ20）。追加: 用語（HTTPステータス/Webhook/OAuth・トークン/マイグレーション/embedding/HTTPS・TLS/レート制限・冪等性/CORS/CI・CD 等）・ツール環境（Docker/PowerShell/Supabase/Cloudflare Worker/Claude API・モデル/Task Scheduler・cron/Python venv 等）・コマンド（検索調査系/プロセス管理/環境PATH系/アーカイブ/git応用/権限パターン）。3バッチとも headless 自律・skip0・DB独立検証。教訓: 学習マップ説明文に `|`（パイプ）を使うと表行がドロップする（memory [[learning-map-pipe-drops-row]]）
- **2026-06-20（glossary ジャンル新設）**: **新ジャンル `glossary`（基礎用語・コマンド解説）を追加**（8ジャンル目）。非エンジニア向けに ①IT/AI用語（Python/JSON/Git/API 等）②Claude Code頻出コマンド（cd/rm/curl 等を危険度・機能別に、**承認時の注意点を Tak の R77 4層設計に紐づけ**）。実装: migration SQL（genre CHECK制約＋tags L1/L2＋category、Supabase SQL Editor で Tak が適用）→ seed VALID_GENRES → `docs/learning-maps/glossary.md` → auto-basics-fill.md タグ表・記事方針 → index.html TAG_COLORS → headless で記事生成（権限記事に R77/Allow Once/4層が反映済を確認）。memory [[research-hub-add-genre-recipe]]。派生で tak-orchestrator R84（permission 挙動の版差ドリフト検証）を起票
- **2026-06-18〜20**: **基礎記事の充実を 67/67 完走**（covered 63 + deep 4・uncovered 0）。headless 夜間自律レーン（`claude -p --allowedTools` + `learning-cli.mjs`、git非接触・品質ノルマでガード）で3バッチ実行: 18日=9件（ai_tech中心）、19日=19件（tools→ai_tech周辺→security_risk）、20日=9件（business/keiri_dx/ai_tech残）。各バッチ skip0・全件品質ノルマ通過、DB側でカバレッジ増分と記事実在を独立検証。inline では権限プロンプトで止まるため headless 化（autonomous-task-template 準拠）。memory [[headless-write-works-cli-2-1-158]]
- **2026-06-18**: **思考学習マップを B1階層ナビ型に作り替え＋フェーズB/C完了**。①最新 tak-html-note 準拠で B2(1枚図解)→B1(Level1マインドマップ大局図→領域ページ×4＋俗説/血肉化の単独ページ、パンくず・navigate)。②フェーズB: research 4並列でWeb検証し確証度を誠実に再判定（メタ認知/認知バイアス🟢→🟡、自己説明🟡→🟢 等、俗説補正6件）。③フェーズC: 全17トピックを `articles` Edge Function ビューワー（`?slug=`）へリンク（21リンク全200確認）。SSOT(`docs/thinking-learning-worldview.md`)に §7検証・§8記事マップを追記。memory [[articles-edge-function-slug-viewer]]。**残**: 確証度を🟡🔵に下げたトピック（メンタルモデル/システム思考/音声外化）は必要なら追加調査で根拠を厚くする余地あり
- **2026-06-14**: **思考学習 世界観マップ**（`thinking-map.html`）フェーズA完成。**重要な軌道修正**：当初「自分語フレームを中心に束ねる」設計→ Tak 指示で「リサーチ整理＝一般用語、自分語＝血肉化レイヤー（個人）」と**層を分離**。4領域×17トピックを一般用語＋確証度で整理。コミット `852d037`
- **2026-06-10〜12**: **好みフィードバック・ループ**（ADR-LG-009）と**記事フィードバック→フォローアップ記事**の2機能を実装。
  - 好み: クリップ記事を recency weighting（半減期30日）集計する `get_preference_profile` RPC + auto-research-collect Step 1.7（好み/バランス/探索の3系統ミックス・ジャンル占有上限40%・コールドスタート）。実DB検証で total_clips=80。Console 貼り直し済（2026-06-11）
  - 記事FB: `article_feedbacks` テーブル + RPC 3本（submit/get_pending/complete）+ index.html 記事末尾💬欄 + 新 Routine `feedback-article-runner`（7:30 JST, `trig_01MYmCzYp5uGNEncchErp2vX`）。migration 適用 + RPC ラウンドトリップ検証済
  - コミット: `f296db5`/`1814a93`/`1eb7a9b`/`44f940d`（好み）、`f6869f4`/`ecf17bb`/`acf2d7b`/`39bd93d`（記事FB）
- **2026-06-10（前セッション）**: タクソノミー7ジャンル再編 + 演出レイヤー + 全7ジャンル学習マップ（67トピック）+ ローカル /loop 基礎面埋め（auto-basics-fill）。詳細は `git log` 参照
- **2026-05-26**: auto-claude-code-watch Phase1 導入（学習マップ駆動の毎日記事化 + スタンプラリー方式）。新規 Routine + テーブル + 4 RPC + seed スクリプト + CONSOLE-READY 生成スクリプト追加。Worker の RPC ルート Accept-Profile バグを構造的に修正。Edge Function に X-Allow-Override 防御追加（quality_override 悪用防止）。コミット4本（`e83a60b` / `43ad174` / `ccc5fd1` / `2042d1b`）。詳細 → [learnings/2026-05-26_claude-code-watch-launch.md](../learnings/2026-05-26_claude-code-watch-launch.md)
- **2026-05-24**: navigator.md / 文書役割分担の後付け失敗を踏まえ、グローバル new-project スキルに Phase 2「文書体系の整備」を追加。詳細 → [learnings/2026-05-24_new-project-phase2.md](../learnings/2026-05-24_new-project-phase2.md)
- **2026-05-23**: 大規模復旧セッション。5週間沈黙していたパイプラインを v2.2 設計（曜日別軸・公式ニュース最優先・自動DR・Worker 中継・Discord 通知）で完全復旧。memory に学び 9件追加。コミット3本（`f128ed4` / `beeaff8` / `de27490`）
- それ以前: `git log --oneline` で確認
