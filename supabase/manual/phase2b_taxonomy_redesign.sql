-- ============================================
-- Research Hub - Phase 2b
-- タクソノミー再編（確定版 2026-06-10）
--
-- 確定タクソノミー: tak-lifelog/docs/research-taxonomy.md
--
-- 目的:
--   1. tags 階層を 7 トップジャンル + サブに再編（既存ID温存・DELETE なし）
--   2. categories を 7 ジャンルの正規セットに統一（L1 mirror）
--   3. 既存記事の category を 16 フラット英語スラッグ → 7 ジャンルへ一括マップ
--
-- 設計原則:
--   - name スラッグ = 不変の識別子。label_ja(表示)/parent_id/sort_order のみ更新
--   - 新概念は新スラッグを追加。既存タグの DELETE は一切しない（article_tags 保全）
--   - すべて冪等（ON CONFLICT DO UPDATE / マッピング駆動 UPDATE）。何度実行しても同結果
--
-- 実行方法: Supabase SQL Editor → このSQL全体をコピペ → Run
-- ============================================

BEGIN;

-- ============================================
-- STEP 1: L1（トップジャンル）7 個を upsert
--   既存 5 個（accounting/ai_tech/tools/security_risk/business）は label_ja 更新
--   新規 2 個（keiri_dx/thinking_learning）を追加
--   sort_order を 10..70 で振り直し
-- ============================================
INSERT INTO research.tags (name, label_ja, level, parent_id, sort_order, icon) VALUES
  ('accounting',        '会計・財務・税務',         1, NULL, 10, '📊'),
  ('keiri_dx',          '経理DX・業務改善',         1, NULL, 20, '⚙️'),
  ('ai_tech',           'AI・基盤技術',             1, NULL, 30, '🤖'),
  ('tools',             'AIツール・開発',           1, NULL, 40, '🔧'),
  ('business',          'AI戦略・社会・倫理',       1, NULL, 50, '💼'),
  ('security_risk',     'セキュリティ・ガバナンス', 1, NULL, 60, '🔒'),
  ('thinking_learning', '思考・学習・メタスキル',   1, NULL, 70, '🧠')
ON CONFLICT (name) DO UPDATE SET
  label_ja   = EXCLUDED.label_ja,
  level      = 1,
  parent_id  = NULL,
  sort_order = EXCLUDED.sort_order,
  icon       = COALESCE(EXCLUDED.icon, research.tags.icon);

-- ============================================
-- STEP 2: L2（サブカテゴリ）を親ごとに upsert
--   親は name サブクエリで解決（L1 が STEP 1 で確定済み）
--   既存スラッグは label_ja/parent/sort のみ更新、新概念は追加
-- ============================================

-- L2 / ■会計・財務・税務 ----------------------------------------
INSERT INTO research.tags (name, label_ja, level, parent_id, sort_order)
SELECT v.name, v.label_ja, 2, p.id, v.srt
FROM (VALUES
  ('consolidation',          '連結決算・グループ経理', 11),  -- ★新規
  ('management_accounting',  '管理会計・FP&A',         12),  -- ★新規
  ('regulation',             'IFRS・開示・会計基準',   13),  -- 既存(規制・基準)を再ラベル
  ('audit',                  '監査・内部統制',         14),  -- 既存(監査)
  ('tax',                    '税務',                   15),  -- 既存(税務申告)
  ('bookkeeping',            '記帳・仕訳・実務',       16),  -- 既存(記帳・仕訳)
  ('ma_valuation',           'M&A・バリュエーション',  17)   -- ★新規
) AS v(name, label_ja, srt)
JOIN research.tags p ON p.name = 'accounting'
ON CONFLICT (name) DO UPDATE SET
  label_ja = EXCLUDED.label_ja, level = 2,
  parent_id = EXCLUDED.parent_id, sort_order = EXCLUDED.sort_order;

-- L2 / ■経理DX・業務改善（新トップ） ----------------------------
--   ※ dx は旧 business 配下 → keiri_dx 配下へ reparent（ON CONFLICT が処理）
INSERT INTO research.tags (name, label_ja, level, parent_id, sort_order)
SELECT v.name, v.label_ja, 2, p.id, v.srt
FROM (VALUES
  ('bpr',                    '業務設計・BPR',                 21),  -- ★新規
  ('accounting_automation',  '経理の自動化（freee/GAS/HITL）', 22),  -- ★新規
  ('dx',                     'DX・業務効率化',                23),  -- 既存(business配下から移設)
  ('ic_automation',          '内部統制×自動化',               24)   -- ★新規
) AS v(name, label_ja, srt)
JOIN research.tags p ON p.name = 'keiri_dx'
ON CONFLICT (name) DO UPDATE SET
  label_ja = EXCLUDED.label_ja, level = 2,
  parent_id = EXCLUDED.parent_id, sort_order = EXCLUDED.sort_order;

