-- ============================================
-- パーソナルAIリサーチ基盤
-- 記事ビューアー用RPC関数
--
-- Edge Functionから呼び出して、CSSテンプレート+body_htmlを
-- 結合した完全なHTMLを返す関数
--
-- 実行方法: Supabaseダッシュボード → SQL Editor → Run
-- ============================================

-- 単一記事のフルHTML生成
CREATE OR REPLACE FUNCTION public.get_article_html(article_slug text)
RETURNS TABLE (
  full_html text,
  title_ja text,
  source_date date
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = research, public
AS $$
DECLARE
  v_article research.articles%ROWTYPE;
  v_css text;
  v_sources text := '';
  v_tags text := '';
  rec record;
BEGIN
  -- 記事を取得
  SELECT * INTO v_article
  FROM research.articles a
  WHERE a.slug = article_slug AND a.status = 'published';

  IF NOT FOUND THEN
    RETURN QUERY SELECT
      '<html><body><h1>404 - Article Not Found</h1></body></html>'::text,
      'Not Found'::text,
      NULL::date;
    RETURN;
  END IF;

  -- CSSテンプレート取得
  SELECT css_content INTO v_css
  FROM research.css_templates
  WHERE id = v_article.css_template_id;

  IF v_css IS NULL THEN
    SELECT css_content INTO v_css
    FROM research.css_templates
    WHERE is_default = true
    LIMIT 1;
  END IF;

  -- HTMLを結合して返す
  RETURN QUERY SELECT
    '<!DOCTYPE html><html lang="ja"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0"><title>' ||
    COALESCE(v_article.title_ja, v_article.title) ||
    '</title><style>' ||
    COALESCE(v_css, '') ||
    '</style></head><body>' ||
    COALESCE(v_article.body_html, '<p>No content</p>') ||
    '</body></html>',
    v_article.title_ja,
    v_article.source_date;
END;
$$;

-- 記事一覧のHTML生成（トップページ用）
CREATE OR REPLACE FUNCTION public.get_articles_index_html(
  p_category text DEFAULT NULL,
  p_limit int DEFAULT 30
)
RETURNS TABLE (full_html text)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = research, public
AS $$
DECLARE
  v_body text := '';
  rec record;
BEGIN
  -- 記事一覧を構築
  FOR rec IN
    SELECT a.slug, a.title_ja, a.summary, a.source_date, c.label_ja as cat_label
    FROM research.articles a
    LEFT JOIN research.categories c ON c.id = a.category_id
    WHERE a.status = 'published'
      AND (p_category IS NULL OR c.name = p_category)
    ORDER BY a.source_date DESC
    LIMIT p_limit
  LOOP
    v_body := v_body ||
      '<div style="background:#fff;margin:12px auto;padding:20px;border-radius:12px;max-width:680px;box-shadow:0 1px 8px rgba(0,0,0,0.06);">' ||
      '<div style="font-size:12px;color:#e94560;font-weight:700;margin-bottom:6px;">' || COALESCE(rec.cat_label, '') || ' | ' || COALESCE(rec.source_date::text, '') || '</div>' ||
      '<a href="?slug=' || rec.slug || '" style="font-size:19px;font-weight:800;color:#1a1a2e;text-decoration:none;line-height:1.5;display:block;margin-bottom:8px;">' || COALESCE(rec.title_ja, '') || '</a>' ||
      '<p style="font-size:15px;color:#666;line-height:1.7;margin:0;">' || COALESCE(left(rec.summary, 150), '') || '...</p>' ||
      '</div>';
  END LOOP;

  RETURN QUERY SELECT
    '<!DOCTYPE html><html lang="ja"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0"><title>AI Research Hub</title>' ||
    '<style>*{margin:0;padding:0;box-sizing:border-box;}body{font-family:-apple-system,BlinkMacSystemFont,''Hiragino Sans'',''Noto Sans JP'',sans-serif;background:#f5f5f5;}</style></head><body>' ||
    '<div style="background:linear-gradient(135deg,#1a1a2e 0%,#16213e 50%,#0f3460 100%);color:#fff;padding:32px 20px;text-align:center;">' ||
    '<div style="display:inline-block;background:linear-gradient(90deg,#e94560,#ff6b6b);color:#fff;font-size:11px;font-weight:700;padding:3px 12px;border-radius:20px;letter-spacing:1px;margin-bottom:12px;">AI RESEARCH HUB</div>' ||
    '<h1 style="font-size:24px;font-weight:800;">Tak''s Research Library</h1>' ||
    '<p style="font-size:13px;opacity:0.7;margin-top:8px;">パーソナルAIリサーチ基盤</p>' ||
    '</div>' ||
    '<div style="padding:8px 16px;">' ||
    v_body ||
    '</div></body></html>';
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_article_html TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.get_articles_index_html TO anon, authenticated;

DO $$
BEGIN
  RAISE NOTICE '記事ビューアーRPC関数の作成が完了しました！';
END $$;
