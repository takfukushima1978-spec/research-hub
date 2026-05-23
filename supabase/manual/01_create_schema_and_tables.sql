-- ============================================
-- パーソナルAIリサーチ基盤 - Phase 1
-- Step 1: スキーマ & テーブル作成
--
-- 実行方法: Supabaseダッシュボード → SQL Editor → New Query
-- このファイルの内容をすべてコピペして「Run」
-- ============================================

-- pgvector拡張を有効化（セマンティック検索用）
CREATE EXTENSION IF NOT EXISTS vector;

-- リサーチ専用スキーマを作成
CREATE SCHEMA IF NOT EXISTS research;

-- ============================================
-- カテゴリマスタ
-- ============================================
CREATE TABLE research.categories (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name        TEXT NOT NULL UNIQUE,
  label_ja    TEXT NOT NULL,
  description TEXT,
  created_at  TIMESTAMPTZ DEFAULT now()
);

-- 初期カテゴリ投入
INSERT INTO research.categories (name, label_ja, description) VALUES
  ('claude_code', 'Claude Code', 'Claude Codeの公式発表・活用スキル・セキュリティ情報'),
  ('ai_accounting', 'AI会計トレンド', 'AIを活用した会計士・税理士の先進事例やAI活用術'),
  ('claude_code_official', 'Claude Code公式発表', 'Claude Codeの公式リリース・アップデート情報');

-- ============================================
-- タグ
-- ============================================
CREATE TABLE research.tags (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name        TEXT NOT NULL UNIQUE,
  created_at  TIMESTAMPTZ DEFAULT now()
);

-- 初期タグ投入
INSERT INTO research.tags (name) VALUES
  ('security'), ('mcp'), ('agent-teams'), ('computer-use'),
  ('hooks'), ('voice'), ('enterprise'), ('model-release'),
  ('acquisition'), ('policy'), ('performance'), ('cowork'),
  ('audit'), ('tax'), ('ai-tools'), ('regulation');

-- ============================================
-- CSSテンプレート管理
-- ============================================
CREATE TABLE research.css_templates (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name        TEXT NOT NULL UNIQUE,
  css_content TEXT NOT NULL,
  is_default  BOOLEAN DEFAULT false,
  created_at  TIMESTAMPTZ DEFAULT now()
);

