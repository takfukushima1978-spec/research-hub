-- ============================================
-- Research Hub v2 - Phase 2a
-- セキュア版マイグレーション
--
-- フィードバック反映:
-- 1. RLSをauthenticated + RPC経由に厳格化
-- 2. Google認証前提のポリシー
-- 3. 固定UUID廃止 → gen_random_uuid() + CTE
-- 4. タグ再付与とDELETEを一連のトランザクション
-- 5. source_typeバリデーション強化
-- 6. ORDER BY改善
--
-- 実行方法: SQL Editor → このSQL全体をコピペ → Run
-- ============================================

BEGIN;

-- ============================================
-- STEP 1: articles テーブル拡張
-- ============================================

-- 既読/クリップフラグ
ALTER TABLE research.articles
  ADD COLUMN IF NOT EXISTS is_read BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS is_clipped BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS read_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS clipped_at TIMESTAMPTZ;

-- ソースタイプ
ALTER TABLE research.articles
  ADD COLUMN IF NOT EXISTS source_type TEXT DEFAULT 'auto_research';

-- source_type制約（既存データがある場合を考慮してNOT VALIDで追加後にVALIDATE）
ALTER TABLE research.articles
  ADD CONSTRAINT chk_source_type
  CHECK (source_type IN (
    'auto_research', 'manual_clip',
    'manual_note', 'external_article'
  )) NOT VALID;
ALTER TABLE research.articles VALIDATE CONSTRAINT chk_source_type;

-- 外部記事URL
ALTER TABLE research.articles
  ADD COLUMN IF NOT EXISTS external_url TEXT;

-- updated_atカラム確認（toggle_article_flagで使用）
ALTER TABLE research.articles
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT now();

-- インデックス
CREATE INDEX IF NOT EXISTS idx_articles_is_read ON research.articles(is_read);
CREATE INDEX IF NOT EXISTS idx_articles_is_clipped ON research.articles(is_clipped);
CREATE INDEX IF NOT EXISTS idx_articles_source_type ON research.articles(source_type);

-- ============================================
-- STEP 2: tags テーブル階層化
-- ============================================

ALTER TABLE research.tags
  ADD COLUMN IF NOT EXISTS parent_id UUID REFERENCES research.tags(id),
  ADD COLUMN IF NOT EXISTS level INT DEFAULT 1,
  ADD COLUMN IF NOT EXISTS label_ja TEXT,
  ADD COLUMN IF NOT EXISTS sort_order INT DEFAULT 0,
  ADD COLUMN IF NOT EXISTS icon TEXT;

-- level制約
ALTER TABLE research.tags
  ADD CONSTRAINT chk_tag_level CHECK (level IN (1, 2, 3)) NOT VALID;
ALTER TABLE research.tags VALIDATE CONSTRAINT chk_tag_level;

CREATE INDEX IF NOT EXISTS idx_tags_parent ON research.tags(parent_id);
CREATE INDEX IF NOT EXISTS idx_tags_level ON research.tags(level);

-- ============================================
-- STEP 3: 既存記事のタグ情報を保存（再付与用）
-- ============================================

-- 既存のタグ紐付けを一時テーブルに退避
CREATE TEMP TABLE _old_article_tags AS
SELECT at2.article_id, t.name as tag_name
FROM research.article_tags at2
JOIN research.tags t ON t.id = at2.tag_id;

-- 既存タグを削除（紐付け → タグ本体の順）
DELETE FROM research.article_tags;
DELETE FROM research.tags;

-- ============================================
-- STEP 4: 階層タグ投入（gen_random_uuid使用）
-- ============================================

