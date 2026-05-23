-- ============================================
-- Research Hub v2 - Phase 2a (v3 Simple版)
-- CTE連鎖をやめて個別INSERT文に分割
-- ============================================

BEGIN;

-- ============================================
-- STEP 1: articles テーブル拡張
-- ============================================
ALTER TABLE research.articles ADD COLUMN IF NOT EXISTS is_read BOOLEAN DEFAULT false;
ALTER TABLE research.articles ADD COLUMN IF NOT EXISTS is_clipped BOOLEAN DEFAULT false;
ALTER TABLE research.articles ADD COLUMN IF NOT EXISTS read_at TIMESTAMPTZ;
ALTER TABLE research.articles ADD COLUMN IF NOT EXISTS clipped_at TIMESTAMPTZ;
ALTER TABLE research.articles ADD COLUMN IF NOT EXISTS source_type TEXT DEFAULT 'auto_research';
ALTER TABLE research.articles ADD COLUMN IF NOT EXISTS external_url TEXT;
ALTER TABLE research.articles ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT now();

DO $$ BEGIN
  ALTER TABLE research.articles ADD CONSTRAINT chk_source_type
    CHECK (source_type IN ('auto_research','manual_clip','manual_note','external_article')) NOT VALID;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;
ALTER TABLE research.articles VALIDATE CONSTRAINT chk_source_type;

CREATE INDEX IF NOT EXISTS idx_articles_is_read ON research.articles(is_read);
CREATE INDEX IF NOT EXISTS idx_articles_is_clipped ON research.articles(is_clipped);
CREATE INDEX IF NOT EXISTS idx_articles_source_type ON research.articles(source_type);

-- ============================================
-- STEP 2: tags テーブル階層化
-- ============================================
ALTER TABLE research.tags ADD COLUMN IF NOT EXISTS parent_id UUID REFERENCES research.tags(id);
ALTER TABLE research.tags ADD COLUMN IF NOT EXISTS level INT DEFAULT 1;
ALTER TABLE research.tags ADD COLUMN IF NOT EXISTS label_ja TEXT;
ALTER TABLE research.tags ADD COLUMN IF NOT EXISTS sort_order INT DEFAULT 0;
ALTER TABLE research.tags ADD COLUMN IF NOT EXISTS icon TEXT;

DO $$ BEGIN
  ALTER TABLE research.tags ADD CONSTRAINT chk_tag_level CHECK (level IN (1, 2, 3)) NOT VALID;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;
ALTER TABLE research.tags VALIDATE CONSTRAINT chk_tag_level;

CREATE INDEX IF NOT EXISTS idx_tags_parent ON research.tags(parent_id);
CREATE INDEX IF NOT EXISTS idx_tags_level ON research.tags(level);

-- ============================================
-- STEP 3: 旧タグ退避 → 削除
-- ============================================
CREATE TEMP TABLE _old_article_tags AS
SELECT at2.article_id, t.name as tag_name
FROM research.article_tags at2
JOIN research.tags t ON t.id = at2.tag_id;

DELETE FROM research.article_tags;
DELETE FROM research.tags;

-- ============================================
-- STEP 4: 階層タグ投入（個別INSERT版）
-- ============================================

-- L1: 大区分
INSERT INTO research.tags (name, label_ja, level, icon, sort_order) VALUES
  ('accounting', '会計・税務', 1, '📊', 10),
  ('ai_tech', 'AI・テクノロジー', 1, '🤖', 20),
  ('tools', 'ツール・プロダクト', 1, '🔧', 30),
  ('security_risk', 'セキュリティ・リスク', 1, '🔒', 40),
  ('business', '経営・戦略', 1, '💼', 50);

-- L2: 会計・税務
INSERT INTO research.tags (name, label_ja, level, parent_id, sort_order)
SELECT v.name, v.label_ja, 2, p.id, v.srt
FROM (VALUES ('audit','監査',11),('tax','税務申告',12),('bookkeeping','記帳・仕訳',13),('regulation','規制・基準',14)) AS v(name,label_ja,srt),
     research.tags p WHERE p.name = 'accounting' AND p.level = 1;

-- L2: AI・テクノロジー
INSERT INTO research.tags (name, label_ja, level, parent_id, sort_order)
SELECT v.name, v.label_ja, 2, p.id, v.srt
FROM (VALUES ('generative_ai','生成AI',21),('agents','エージェント',22),('computer_use','Computer Use',23),('mcp','MCP',24)) AS v(name,label_ja,srt),
     research.tags p WHERE p.name = 'ai_tech' AND p.level = 1;

-- L2: ツール・プロダクト
INSERT INTO research.tags (name, label_ja, level, parent_id, sort_order)
SELECT v.name, v.label_ja, 2, p.id, v.srt
FROM (VALUES ('claude_code','Claude Code',31),('cowork','Cowork',32),('accounting_sw','会計ソフト',33),('other_ai_tools','その他AIツール',34)) AS v(name,label_ja,srt),
     research.tags p WHERE p.name = 'tools' AND p.level = 1;