-- NewsPicks風CSSテンプレートを投入
INSERT INTO research.css_templates (name, css_content, is_default) VALUES (
  'newspicks_dark',
  '* { margin: 0; padding: 0; box-sizing: border-box; }
body { font-family: -apple-system, BlinkMacSystemFont, ''Hiragino Sans'', ''Noto Sans JP'', sans-serif; background: #f5f5f5; color: #333; line-height: 1.85; font-size: 18px; -webkit-font-smoothing: antialiased; }
.header { background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%); color: #fff; padding: 40px 20px 32px; text-align: center; }
.header .label { display: inline-block; background: linear-gradient(90deg, #e94560, #ff6b6b); color: #fff; font-size: 12px; font-weight: 700; padding: 3px 12px; border-radius: 20px; letter-spacing: 1px; margin-bottom: 16px; }
.header h1 { font-size: 26px; font-weight: 800; line-height: 1.4; margin-bottom: 12px; }
.header .date { font-size: 13px; opacity: 0.7; }
.lead { background: #fff; margin: -16px 16px 20px; padding: 24px 20px; border-radius: 12px; box-shadow: 0 2px 12px rgba(0,0,0,0.08); font-size: 17px; color: #555; line-height: 1.9; position: relative; max-width: 680px; margin-left: auto; margin-right: auto; }
.lead::before { content: ''''; position: absolute; top: 0; left: 0; right: 0; height: 4px; background: linear-gradient(90deg, #e94560, #ff6b6b); border-radius: 12px 12px 0 0; }
.card { background: #fff; margin: 16px auto; padding: 28px 22px; border-radius: 12px; box-shadow: 0 1px 8px rgba(0,0,0,0.06); max-width: 680px; }
.card .num { display: inline-block; background: linear-gradient(135deg, #e94560, #ff6b6b); color: #fff; font-size: 12px; font-weight: 700; width: 28px; height: 28px; line-height: 28px; text-align: center; border-radius: 50%; margin-bottom: 12px; }
.card h2 { font-size: 21px; font-weight: 800; color: #1a1a2e; margin-bottom: 14px; line-height: 1.5; }
.card p { font-size: 17px; color: #444; margin-bottom: 12px; }
.card .highlight { background: #fff8f0; border-left: 4px solid #e94560; padding: 12px 16px; margin: 16px 0; border-radius: 0 8px 8px 0; font-size: 16px; color: #555; }
.card .source-link { margin-top: 14px; padding-top: 10px; border-top: 1px dashed #e0e0e0; font-size: 14px; }
.card .source-link a { color: #e94560; text-decoration: none; }
.dark-card { background: linear-gradient(135deg, #0f3460, #1a1a2e); color: #fff; margin: 16px auto; padding: 28px 22px; border-radius: 12px; max-width: 680px; }
.dark-card h2 { color: #ff6b6b; font-size: 21px; margin-bottom: 14px; }
.dark-card p { color: #ccc; font-size: 17px; margin-bottom: 12px; }
.closing { background: #fff; margin: 24px auto; padding: 28px 22px; border-radius: 12px; box-shadow: 0 1px 8px rgba(0,0,0,0.06); max-width: 680px; border-top: 3px solid #e94560; }
.closing h3 { font-size: 18px; color: #e94560; margin-bottom: 12px; }
.closing p { font-size: 16px; color: #666; line-height: 1.85; }
.sources { max-width: 680px; margin: 20px auto 40px; padding: 20px 22px; font-size: 14px; color: #888; }
.sources h4 { font-size: 15px; color: #666; margin-bottom: 10px; }
.sources a { color: #e94560; text-decoration: none; word-break: break-all; }
.sources ul { list-style: none; padding: 0; }
.sources li { margin-bottom: 8px; padding-left: 16px; position: relative; }
.sources li::before { content: ''→''; position: absolute; left: 0; color: #ccc; }
code { background: #f0f0f0; padding: 2px 6px; border-radius: 4px; font-size: 16px; color: #e94560; }',
  true
);

-- ============================================
-- 記事メイン
-- ============================================
CREATE TABLE research.articles (
  id              UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title           TEXT NOT NULL,
  title_ja        TEXT,
  slug            TEXT UNIQUE,
  category_id     UUID REFERENCES research.categories(id),
  css_template_id UUID REFERENCES research.css_templates(id),

  -- 本文（CSSなしのbodyコンテンツのみ）
  body_html       TEXT,
  body_markdown   TEXT,
  body_text       TEXT,
  summary         TEXT,

  -- メタデータ
  source_date     DATE,
  published_at    TIMESTAMPTZ DEFAULT now(),
  author          TEXT DEFAULT 'auto',

  -- ステータス
  status          TEXT DEFAULT 'published'
                  CHECK (status IN ('draft','published','archived')),

  -- 自動生成メタ
  research_task   TEXT,
  generated_at    TIMESTAMPTZ DEFAULT now(),

  created_at      TIMESTAMPTZ DEFAULT now(),
  updated_at      TIMESTAMPTZ DEFAULT now()
);

-- ============================================
-- 記事 × タグ（多対多）
-- ============================================
CREATE TABLE research.article_tags (
  article_id  UUID REFERENCES research.articles(id) ON DELETE CASCADE,
  tag_id      UUID REFERENCES research.tags(id) ON DELETE CASCADE,
  PRIMARY KEY (article_id, tag_id)
);

-- ============================================
-- ベクトル埋め込み（セマンティック検索用）
-- ============================================
CREATE TABLE research.article_embeddings (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  article_id  UUID REFERENCES research.articles(id) ON DELETE CASCADE,
  chunk_index INT DEFAULT 0,
  content     TEXT NOT NULL,
  embedding   vector(1536),
  created_at  TIMESTAMPTZ DEFAULT now()
);

-- ============================================
-- ソースURL管理
-- ============================================
CREATE TABLE research.research_sources (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  article_id  UUID REFERENCES research.articles(id) ON DELETE CASCADE,
  url         TEXT NOT NULL,
  title       TEXT,
  domain      TEXT,
  fetched_at  TIMESTAMPTZ DEFAULT now(),
  UNIQUE(article_id, url)
);

-- ============================================
-- リサーチトピック管理
-- ============================================
CREATE TABLE research.research_topics (
  id                UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name              TEXT NOT NULL,
  description       TEXT,
  category_id       UUID REFERENCES research.categories(id),
  schedule_task_id  TEXT,
  cron_expression   TEXT,
  is_active         BOOLEAN DEFAULT true,
  search_queries    JSONB,
  created_at        TIMESTAMPTZ DEFAULT now()
);

-- ============================================
-- インデックス
-- ============================================
CREATE INDEX idx_articles_category ON research.articles(category_id);
CREATE INDEX idx_articles_status ON research.articles(status);
CREATE INDEX idx_articles_source_date ON research.articles(source_date DESC);
CREATE INDEX idx_articles_slug ON research.articles(slug);
CREATE INDEX idx_sources_url ON research.research_sources(url);
CREATE INDEX idx_sources_article ON research.research_sources(article_id);
CREATE INDEX idx_tags_name ON research.tags(name);

-- ベクトル検索用インデックス（データ投入後に作成推奨だが先に定義）
-- 記事数が100を超えたら以下を実行:
-- CREATE INDEX idx_embeddings_vector ON research.article_embeddings
--   USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);

-- ============================================
-- RLSポリシー（anon keyでのアクセス許可）
-- ============================================
ALTER TABLE research.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE research.tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE research.css_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE research.articles ENABLE ROW LEVEL SECURITY;
ALTER TABLE research.article_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE research.article_embeddings ENABLE ROW LEVEL SECURITY;
ALTER TABLE research.research_sources ENABLE ROW LEVEL SECURITY;
ALTER TABLE research.research_topics ENABLE ROW LEVEL SECURITY;

-- 全テーブルに読み取り許可
CREATE POLICY "Allow public read categories" ON research.categories FOR SELECT USING (true);
CREATE POLICY "Allow public read tags" ON research.tags FOR SELECT USING (true);
CREATE POLICY "Allow public read css_templates" ON research.css_templates FOR SELECT USING (true);
CREATE POLICY "Allow public read articles" ON research.articles FOR SELECT USING (true);
CREATE POLICY "Allow public read article_tags" ON research.article_tags FOR SELECT USING (true);
CREATE POLICY "Allow public read embeddings" ON research.article_embeddings FOR SELECT USING (true);
CREATE POLICY "Allow public read sources" ON research.research_sources FOR SELECT USING (true);
CREATE POLICY "Allow public read topics" ON research.research_topics FOR SELECT USING (true);

-- 書き込み許可（anon keyでの投入用）
CREATE POLICY "Allow public insert articles" ON research.articles FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public insert article_tags" ON research.article_tags FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public insert embeddings" ON research.article_embeddings FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public insert sources" ON research.research_sources FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public insert topics" ON research.research_topics FOR INSERT WITH CHECK (true);

-- researchスキーマへのアクセス権をPostgRESTに付与
GRANT USAGE ON SCHEMA research TO anon, authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA research TO anon, authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA research TO anon, authenticated;

-- 今後作成されるテーブルにもデフォルトで権限付与
ALTER DEFAULT PRIVILEGES IN SCHEMA research
  GRANT ALL ON TABLES TO anon, authenticated;
ALTER DEFAULT PRIVILEGES IN SCHEMA research
  GRANT ALL ON SEQUENCES TO anon, authenticated;

-- ============================================
-- 完了メッセージ
-- ============================================
DO $$
BEGIN
  RAISE NOTICE 'research スキーマの作成が完了しました！';
  RAISE NOTICE 'テーブル: categories, tags, css_templates, articles, article_tags, article_embeddings, research_sources, research_topics';
  RAISE NOTICE 'RLSポリシー: 全テーブルに読み取り・書き込み許可を設定済み';
END $$;