-- L1: 大区分
WITH l1_insert AS (
  INSERT INTO research.tags (name, label_ja, level, icon, sort_order) VALUES
    ('accounting', '会計・税務', 1, '📊', 10),
    ('ai_tech', 'AI・テクノロジー', 1, '🤖', 20),
    ('tools', 'ツール・プロダクト', 1, '🔧', 30),
    ('security_risk', 'セキュリティ・リスク', 1, '🔒', 40),
    ('business', '経営・戦略', 1, '💼', 50)
  RETURNING id, name
),
-- L2: 中区分 - 会計・税務
l2_accounting AS (
  INSERT INTO research.tags (name, label_ja, level, parent_id, sort_order)
  SELECT v.name, v.label_ja, 2, l1.id, v.srt
  FROM l1_insert l1,
  (VALUES
    ('audit', '監査', 11),
    ('tax', '税務申告', 12),
    ('bookkeeping', '記帳・仕訳', 13),
    ('regulation', '規制・基準', 14)
  ) AS v(name, label_ja, srt)
  WHERE l1.name = 'accounting'
  RETURNING id, name
),
-- L2: 中区分 - AI・テクノロジー
l2_ai AS (
  INSERT INTO research.tags (name, label_ja, level, parent_id, sort_order)
  SELECT v.name, v.label_ja, 2, l1.id, v.srt
  FROM l1_insert l1,
  (VALUES
    ('generative_ai', '生成AI', 21),
    ('agents', 'エージェント', 22),
    ('computer_use', 'Computer Use', 23),
    ('mcp', 'MCP', 24)
  ) AS v(name, label_ja, srt)
  WHERE l1.name = 'ai_tech'
  RETURNING id, name
),
-- L2: 中区分 - ツール・プロダクト
l2_tools AS (
  INSERT INTO research.tags (name, label_ja, level, parent_id, sort_order)
  SELECT v.name, v.label_ja, 2, l1.id, v.srt
  FROM l1_insert l1,
  (VALUES
    ('claude_code', 'Claude Code', 31),
    ('cowork', 'Cowork', 32),
    ('accounting_sw', '会計ソフト', 33),
    ('other_ai_tools', 'その他AIツール', 34)
  ) AS v(name, label_ja, srt)
  WHERE l1.name = 'tools'
  RETURNING id, name
),
-- L2: 中区分 - セキュリティ・リスク
l2_security AS (
  INSERT INTO research.tags (name, label_ja, level, parent_id, sort_order)
  SELECT v.name, v.label_ja, 2, l1.id, v.srt
  FROM l1_insert l1,
  (VALUES
    ('vulnerability', '脆弱性', 41),
    ('prompt_injection', 'プロンプトインジェクション', 42),
    ('data_protection', 'データ保護', 43),
    ('policy', 'ポリシー・安全性', 44)
  ) AS v(name, label_ja, srt)
  WHERE l1.name = 'security_risk'
  RETURNING id, name
),
-- L2: 中区分 - 経営・戦略
l2_business AS (
  INSERT INTO research.tags (name, label_ja, level, parent_id, sort_order)
  SELECT v.name, v.label_ja, 2, l1.id, v.srt
  FROM l1_insert l1,
  (VALUES
    ('dx', 'DX・業務効率化', 51),
    ('industry', '業界動向', 52),
    ('talent', '人材・組織', 53)
  ) AS v(name, label_ja, srt)
  WHERE l1.name = 'business'
  RETURNING id, name
),
-- L3: 小区分 - Claude Code配下
l3_claude_code AS (
  INSERT INTO research.tags (name, label_ja, level, parent_id, sort_order)
  SELECT v.name, v.label_ja, 3, l2.id, v.srt
  FROM l2_tools l2,
  (VALUES
    ('hooks', 'Hooks', 311),
    ('skills', 'Skills', 312),
    ('voice_mode', 'Voice Mode', 313),
    ('sandbox_mode', 'Sandbox', 314)
  ) AS v(name, label_ja, srt)
  WHERE l2.name = 'claude_code'
  RETURNING id, name
),
-- L3: 小区分 - エージェント配下
l3_agents AS (
  INSERT INTO research.tags (name, label_ja, level, parent_id, sort_order)
  SELECT v.name, v.label_ja, 3, l2.id, v.srt
  FROM l2_ai l2,
  (VALUES
    ('agent_teams', 'Agent Teams', 221),
    ('managed_agents', 'Managed Agents', 222)
  ) AS v(name, label_ja, srt)
  WHERE l2.name = 'agents'
  RETURNING id, name
),
-- L3: 小区分 - MCP配下
l3_mcp AS (
  INSERT INTO research.tags (name, label_ja, level, parent_id, sort_order)
  SELECT v.name, v.label_ja, 3, l2.id, v.srt
  FROM l2_ai l2,
  (VALUES
    ('elicitation', 'Elicitation', 241)
  ) AS v(name, label_ja, srt)
  WHERE l2.name = 'mcp'
  RETURNING id, name
),
-- L3: 小区分 - 会計ソフト配下
l3_accounting_sw AS (
  INSERT INTO research.tags (name, label_ja, level, parent_id, sort_order)
  SELECT v.name, v.label_ja, 3, l2.id, v.srt
  FROM l2_tools l2,
  (VALUES
    ('freee', 'freee', 331),
    ('money_forward', 'マネーフォワード', 332)
  ) AS v(name, label_ja, srt)
  WHERE l2.name = 'accounting_sw'
  RETURNING id, name
),
-- L3: 小区分 - その他AIツール配下
l3_other_tools AS (
  INSERT INTO research.tags (name, label_ja, level, parent_id, sort_order)
  SELECT v.name, v.label_ja, 3, l2.id, v.srt
  FROM l2_tools l2,
  (VALUES
    ('notebooklm', 'NotebookLM', 341),
    ('chatgpt', 'ChatGPT', 342),
    ('perplexity', 'Perplexity', 343)
  ) AS v(name, label_ja, srt)
  WHERE l2.name = 'other_ai_tools'
  RETURNING id, name
)
-- 投入確認用
SELECT 'Tags inserted' as status,
  (SELECT count(*) FROM research.tags) as total_tags;

