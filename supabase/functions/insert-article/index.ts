// insert-article Edge Function
// ChatGPT Custom GPT → この関数 → insert_research_article RPC → Research DB
// 認証: X-Internal-Token ヘッダーによる共有シークレット検証

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY")!;
const INTERNAL_TOKEN = Deno.env.get("INTERNAL_TOKEN")!;

// レートリミット: IPごとに1分間10リクエストまで
const rateLimitMap = new Map<string, { count: number; resetAt: number }>();
const RATE_LIMIT_WINDOW_MS = 60_000;
const RATE_LIMIT_MAX = 10;

function checkRateLimit(ip: string): boolean {
  const now = Date.now();
  const entry = rateLimitMap.get(ip);
  if (!entry || now > entry.resetAt) {
    rateLimitMap.set(ip, { count: 1, resetAt: now + RATE_LIMIT_WINDOW_MS });
    return true;
  }
  entry.count++;
  return entry.count <= RATE_LIMIT_MAX;
}

// バリデーション: 必須フィールドの存在と型チェック
interface ArticlePayload {
  title: string;
  slug: string;
  category_name: string;
  body_html: string;
  body_text: string;
  summary: string;
  source_date: string;
  css_template_id?: string | null;
  tag_names?: string[];
  source_urls?: { url: string; title: string; domain: string }[];
}

function validatePayload(body: unknown): { ok: true; data: ArticlePayload } | { ok: false; error: string } {
  if (!body || typeof body !== "object") {
    return { ok: false, error: "リクエストボディがJSONオブジェクトではありません" };
  }

  const b = body as Record<string, unknown>;
  const requiredStrings = ["title", "slug", "category_name", "body_html", "body_text", "summary", "source_date"];
  for (const key of requiredStrings) {
    if (typeof b[key] !== "string" || (b[key] as string).trim() === "") {
      return { ok: false, error: `${key} は必須の文字列フィールドです` };
    }
  }

  // source_date の形式チェック（YYYY-MM-DD）
  if (!/^\d{4}-\d{2}-\d{2}$/.test(b.source_date as string)) {
    return { ok: false, error: "source_date はYYYY-MM-DD形式で指定してください" };
  }

  // tag_names: 省略可、指定時は文字列配列
  if (b.tag_names !== undefined && b.tag_names !== null) {
    if (!Array.isArray(b.tag_names) || !b.tag_names.every((t: unknown) => typeof t === "string")) {
      return { ok: false, error: "tag_names は文字列の配列で指定してください" };
    }
  }

  // source_urls: 省略可、指定時はオブジェクト配列
  if (b.source_urls !== undefined && b.source_urls !== null) {
    if (!Array.isArray(b.source_urls)) {
      return { ok: false, error: "source_urls は配列で指定してください" };
    }
    for (const s of b.source_urls) {
      if (typeof s !== "object" || !s || typeof s.url !== "string") {
        return { ok: false, error: "source_urls の各要素には url が必要です" };
      }
    }
  }

  return { ok: true, data: b as unknown as ArticlePayload };
}

Deno.serve(async (req) => {
  // CORSプリフライト対応
  if (req.method === "OPTIONS") {
    return new Response(null, {
      status: 204,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type, X-Internal-Token",
      },
    });
  }

  // POSTのみ許可
  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
      headers: { "Content-Type": "application/json" },
    });
  }

  // トークン検証
  const token = req.headers.get("X-Internal-Token");
  if (!token || token !== INTERNAL_TOKEN) {
    return new Response(JSON.stringify({ error: "Unauthorized" }), {
      status: 401,
      headers: { "Content-Type": "application/json" },
    });
  }

  // レートリミット
  const ip = req.headers.get("x-forwarded-for")?.split(",")[0]?.trim() ?? "unknown";
  if (!checkRateLimit(ip)) {
    return new Response(JSON.stringify({ error: "Rate limit exceeded" }), {
      status: 429,
      headers: { "Content-Type": "application/json" },
    });
  }

  // リクエストボディのパース・バリデーション
  let body: unknown;
  try {
    body = await req.json();
  } catch {
    return new Response(JSON.stringify({ error: "Invalid JSON" }), {
      status: 400,
      headers: { "Content-Type": "application/json" },
    });
  }

  const validation = validatePayload(body);
  if (!validation.ok) {
    return new Response(JSON.stringify({ error: validation.error }), {
      status: 400,
      headers: { "Content-Type": "application/json" },
    });
  }

  const data = validation.data;

  // Supabaseクライアントでinsert_research_article RPCを呼び出し
  const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
  const { data: articleId, error } = await supabase.rpc("insert_research_article", {
    p_title: data.title,
    p_slug: data.slug,
    p_category_name: data.category_name,
    p_body_html: data.body_html,
    p_body_text: data.body_text,
    p_summary: data.summary,
    p_source_date: data.source_date,
    p_css_template_id: data.css_template_id ?? null,
    p_tag_names: data.tag_names ?? [],
    p_source_urls: data.source_urls ?? [],
  });

  if (error) {
    console.error("RPC error:", error);
    return new Response(JSON.stringify({ error: error.message }), {
      status: 400,
      headers: { "Content-Type": "application/json" },
    });
  }

  return new Response(JSON.stringify({ id: articleId }), {
    status: 201,
    headers: { "Content-Type": "application/json" },
  });
});
