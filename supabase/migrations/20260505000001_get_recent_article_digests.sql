-- get_recent_article_digests
-- 直近 N 日間の記事ダイジェストを返す。
-- auto-research-collect スケジュールタスクが収集前に呼び出し、
-- テーマ・固有名詞・タグの重複を避けるための入力として利用する。

CREATE OR REPLACE FUNCTION public.get_recent_article_digests(p_days int DEFAULT 14)
RETURNS TABLE (
  id            uuid,
  title         text,
  summary       text,
  source_date   date,
  category_name text,
  category_label text,
  tags          text[]
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, research
AS $$
  SELECT
    a.id,
    a.title_ja            AS title,
    a.summary,
    a.source_date,
    c.name                AS category_name,
    c.label_ja            AS category_label,
    COALESCE(
      ARRAY(
        SELECT t.name
        FROM research.article_tags at
        JOIN research.tags t ON t.id = at.tag_id
        WHERE at.article_id = a.id
        ORDER BY t.name
      ),
      ARRAY[]::text[]
    ) AS tags
  FROM research.articles a
  LEFT JOIN research.categories c ON c.id = a.category_id
  WHERE a.status = 'published'
    AND a.source_date >= (CURRENT_DATE - (GREATEST(p_days, 1) || ' days')::interval)::date
  ORDER BY a.source_date DESC, a.id DESC
  LIMIT 200;
$$;

GRANT EXECUTE ON FUNCTION public.get_recent_article_digests(int) TO anon, authenticated, service_role;

COMMENT ON FUNCTION public.get_recent_article_digests(int) IS
  '直近 p_days 日間の published 記事ダイジェスト (title/summary/tags/category) を返す。重複テーマ検知用。';