-- ============================================
-- STEP 5: 既存記事のタグ再付与
-- ============================================

-- 旧タグ名 → 新タグ名のマッピングで再付与
INSERT INTO research.article_tags (article_id, tag_id)
SELECT DISTINCT old.article_id, new_t.id
FROM _old_article_tags old
JOIN research.tags new_t ON (
  -- 旧タグ名と新タグ名の対応
  (old.tag_name = 'security' AND new_t.name IN ('vulnerability', 'security_risk'))
  OR (old.tag_name = 'mcp' AND new_t.name = 'mcp')
  OR (old.tag_name = 'agent-teams' AND new_t.name = 'agent_teams')
  OR (old.tag_name = 'computer-use' AND new_t.name = 'computer_use')
  OR (old.tag_name = 'hooks' AND new_t.name = 'hooks')
  OR (old.tag_name = 'voice' AND new_t.name = 'voice_mode')
  OR (old.tag_name = 'enterprise' AND new_t.name = 'dx')
  OR (old.tag_name = 'model-release' AND new_t.name = 'ai_tech')
  OR (old.tag_name = 'acquisition' AND new_t.name = 'industry')
  OR (old.tag_name = 'policy' AND new_t.name = 'policy')
  OR (old.tag_name = 'cowork' AND new_t.name = 'cowork')
  OR (old.tag_name = 'performance' AND new_t.name = 'dx')
  OR (old.tag_name = 'audit' AND new_t.name = 'audit')
  OR (old.tag_name = 'tax' AND new_t.name = 'tax')
  OR (old.tag_name = 'ai-tools' AND new_t.name = 'other_ai_tools')
  OR (old.tag_name = 'regulation' AND new_t.name = 'regulation')
)
ON CONFLICT DO NOTHING;

-- 一時テーブル削除
DROP TABLE IF EXISTS _old_article_tags;

-- ============================================
-- STEP 6: 階層タグビュー（ORDER BY改善）
-- ============================================

CREATE OR REPLACE VIEW research.tags_tree AS
SELECT
  t.id, t.name, t.label_ja, t.level,
  t.parent_id, t.sort_order, t.icon,
  p.name as parent_name,
  p.label_ja as parent_label_ja,
  gp.name as grandparent_name,
  gp.label_ja as grandparent_label_ja
FROM research.tags t
LEFT JOIN research.tags p ON p.id = t.parent_id
LEFT JOIN research.tags gp ON gp.id = p.parent_id
ORDER BY
  t.level,
  COALESCE(gp.sort_order, 0),
  COALESCE(p.sort_order, 0),
  t.sort_order;

GRANT SELECT ON research.tags_tree TO anon, authenticated;

-- ============================================
-- STEP 7: RLSポリシー厳格化
-- ============================================

-- 既存の緩いポリシーを削除
DROP POLICY IF EXISTS "Allow public update articles" ON research.articles;
DROP POLICY IF EXISTS "Allow public insert articles" ON research.articles;
DROP POLICY IF EXISTS "Allow public insert article_tags" ON research.article_tags;
DROP POLICY IF EXISTS "Allow public insert embeddings" ON research.article_embeddings;
DROP POLICY IF EXISTS "Allow public insert sources" ON research.research_sources;
DROP POLICY IF EXISTS "Allow public insert topics" ON research.research_topics;

-- SELECT: anon（読み取りは公開のまま、Google認証後に変更予定）
-- INSERT/UPDATE: authenticatedのみ
-- ※ RPC関数はSECURITY DEFINERなので、関数経由なら
--   anon/authenticatedどちらでもDB操作可能

-- articles: 読み取りは許可、直接書き込みはauthenticatedのみ
CREATE POLICY "articles_select" ON research.articles
  FOR SELECT USING (true);
CREATE POLICY "articles_insert_auth" ON research.articles
  FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "articles_update_auth" ON research.articles
  FOR UPDATE TO authenticated
  USING (true)
  WITH CHECK (true);

-- article_tags
CREATE POLICY "article_tags_insert_auth" ON research.article_tags
  FOR INSERT TO authenticated WITH CHECK (true);

-- article_embeddings
CREATE POLICY "embeddings_insert_auth" ON research.article_embeddings
  FOR INSERT TO authenticated WITH CHECK (true);

-- research_sources
CREATE POLICY "sources_insert_auth" ON research.research_sources
  FOR INSERT TO authenticated WITH CHECK (true);