-- L2: セキュリティ・リスク
INSERT INTO research.tags (name, label_ja, level, parent_id, sort_order)
SELECT v.name, v.label_ja, 2, p.id, v.srt
FROM (VALUES ('vulnerability','脆弱性',41),('prompt_injection','プロンプトインジェクション',42),('data_protection','データ保護',43),('policy','ポリシー・安全性',44)) AS v(name,label_ja,srt),
     research.tags p WHERE p.name = 'security_risk' AND p.level = 1;

-- L2: 経営・戦略
INSERT INTO research.tags (name, label_ja, level, parent_id, sort_order)
SELECT v.name, v.label_ja, 2, p.id, v.srt
FROM (VALUES ('dx','DX・業務効率化',51),('industry','業界動向',52),('talent','人材・組織',53)) AS v(name,label_ja,srt),
     research.tags p WHERE p.name = 'business' AND p.level = 1;

-- L3: Claude Code配下
INSERT INTO research.tags (name, label_ja, level, parent_id, sort_order)
SELECT v.name, v.label_ja, 3, p.id, v.srt
FROM (VALUES ('hooks','Hooks',311),('skills','Skills',312),('voice_mode','Voice Mode',313),('sandbox_mode','Sandbox',314)) AS v(name,label_ja,srt),
     research.tags p WHERE p.name = 'claude_code' AND p.level = 2;

-- L3: エージェント配下
INSERT INTO research.tags (name, label_ja, level, parent_id, sort_order)
SELECT v.name, v.label_ja, 3, p.id, v.srt
FROM (VALUES ('agent_teams','Agent Teams',221),('managed_agents','Managed Agents',222)) AS v(name,label_ja,srt),
     research.tags p WHERE p.name = 'agents' AND p.level = 2;

-- L3: MCP配下
INSERT INTO research.tags (name, label_ja, level, parent_id, sort_order)
SELECT v.name, v.label_ja, 3, p.id, v.srt
FROM (VALUES ('elicitation','Elicitation',241)) AS v(name,label_ja,srt),
     research.tags p WHERE p.name = 'mcp' AND p.level = 2;

-- L3: 会計ソフト配下
INSERT INTO research.tags (name, label_ja, level, parent_id, sort_order)
SELECT v.name, v.label_ja, 3, p.id, v.srt
FROM (VALUES ('freee','freee',331),('money_forward','マネーフォワード',332)) AS v(name,label_ja,srt),
     research.tags p WHERE p.name = 'accounting_sw' AND p.level = 2;

-- L3: その他AIツール配下
INSERT INTO research.tags (name, label_ja, level, parent_id, sort_order)
SELECT v.name, v.label_ja, 3, p.id, v.srt
FROM (VALUES ('notebooklm','NotebookLM',341),('chatgpt','ChatGPT',342),('perplexity','Perplexity',343)) AS v(name,label_ja,srt),
     research.tags p WHERE p.name = 'other_ai_tools' AND p.level = 2;

-- ============================================
-- STEP 5: 既存記事のタグ再付与
-- ============================================
INSERT INTO research.article_tags (article_id, tag_id)
SELECT DISTINCT old_at.article_id, new_t.id
FROM _old_article_tags old_at
JOIN research.tags new_t ON (
  (old_at.tag_name = 'security' AND new_t.name IN ('vulnerability','security_risk'))
  OR (old_at.tag_name = 'mcp' AND new_t.name = 'mcp')
  OR (old_at.tag_name = 'agent-teams' AND new_t.name = 'agent_teams')
  OR (old_at.tag_name = 'computer-use' AND new_t.name = 'computer_use')
  OR (old_at.tag_name = 'hooks' AND new_t.name = 'hooks')
  OR (old_at.tag_name = 'voice' AND new_t.name = 'voice_mode')
  OR (old_at.tag_name = 'enterprise' AND new_t.name = 'dx')
  OR (old_at.tag_name = 'model-release' AND new_t.name = 'ai_tech')
  OR (old_at.tag_name = 'acquisition' AND new_t.name = 'industry')
  OR (old_at.tag_name = 'policy' AND new_t.name = 'policy')
  OR (old_at.tag_name = 'cowork' AND new_t.name = 'cowork')
  OR (old_at.tag_name = 'performance' AND new_t.name = 'dx')
  OR (old_at.tag_name = 'audit' AND new_t.name = 'audit')
  OR (old_at.tag_name = 'tax' AND new_t.name = 'tax')
  OR (old_at.tag_name = 'ai-tools' AND new_t.name = 'other_ai_tools')
  OR (old_at.tag_name = 'regulation' AND new_t.name = 'regulation')
)
ON CONFLICT DO NOTHING;

DROP TABLE IF EXISTS _old_article_tags;

-- ============================================
-- STEP 6: ビュー作成
-- ============================================
CREATE OR REPLACE VIEW research.tags_tree AS
SELECT
  t.id, t.name, t.label_ja, t.level,
  t.parent_id, t.sort_order, t.icon,
  p.name as parent_name, p.label_ja as parent_label_ja,
  gp.name as grandparent_name, gp.label_ja as grandparent_label_ja
