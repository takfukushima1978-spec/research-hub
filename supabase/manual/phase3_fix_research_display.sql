-- ============================================
-- Research Hub - Phase 3 修正
-- get_article_research RPC に result_body を追加
-- ============================================

CREATE OR REPLACE FUNCTION public.get_article_research(
  p_article_id uuid
) RETURNS TABLE (
  request_id uuid,
  focus_point text,
  additional_context text,
  status text,
  result_summary text,
  result_body text,
  result_doc_url text,
  notebooklm_status text,
  created_at timestamptz,
  completed_at timestamptz
)
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = research, public AS $$
BEGIN
  RETURN QUERY
  SELECT
    r.id as request_id,
    r.focus_point,
    r.additional_context,
    r.status,
    r.result_summary,
    r.result_body,
    r.result_doc_url,
    r.notebooklm_status,
    r.created_at,
    r.completed_at
  FROM research.deep_research_requests r
  WHERE r.article_id = p_article_id
  ORDER BY r.created_at DESC;
END; $$;

GRANT EXECUTE ON FUNCTION public.get_article_research TO anon, authenticated;

DO $$ BEGIN
  RAISE NOTICE 'get_article_research RPC updated with result_body';
END $$;
