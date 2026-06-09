-- 学習マップ（スタンプラリー）の全ジャンル一般化テーブル
--
-- 用途:
--   夜間自律実行 auto-basics-fill（ローカル /loop）が、7ジャンルの「基礎の面」を
--   埋めるために未カバーの入門トピックを優先的に記事化する SSOT。
--   既存の claude_code_topics（Claude Code 限定）はそのまま温存し、本テーブルは
--   全7ジャンル（accounting / keiri_dx / ai_tech / tools / business / security_risk /
--   thinking_learning）の基礎トピックを扱う。Claude Code の基礎は claude_code_topics 側が担当。
--
-- SSOT:
--   docs/learning-maps/<genre>.md （人間編集 / PR レビュー対象）
--   scripts/seed-learning-topics.mjs で markdown → DB upsert
--
-- 冪等版（CLAUDE.md / dont-do.md 方針）。何度実行しても安全。

-- ============================================
-- STEP 1: learning_topics テーブル
-- ============================================
CREATE TABLE IF NOT EXISTS research.learning_topics (
  topic_id            text PRIMARY KEY,
  genre               text NOT NULL,                  -- 7ジャンルL1スラッグ
  area                text NOT NULL,                  -- ジャンル内クラスタ（例: 基礎概念 / 主要論点）
  subarea             text,
  title               text NOT NULL,
  description         text,
  doc_url             text,
  coverage_status     text NOT NULL DEFAULT 'uncovered'
                      CHECK (coverage_status IN ('uncovered', 'covered', 'deep', 'archived')),
  article_count       int  NOT NULL DEFAULT 0,
  related_article_ids uuid[] NOT NULL DEFAULT '{}',
  priority            int  NOT NULL DEFAULT 3 CHECK (priority BETWEEN 1 AND 5),
  last_covered_at     timestamptz,
  created_at          timestamptz NOT NULL DEFAULT now(),
  updated_at          timestamptz NOT NULL DEFAULT now()
);

-- genre は7ジャンルL1スラッグに限定（NOT VALID → VALIDATE で既存行があっても安全）
ALTER TABLE research.learning_topics
  DROP CONSTRAINT IF EXISTS chk_learning_genre;
ALTER TABLE research.learning_topics
  ADD CONSTRAINT chk_learning_genre CHECK (
    genre IN ('accounting','keiri_dx','ai_tech','tools','business','security_risk','thinking_learning')
  ) NOT VALID;
ALTER TABLE research.learning_topics VALIDATE CONSTRAINT chk_learning_genre;

CREATE INDEX IF NOT EXISTS idx_learn_topics_genre    ON research.learning_topics(genre);
CREATE INDEX IF NOT EXISTS idx_learn_topics_status   ON research.learning_topics(coverage_status);
CREATE INDEX IF NOT EXISTS idx_learn_topics_priority ON research.learning_topics(priority DESC);

-- RLS（既存テーブルと同じ運用: 公開読み取り / 公開書き込み）
ALTER TABLE research.learning_topics ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'research' AND tablename = 'learning_topics'
      AND policyname = 'Allow public read learning_topics'
  ) THEN
    CREATE POLICY "Allow public read learning_topics"
      ON research.learning_topics FOR SELECT USING (true);
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'research' AND tablename = 'learning_topics'
      AND policyname = 'Allow public write learning_topics'
  ) THEN
    CREATE POLICY "Allow public write learning_topics"
      ON research.learning_topics FOR ALL USING (true) WITH CHECK (true);
  END IF;
END $$;

-- updated_at 自動更新トリガー
CREATE OR REPLACE FUNCTION research.touch_learning_topics_updated_at()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_touch_learning_topics_updated_at ON research.learning_topics;
CREATE TRIGGER trg_touch_learning_topics_updated_at
  BEFORE UPDATE ON research.learning_topics
  FOR EACH ROW EXECUTE FUNCTION research.touch_learning_topics_updated_at();

-- ジャンル×領域別 進捗ビュー
CREATE OR REPLACE VIEW research.learning_coverage AS
SELECT
  genre,
  area,
  COUNT(*) AS total,
  COUNT(*) FILTER (WHERE coverage_status = 'covered')   AS covered,
  COUNT(*) FILTER (WHERE coverage_status = 'deep')       AS deep,
  COUNT(*) FILTER (WHERE coverage_status = 'uncovered')  AS uncovered,
  ROUND(
    (COUNT(*) FILTER (WHERE coverage_status IN ('covered','deep')))::numeric
    / NULLIF(COUNT(*) FILTER (WHERE coverage_status != 'archived'), 0)::numeric * 100,
    1
  ) AS coverage_pct
FROM research.learning_topics
WHERE coverage_status != 'archived'
GROUP BY genre, area
ORDER BY genre, area;

GRANT SELECT ON research.learning_coverage TO anon, authenticated, service_role;

COMMENT ON TABLE research.learning_topics IS
  '全7ジャンルの学習マップ（基礎の面埋め）。SSOT は docs/learning-maps/<genre>.md。Claude Code 基礎は claude_code_topics 側。';

