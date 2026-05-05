-- pgvector ベースの重複検知スキャフォールド (opt-in)
--
-- 用途:
--   auto-research-collect が記事投入時に embedding を計算して送ると、
--   insert-article が既存記事の embedding と cosine 類似度を比較し、
--   閾値超なら 409 で重複拒否できる。
--
-- 前提:
--   embedding は呼び出し側 (スケジュールタスク or Edge Function) で生成する。
--   推奨: OpenAI text-embedding-3-small (1536 dim) または Voyage AI voyage-3 (1024 dim)。
--   ここでは 1536 を採用。次元を変える場合は ALTER TABLE で調整。
--
-- 適用は任意。embedding を送らない既存フローはこれまで通り動作する (NULL のまま挿入)。

CREATE EXTENSION IF NOT EXISTS vector;

ALTER TABLE research.articles
  ADD COLUMN IF NOT EXISTS embedding vector(1536);

-- IVF Flat index は行数が多くなってから作る方が効率的だが、
-- 初期段階は HNSW (より高品質) でも IVF でも可。pgvector >= 0.5 なら HNSW が利用可能。
-- ここでは安全側で IVF を作成 (lists は規模に応じて調整)。
CREATE INDEX IF NOT EXISTS articles_embedding_cosine_idx
  ON research.articles
  USING ivfflat (embedding vector_cosine_ops)
  WITH (lists = 100);

-- 類似記事検索 RPC
-- 与えられた embedding と既存 published 記事の cosine 類似度を計算し、
-- 閾値以上のものを類似度降順で返す。
CREATE OR REPLACE FUNCTION public.find_similar_articles_by_embedding(
  p_embedding   vector(1536),
  p_threshold   float DEFAULT 0.85,
  p_days        int   DEFAULT 30,
  p_limit       int   DEFAULT 5
)
RETURNS TABLE (
  id            uuid,
  title         text,
  summary       text,
  source_date   date,
  similarity    float
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, research, urawa_log
AS $$
  SELECT
    a.id,
    a.title_ja AS title,
    a.summary,
    a.source_date,
    (1 - (a.embedding <=> p_embedding))::float AS similarity
  FROM research.articles a
  WHERE a.status = 'published'
    AND a.embedding IS NOT NULL
    AND a.source_date >= (CURRENT_DATE - (GREATEST(p_days, 1) || ' days')::interval)::date
    AND (1 - (a.embedding <=> p_embedding)) >= p_threshold
  ORDER BY a.embedding <=> p_embedding ASC
  LIMIT GREATEST(p_limit, 1);
$$;

GRANT EXECUTE ON FUNCTION public.find_similar_articles_by_embedding(vector, float, int, int)
  TO anon, authenticated, service_role;

COMMENT ON FUNCTION public.find_similar_articles_by_embedding(vector, float, int, int) IS
  '与えられた embedding と類似する既存記事を返す。閾値以上のものが存在すれば重複とみなす運用想定。';

-- 既存記事に embedding を後付けで設定する RPC
-- insert-article は anon key で動作するため、テーブル直接 UPDATE はせずこの RPC 経由で書き戻す。
CREATE OR REPLACE FUNCTION public.update_article_embedding(
  p_article_id uuid,
  p_embedding  vector(1536)
)
RETURNS void
LANGUAGE sql
VOLATILE
SECURITY DEFINER
SET search_path = public, research, urawa_log
AS $$
  UPDATE research.articles
     SET embedding = p_embedding
   WHERE id = p_article_id;
$$;

GRANT EXECUTE ON FUNCTION public.update_article_embedding(uuid, vector)
  TO anon, authenticated, service_role;

COMMENT ON FUNCTION public.update_article_embedding(uuid, vector) IS
  '記事に embedding を設定する。insert-article が記事投入後に呼び出す。';
