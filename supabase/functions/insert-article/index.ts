// insert-article Edge Function v2
// ChatGPT Custom GPT / Gmail Import → この関数 → insert_research_article RPC → Research DB
// 認証: X-Internal-Token ヘッダーによる共有シークレット検証

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY")!;
const INTERNAL_TOKEN = Deno.env.get("INTERNAL_TOKEN")!;

// レートリミット: IPごとに1分間10リクエストまで
const rateLimitMap = new Map<string, { count: number; resetAt: number }>();
const RATE_LIMIT_WINDOW_MS = 60_000;
const RATE_LIMIT_MAX = 10;

// 記事品質ノルマ（Deep / Wide な記事のみを許容）
// 環境変数で上書き可能: MIN_BODY_TEXT_LENGTH / MIN_SOURCE_URLS / MIN_TAG_NAMES
// quality_override: true をペイロードに含めると個別にスキップ可能（手動投入用）
const MIN_BODY_TEXT_LENGTH = parseInt(Deno.env.get("MIN_BODY_TEXT_LENGTH") ?? "1500", 10);
const MIN_SOURCE_URLS = parseInt(Deno.env.get("MIN_SOURCE_URLS") ?? "3", 10);
const MIN_TAG_NAMES = parseInt(Deno.env.get("MIN_TAG_NAMES") ?? "4", 10);

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

// slug自動生成: タイトルと日付からslugを作成
function generateSlug(title: string, sourceDate: string): string {
  const base = title
    .replace(/[^a-zA-Z0-9\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FFF\s-]/g, "")
    .trim()
    .substring(0, 40)
    .replace(/\s+/g, "-")
    .toLowerCase();
  const datePart = sourceDate.replace(/-/g, "");
  const rand = Math.random().toString(36).substring(2, 8);
  return `${datePart}_${base || "article"}_${rand}`;
}

// バリデーション
interface ArticlePayload {
  title: string;
  slug?: string;
  category_name: string;
  body_html: string;
  body_text?: string;
  summary: string;
  source_date: string;
  css_template_id?: string | null;
  tag_names?: string[];
  source_urls?: { url: string; title: string; domain: string }[];
  quality_override?: boolean;
  embedding?: number[];
  similarity_threshold?: number;
  similarity_days?: number;
  force_insert?: boolean;
}

