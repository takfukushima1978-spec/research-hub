// deep-research Edge Function
// Deep Researchの未処理リクエスト取得・結果書き戻しを提供
// 認証: X-Internal-Token または Authorization: Bearer

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY")!;
const INTERNAL_TOKEN = Deno.env.get("INTERNAL_TOKEN")!;

function authenticate(req: Request): boolean {
  const token = req.headers.get("X-Internal-Token")
    || req.headers.get("Authorization")?.replace(/^Bearer\s+/i, "")
    || null;
  return token === INTERNAL_TOKEN;
}

Deno.serve(async (req) => {
  const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type, X-Internal-Token, Authorization",
  };
  const jsonHeaders = { "Content-Type": "application/json", ...corsHeaders };

  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405, headers: jsonHeaders,
    });
  }

  if (!authenticate(req)) {
    return new Response(JSON.stringify({ error: "Unauthorized" }), {
      status: 401, headers: jsonHeaders,
    });
  }

  let body: Record<string, unknown>;
  try {
    body = await req.json() as Record<string, unknown>;
  } catch {
    return new Response(JSON.stringify({ error: "Invalid JSON" }), {
      status: 400, headers: jsonHeaders,
    });
  }

  const action = body.action as string;
  const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

  // === action: list_pending — 未処理リクエスト一覧 ===
  if (action === "list_pending") {
    const { data, error } = await supabase.rpc("get_pending_deep_research");
    if (error) {
      return new Response(JSON.stringify({ error: error.message }), {
        status: 400, headers: jsonHeaders,
      });
    }
    return new Response(JSON.stringify({ requests: data }), {
      status: 200, headers: jsonHeaders,
    });
  }

  // === action: complete — 結果書き戻し ===
  if (action === "complete") {
    const requestId = body.request_id as string;
    const resultSummary = body.result_summary as string;
    const resultBody = body.result_body as string;
    const resultDocUrl = (body.result_doc_url as string) || null;

    if (!requestId) {
      return new Response(JSON.stringify({ error: "request_id は必須です" }), {
        status: 400, headers: jsonHeaders,
      });
    }
    if (!resultSummary || !resultBody) {
      return new Response(JSON.stringify({ error: "result_summary と result_body は必須です" }), {
        status: 400, headers: jsonHeaders,
      });
    }

    const { data, error } = await supabase.rpc("complete_deep_research", {
      p_request_id: requestId,
      p_result_summary: resultSummary,
      p_result_body: resultBody,
      p_result_doc_url: resultDocUrl,
    });

    if (error) {
      console.error("complete_deep_research error:", error.message);
      return new Response(JSON.stringify({ error: error.message }), {
        status: 400, headers: jsonHeaders,
      });
    }

    console.log("Deep research completed:", requestId);
    return new Response(JSON.stringify({ id: data, status: "completed" }), {
      status: 200, headers: jsonHeaders,
    });
  }

  return new Response(JSON.stringify({ error: "不明なactionです。list_pending または complete を指定してください" }), {
    status: 400, headers: jsonHeaders,
  });
});
