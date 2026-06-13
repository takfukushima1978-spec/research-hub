---
name: add-routine
description: Research Hub に新しいスケジュールタスク（Routine）を追加するときに使用。「Routine追加」「新しいスケジュールタスク」「定期タスクを作る」と言われたとき、または新機能の一部として夜間自動処理を足すときに起動。migration→CONSOLEプロンプト→検証→Console登録→docs同期の取りこぼしを防ぐ。
---

# Research Hub に新 Routine を追加する

Anthropic Console の Scheduled Task（Routine）を1本増やすときの定型フロー。
過去3回（deep-research-runner / auto-claude-code-watch / feedback-article-runner）で
「trigger ID 記録漏れ」「docs 同期漏れ」「コネクター付けっぱなし（過剰権限）」が起きやすいので手順化する。

## 前提アーキテクチャ（毎回同じ）

- クラウド sandbox → Supabase 直叩きは Cloudflare bot 検知で 403 → **必ず `research-hub-relay` Worker 経由**
- クライアントは `X-Internal-Token` のみ送る。Worker が anon key / apikey / Authorization を内部付与
- 書き込み系 RPC は Worker の deny list で直叩き禁止 → Edge Function 経由（新 RPC が書き込み系なら deny 要否を判断）
- プロンプトは `prompts/<name>-CONSOLE.md`（テンプレ・git管理）→ `generate-console-ready.mjs` で実値埋込版を生成（gitignore）

## チェックリスト（順に TodoWrite 化して潰す）

### 1. DB（必要なら）
- [ ] `supabase/migrations/<YYYYMMDD>_<topic>.sql` を**冪等版**で作成（`CREATE TABLE IF NOT EXISTS` / RLS は `pg_policies` 存在チェック / RPC は `CREATE OR REPLACE`）
- [ ] RPC は `public` スキーマ・`SECURITY DEFINER`・`SET search_path = public, research, urawa_log`（urawa_log 同居対応）・`GRANT ... TO anon, authenticated, service_role`
- [ ] 末尾に検証 SELECT を付ける

### 2. Worker deny list 判断
- [ ] 新 RPC が**書き込み系で品質ノルマ等を bypass しうる**か判定 → するなら `worker/src/index.ts` の `DENY_RPC_NAMES` に追加 + `cd worker && npx wrangler deploy`
- [ ] 安全な read / status 更新だけなら Worker 変更不要（`/rest/v1/rpc/*` は既に許可済）

### 3. CONSOLE プロンプト作成
- [ ] `prompts/<name>-CONSOLE.md` を既存（feedback-article-runner 等）に倣って作成
  - ヘッダ説明 + `# ▼ ここから下が Console に貼り付ける本体 ▼` マーカー必須（gen スクリプトが本体を切り出す）
  - `<<RELAY_URL>>` / `<<INTERNAL_TOKEN>>` プレースホルダ
  - **自律運転ガードレール**（再生成最大2回でskip / 1件失敗で止めない / 409・レート想定内 / 1セッション上限 / クリーン停止）
  - 末尾に**処理サマリ Step**（投入/skip/error 件数）→ 緑チェックの空振り防止（[[routines-host-not-allowed-silent-failure]]）
- [ ] `node scripts/generate-console-ready.mjs <name>` で CONSOLE-READY 生成（要 `.supabase-config`。無ければ [[onedrive-secret-config-dehydration]] 参照）

### 4. 適用・検証（Tak 手動 + Claude 検証）
- [ ] migration を Supabase SQL Editor で適用（Tak）→ 検証 SELECT の戻りを確認
- [ ] 一時検証スクリプト `scripts/tmp-verify-<topic>.mjs` を書いて Worker 経由ラウンドトリップ（送信→取得→cleanup）を確認 → **検証後に削除**
  - token は `.supabase-config` から読む（コマンド行に出さない＝bash-advisor 安全）
  - RPC 404 PGRST202 が出たら migration 未適用のサイン（テーブル直クエリが 200 なら Worker/token は正常）

### 5. Console 登録（Tak 手動）
- [ ] Console で trigger 新規作成 → CONSOLE-READY を貼付 → cron 設定
- [ ] 環境は「**Cloudflare Workers_My Reserch**」を選択（Allowed domains 登録済を共有）
- [ ] **コネクターは最小権限**: Gmail / Google Calendar 等は不要なら削除（Web検索 + Worker HTTPS で完結する Routine は付けない）
- [ ] 発行された `trig_...` を URL（`claude.ai/code/routines/<trig>`）から取得

### 6. docs 3点同期（取りこぼし最多・必須）
- [ ] `scheduled-tasks.md`: 新セクション（trigger ID / cron / 役割 / 依存 migration / 初期セットアップ手順 / 作成日・登録日）
- [ ] `CLAUDE.md`: アーキテクチャ図・Routine 表・RPC 一覧（新 RPC があれば）・機能セクション
- [ ] `navigator.md`: 現状サマリーの Routine 数・Trigger ID 一覧・セッション履歴

### 7. コミット
- [ ] 機能単位で分割（feat(db) / feat(runner) / docs）。CONSOLE-READY は gitignore 確認（commit 禁止）

## 関連
- 既存 Routine の正: `scheduled-tasks.md`
- 仕様の正: `CLAUDE.md`
- gen スクリプト: `scripts/generate-console-ready.mjs`