-- ============================================
-- STEP 2: source_type に 'basics_fill' を追加（ニュース/基礎の識別用）
-- ============================================
ALTER TABLE research.articles DROP CONSTRAINT IF EXISTS chk_source_type;
ALTER TABLE research.articles
  ADD CONSTRAINT chk_source_type
  CHECK (source_type IN (
    'auto_research', 'manual_clip', 'manual_note', 'external_article', 'basics_fill'
  )) NOT VALID;
ALTER TABLE research.articles VALIDATE CONSTRAINT chk_source_type;

-- ============================================
-- STEP 3: RPC（public スキーマ・SECURITY DEFINER・urawa_log 同居対応）
-- ============================================

-- 3-1) 未カバートピック取得（genre 任意フィルタ）
CREATE OR REPLACE FUNCTION public.get_uncovered_learning_topics(
  p_genre text DEFAULT NULL,
  p_limit int  DEFAULT 10
)
RETURNS TABLE (
  topic_id text, genre text, area text, subarea text, title text,
  description text, doc_url text, priority int,
  coverage_status text, article_count int, last_covered_at timestamptz
)
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public, research, urawa_log
AS $$
  SELECT t.topic_id, t.genre, t.area, t.subarea, t.title,
         t.description, t.doc_url, t.priority,
         t.coverage_status, t.article_count, t.last_covered_at
  FROM research.learning_topics t
  WHERE t.coverage_status IN ('uncovered', 'covered')
    AND (p_genre IS NULL OR t.genre = p_genre)
  ORDER BY
    CASE t.coverage_status WHEN 'uncovered' THEN 0 WHEN 'covered' THEN 1 ELSE 2 END ASC,
    t.priority DESC,
    t.last_covered_at ASC NULLS FIRST,
    t.topic_id ASC
  LIMIT GREATEST(p_limit, 1);
$$;

GRANT EXECUTE ON FUNCTION public.get_uncovered_learning_topics(text, int)
  TO anon, authenticated, service_role;

-- 3-2) トピックを記事化済みにマーク（uncovered→covered, covered→deep）
CREATE OR REPLACE FUNCTION public.mark_learning_topic_covered(
  p_topic_id text, p_article_id uuid
)
RETURNS TABLE (topic_id text, coverage_status text, article_count int)
LANGUAGE plpgsql VOLATILE SECURITY DEFINER
SET search_path = public, research, urawa_log
AS $$
DECLARE
  v_current text;
  v_new     text;
BEGIN
  SELECT t.coverage_status INTO v_current
  FROM research.learning_topics t WHERE t.topic_id = p_topic_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION '指定された topic_id が存在しません: %', p_topic_id;
  END IF;

  v_new := CASE v_current
    WHEN 'uncovered' THEN 'covered'
    WHEN 'covered'   THEN 'deep'
    WHEN 'deep'      THEN 'deep'
    ELSE v_current
  END;

  UPDATE research.learning_topics t
     SET coverage_status     = v_new,
         article_count       = t.article_count + 1,
         related_article_ids = array_append(t.related_article_ids, p_article_id),
         last_covered_at     = now()
   WHERE t.topic_id = p_topic_id;

  RETURN QUERY
    SELECT t.topic_id, t.coverage_status, t.article_count
    FROM research.learning_topics t WHERE t.topic_id = p_topic_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.mark_learning_topic_covered(text, uuid)
  TO anon, authenticated, service_role;

-- 3-3) カバレッジ進捗サマリ（genre 任意フィルタ）
CREATE OR REPLACE FUNCTION public.get_learning_coverage_summary(
  p_genre text DEFAULT NULL
)
RETURNS TABLE (
  genre text, area text, total bigint,
  covered bigint, deep bigint, uncovered bigint, coverage_pct numeric
)
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public, research, urawa_log
AS $$
  SELECT genre, area, total, covered, deep, uncovered, coverage_pct
  FROM research.learning_coverage
  WHERE (p_genre IS NULL OR genre = p_genre)
  ORDER BY genre, area;
$$;

GRANT EXECUTE ON FUNCTION public.get_learning_coverage_summary(text)
  TO anon, authenticated, service_role;

-- 3-4) seed スクリプト用 upsert（coverage_status / article_count は維持）
CREATE OR REPLACE FUNCTION public.upsert_learning_topic(
  p_topic_id text, p_genre text, p_area text, p_subarea text,
  p_title text, p_description text, p_doc_url text, p_priority int
)
RETURNS void
LANGUAGE sql VOLATILE SECURITY DEFINER
SET search_path = public, research, urawa_log
AS $$
  INSERT INTO research.learning_topics
    (topic_id, genre, area, subarea, title, description, doc_url, priority)
  VALUES
    (p_topic_id, p_genre, p_area, p_subarea, p_title, p_description, p_doc_url, p_priority)
  ON CONFLICT (topic_id) DO UPDATE
    SET genre = EXCLUDED.genre, area = EXCLUDED.area, subarea = EXCLUDED.subarea,
        title = EXCLUDED.title, description = EXCLUDED.description,
        doc_url = EXCLUDED.doc_url, priority = EXCLUDED.priority;
$$;

GRANT EXECUTE ON FUNCTION public.upsert_learning_topic(text, text, text, text, text, text, text, int)
  TO anon, authenticated, service_role;

-- ============================================
-- 検証
-- ============================================
SELECT 'learning_topics 作成完了' AS status,
       (SELECT count(*) FROM research.learning_topics) AS topic_count;
