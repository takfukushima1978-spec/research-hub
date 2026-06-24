-- ============================================
-- Research Hub - 診断テスト記事（DIAGNOSTIC_*）の一括削除
-- 2026-06-21
--
-- 目的: 品質ノルマ / RPC bypass の検証時に投入された使い捨てテスト記事が
--   ビューワー先頭に残り続ける残骸を「全件」除去する。
--   実測で確認された残骸（2026-06-21 時点・いずれも同一シグネチャ）:
--     - baab732f-... DIAGNOSTIC_TEST_REJECTED   （初回 migration で削除済）
--     - 908053d6-... DIAGNOSTIC_TEST_REJECTED   （別ID・2件目）
--     - 0455753d-... DIAGNOSTIC_RPC_BYPASS_TEST （RPC bypass 事故の残骸, CLAUDE.md 2026-05-27）
--
-- 方針: ID 直打ちでは取りこぼすため「シグネチャ一括削除」にする
--   （design-patterns「構造問題は同じパターンを全部 grep」）。
--   4条件ガードで実記事には絶対当たらない:
--     title_ja LIKE 'DIAGNOSTIC%' AND summary='test' AND body_text='short' AND source_date='2999-12-31'
--   （2999-12-31 = 番兵的な未来日 → source_date.desc で最上位固定が表示残存の原因）
--   子テーブル（article_tags / deep_research_requests / article_feedbacks）を先に削除。
--   冪等: 既に削除済みなら全 DELETE が 0 行で無害。再実行・将来の残骸にも有効。
--
-- 実行方法: Supabase SQL Editor → このSQL全体をコピペ → Run
--   （articles 系は書き込み専用 RPC が無く Worker GET も articles/tags のみ許可のため、
--    削除は SQL Editor or service_role が必須。glossary_genre.sql と同じ理由）
-- ============================================

BEGIN;

-- 削除前の確認（実行ログに残す）: 対象が想定どおりのテスト記事か
SELECT id, title_ja, summary, status, source_date
FROM research.articles
WHERE title_ja LIKE 'DIAGNOSTIC%'
  AND summary = 'test'
  AND body_text = 'short'
  AND source_date = '2999-12-31';

-- STEP 1: 子テーブルの参照行を先に削除（FK 制約に依存せず確実に）
WITH targets AS (
  SELECT id FROM research.articles
  WHERE title_ja LIKE 'DIAGNOSTIC%' AND summary = 'test'
    AND body_text = 'short' AND source_date = '2999-12-31'
)
DELETE FROM research.article_tags WHERE article_id IN (SELECT id FROM targets);

WITH targets AS (
  SELECT id FROM research.articles
  WHERE title_ja LIKE 'DIAGNOSTIC%' AND summary = 'test'
    AND body_text = 'short' AND source_date = '2999-12-31'
)
DELETE FROM research.deep_research_requests WHERE article_id IN (SELECT id FROM targets);

WITH targets AS (
  SELECT id FROM research.articles
  WHERE title_ja LIKE 'DIAGNOSTIC%' AND summary = 'test'
    AND body_text = 'short' AND source_date = '2999-12-31'
)
DELETE FROM research.article_feedbacks WHERE article_id IN (SELECT id FROM targets);

-- STEP 2: 本体を削除（4条件シグネチャで誤削除防止）
DELETE FROM research.articles
WHERE title_ja LIKE 'DIAGNOSTIC%'
  AND summary = 'test'
  AND body_text = 'short'
  AND source_date = '2999-12-31';

COMMIT;

-- ============================================
-- 検証（COMMIT 後）: 0 行になっていれば成功
-- ============================================
SELECT count(*) AS remaining
FROM research.articles
WHERE title_ja LIKE 'DIAGNOSTIC%'
  AND summary = 'test'
  AND body_text = 'short'
  AND source_date = '2999-12-31';
