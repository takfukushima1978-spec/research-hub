#!/usr/bin/env node
/**
 * seed-claude-code-topics.mjs
 *
 * docs/claude-code-learning-map.md をパースして
 * research.claude_code_topics に upsert する seed スクリプト。
 *
 * 使い方:
 *   node scripts/seed-claude-code-topics.mjs
 *
 * 必要な環境変数:
 *   INTERNAL_TOKEN  研究 Hub Worker の X-Internal-Token
 *   RELAY_URL       任意。デフォルトは https://research-hub-relay.tak-fukushima1978.workers.dev
 *
 * `.supabase-config` （tak-work/リサーチ/auto-research/）に
 *   INTERNAL_TOKEN=xxx
 * が書かれていれば、それを自動で読み込む（環境変数優先）。
 *
 * 冪等。何度実行しても安全。
 *   - 既存トピックは upsert（coverage_status / article_count は維持）
 *   - 削除されたトピックは DB 側に残る（手動で archived にする運用）
 */

import { readFileSync, existsSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const REPO_ROOT = resolve(__dirname, "..");
const MAP_PATH  = resolve(REPO_ROOT, "docs/claude-code-learning-map.md");

const DEFAULT_RELAY_URL =
  "https://research-hub-relay.tak-fukushima1978.workers.dev";

// ============================================
// 設定読み込み
// ============================================
function loadConfig() {
  let token = process.env.INTERNAL_TOKEN ?? null;
  let relayUrl = process.env.RELAY_URL ?? DEFAULT_RELAY_URL;

  if (!token) {
    // 正本: git 射程外（C:\dev\.secrets）。tak-work 内は git clean 等で消えうるため fallback
    const candidates = [
      resolve(REPO_ROOT, "../.secrets/.supabase-config"),
      resolve(REPO_ROOT, "../../.secrets/.supabase-config"),
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
      "[ERROR] INTERNAL_TOKEN が見つかりません。" +
        "環境変数 INTERNAL_TOKEN を設定するか、" +
        "tak-work/リサーチ/auto-research/.supabase-config を配置してください。"
    );
    process.exit(1);
  }

  return { token, relayUrl };
}

// ============================================
// markdown のテーブルパース
// ============================================
const AREA_HEADINGS = {
  "📘 基礎・概念": "基礎・概念",
  "📗 対話・操作": "対話・操作",
  "📙 ツールシステム": "ツールシステム",
  "📕 拡張機構": "拡張機構",
  "📓 連携・統合": "連携・統合",
  "📔 開発・運用": "開発・運用",
  "📒 ベストプラクティス": "ベストプラクティス",
};

function parseMap(markdown) {
  const lines = markdown.split(/\r?\n/);
  const topics = [];
  let currentArea = null;

  for (const line of lines) {
    // 領域見出し検出: "### 📘 基礎・概念"
    const heading = line.match(/^###\s+(.+?)\s*$/);
    if (heading) {
      const found = Object.entries(AREA_HEADINGS).find(([k]) =>
        heading[1].includes(k)
      );
      currentArea = found ? found[1] : null;
      continue;
    }

    if (!currentArea) continue;

    // テーブル行検出: | topic_id | title | doc_url | priority | description |
    if (!line.startsWith("|")) continue;
    if (line.includes("---")) continue; // 区切り行
    if (line.includes("topic_id")) continue; // ヘッダ行

    const cells = line
      .split("|")
      .slice(1, -1)
      .map((c) => c.trim());

    if (cells.length !== 5) continue;

    const [topic_id, title, doc_url, priorityStr, description] = cells;
    const priority = parseInt(priorityStr, 10);

    if (!topic_id || !title) continue;
    if (Number.isNaN(priority)) continue;

    topics.push({
      topic_id,
      area: currentArea,
      subarea: null, // 現状は subarea 未使用（将来拡張用）
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
async function upsertTopic(relayUrl, token, topic) {
  const res = await fetch(`${relayUrl}/rest/v1/rpc/upsert_claude_code_topic`, {
    method: "POST",
    headers: {
      "X-Internal-Token": token,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      p_topic_id: topic.topic_id,
      p_area: topic.area,
      p_subarea: topic.subarea,
      p_title: topic.title,
      p_description: topic.description,
      p_doc_url: topic.doc_url,
      p_priority: topic.priority,
    }),
  });

  if (!res.ok) {
    const body = await res.text();
    throw new Error(
      `upsert 失敗 [${topic.topic_id}]: ${res.status} ${res.statusText} - ${body}`
    );
  }
}

// ============================================
// メイン
// ============================================
async function main() {
  const { token, relayUrl } = loadConfig();

  if (!existsSync(MAP_PATH)) {
    console.error(`[ERROR] マップファイルが見つかりません: ${MAP_PATH}`);
    process.exit(1);
  }

  const md = readFileSync(MAP_PATH, "utf-8");
  const topics = parseMap(md);

  console.log(`[seed] パース結果: ${topics.length} トピック`);
  const byArea = topics.reduce((acc, t) => {
    acc[t.area] = (acc[t.area] ?? 0) + 1;
    return acc;
  }, {});
  for (const [area, count] of Object.entries(byArea)) {
    console.log(`  - ${area}: ${count}`);
  }

  let ok = 0;
  let ng = 0;
  for (const topic of topics) {
    try {
      await upsertTopic(relayUrl, token, topic);
      ok++;
      process.stdout.write(".");
    } catch (e) {
      ng++;
      console.error(`\n  ✗ ${topic.topic_id}: ${e.message}`);
    }
  }

  console.log(`\n[seed] 完了: 成功 ${ok} / 失敗 ${ng}`);
  process.exit(ng === 0 ? 0 : 1);
}

main().catch((e) => {
  console.error("[FATAL]", e);
  process.exit(1);
});
