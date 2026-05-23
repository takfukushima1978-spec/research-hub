-- ============================================
-- パーソナルAIリサーチ基盤 - Phase 2
-- セマンティック検索用RPC関数
--
-- 実行方法: Supabaseダッシュボード → SQL Editor → New Query
-- このファイルの内容をすべてコピペして「Run」
-- ============================================

-- ============================================
-- セマンティック検索関数
-- ベクトル類似度で記事を検索
-- ============================================
CREATE OR REPLACE FUNCTION research.search_articles(
  query_embedding vector(1536),
  match_threshold float DEFAULT 0.7,
  match_count int DEFAULT 10,
  filter_category uuid DEFAULT NULL,
  filter_status text DEFAULT 'published'
)
RETURNS TABLE (
  id uuid,
  title_ja text,
  summary text,
  source_date date,
  slug text,
  category_name text,
  similarity float
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = research, public
AS $$
BEGIN
  RETURN QUERY
  SELECT
    a.id,
    a.title_ja,
    a.summary,
    a.source_date,
    a.slug,
    c.label_ja as category_name,
    1 - (e.embedding <=> query_embedding) as similarity
  FROM research.article_embeddings e
  JOIN research.articles a ON a.id = e.article_id
  LEFT JOIN research.categories c ON c.id = a.category_id
  WHERE 1 - (e.embedding <=> query_embedding) > match_threshold
    AND (filter_category IS NULL OR a.category_id = filter_category)
    AND a.status = filter_status
  ORDER BY similarity DESC
  LIMIT match_count;
END;
$$;

-- ============================================
-- キーワード検索関数（全文検索）
-- セマンティック検索の補完用
-- ============================================
CREATE OR REPLACE FUNCTION research.keyword_search(
  query_text text,
  match_count int DEFAULT 10
)
RETURNS TABLE (
  id uuid,
  title_ja text,
  summary text,
  source_date date,
  slug text,
  category_name text
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = research, public
AS $$
BEGIN
  RETURN QUERY
  SELECT
    a.id,
    a.title_ja,
    a.summary,
    a.source_date,
    a.slug,
    c.label_ja as category_name
  FROM research.articles a
  LEFT JOIN research.categories c ON c.id = a.category_id
  WHERE a.status = 'published'
    AND (
      a.title_ja ILIKE '%' || query_text || '%'
      OR a.body_text ILIKE '%' || query_text || '%'
      OR a.summary ILIKE '%' || query_text || '%'
    )
  ORDER BY a.source_date DESC
  LIMIT match_count;
END;
$$;

-- ============================================
-- 記事一覧取得関数（カテゴリ・日付フィルタ）
-- ============================================
CREATE OR REPLACE FUNCTION research.list_articles(
  filter_category text DEFAULT NULL,
  filter_after date DEFAULT NULL,
  filter_before date DEFAULT NULL,
  page_size int DEFAULT 20,
  page_offset int DEFAULT 0
)
RETURNS TABLE (
  id uuid,
  title_ja text,
  summary text,
  source_date date,
  slug text,
  category_name text,
  tags text[]
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = research, public
AS $$
BEGIN
  RETURN QUERY
  SELECT
    a.id,
    a.title_ja,
    a.summary,
    a.source_date,
    a.slug,
    c.label_ja as category_name,
    ARRAY(
      SELECT t.name FROM research.article_tags at2
      JOIN research.tags t ON t.id = at2.tag_id
      WHERE at2.article_id = a.id
    ) as tags
  FROM research.articles a
  LEFT JOIN research.categories c ON c.id = a.category_id
  WHERE a.status = 'published'
    AND (filter_category IS NULL OR c.name = filter_category)
    AND (filter_after IS NULL OR a.source_date >= filter_after)
    AND (filter_before IS NULL OR a.source_date <= filter_before)
  ORDER BY a.source_date DESC
  LIMIT page_size
  OFFSET page_offset;
END;
$$;

-- ============================================
-- 統計関数
-- ============================================
CREATE OR REPLACE FUNCTION research.get_stats()
RETURNS TABLE (
  total_articles int,
  total_sources int,
  total_embeddings int,
  categories_summary jsonb,
  date_range jsonb
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = research, public
AS $$
BEGIN
  RETURN QUERY
  SELECT
    (SELECT count(*)::int FROM research.articles WHERE status = 'published'),
    (SELECT count(*)::int FROM research.research_sources),
    (SELECT count(*)::int FROM research.article_embeddings),
    (SELECT jsonb_agg(jsonb_build_object('category', c.label_ja, 'count', cnt))
     FROM (
       SELECT a.category_id, count(*) as cnt
       FROM research.articles a WHERE a.status = 'published'
       GROUP BY a.category_id
     ) sub
     JOIN research.categories c ON c.id = sub.category_id),
    jsonb_build_object(
      'earliest', (SELECT min(source_date) FROM research.articles WHERE status = 'published'),
      'latest', (SELECT max(source_date) FROM research.articles WHERE status = 'published')
    );
END;
$$;

-- ============================================
-- RPC関数のアクセス権付与
-- ============================================
GRANT EXECUTE ON FUNCTION research.search_articles TO anon, authenticated;
GRANT EXECUTE ON FUNCTION research.keyword_search TO anon, authenticated;
GRANT EXECUTE ON FUNCTION research.list_articles TO anon, authenticated;
GRANT EXECUTE ON FUNCTION research.get_stats TO anon, authenticated;

-- ============================================
-- 完了メッセージ
-- ============================================
DO $$
BEGIN
  RAISE NOTICE 'セマンティック検索関数の作成が完了しました！';
  RAISE NOTICE '関数: search_articles, keyword_search, list_articles, get_stats';
END $$;