-- L2 / ■AI・基盤技術 -------------------------------------------
INSERT INTO research.tags (name, label_ja, level, parent_id, sort_order)
SELECT v.name, v.label_ja, 2, p.id, v.srt
FROM (VALUES
  ('generative_ai', '生成AI・基盤モデル',        31),  -- 既存(生成AI)
  ('agents',        'エージェント・MCP',          32),  -- 既存(エージェント)
  ('computer_use',  'Computer Use・自動操作',     33),  -- 既存(Computer Use)
  ('mcp',           'MCP',                        34),  -- 既存(維持・L3 elicitation の親)
  ('semiconductor', '半導体・地政学',             35),  -- ★新規(flat: semiconductor_geopolitics 吸収)
  ('quantum',       '量子・新ハードウェア',       36),  -- ★新規(flat: quantum_hardware 吸収)
  ('robotics',      'ロボティクス・フィジカルAI', 37),  -- ★新規(flat: robotics/physical_ai 吸収)
  ('biotech_ai',    'バイオ×AI',                 38)   -- ★新規(flat: biotech_ai 吸収)
) AS v(name, label_ja, srt)
JOIN research.tags p ON p.name = 'ai_tech'
ON CONFLICT (name) DO UPDATE SET
  label_ja = EXCLUDED.label_ja, level = 2,
  parent_id = EXCLUDED.parent_id, sort_order = EXCLUDED.sort_order;

-- L2 / ■AIツール・開発 -----------------------------------------
INSERT INTO research.tags (name, label_ja, level, parent_id, sort_order)
SELECT v.name, v.label_ja, 2, p.id, v.srt
FROM (VALUES
  ('claude_code',    'Claude Code',          41),  -- 既存(維持・L3 hooks 等の親)
  ('codex_chatgpt',  'Codex / ChatGPT（OpenAI）', 42),  -- ★新規
  ('gemini',         'Gemini（Google）',     43),  -- ★新規
  ('grok',           'Grok（xAI）',          44),  -- ★新規
  ('notion',         'Notion',               45),  -- ★新規
  ('slack',          'Slack',                46),  -- ★新規
  ('developer_tools','開発者ツール（その他）', 47),  -- ★新規(flat: developer_tools 吸収)
  ('accounting_sw',  '会計ソフト・SaaS',     48),  -- 既存(会計ソフト, L3 freee 等の親)
  ('other_ai_tools', 'その他AIツール',       49),  -- 既存(維持・L3 notebooklm 等の親)
  ('cowork',         'Cowork',               50)   -- 既存(維持・末尾へ)
) AS v(name, label_ja, srt)
JOIN research.tags p ON p.name = 'tools'
ON CONFLICT (name) DO UPDATE SET
  label_ja = EXCLUDED.label_ja, level = 2,
  parent_id = EXCLUDED.parent_id, sort_order = EXCLUDED.sort_order;

-- L2 / ■AI戦略・社会・倫理 -------------------------------------
INSERT INTO research.tags (name, label_ja, level, parent_id, sort_order)
SELECT v.name, v.label_ja, 2, p.id, v.srt
FROM (VALUES
  ('ai_strategy',  '事業戦略',                            51),  -- ★新規(flat: enterprise_ai/ai_business 吸収)
  ('industry',     '業界動向',                            52),  -- 既存(維持)
  ('ai_policy',    'AI政策・規制',                        53),  -- ★新規(flat: policy_ai 吸収)
  ('ai_criticism', 'AI批評・リスク論',                    54),  -- ★新規(flat: ai_criticism 吸収)
  ('ai_human',     'AIと人間・グラデーション設計・教育',  55),  -- ★新規
  ('talent',       '人材・組織',                          56)   -- 既存(維持)
) AS v(name, label_ja, srt)
JOIN research.tags p ON p.name = 'business'
ON CONFLICT (name) DO UPDATE SET
  label_ja = EXCLUDED.label_ja, level = 2,
  parent_id = EXCLUDED.parent_id, sort_order = EXCLUDED.sort_order;

-- L2 / ■セキュリティ・ガバナンス（既存4つと一致・親/sort 再確認のみ） ---
INSERT INTO research.tags (name, label_ja, level, parent_id, sort_order)
SELECT v.name, v.label_ja, 2, p.id, v.srt
FROM (VALUES
  ('vulnerability',    '脆弱性',                   61),
  ('prompt_injection', 'プロンプトインジェクション', 62),
  ('data_protection',  'データ保護',               63),
  ('policy',           'ポリシー・安全性',         64)
) AS v(name, label_ja, srt)
JOIN research.tags p ON p.name = 'security_risk'
ON CONFLICT (name) DO UPDATE SET
  label_ja = EXCLUDED.label_ja, level = 2,
  parent_id = EXCLUDED.parent_id, sort_order = EXCLUDED.sort_order;

