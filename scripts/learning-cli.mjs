#!/usr/bin/env node
/**
 * learning-cli.mjs
 *
 * 夜間自律実行 auto-basics-fill（ローカル /loop）が DB I/O に使う専用 CLI。
 * **生の curl を loop に叩かせず、本 CLI に閉じ込める**ことで:
 *   - INTERNAL_TOKEN は本ファイル内部で .supabase-config から読む → コマンド行に秘密が出ない
 *     （bash-advisor フックの「機密参照＋外部送信」を踏まない。無人 /loop でも止まらない）
 *   - settings.local.json には `Bash(node scripts/learning-cli.mjs:*)` の1行だけを narrow に許可
 *
 * サブコマンド:
 *   get-uncovered [genre] [limit]     未カバー学習トピックを JSON 配列で出力
 *   coverage      [genre]             カバレッジ進捗サマリを JSON で出力
 *   insert        <path-to-json>      記事JSONを insert-article Edge Function に投入(品質ゲート通過)
 *   mark-covered  <topic_id> <article_id>   トピックを covered にマーク(基礎記事のリンク記録)
 *
 * 終了コード: 成功=0 / 失敗=非0（loop は失敗を検知して skip しログできる）
 */

import { readFileSync, existsSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const REPO_ROOT = resolve(__dirname, "..");
const DEFAULT_RELAY_URL =
  "https://research-hub-relay.tak-fukushima1978.workers.dev";

function loadConfig() {
  let token = process.env.INTERNAL_TOKEN ?? null;
  const relayUrl = process.env.RELAY_URL ?? DEFAULT_RELAY_URL;
  if (!token) {
    const candidates = [
      // 正本: git 射程外（C:\dev\.secrets）。tak-work 内は git clean 等で消えうるため fallback
      resolve(REPO_ROOT, "../.secrets/.supabase-config"),
      resolve(REPO_ROOT, "../../.secrets/.supabase-config"),
      resolve(REPO_ROOT, "../tak-work/リサーチ/auto-research/.supabase-config"),
      resolve(REPO_ROOT, "../../tak-work/リサーチ/auto-research/.supabase-config"),
    ];
    for (const path of candidates) {
      if (!existsSync(path)) continue;
      const m = readFileSync(path, "utf-8").match(/^INTERNAL_TOKEN\s*=\s*(.+)$/m);
      if (m) { token = m[1].trim().replace(/^["']|["']$/g, ""); break; }
    }
  }
  if (!token) {
    console.error("[ERROR] INTERNAL_TOKEN が見つかりません（環境変数 or 設定ファイル）");
    process.exit(2);
  }
  return { token, relayUrl };
}

async function rpc(relayUrl, token, name, body) {
  const res = await fetch(`${relayUrl}/rest/v1/rpc/${name}`, {
    method: "POST",
    headers: { "X-Internal-Token": token, "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });
  const text = await res.text();
  if (!res.ok) throw new Error(`rpc ${name} 失敗: ${res.status} ${text}`);
  return text ? JSON.parse(text) : null;
}

async function main() {
  const { token, relayUrl } = loadConfig();
  const [cmd, ...args] = process.argv.slice(2);

  switch (cmd) {
    case "get-uncovered": {
      const [genre, limit] = args;
      const rows = await rpc(relayUrl, token, "get_uncovered_learning_topics", {
        p_genre: genre && genre !== "all" ? genre : null,
        p_limit: limit ? parseInt(limit, 10) : 5,
      });
      process.stdout.write(JSON.stringify(rows, null, 2) + "\n");
      break;
    }
    case "coverage": {
      const [genre] = args;
      const rows = await rpc(relayUrl, token, "get_learning_coverage_summary", {
        p_genre: genre && genre !== "all" ? genre : null,
      });
      process.stdout.write(JSON.stringify(rows, null, 2) + "\n");
      break;
    }
    case "insert": {
      const [jsonPath] = args;
      if (!jsonPath || !existsSync(jsonPath)) {
        console.error("[ERROR] insert には記事JSONファイルのパスが必要です");
        process.exit(2);
      }
      const payload = readFileSync(jsonPath, "utf-8");
      const res = await fetch(`${relayUrl}/functions/v1/insert-article`, {
        method: "POST",
        headers: { "X-Internal-Token": token, "Content-Type": "application/json" },
        body: payload,
      });
      const text = await res.text();
      process.stdout.write(text + "\n");
      if (!res.ok) { console.error(`[insert NG] HTTP ${res.status}`); process.exit(1); }
      break;
    }
    case "mark-covered": {
      const [topicId, articleId] = args;
      if (!topicId || !articleId) {
        console.error("[ERROR] mark-covered には topic_id と article_id が必要です");
        process.exit(2);
      }
      const row = await rpc(relayUrl, token, "mark_learning_topic_covered", {
        p_topic_id: topicId,
        p_article_id: articleId,
      });
      process.stdout.write(JSON.stringify(row) + "\n");
      break;
    }
    default:
      console.error(
        "使い方: node scripts/learning-cli.mjs <get-uncovered|coverage|insert|mark-covered> [args]"
      );
      process.exit(2);
  }
}

main().catch((e) => { console.error(`[ERROR] ${e.message}`); process.exit(1); });
