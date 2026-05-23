# Research Hub Navigator

> プロジェクトの現状ダッシュボード。
> 仕様詳細は `CLAUDE.md`、Routine 詳細は `scheduled-tasks.md`、
> 横断的な学びは global memory (`C:\dev\.claude\projects\c--dev-research-hub\memory\`) を参照。

最終更新: 2026-05-23

---

## 📊 現状サマリー

| 項目 | 値 |
|---|---|
| パイプライン状態 | ✅ **稼働中**（2026-05-23 完全復旧、5週間沈黙から復帰）|
| 累計記事数 | 50 件前後（system-test 含む過去、本日テスト記事は削除済） |
| 最終投入日 | 2026-05-23 (auto-research-collect が3件投入) |
| 稼働中の Routine | 3つ（auto-research-collect / deep-research-runner / auto-research-morning-email）|
| Worker | `research-hub-relay` デプロイ済（Version `c7ce95e9` 系）|
| 通知チャネル | Discord `#research-hub-notify` で稼働確認済 |
| 直近の問題 | 5/17 の Routine × (詳細未確認)、DR 自動 completed 現象（要 Phase 2 調査）|

## 🎯 直近の重点

- **明朝 2026-05-24 3:03 JST から本番自動運用が始まる**。各 Routine の動作確認を Tak が朝6:57の Discord 通知で行う
- 5/24-5/28 の 5日間で安定運用を観察し、ハマりが出なければ Phase 2 に着手
- Phase 2 着手時の優先順位: フィードバックループ復活 > URL hash 対応 > DR 自動 completed 原因究明

## 📋 残タスク (Phase 2)

1. **Discord フィードバックループ復活**
   - Discord メッセージに 1-5 reaction を Bot で自動付与
   - Reaction Events を Cloudflare Workers Bot で受信 → `user_feedback` テーブルに記録
   - auto-research-collect の翌朝リサーチで feedback を読み取って優先度反映
   - 関連 memory: [[discord-webhook-notification-pattern]]

2. **ビューワー index.html を URL hash 対応に**
   - `index.html#article=<slug>` で個別記事ページに直リンク可能にする
   - Discord embed の `url` フィールドを slug ベースに切替
   - メール / Discord から記事を1タップで開けるようにする

3. **DR 自動 completed 現象の調査**
   - auto-research-collect が `action=request` した直後、同セッション内で DR が completed になっている
   - 関連 memory: [[dr-self-completion-mystery]]
   - Run 詳細ログ + `supabase/functions/deep-research/index.ts` ソース再読
   - 必要ならプロンプトに「complete アクションは呼ぶな」を明示

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
- deep-research-runner: `trig_01C2e5bSQA4xqznQ3oY3QgQU`
- auto-research-morning-email: `trig_01849zsAtA2CXcHwXoVwyKhv`

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

- **2026-05-24**: navigator.md / 文書役割分担の後付け失敗を踏まえ、グローバル new-project スキルに Phase 2「文書体系の整備」を追加。詳細 → [learnings/2026-05-24_new-project-phase2.md](learnings/2026-05-24_new-project-phase2.md)
- **2026-05-23**: 大規模復旧セッション。5週間沈黙していたパイプラインを v2.2 設計（曜日別軸・公式ニュース最優先・自動DR・Worker 中継・Discord 通知）で完全復旧。memory に学び 9件追加（新規4+前回5）。コミット3本（`f128ed4` / `beeaff8` / `de27490`）。詳細は git log と memory を参照
- それ以前: `git log --oneline` で確認

## 📚 グローバルへの貢献（learnings）

このプロジェクトで得た学びのうち、グローバル設定（~/.claude/）や他プロジェクトに影響したもの。

| 日付 | 学び（project 側） | グローバル反映先 | 起点 commit |
|---|---|---|---|
| 2026-05-24 | [navigator.md は初期設定に組み込む](learnings/2026-05-24_new-project-phase2.md) | `~/.claude/skills/new-project/SKILL.md` Phase 2 追加 | `3f2d78b` |

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
