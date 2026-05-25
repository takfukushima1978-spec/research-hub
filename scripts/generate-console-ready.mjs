#!/usr/bin/env node
/**
 * generate-console-ready.mjs
 *
 * prompts/*-CONSOLE.md のプレースホルダを実値に置換して
 * prompts/CONSOLE-READY-*.md を生成する。
 *
 * 使い方:
 *   node scripts/generate-console-ready.mjs                  # 全 *-CONSOLE.md を変換
 *   node scripts/generate-console-ready.mjs auto-claude-code-watch  # 1 つだけ
 *
 * プレースホルダ:
 *   <<RELAY_URL>>      → https://research-hub-relay.tak-fukushima1978.workers.dev
 *   <<INTERNAL_TOKEN>> → .supabase-config から取得
 *
 * 出力ファイルは .gitignore 対象。コミットしない。
 */

import { readFileSync, writeFileSync, existsSync, readdirSync } from "node:fs";
import { dirname, resolve, basename } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const REPO_ROOT = resolve(__dirname, "..");
const PROMPTS_DIR = resolve(REPO_ROOT, "prompts");

const DEFAULT_RELAY_URL =
  "https://research-hub-relay.tak-fukushima1978.workers.dev";

function loadToken() {
  if (process.env.INTERNAL_TOKEN) return process.env.INTERNAL_TOKEN;

  const candidates = [
    resolve(REPO_ROOT, "../tak-work/リサーチ/auto-research/.supabase-config"),
    resolve(REPO_ROOT, "../../tak-work/リサーチ/auto-research/.supabase-config"),
  ];
  for (const path of candidates) {
    if (!existsSync(path)) continue;
    const content = readFileSync(path, "utf-8");
    const m = content.match(/^INTERNAL_TOKEN\s*=\s*(.+)$/m);
    if (m) {
      console.log(`[gen] INTERNAL_TOKEN を ${path} から取得`);
      return m[1].trim().replace(/^["']|["']$/g, "");
    }
  }

  console.error(
    "[ERROR] INTERNAL_TOKEN が見つかりません。" +
      "環境変数 INTERNAL_TOKEN を設定するか、" +
      ".supabase-config を配置してください。"
  );
  process.exit(1);
}

function processFile(srcName, token, relayUrl) {
  const srcPath = resolve(PROMPTS_DIR, srcName);
  const dstName = `CONSOLE-READY-${srcName.replace(/-CONSOLE\.md$/, ".md")}`;
  const dstPath = resolve(PROMPTS_DIR, dstName);

  let content = readFileSync(srcPath, "utf-8");

  // ヘッダー部 (---で囲まれた前段、Console に貼らない説明) を切り落とす
  // 各 *-CONSOLE.md は「# ▼ ここから下が Console に貼り付ける本体 ▼」以降が本体
  const marker = "# ▼ ここから下が Console に貼り付ける本体 ▼";
  const idx = content.indexOf(marker);
  if (idx !== -1) {
    content = content.substring(idx + marker.length).trimStart();
  }

  // プレースホルダ置換
  const before = content;
  content = content
    .replaceAll("<<RELAY_URL>>", relayUrl)
    .replaceAll("<<INTERNAL_TOKEN>>", token);

  const replacedRelay = (before.match(/<<RELAY_URL>>/g) || []).length;
  const replacedToken = (before.match(/<<INTERNAL_TOKEN>>/g) || []).length;

  writeFileSync(dstPath, content, "utf-8");
  console.log(
    `[gen] ${srcName} → ${dstName} ` +
      `(RELAY_URL ${replacedRelay} 箇所 / INTERNAL_TOKEN ${replacedToken} 箇所 置換)`
  );
}

function main() {
  const token = loadToken();
  const relayUrl = process.env.RELAY_URL ?? DEFAULT_RELAY_URL;
  const arg = process.argv[2];

  let targets;
  if (arg) {
    // 引数指定: "auto-claude-code-watch" or "auto-claude-code-watch-CONSOLE.md"
    const name = arg.endsWith(".md") ? arg : `${arg}-CONSOLE.md`;
    targets = [name];
  } else {
    targets = readdirSync(PROMPTS_DIR)
      .filter((n) => n.endsWith("-CONSOLE.md") && !n.startsWith("CONSOLE-READY"));
  }

  for (const name of targets) {
    const path = resolve(PROMPTS_DIR, name);
    if (!existsSync(path)) {
      console.error(`[skip] ${name} が見つかりません`);
      continue;
    }
    processFile(name, token, relayUrl);
  }
}

main();
