-- ============================================
-- Research Hub - glossary ジャンル追加（8ジャンル目）
-- 2026-06-20
--
-- 目的: 非エンジニア向けの「基礎用語・コマンド解説」ジャンルを taxonomy に追加する。
--   1. tags に L1 `glossary` + L2 4個を upsert（phase2b_taxonomy_redesign.sql と同型）
--   2. categories に `glossary` を upsert（label_ja/description）
--
-- 設計原則（phase2b 踏襲）:
--   - name スラッグ = 不変の識別子。label_ja/parent_id/sort_order のみ更新
--   - 既存タグ/カテゴリの DELETE は一切しない（article_tags 保全）
--   - 冪等（ON CONFLICT DO UPDATE）。何度実行しても同結果
--
-- 実行方法: Supabase SQL Editor → このSQL全体をコピペ → Run
--   （tags/categories は書き込み系のため Worker RPC 経由では不可。SQL Editor or service_role が必要）
--
-- タクソノミー SSOT: tak-lifelog/docs/research-taxonomy.md にも 8 ジャンル目を反映すること（doc-sync）
-- ============================================

BEGIN;

-- ============================================
-- STEP 0: learning_topics の genre CHECK 制約に glossary を追加
--   （元の chk_learning_genre は7ジャンル限定。glossary を seed する前に必須）
-- ============================================
ALTER TABLE research.learning_topics DROP CONSTRAINT IF EXISTS chk_learning_genre;
ALTER TABLE research.learning_topics ADD CONSTRAINT chk_learning_genre CHECK (
  genre IN ('accounting','keiri_dx','ai_tech','tools','business','security_risk','thinking_learning','glossary')
) NOT VALID;
ALTER TABLE research.learning_topics VALIDATE CONSTRAINT chk_learning_genre;

-- ============================================
-- STEP 1: L1（トップジャンル）glossary を upsert（sort_order=80 で末尾）
-- ============================================
INSERT INTO research.tags (name, label_ja, level, parent_id, sort_order, icon) VALUES
  ('glossary', '基礎用語・コマンド', 1, NULL, 80, '📖')
ON CONFLICT (name) DO UPDATE SET
  label_ja   = EXCLUDED.label_ja,
  level      = 1,
  parent_id  = NULL,
  sort_order = EXCLUDED.sort_order,
  icon       = COALESCE(EXCLUDED.icon, research.tags.icon);

-- ============================================
-- STEP 2: L2（サブカテゴリ）を glossary 配下に upsert
--   親は name サブクエリで解決（L1 が STEP 1 で確定済み）
-- ============================================
INSERT INTO research.tags (name, label_ja, level, parent_id, sort_order)
SELECT v.name, v.label_ja, 2, p.id, v.srt
FROM (VALUES
  ('terms_lang',     '言語・データ記法',         81),  -- Python/JSON/YAML/Markdown/HTML
  ('terms_dev',      '開発の基礎概念',           82),  -- Git/API/CLI/環境変数/DB/Node
  ('cc_commands',    'Claude Code コマンド',     83),  -- コマンドの意味（危険度・機能別）
  ('cc_permission',  '権限・承認の判断',         84)   -- Allow Bash(...)? の読み方・R77 4層
) AS v(name, label_ja, srt)
JOIN research.tags p ON p.name = 'glossary'
ON CONFLICT (name) DO UPDATE SET
  label_ja = EXCLUDED.label_ja, level = 2,
  parent_id = EXCLUDED.parent_id, sort_order = EXCLUDED.sort_order;

-- ============================================
-- STEP 3: categories に glossary を upsert（L1 mirror）
-- ============================================
INSERT INTO research.categories (name, label_ja, description) VALUES
  ('glossary', '基礎用語・コマンド', '非エンジニア向けの基礎用語解説（Python/JSON 等）と Claude Code 頻出コマンドの意味・承認時の注意点')
ON CONFLICT (name) DO UPDATE SET
  label_ja    = EXCLUDED.label_ja,
  description = EXCLUDED.description;

COMMIT;

-- ============================================
-- 検証（COMMIT 後）
-- ============================================
-- L1/L2 階層
SELECT level, sort_order, name, label_ja
FROM research.tags
WHERE name = 'glossary' OR parent_id = (SELECT id FROM research.tags WHERE name = 'glossary')
ORDER BY level, sort_order;

-- category
SELECT name, label_ja FROM research.categories WHERE name = 'glossary';
