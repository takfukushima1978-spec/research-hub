#!/usr/bin/env node
/**
 * seed-learning-topics.mjs
 *
 * docs/learning-maps/<genre>.md を全てパースして
 * research.learning_topics に upsert する汎用 seed スクリプト。
 *
 *   - genre は **ファイル名**（拡張子なし）から決まる（例: accounting.md → genre=accounting）
 *   - 各ファイル内は `### <area>` 見出し + 表
 *     `| topic_id | title | doc_url | priority | description |` の固定スキーマ
 *
 * 使い方:
 *   node scripts/seed-learning-topics.mjs                 # 全ジャンル
 *   node scripts/seed-learning-topics.mjs accounting      # 1ジャンルだけ
 *
 * 必要な環境変数（seed-claude-code-topics.mjs と同じ）:
 *   INTERNAL_TOKEN  研究 Hub Worker の X-Internal-Token（.supabase-config から自動取得可）
 *   RELAY_URL       任意。デフォルトは research-hub-relay
 *
 * 冪等。coverage_status / article_count は upsert で維持される。
 */

import { readFileSync, existsSync, readdirSync } from "node:fs";
import { dirname, resolve, basename } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const REPO_ROOT = resolve(__dirname, "..");
const MAPS_DIR  = resolve(REPO_ROOT, "docs/learning-maps");

const DEFAULT_RELAY_URL =
  "https://research-hub-relay.tak-fukushima1978.workers.dev";

const VALID_GENRES = new Set([
  "accounting", "keiri_dx", "ai_tech", "tools",
  "business", "security_risk", "thinking_learning",
]);

// ============================================
// 設定読み込み（.supabase-config からトークン取得）
// ============================================
function loadConfig() {
  let token = process.env.INTERNAL_TOKEN ?? null;
  const relayUrl = process.env.RELAY_URL ?? DEFAULT_RELAY_URL;

  if (!token) {
    const candidates = [
      resolve(REPO_ROOT, "../tak-work/リサーチ/auto-research/.supabase-config"),
      resolve(REPO_ROOT, "../../tak-work/リサーチ/auto-research/.supabase-config"),
    ];
    for (const path of candidates) {
      if (!existsSync(path)) continue;
      const content = readFileSync(path, "utf-8");
      const m = content.match(/^INTERNAL_TOKEN\s*=\s*(.+)$/m);
      if (m) {
        token = m[1].trim().replace(/^["']|["']$/g, "");
        console.log(`[seed] INTERNAL_TOKEN を ${path} から取得`);
        break;
      }
    }
  }

  if (!token) {
    console.error(
      "[ERROR] INTERNAL_TOKEN が見つかりません。環境変数 INTERNAL_TOKEN を設定するか、" +
        ".supabase-config を配置してください。"
    );
    process.exit(1);
  }

  return { token, relayUrl };
}

// ============================================
// markdown パース（### area + 表）
// ============================================
function parseMap(markdown, genre) {
  const lines = markdown.split(/\r?\n/);
  const topics = [];
  let currentArea = null;

  for (const line of lines) {
    const heading = line.match(/^###\s+(.+?)\s*$/);
    if (heading) {
      // 先頭の絵文字や記号を除いた領域名を採用
      currentArea = heading[1].replace(/^[\p{Emoji}\s]+/u, "").trim() || heading[1].trim();
      continue;
    }
    if (!currentArea) continue;
    if (!line.startsWith("|")) continue;
    if (line.includes("---")) continue;
    if (line.includes("topic_id")) continue;

    const cells = line.split("|").slice(1, -1).map((c) => c.trim());
    if (cells.length !== 5) continue;

    const [topic_id, title, doc_url, priorityStr, description] = cells;
    const priority = parseInt(priorityStr, 10);
    if (!topic_id || !title) continue;
    if (Number.isNaN(priority)) continue;

    topics.push({
      topic_id,
      genre,
      area: currentArea,
      subarea: null,
      title,
      description: description || null,
      doc_url: doc_url || null,
      priority,
    });
  }
  return topics;
}

// ============================================
// RPC 呼び出し
// ============================================
async function upsertTopic(relayUrl, token, t) {
  const res = await fetch(`${relayUrl}/rest/v1/rpc/upsert_learning_topic`, {
    method: "POST",
    headers: { "X-Internal-Token": token, "Content-Type": "application/json" },
    body: JSON.stringify({
      p_topic_id: t.topic_id,
      p_genre: t.genre,
      p_area: t.area,
      p_subarea: t.subarea,
      p_title: t.title,
      p_description: t.description,
      p_doc_url: t.doc_url,
      p_priority: t.priority,
    }),
  });
  if (!res.ok) {
    const body = await res.text();
    throw new Error(`upsert 失敗 [${t.topic_id}]: ${res.status} ${res.statusText} - ${body}`);
  }
}

// ============================================
// メイン
// ============================================
async function main() {
  const { token, relayUrl } = loadConfig();
  const only = process.argv[2]; // 任意: 1ジャンル指定

  if (!existsSync(MAPS_DIR)) {
    console.error(`[ERROR] マップディレクトリが見つかりません: ${MAPS_DIR}`);
    process.exit(1);
  }

  const files = readdirSync(MAPS_DIR)
    .filter((n) => n.endsWith(".md"))
    .filter((n) => !only || basename(n, ".md") === only);

  let all = [];
  for (const file of files) {
    const genre = basename(file, ".md");
    if (!VALID_GENRES.has(genre)) {
      console.warn(`[skip] ${file}: 未知の genre スラッグ（7ジャンル以外）`);
      continue;
    }
    const md = readFileSync(resolve(MAPS_DIR, file), "utf-8");
    const topics = parseMap(md, genre);
    console.log(`[seed] ${file} (genre=${genre}): ${topics.length} トピック`);
    all = all.concat(topics);
  }

  console.log(`[seed] 合計 ${all.length} トピックを upsert します`);

  let ok = 0, ng = 0;
  for (const t of all) {
    try {
      await upsertTopic(relayUrl, token, t);
      ok++;
    } catch (e) {
      ng++;
      console.error(`  [NG] ${e.message}`);
    }
  }
  console.log(`[seed] 完了: 成功 ${ok} / 失敗 ${ng}`);
  if (ng > 0) process.exit(1);
}

main();