-- L2 / ■思考・学習・メタスキル（新トップ） ---------------------
INSERT INTO research.tags (name, label_ja, level, parent_id, sort_order)
SELECT v.name, v.label_ja, 2, p.id, v.srt
FROM (VALUES
  ('metacognition',    '思考法・メタ認知',           71),  -- ★新規
  ('learning_science', '学習科学・骨肉化',           72),  -- ★新規
  ('brain_dopamine',   '脳科学・ドーパミン・依存',   73),  -- ★新規
  ('self_management',  '時間管理・セルフマネジメント', 74),  -- ★新規
  ('voice_externalize','音声入力・思考の外化',       75),  -- ★新規
  ('knowledge_design', 'ナレッジ設計・思考資産化',   76),  -- ★新規
  ('career_sidebiz',   'キャリア・副業・個人事業',   77)   -- ★新規
) AS v(name, label_ja, srt)
JOIN research.tags p ON p.name = 'thinking_learning'
ON CONFLICT (name) DO UPDATE SET
  label_ja = EXCLUDED.label_ja, level = 2,
  parent_id = EXCLUDED.parent_id, sort_order = EXCLUDED.sort_order;

-- ※ L3（hooks/skills/voice_mode/sandbox_mode, agent_teams/managed_agents,
--    elicitation, freee/money_forward, notebooklm/chatgpt/perplexity）は
--    親スラッグが全て存続するため変更不要（自動的に新階層へ追従）。

-- ============================================
-- STEP 3: categories を 7 ジャンルの正規セットに upsert（L1 mirror）
--   旧 16 フラットカテゴリは行としては残すが、STEP 4 で参照ゼロになる
-- ============================================
INSERT INTO research.categories (name, label_ja, description) VALUES
  ('accounting',        '会計・財務・税務',         '連結・管理会計・IFRS・監査・税務・記帳・M&A'),
  ('keiri_dx',          '経理DX・業務改善',         'BPR・経理自動化・内部統制×自動化（副業の核）'),
  ('ai_tech',           'AI・基盤技術',             '生成AI・エージェント・半導体・量子・ロボ・バイオ'),
  ('tools',             'AIツール・開発',           'Claude Code・Codex・Gemini・Grok・Notion・Slack 等'),
  ('business',          'AI戦略・社会・倫理',       '事業戦略・業界動向・政策規制・批評・AIと人間'),
  ('security_risk',     'セキュリティ・ガバナンス', '脆弱性・プロンプトインジェクション・データ保護'),
  ('thinking_learning', '思考・学習・メタスキル',   '思考法・学習科学・脳科学・時間管理・ナレッジ設計')
ON CONFLICT (name) DO UPDATE SET
  label_ja    = EXCLUDED.label_ja,
  description = EXCLUDED.description;

-- ============================================
-- STEP 4: 既存記事の category を 7 ジャンルへ一括マップ（冪等）
--   旧フラット名 → 新ジャンル名。再実行しても新ジャンルは old_name に無いので不変
-- ============================================
WITH catmap(old_name, new_name) AS (VALUES
  ('claude_code_official',      'tools'),
  ('claude_code',               'tools'),
  ('developer_tools',           'tools'),
  ('ai_products',               'tools'),
  ('ai_accounting',             'accounting'),
  ('frontier_model',            'ai_tech'),
  ('semiconductor_geopolitics', 'ai_tech'),
  ('robotics',                  'ai_tech'),
  ('physical_ai',               'ai_tech'),
  ('quantum_hardware',          'ai_tech'),
  ('biotech_ai',                'ai_tech'),
  ('policy_ai',                 'business'),
  ('ai_criticism',              'business'),
  ('ai_business',               'business'),
  ('enterprise_ai',             'business'),
  ('thinking',                  'thinking_learning')
)
UPDATE research.articles a
SET category_id = nc.id,
    updated_at  = now()
FROM research.categories oc
JOIN catmap m   ON m.old_name = oc.name
JOIN research.categories nc ON nc.name = m.new_name
WHERE a.category_id = oc.id;

COMMIT;

-- ============================================
-- 検証（COMMIT 後に確認用 SELECT）
-- ============================================
-- L1/L2 階層の確認
SELECT level, sort_order, name, label_ja, parent_id
FROM research.tags
WHERE level <= 2
ORDER BY level, sort_order;

-- 記事のジャンル別件数（7 ジャンルに収束しているか）
SELECT c.name, c.label_ja, count(a.id) AS articles
FROM research.categories c
LEFT JOIN research.articles a ON a.category_id = c.id AND a.status = 'published'
GROUP BY c.name, c.label_ja
ORDER BY articles DESC;
