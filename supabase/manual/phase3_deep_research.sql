-- ============================================
-- Research Hub - Phase 3: Deep Research
-- 深掘りリクエスト＋リサーチ結果テーブル
-- ============================================

BEGIN;

-- ============================================
-- deep_research_requests: 深掘りリクエスト管理
-- ============================================
CREATE TABLE IF NOT EXISTS research.deep_research_requests (
  id              UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  article_id      UUID REFERENCES research.articles(id) ON DELETE CASCADE,

  -- リクエスト内容
  focus_point     TEXT NOT NULL,          -- 深掘りしてほしいポイント
  additional_context TEXT,                -- 追加の文脈・質問

  -- ステータス管理
  status          TEXT DEFAULT 'pending'
                  CHECK (status IN ('pending', 'processing', 'completed', 'failed')),
  priority        INT DEFAULT 5           -- 1(最高)〜10(最低)
                  CHECK (priority BETWEEN 1 AND 10),

  -- スケジュール
  scheduled_at    TIMESTAMPTZ,            -- 実行予定日時（NULLなら次回のタスク実行時）
  started_at      TIMESTAMPTZ,
  completed_at    TIMESTAMPTZ,

  -- 結果
  result_doc_url  TEXT,                   -- Googleドキュメントの URL
  result_summary  TEXT,                   -- リサーチ結果の要約
  result_body     TEXT,                   -- リサーチ結果の全文

  -- NotebookLM連携
  notebooklm_status TEXT DEFAULT 'not_started'
                  CHECK (notebooklm_status IN ('not_started', 'doc_ready', 'audio_ready', 'slides_ready')),

  created_at      TIMESTAMPTZ DEFAULT now(),
  updated_at      TIMESTAMPTZ DEFAULT now()
);

-- インデックス
CREATE INDEX IF NOT EXISTS idx_drr_article ON research.deep_research_requests(article_id);
CREATE INDEX IF NOT EXISTS idx_drr_status ON research.deep_research_requests(status);
CREATE INDEX IF NOT EXISTS idx_drr_pending ON research.deep_research_requests(status, priority) WHERE status = 'pending';

-- RLS
ALTER TABLE research.deep_research_requests ENABLE ROW LEVEL SECURITY;
CREATE POLICY "drr_select" ON research.deep_research_requests FOR SELECT USING (true);
CREATE POLICY "drr_insert_auth" ON research.deep_research_requests FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "drr_update_auth" ON research.deep_research_requests FOR UPDATE TO authenticated USING (true) WITH CHECK (true);

-- ============================================
-- RPC: 深掘りリクエスト登録
-- ============================================
CREATE OR REPLACE FUNCTION public.create_deep_research_request(
  p_article_id uuid,
  p_focus_point text,
  p_additional_context text DEFAULT NULL,
  p_priority int DEFAULT 5
) RETURNS uuid
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = research, public AS $$
DECLARE
  v_id uuid;
BEGIN
  IF p_focus_point IS NULL OR trim(p_focus_point) = '' THEN
    RAISE EXCEPTION 'focus_point is required';
  END IF;

  -- 記事存在チェック
  IF NOT EXISTS (SELECT 1 FROM research.articles WHERE id = p_article_id) THEN
    RAISE EXCEPTION 'Article not found: %', p_article_id;
  END IF;

  INSERT INTO research.deep_research_requests (
    article_id, focus_point, additional_context, priority
  ) VALUES (
    p_article_id, p_focus_point, p_additional_context, p_priority
  ) RETURNING id INTO v_id;

  -- 元記事をクリップ状態にする（まだでなければ）
  UPDATE research.articles
  SET is_clipped = true,
      clipped_at = COALESCE(clipped_at, now()),
      updated_at = now()
  WHERE id = p_article_id AND NOT is_clipped;

  RETURN v_id;
END; $$;

-- ============================================
-- RPC: 未処理リクエスト一覧取得（タスク実行用）
-- ============================================
CREATE OR REPLACE FUNCTION public.get_pending_research_requests(
  p_limit int DEFAULT 5
) RETURNS TABLE (
  request_id uuid,
  article_id uuid,
  article_title text,
  article_summary text,
  focus_point text,
  additional_context text,
  priority int
)
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = research, public AS $$
BEGIN
  RETURN QUERY
  SELECT
    r.id as request_id,
    r.article_id,
    a.title_ja as article_title,
    a.summary as article_summary,
    r.focus_point,
    r.additional_context,
    r.priority
  FROM research.deep_research_requests r
  JOIN research.articles a ON a.id = r.article_id
  WHERE r.status = 'pending'
  ORDER BY r.priority ASC, r.created_at ASC
  LIMIT p_limit;
END; $$;

-- ============================================
-- RPC: リサーチ結果を保存
-- ============================================
CREATE OR REPLACE FUNCTION public.complete_deep_research(
  p_request_id uuid,
  p_result_summary text,
  p_result_body text,
  p_result_doc_url text DEFAULT NULL
) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = research, public AS $$
BEGIN
  UPDATE research.deep_research_requests
  SET status = 'completed',
      completed_at = now(),
      result_summary = p_result_summary,
      result_body = p_result_body,
      result_doc_url = p_result_doc_url,
      notebooklm_status = CASE WHEN p_result_doc_url IS NOT NULL THEN 'doc_ready' ELSE 'not_started' END,
      updated_at = now()
  WHERE id = p_request_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Request not found: %', p_request_id;
  END IF;
END; $$;

-- ============================================
-- RPC: 記事の深掘り結果取得（ビューアー用）
-- ============================================
CREATE OR REPLACE FUNCTION public.get_article_research(
  p_article_id uuid
) RETURNS TABLE (
  request_id uuid,
  focus_point text,
  status text,
  result_summary text,
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
    r.status,
    r.result_summary,
    r.result_doc_url,
    r.notebooklm_status,
    r.created_at,
    r.completed_at
  FROM research.deep_research_requests r
  WHERE r.article_id = p_article_id
  ORDER BY r.created_at DESC;
END; $$;

-- GRANT
GRANT EXECUTE ON FUNCTION public.create_deep_research_request TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.get_pending_research_requests TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.complete_deep_research TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.get_article_research TO anon, authenticated;

COMMIT;

-- 確認
DO $$
BEGIN
  RAISE NOTICE 'Phase 3 Deep Research テーブル＆関数の作成完了!';
END $$;
