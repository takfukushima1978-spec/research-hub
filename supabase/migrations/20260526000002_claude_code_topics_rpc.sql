-- Claude Code 学習マップ用 RPC
--
-- 3本:
--   1) get_uncovered_claude_code_topics(p_limit)
--      未カバートピックを priority 高 + last_covered_at 古い順で返す
--   2) mark_topic_covered(p_topic_id, p_article_id)
--      記事化されたトピックの状態を更新する（uncovered→covered, covered→deep）
--   3) get_claude_code_coverage_summary()
--      領域別の進捗をまとめて返す（Routine が Step 9 サマリで利用）
--
-- 全 RPC は public スキーマに置く（既存運用と統一）。
-- SECURITY DEFINER + search_path = public, research, urawa_log
-- （memory: supabase-shared-with-urawa-log.md / urawa_log 同居スキーマ対応）

-- =====================================================
-- 1) get_uncovered_claude_code_topics
-- =====================================================
CREATE OR REPLACE FUNCTION public.get_uncovered_claude_code_topics(
  p_limit int DEFAULT 10
)
RETURNS TABLE (
  topic_id        text,
  area            text,
  subarea         text,
  title           text,
  description     text,
  doc_url         text,
  priority        int,
  coverage_status text,
  article_count   int,
  last_covered_at timestamptz
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, research, urawa_log
AS $$
  SELECT
    t.topic_id,
    t.area,
    t.subarea,
    t.title,
    t.description,
    t.doc_url,
    t.priority,
    t.coverage_status,
    t.article_count,
    t.last_covered_at
  FROM research.claude_code_topics t
  WHERE t.coverage_status IN ('uncovered', 'covered')
    AND t.coverage_status != 'archived'
  ORDER BY
    CASE t.coverage_status
      WHEN 'uncovered' THEN 0
      WHEN 'covered'   THEN 1
      ELSE 2
    END ASC,
    t.priority DESC,
    t.last_covered_at ASC NULLS FIRST,
    t.topic_id ASC
  LIMIT GREATEST(p_limit, 1);
$$;

GRANT EXECUTE ON FUNCTION public.get_uncovered_claude_code_topics(int)
  TO anon, authenticated, service_role;

COMMENT ON FUNCTION public.get_uncovered_claude_code_topics(int) IS
  '未カバー（uncovered）または1回カバー済（covered）のトピックを優先度順に返す。Routine が解説記事化の候補選定に使う。';

-- =====================================================
-- 2) mark_topic_covered
-- =====================================================
CREATE OR REPLACE FUNCTION public.mark_topic_covered(
  p_topic_id   text,
  p_article_id uuid
)
RETURNS TABLE (
  topic_id        text,
  coverage_status text,
  article_count   int
)
LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER
SET search_path = public, research, urawa_log
AS $$
DECLARE
  v_current_status text;
  v_new_status     text;
BEGIN
  -- 現在の状態を取得
  SELECT t.coverage_status INTO v_current_status
  FROM research.claude_code_topics t
  WHERE t.topic_id = p_topic_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION '指定された topic_id が存在しません: %', p_topic_id;
  END IF;

  -- 状態遷移: uncovered → covered, covered → deep, deep → deep（変化なし）
  v_new_status := CASE v_current_status
    WHEN 'uncovered' THEN 'covered'
    WHEN 'covered'   THEN 'deep'
    WHEN 'deep'      THEN 'deep'
    ELSE v_current_status
  END;

  -- 更新（related_article_ids に追加、article_count をインクリメント）
  UPDATE research.claude_code_topics t
     SET coverage_status     = v_new_status,
         article_count       = t.article_count + 1,
         related_article_ids = array_append(t.related_article_ids, p_article_id),
         last_covered_at     = now()
   WHERE t.topic_id = p_topic_id;

  RETURN QUERY
    SELECT t.topic_id, t.coverage_status, t.article_count
    FROM research.claude_code_topics t
    WHERE t.topic_id = p_topic_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.mark_topic_covered(text, uuid)
  TO anon, authenticated, service_role;

COMMENT ON FUNCTION public.mark_topic_covered(text, uuid) IS
  'トピックを記事化済みとしてマーク。uncovered→covered, covered→deep に遷移し、article_count を増やす。';

-- =====================================================
-- 3) get_claude_code_coverage_summary
-- =====================================================
CREATE OR REPLACE FUNCTION public.get_claude_code_coverage_summary()
RETURNS TABLE (
  area         text,
  total        bigint,
  covered      bigint,
  deep         bigint,
  uncovered    bigint,
  coverage_pct numeric
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, research, urawa_log
AS $$
  SELECT area, total, covered, deep, uncovered, coverage_pct
  FROM research.claude_code_coverage
  ORDER BY area;
$$;

GRANT EXECUTE ON FUNCTION public.get_claude_code_coverage_summary()
  TO anon, authenticated, service_role;

COMMENT ON FUNCTION public.get_claude_code_coverage_summary() IS
  '領域別の coverage 進捗を返す。Routine の Step 9 サマリで利用。';

-- =====================================================
-- 4) upsert_claude_code_topic（seed スクリプト用）
-- =====================================================
CREATE OR REPLACE FUNCTION public.upsert_claude_code_topic(
  p_topic_id    text,
  p_area        text,
  p_subarea     text,
  p_title       text,
  p_description text,
  p_doc_url     text,
  p_priority    int
)
RETURNS void
LANGUAGE sql
VOLATILE
SECURITY DEFINER
SET search_path = public, research, urawa_log
AS $$
  INSERT INTO research.claude_code_topics
    (topic_id, area, subarea, title, description, doc_url, priority)
  VALUES
    (p_topic_id, p_area, p_subarea, p_title, p_description, p_doc_url, p_priority)
  ON CONFLICT (topic_id) DO UPDATE
    SET area        = EXCLUDED.area,
        subarea     = EXCLUDED.subarea,
        title       = EXCLUDED.title,
        description = EXCLUDED.description,
        doc_url     = EXCLUDED.doc_url,
        priority    = EXCLUDED.priority;
$$;

GRANT EXECUTE ON FUNCTION public.upsert_claude_code_topic(text, text, text, text, text, text, int)
  TO anon, authenticated, service_role;

COMMENT ON FUNCTION public.upsert_claude_code_topic(text, text, text, text, text, text, int) IS
  'docs/claude-code-learning-map.md からの seed 用。トピックを upsert する（coverage_status / article_count は維持）。';