function validatePayload(body: unknown): { ok: true; data: ArticlePayload } | { ok: false; error: string } {
  if (!body || typeof body !== "object") {
    return { ok: false, error: "リクエストボディがJSONオブジェクトではありません" };
  }

  const b = body as Record<string, unknown>;

  // title は必須
  if (typeof b.title !== "string" || b.title.trim() === "") {
    return { ok: false, error: "title は必須の文字列フィールドです" };
  }

  // category_name: 必須（RPCで自動作成されるため存在チェックのみ）
  if (typeof b.category_name !== "string" || b.category_name.trim() === "") {
    return { ok: false, error: "category_name は必須の文字列フィールドです" };
  }

  // body_html: 必須
  if (typeof b.body_html !== "string" || b.body_html.trim() === "") {
    return { ok: false, error: "body_html は必須の文字列フィールドです" };
  }

  // summary: 必須
  if (typeof b.summary !== "string" || b.summary.trim() === "") {
    return { ok: false, error: "summary は必須の文字列フィールドです" };
  }

  // source_date: 必須、YYYY-MM-DD形式
  if (typeof b.source_date !== "string" || b.source_date.trim() === "") {
    return { ok: false, error: "source_date は必須の文字列フィールドです" };
  }
  if (!/^\d{4}-\d{2}-\d{2}$/.test(b.source_date as string)) {
    return { ok: false, error: "source_date はYYYY-MM-DD形式で指定してください" };
  }

  // body_text: 省略可（body_htmlからストリップして自動生成）
  if (b.body_text !== undefined && b.body_text !== null && typeof b.body_text !== "string") {
    return { ok: false, error: "body_text は文字列で指定してください" };
  }

  // slug: 省略可（自動生成）
  if (b.slug !== undefined && b.slug !== null && typeof b.slug !== "string") {
    return { ok: false, error: "slug は文字列で指定してください" };
  }

  // tag_names: 省略可
  if (b.tag_names !== undefined && b.tag_names !== null) {
    if (!Array.isArray(b.tag_names) || !b.tag_names.every((t: unknown) => typeof t === "string")) {
      return { ok: false, error: "tag_names は文字列の配列で指定してください" };
    }
  }

  // quality_override: 省略可（true の場合、品質ノルマチェックをスキップ）
  if (b.quality_override !== undefined && b.quality_override !== null && typeof b.quality_override !== "boolean") {
    return { ok: false, error: "quality_override は boolean で指定してください" };
  }

  // embedding: 省略可（指定時は数値配列）
  if (b.embedding !== undefined && b.embedding !== null) {
    if (!Array.isArray(b.embedding) || !b.embedding.every((v: unknown) => typeof v === "number" && Number.isFinite(v))) {
      return { ok: false, error: "embedding は数値の配列で指定してください" };
    }
  }

  // similarity_threshold: 省略可（0〜1の数値）
  if (b.similarity_threshold !== undefined && b.similarity_threshold !== null) {
    if (typeof b.similarity_threshold !== "number" || b.similarity_threshold < 0 || b.similarity_threshold > 1) {
      return { ok: false, error: "similarity_threshold は 0〜1 の数値で指定してください" };
    }
  }

  // similarity_days: 省略可（正の整数）
  if (b.similarity_days !== undefined && b.similarity_days !== null) {
    if (typeof b.similarity_days !== "number" || !Number.isInteger(b.similarity_days) || b.similarity_days < 1) {
      return { ok: false, error: "similarity_days は正の整数で指定してください" };
    }
  }

  // force_insert: 省略可（true の場合、類似度判定をスキップ）
  if (b.force_insert !== undefined && b.force_insert !== null && typeof b.force_insert !== "boolean") {
    return { ok: false, error: "force_insert は boolean で指定してください" };
  }

  // source_urls: 省略可
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

// HTMLタグ除去（body_text自動生成用）
function stripHtml(html: string): string {
  return html.replace(/<[^>]*>/g, " ").replace(/\s+/g, " ").trim();
}

Deno.serve(async (req) => {
  const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type, X-Internal-Token, Authorization",
  };

  // CORSプリフライト
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: corsHeaders });
  }

  // POSTのみ許可
  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
      headers: { "Content-Type": "application/json", ...corsHeaders },
    });
  }

  // トークン検証（X-Internal-Token または Authorization: Bearer の両方に対応）
  const token = req.headers.get("X-Internal-Token")
    || req.headers.get("Authorization")?.replace(/^Bearer\s+/i, "")
    || null;
  if (!token || token !== INTERNAL_TOKEN) {
    return new Response(JSON.stringify({ error: "Unauthorized" }), {
      status: 401,
      headers: { "Content-Type": "application/json", ...corsHeaders },
    });
  }

  // レートリミット
  const ip = req.headers.get("x-forwarded-for")?.split(",")[0]?.trim() ?? "unknown";
  if (!checkRateLimit(ip)) {
    return new Response(JSON.stringify({ error: "Rate limit exceeded" }), {
      status: 429,
      headers: { "Content-Type": "application/json", ...corsHeaders },
    });
  }

  // リクエストボディのパース
  let body: unknown;
  try {
    body = await req.json();
  } catch {
    return new Response(JSON.stringify({ error: "Invalid JSON" }), {
      status: 400,
      headers: { "Content-Type": "application/json", ...corsHeaders },
    });
  }

  // バリデーション
  const validation = validatePayload(body);
  if (!validation.ok) {
    console.error("Validation failed:", validation.error, JSON.stringify(body).substring(0, 500));
    return new Response(JSON.stringify({ error: validation.error }), {
      status: 400,
      headers: { "Content-Type": "application/json", ...corsHeaders },
    });
  }

  const data = validation.data;

  // slug自動生成
  const slug = data.slug?.trim() || generateSlug(data.title, data.source_date);

  // body_text自動生成（未指定時）
  const bodyText = data.body_text?.trim() || stripHtml(data.body_html);

  // 品質ノルマ検証（quality_override:true でスキップ可能）
  if (!data.quality_override) {
    const qualityErrors: string[] = [];
    if (bodyText.length < MIN_BODY_TEXT_LENGTH) {
      qualityErrors.push(
        `本文が短すぎます (${bodyText.length} 文字)。最低 ${MIN_BODY_TEXT_LENGTH} 文字必要です。背景・事実データ・比較・インパクト分析・アクションアイテムを含めて拡充してください。`,
      );
    }
    const sourceCount = data.source_urls?.length ?? 0;
    if (sourceCount < MIN_SOURCE_URLS) {
      qualityErrors.push(
        `source_urls が不足しています (${sourceCount} 件)。最低 ${MIN_SOURCE_URLS} 件の一次ソースを含めてください。`,
      );
    }
    const tagCount = data.tag_names?.length ?? 0;
    if (tagCount < MIN_TAG_NAMES) {
      qualityErrors.push(
        `tag_names が不足しています (${tagCount} 件)。最低 ${MIN_TAG_NAMES} 件のタグを付けてください。`,
      );
    }
    if (qualityErrors.length > 0) {
      console.warn("Quality check failed:", qualityErrors.join(" / "));
      return new Response(
        JSON.stringify({
          error: "記事品質ノルマを満たしていません",
          details: qualityErrors,
          hint: "auto-research-collect では body_text 1500-2500字 / source_urls 3件以上 / tag_names 4件以上 が必須です。手動投入時のみ quality_override:true で回避可能。",
        }),
        { status: 400, headers: { "Content-Type": "application/json", ...corsHeaders } },
      );
    }
  }

  // SupabaseクライアントでRPC呼び出し
  const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

  // embedding ベース重複検知 (opt-in: embedding が送られてきた場合のみ)
  // force_insert:true でスキップ可能
  if (data.embedding && data.embedding.length > 0 && !data.force_insert) {
    const threshold = data.similarity_threshold ?? 0.85;
    const days = data.similarity_days ?? 30;
    const { data: similar, error: simError } = await supabase.rpc("find_similar_articles_by_embedding", {
      p_embedding: data.embedding,
      p_threshold: threshold,
      p_days: days,
      p_limit: 5,
    });
    if (simError) {
      // RPC 未デプロイ等は致命的にせず、ログだけ残してスキップ (後方互換性)
      console.warn("find_similar_articles_by_embedding skipped:", simError.message);
    } else if (Array.isArray(similar) && similar.length > 0) {
      console.warn("Similar article detected, rejecting insert:", similar);
      return new Response(
        JSON.stringify({
          error: "類似する既存記事が存在します",
          similar_articles: similar,
          hint: `閾値 ${threshold} 以上の類似度の既存記事を検出。別アングルで書き直すか、force_insert:true で強制投入してください。`,
        }),
        { status: 409, headers: { "Content-Type": "application/json", ...corsHeaders } },
      );
    }
  }

  const { data: articleId, error } = await supabase.rpc("insert_research_article", {
    p_title: data.title,
    p_slug: slug,
    p_category_name: data.category_name,
    p_body_html: data.body_html,
    p_body_text: bodyText,
    p_summary: data.summary,
    p_source_date: data.source_date,
    p_css_template_id: data.css_template_id ?? null,
    p_tag_names: data.tag_names ?? [],
    p_source_urls: data.source_urls ?? [],
  });

  if (error) {
    console.error("RPC error:", error.message, "code:", error.code, "details:", error.details);
    return new Response(JSON.stringify({ error: error.message, code: error.code }), {
      status: 400,
      headers: { "Content-Type": "application/json", ...corsHeaders },
    });
  }

  // embedding が送られていれば書き戻す (失敗しても投入自体は成功扱い)
  let embeddingStored = false;
  if (data.embedding && data.embedding.length > 0) {
    const { error: embError } = await supabase.rpc("update_article_embedding", {
      p_article_id: articleId,
      p_embedding: data.embedding,
    });
    if (embError) {
      console.warn("update_article_embedding failed:", embError.message);
    } else {
      embeddingStored = true;
    }
  }

  console.log("Article inserted:", articleId, "slug:", slug, "embedding_stored:", embeddingStored);
  return new Response(JSON.stringify({ id: articleId, slug: slug, embedding_stored: embeddingStored }), {
    status: 201,
    headers: { "Content-Type": "application/json", ...corsHeaders },
  });
});
