-- Claude Code 学習マップ（スタンプラリー）テーブル
--
-- 用途:
--   auto-claude-code-watch スケジュールタスクが「新規ネタが足りない日」に
--   未カバーの公式ドキュメントトピックを解説記事化するための SSOT。
--   進捗状態（uncovered → covered → deep）を tracking し、
--   領域バランスを取りながらキャッチアップ記事を生成する。
--
-- SSOT:
--   docs/claude-code-learning-map.md （人間編集 / PR レビュー対象）
--   scripts/seed-claude-code-topics.mjs で markdown → DB upsert
--
-- 冪等版で書く（CLAUDE.md / dont-do.md の方針）。

CREATE TABLE IF NOT EXISTS research.claude_code_topics (
  topic_id            text PRIMARY KEY,
  area                text NOT NULL,
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

CREATE INDEX IF NOT EXISTS idx_cc_topics_status   ON research.claude_code_topics(coverage_status);
CREATE INDEX IF NOT EXISTS idx_cc_topics_area     ON research.claude_code_topics(area);
CREATE INDEX IF NOT EXISTS idx_cc_topics_priority ON research.claude_code_topics(priority DESC);

-- RLS（既存テーブルと同じ運用: 公開読み取り / 公開書き込み）
ALTER TABLE research.claude_code_topics ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'research'
      AND tablename = 'claude_code_topics'
      AND policyname = 'Allow public read claude_code_topics'
  ) THEN
    CREATE POLICY "Allow public read claude_code_topics"
      ON research.claude_code_topics FOR SELECT USING (true);
  END IF;
END $$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'research'
      AND tablename = 'claude_code_topics'
      AND policyname = 'Allow public write claude_code_topics'
  ) THEN
    -- 書き込みは RPC 経由で行う想定だが、seed スクリプトが anon で動くため
    -- INSERT / UPDATE / DELETE を anon に開ける（既存 articles テーブルと同じ運用）
    CREATE POLICY "Allow public write claude_code_topics"
      ON research.claude_code_topics FOR ALL USING (true) WITH CHECK (true);
  END IF;
END $$;

-- updated_at 自動更新トリガー
CREATE OR REPLACE FUNCTION research.touch_cc_topics_updated_at()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_touch_cc_topics_updated_at ON research.claude_code_topics;
CREATE TRIGGER trg_touch_cc_topics_updated_at
  BEFORE UPDATE ON research.claude_code_topics
  FOR EACH ROW EXECUTE FUNCTION research.touch_cc_topics_updated_at();

-- 領域別進捗ビュー
CREATE OR REPLACE VIEW research.claude_code_coverage AS
SELECT
  area,
  COUNT(*) AS total,
  COUNT(*) FILTER (WHERE coverage_status = 'covered') AS covered,
  COUNT(*) FILTER (WHERE coverage_status = 'deep')    AS deep,
  COUNT(*) FILTER (WHERE coverage_status = 'uncovered') AS uncovered,
  ROUND(
    (COUNT(*) FILTER (WHERE coverage_status IN ('covered','deep')))::numeric
    / NULLIF(COUNT(*) FILTER (WHERE coverage_status != 'archived'), 0)::numeric * 100,
    1
  ) AS coverage_pct
FROM research.claude_code_topics
WHERE coverage_status != 'archived'
GROUP BY area
ORDER BY area;

GRANT SELECT ON research.claude_code_coverage TO anon, authenticated, service_role;

COMMENT ON TABLE research.claude_code_topics IS
  'Claude Code 学習マップ（スタンプラリー）。SSOT は docs/claude-code-learning-map.md。';
COMMENT ON VIEW  research.claude_code_coverage IS
  '領域別の coverage 進捗ビュー。Routine と UI で参照する。';
