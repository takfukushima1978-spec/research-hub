-- 記事フィードバック → フォローアップ記事自動生成
--
-- 用途:
--   ビューワーの記事詳細画面で Tak が自由入力したフィードバック（「もっと知りたい」
--   「ここを詳しく」等）を蓄積し、翌朝の feedback-article-runner（スケジュールタスク）が
--   pending を拾って、フィードバック内容を起点に追加の詳細記事を自動生成する。
--
-- フロー:
--   [UI] submit_article_feedback (status=pending)
--     → [runner] get_pending_feedbacks で取得 → 記事生成 → insert-article
--     → complete_article_feedback (status=completed, follow_up_article_id をリンク)
--
-- 冪等版（CLAUDE.md / dont-do.md 方針）。何度実行しても安全。

-- ============================================
-- STEP 1: article_feedbacks テーブル
-- ============================================
CREATE TABLE IF NOT EXISTS research.article_feedbacks (
  id                   uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  article_id           uuid NOT NULL REFERENCES research.articles(id) ON DELETE CASCADE,
  feedback_text        text NOT NULL,
  status               text NOT NULL DEFAULT 'pending'
                       CHECK (status IN ('pending', 'processing', 'completed', 'skipped')),
  follow_up_article_id uuid REFERENCES research.articles(id) ON DELETE SET NULL,
  note                 text,                       -- runner が skip 理由等を残す
  created_at           timestamptz NOT NULL DEFAULT now(),
  completed_at         timestamptz
);

CREATE INDEX IF NOT EXISTS idx_article_feedbacks_status     ON research.article_feedbacks(status);
CREATE INDEX IF NOT EXISTS idx_article_feedbacks_article_id ON research.article_feedbacks(article_id);
CREATE INDEX IF NOT EXISTS idx_article_feedbacks_created_at ON research.article_feedbacks(created_at DESC);

-- RLS（既存テーブルと同じ運用: 公開読み取り / 公開書き込み）
ALTER TABLE research.article_feedbacks ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'research' AND tablename = 'article_feedbacks'
      AND policyname = 'Allow public read article_feedbacks'
  ) THEN
    CREATE POLICY "Allow public read article_feedbacks"
      ON research.article_feedbacks FOR SELECT USING (true);
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'research' AND tablename = 'article_feedbacks'
      AND policyname = 'Allow public write article_feedbacks'
  ) THEN
    CREATE POLICY "Allow public write article_feedbacks"
      ON research.article_feedbacks FOR ALL USING (true) WITH CHECK (true);
  END IF;
END $$;

COMMENT ON TABLE research.article_feedbacks IS
  '記事へのフィードバック自由入力。feedback-article-runner が pending を拾い追加詳細記事を自動生成する。';

-- ============================================
-- STEP 2: RPC（public スキーマ・SECURITY DEFINER・urawa_log 同居対応）
-- ============================================

-- 2-1) フィードバック送信（UI から呼ぶ・anon 許可）
CREATE OR REPLACE FUNCTION public.submit_article_feedback(
  p_article_id    uuid,
  p_feedback_text text
)
RETURNS jsonb
LANGUAGE plpgsql VOLATILE SECURITY DEFINER
SET search_path = public, research, urawa_log
AS $$
DECLARE
  v_id      uuid;
  v_trimmed text := btrim(p_feedback_text);
BEGIN
  IF v_trimmed = '' OR v_trimmed IS NULL THEN
    RAISE EXCEPTION 'フィードバック本文が空です';
  END IF;

  -- 起点記事の存在チェック
  IF NOT EXISTS (SELECT 1 FROM research.articles a WHERE a.id = p_article_id) THEN
    RAISE EXCEPTION '指定された記事が存在しません: %', p_article_id;
  END IF;

  INSERT INTO research.article_feedbacks (article_id, feedback_text)
  VALUES (p_article_id, v_trimmed)
  RETURNING id INTO v_id;

  RETURN jsonb_build_object('id', v_id, 'article_id', p_article_id, 'status', 'pending');
END;
$$;

GRANT EXECUTE ON FUNCTION public.submit_article_feedback(uuid, text)
  TO anon, authenticated, service_role;

-- 2-2) pending フィードバック一覧取得（runner が呼ぶ・起点記事の文脈を同梱）
CREATE OR REPLACE FUNCTION public.get_pending_feedbacks(
  p_limit int DEFAULT 3
)
RETURNS TABLE (
  feedback_id    uuid,
  feedback_text  text,
  created_at     timestamptz,
  article_id     uuid,
  article_title  text,
  article_summary text,
  category_name  text,
  tags           text[]
)
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public, research, urawa_log
AS $$
  SELECT
    f.id            AS feedback_id,
    f.feedback_text,
    f.created_at,
    a.id            AS article_id,
    a.title_ja      AS article_title,
    a.summary       AS article_summary,
    c.name          AS category_name,
    COALESCE(
      ARRAY(
        SELECT t.name
        FROM research.article_tags at_
        JOIN research.tags t ON t.id = at_.tag_id
        WHERE at_.article_id = a.id
        ORDER BY t.name
      ),
      ARRAY[]::text[]
    ) AS tags
  FROM research.article_feedbacks f
  JOIN research.articles a    ON a.id = f.article_id
  LEFT JOIN research.categories c ON c.id = a.category_id
  WHERE f.status = 'pending'
  ORDER BY f.created_at ASC
  LIMIT GREATEST(p_limit, 1);
$$;

GRANT EXECUTE ON FUNCTION public.get_pending_feedbacks(int)
  TO anon, authenticated, service_role;

-- 2-3) フィードバック完了マーク（runner が呼ぶ・follow_up 記事をリンク or skip）
CREATE OR REPLACE FUNCTION public.complete_article_feedback(
  p_feedback_id         uuid,
  p_follow_up_article_id uuid DEFAULT NULL,
  p_status              text DEFAULT 'completed',
  p_note                text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql VOLATILE SECURITY DEFINER
SET search_path = public, research, urawa_log
AS $$
DECLARE
  v_status text := COALESCE(p_status, 'completed');
BEGIN
  IF v_status NOT IN ('completed', 'skipped', 'processing') THEN
    RAISE EXCEPTION '不正な status: %', v_status;
  END IF;

  UPDATE research.article_feedbacks
     SET status               = v_status,
         follow_up_article_id = p_follow_up_article_id,
         note                 = p_note,
         completed_at         = CASE WHEN v_status IN ('completed', 'skipped') THEN now() ELSE NULL END
   WHERE id = p_feedback_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION '指定された feedback_id が存在しません: %', p_feedback_id;
  END IF;

  RETURN jsonb_build_object('feedback_id', p_feedback_id, 'status', v_status,
                            'follow_up_article_id', p_follow_up_article_id);
END;
$$;

GRANT EXECUTE ON FUNCTION public.complete_article_feedback(uuid, uuid, text, text)
  TO anon, authenticated, service_role;

-- ============================================
-- 検証
-- ============================================
SELECT 'article_feedbacks 作成完了' AS status,
       (SELECT count(*) FROM research.article_feedbacks) AS feedback_count;