-- research_topics
CREATE POLICY "topics_insert_auth" ON research.research_topics
  FOR INSERT TO authenticated WITH CHECK (true);

-- ============================================
-- STEP 8: RPC関数（SECURITY DEFINER）
-- anon/authenticated両方から呼べるが、
-- DB操作は関数の権限で実行される
-- ============================================

-- フラグ切替（is_read / is_clipped のみ更新）
CREATE OR REPLACE FUNCTION public.toggle_article_flag(
  p_article_id uuid,
  p_flag text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = research, public
AS $$
DECLARE
  v_new_value boolean;
BEGIN
  -- バリデーション
  IF p_flag NOT IN ('read', 'clipped') THEN
    RAISE EXCEPTION 'Invalid flag: %. Must be read or clipped', p_flag;
  END IF;

  IF p_flag = 'read' THEN
    UPDATE research.articles
    SET is_read = NOT is_read,
        read_at = CASE WHEN NOT is_read THEN now() ELSE NULL END,
        updated_at = now()
    WHERE id = p_article_id
    RETURNING is_read INTO v_new_value;
  ELSE
    UPDATE research.articles
    SET is_clipped = NOT is_clipped,
        clipped_at = CASE WHEN NOT is_clipped THEN now() ELSE NULL END,
        updated_at = now()
    WHERE id = p_article_id
    RETURNING is_clipped INTO v_new_value;
  END IF;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Article not found: %', p_article_id;
  END IF;

  RETURN jsonb_build_object(
    'article_id', p_article_id,
    'flag', p_flag,
    'value', v_new_value
  );
END;
$$;

-- 手動記事登録（バリデーション強化）
CREATE OR REPLACE FUNCTION public.add_manual_article(
  p_title text,
  p_url text DEFAULT NULL,
  p_body_text text DEFAULT NULL,
  p_summary text DEFAULT NULL,
  p_tag_ids uuid[] DEFAULT '{}'::uuid[],
  p_source_type text DEFAULT 'manual_clip'
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = research, public
AS $$
DECLARE
  v_article_id uuid;
  v_slug text;
  v_tag_id uuid;
  v_valid_types text[] := ARRAY[
    'manual_clip', 'manual_note', 'external_article'
  ];
BEGIN
  -- source_typeバリデーション
  IF NOT (p_source_type = ANY(v_valid_types)) THEN
    RAISE EXCEPTION 'Invalid source_type: %. Must be one of: %',
      p_source_type, array_to_string(v_valid_types, ', ');
  END IF;

  -- titleバリデーション
  IF p_title IS NULL OR trim(p_title) = '' THEN
    RAISE EXCEPTION 'Title is required';
  END IF;

  -- slug生成
  v_slug := to_char(now(), 'YYYY-MM-DD') || '_manual_'
    || substr(md5(p_title || now()::text), 1, 8);

  -- 記事挿入
  INSERT INTO research.articles (
    title, title_ja, slug, body_text,
    summary, external_url, source_type,
    source_date, status
  ) VALUES (
    p_title, p_title, v_slug,
    COALESCE(p_body_text, ''),
    COALESCE(p_summary, left(COALESCE(p_body_text, p_title), 200)),
    p_url, p_source_type,
    current_date, 'published'
  ) RETURNING id INTO v_article_id;

  -- タグ紐付け
  FOREACH v_tag_id IN ARRAY p_tag_ids LOOP
    INSERT INTO research.article_tags (article_id, tag_id)
    VALUES (v_article_id, v_tag_id)
    ON CONFLICT DO NOTHING;
  END LOOP;

  -- ソースURL登録
  IF p_url IS NOT NULL AND trim(p_url) != '' THEN
    INSERT INTO research.research_sources (
      article_id, url, title, domain
    ) VALUES (
      v_article_id, p_url, p_title,
      (regexp_match(p_url, 'https?://([^/]+)'))[1]
    );
  END IF;

  RETURN v_article_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.toggle_article_flag TO anon, authenticated;
-- add_manual_articleはauthenticatedのみ（新規レコード挿入のため）
-- Google認証導入後はtoggle_article_flagもauthenticatedのみに変更予定
GRANT EXECUTE ON FUNCTION public.add_manual_article TO authenticated;

COMMIT;

-- ============================================
-- 完了確認
-- ============================================
DO $$
DECLARE
  tag_count int;
  article_tag_count int;
BEGIN
  SELECT count(*) INTO tag_count FROM research.tags;
  SELECT count(*) INTO article_tag_count FROM research.article_tags;
  RAISE NOTICE 'Phase 2a 完了!';
  RAISE NOTICE 'タグ数: % (L1: 5, L2: 17, L3: 11+)', tag_count;
  RAISE NOTICE '記事タグ紐付け: % 件（既存記事から再付与）', article_tag_count;
END $$;
