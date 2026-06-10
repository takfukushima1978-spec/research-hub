-- get_preference_profile
-- クリップ済み記事 (is_clipped=true) のタグ/ジャンルを recency weighting 付きで集計し、
-- 「好みプロファイル」を返す。auto-research-collect が毎晩の topic 選定前に呼び出し、
-- ADR-LG-009 (tak-lifelog) の「好み50/バランス30/探索20」ミックスの入力として使う。
--
-- 重み = Σ 0.5^(クリップからの経過日数 / 半減期)
--   半減期 p_half_life_days (デフォルト30日) で直近のクリップを重めに評価する。
-- 集計を SQL 側に置く理由: プロンプト内で夜間エージェントに生記事から集計させると
--   実行ごとにブレる。RPC なら決定的・低トークンで再現性がある。

CREATE OR REPLACE FUNCTION public.get_preference_profile(
  p_half_life_days int DEFAULT 30,
  p_lookback_days  int DEFAULT 180
)
RETURNS jsonb
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public, research
AS $$
WITH clipped AS (
  SELECT
    a.id,
    a.category_id,
    COALESCE(a.clipped_at, a.updated_at, now()) AS clip_ts,
    power(
      0.5,
      EXTRACT(EPOCH FROM (now() - COALESCE(a.clipped_at, a.updated_at, now())))
        / 86400.0
        / GREATEST(p_half_life_days, 1)
    ) AS w
  FROM research.articles a
  WHERE a.is_clipped = true
    AND a.status = 'published'
    AND COALESCE(a.clipped_at, a.updated_at, now())
        >= now() - (GREATEST(p_lookback_days, 1) || ' days')::interval
),
tag_agg AS (
  SELECT
    t.name,
    t.level,
    pt.name           AS parent,
    SUM(c.w)          AS weight,
    COUNT(*)          AS clip_count,
    MAX(c.clip_ts)    AS last_clipped_at
  FROM clipped c
  JOIN research.article_tags at_ ON at_.article_id = c.id
  JOIN research.tags t           ON t.id = at_.tag_id
  LEFT JOIN research.tags pt     ON pt.id = t.parent_id
  GROUP BY t.name, t.level, pt.name
),
genre_agg AS (
  SELECT
    cat.name          AS category,
    SUM(c.w)          AS weight,
    COUNT(*)          AS clip_count
  FROM clipped c
  LEFT JOIN research.categories cat ON cat.id = c.category_id
  GROUP BY cat.name
)
SELECT jsonb_build_object(
  'total_clips',    (SELECT COUNT(*) FROM clipped),
  'half_life_days', p_half_life_days,
  'lookback_days',  p_lookback_days,
  'tags', COALESCE(
    (
      SELECT jsonb_agg(
        jsonb_build_object(
          'name', s.name,
          'level', s.level,
          'parent', s.parent,
          'weight', round(s.weight::numeric, 4),
          'clip_count', s.clip_count,
          'last_clipped_at', s.last_clipped_at
        )
      )
      FROM (
        SELECT * FROM tag_agg
        ORDER BY weight DESC, clip_count DESC, name
        LIMIT 30
      ) s
    ),
    '[]'::jsonb
  ),
  'genres', COALESCE(
    (
      SELECT jsonb_agg(
        jsonb_build_object(
          'category', g.category,
          'weight', round(g.weight::numeric, 4),
          'clip_count', g.clip_count
        )
      )
      FROM (
        SELECT * FROM genre_agg
        ORDER BY weight DESC, clip_count DESC
      ) g
    ),
    '[]'::jsonb
  )
);
$$;

GRANT EXECUTE ON FUNCTION public.get_preference_profile(int, int) TO anon, authenticated, service_role;

COMMENT ON FUNCTION public.get_preference_profile(int, int) IS
  'クリップ記事のタグ/ジャンルを recency weighting (半減期 p_half_life_days) で集計した好みプロファイルを返す。auto-research-collect の topic 選定用 (ADR-LG-009)。';