FROM research.tags t
LEFT JOIN research.tags p ON p.id = t.parent_id
LEFT JOIN research.tags gp ON gp.id = p.parent_id
ORDER BY t.level, COALESCE(gp.sort_order,0), COALESCE(p.sort_order,0), t.sort_order;

GRANT SELECT ON research.tags_tree TO anon, authenticated;

-- ============================================
-- STEP 7: RLSポリシー厳格化
-- ============================================
DROP POLICY IF EXISTS "Allow public update articles" ON research.articles;
DROP POLICY IF EXISTS "Allow public insert articles" ON research.articles;
DROP POLICY IF EXISTS "Allow public insert article_tags" ON research.article_tags;
DROP POLICY IF EXISTS "Allow public insert embeddings" ON research.article_embeddings;
DROP POLICY IF EXISTS "Allow public insert sources" ON research.research_sources;
DROP POLICY IF EXISTS "Allow public insert topics" ON research.research_topics;

CREATE POLICY "articles_select" ON research.articles FOR SELECT USING (true);
CREATE POLICY "articles_insert_auth" ON research.articles FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "articles_update_auth" ON research.articles FOR UPDATE TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "article_tags_insert_auth" ON research.article_tags FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "embeddings_insert_auth" ON research.article_embeddings FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "sources_insert_auth" ON research.research_sources FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "topics_insert_auth" ON research.research_topics FOR INSERT TO authenticated WITH CHECK (true);

-- ============================================
-- STEP 8: RPC関数
-- ============================================

-- フラグ切替
CREATE OR REPLACE FUNCTION public.toggle_article_flag(
  p_article_id uuid, p_flag text
) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = research, public AS $$
DECLARE v_new boolean;
BEGIN
  IF p_flag NOT IN ('read','clipped') THEN
    RAISE EXCEPTION 'Invalid flag: %. Must be read or clipped', p_flag;
  END IF;
  IF p_flag = 'read' THEN
    UPDATE research.articles SET is_read = NOT is_read,
      read_at = CASE WHEN NOT is_read THEN now() ELSE NULL END,
      updated_at = now()
    WHERE id = p_article_id RETURNING is_read INTO v_new;
  ELSE
    UPDATE research.articles SET is_clipped = NOT is_clipped,
      clipped_at = CASE WHEN NOT is_clipped THEN now() ELSE NULL END,
      updated_at = now()
    WHERE id = p_article_id RETURNING is_clipped INTO v_new;
  END IF;
  IF NOT FOUND THEN RAISE EXCEPTION 'Article not found: %', p_article_id; END IF;
  RETURN jsonb_build_object('article_id', p_article_id, 'flag', p_flag, 'value', v_new);
END; $$;

-- 手動記事登録
CREATE OR REPLACE FUNCTION public.add_manual_article(
  p_title text, p_url text DEFAULT NULL, p_body_text text DEFAULT NULL,
  p_summary text DEFAULT NULL, p_tag_ids uuid[] DEFAULT '{}'::uuid[],
  p_source_type text DEFAULT 'manual_clip'
) RETURNS uuid
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = research, public AS $$
DECLARE v_id uuid; v_slug text; v_tid uuid;
  v_valid text[] := ARRAY['manual_clip','manual_note','external_article'];
BEGIN
  IF NOT (p_source_type = ANY(v_valid)) THEN
    RAISE EXCEPTION 'Invalid source_type: %', p_source_type;
  END IF;
  IF p_title IS NULL OR trim(p_title) = '' THEN
    RAISE EXCEPTION 'Title is required';
  END IF;
  v_slug := to_char(now(),'YYYY-MM-DD') || '_manual_' || substr(md5(p_title||now()::text),1,8);
  INSERT INTO research.articles (title,title_ja,slug,body_text,summary,external_url,source_type,source_date,status)
  VALUES (p_title,p_title,v_slug,COALESCE(p_body_text,''),
    COALESCE(p_summary,left(COALESCE(p_body_text,p_title),200)),
    p_url,p_source_type,current_date,'published')
  RETURNING id INTO v_id;
  FOREACH v_tid IN ARRAY p_tag_ids LOOP
    INSERT INTO research.article_tags (article_id,tag_id) VALUES (v_id,v_tid) ON CONFLICT DO NOTHING;
  END LOOP;
  IF p_url IS NOT NULL AND trim(p_url) != '' THEN
    INSERT INTO research.research_sources (article_id,url,title,domain)
    VALUES (v_id,p_url,p_title,(regexp_match(p_url,'https?://([^/]+)'))[1]);
  END IF;
  RETURN v_id;
END; $$;

GRANT EXECUTE ON FUNCTION public.toggle_article_flag TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.add_manual_article TO authenticated;

COMMIT;

-- ============================================
-- 確認
-- ============================================
DO $$
DECLARE tc int; atc int;
BEGIN
  SELECT count(*) INTO tc FROM research.tags;
  SELECT count(*) INTO atc FROM research.article_tags;
  RAISE NOTICE 'Phase 2a 完了! タグ: %, 記事タグ紐付け: %', tc, atc;
END $$;
