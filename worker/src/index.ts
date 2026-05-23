// Research Hub Relay Worker
// Cloudflare Workers 上で動く pass-through proxy。
// Anthropic Routines (data center IP) は Supabase 前段の bot 検知で 403 を食らうため、
// 一度この Worker を経由させて Cloudflare ファミリー間通信に変換する。
//
// エンドポイント:
//   POST /functions/v1/insert-article  → Supabase の同名 Edge Function に転送
//   POST /functions/v1/deep-research   → Supabase の同名 Edge Function に転送
//   POST /rest/v1/rpc/<name>           → Supabase の同名 RPC に転送
//
// 認証: クライアントは X-Internal-Token を送る。Worker は env.INTERNAL_TOKEN と照合し、
// 一致した場合のみ Supabase に転送する (転送時にも同じヘッダを引き継ぐ)。

export interface Env {
  INTERNAL_TOKEN: string;
  SUPABASE_URL: string;
  SUPABASE_ANON_KEY: string;
}

const ALLOWED_PATHS = [
  /^\/functions\/v1\/insert-article$/,
  /^\/functions\/v1\/deep-research$/,
  /^\/rest\/v1\/rpc\/[a-z0-9_]+$/,
];

function jsonResponse(status: number, body: unknown): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

export default {
  async fetch(req: Request, env: Env): Promise<Response> {
    if (req.method === "OPTIONS") {
      return new Response(null, { status: 204 });
    }
    if (req.method !== "POST") {
      return jsonResponse(405, { error: "Method not allowed" });
    }

    // パスのホワイトリストチェック
    const url = new URL(req.url);
    const path = url.pathname;
    if (!ALLOWED_PATHS.some((re) => re.test(path))) {
      return jsonResponse(404, { error: "Not found", path });
    }

    // クライアント認証
    const clientToken = req.headers.get("X-Internal-Token");
    if (!clientToken || clientToken !== env.INTERNAL_TOKEN) {
      return jsonResponse(401, { error: "Unauthorized at relay" });
    }

    // 転送先 URL を構築
    const targetUrl = env.SUPABASE_URL.replace(/\/$/, "") + path + url.search;

    // 転送ヘッダを構築 (元のヘッダは取り回しを単純化するため最小限のみ引き継ぐ)
    const forwardHeaders: Record<string, string> = {
      "Content-Type": req.headers.get("Content-Type") ?? "application/json",
      "Accept": "application/json",
      "X-Internal-Token": env.INTERNAL_TOKEN,
      "Authorization": `Bearer ${env.SUPABASE_ANON_KEY}`,
      "apikey": env.SUPABASE_ANON_KEY,
    };

    // research スキーマ向け REST RPC の場合は Accept-Profile を追加
    if (path.startsWith("/rest/v1/rpc/")) {
      forwardHeaders["Accept-Profile"] = "research";
      forwardHeaders["Content-Profile"] = "research";
    }

    // Supabase に転送
    let upstream: Response;
    try {
      upstream = await fetch(targetUrl, {
        method: "POST",
        headers: forwardHeaders,
        body: await req.text(),
      });
    } catch (err) {
      const msg = err instanceof Error ? err.message : String(err);
      return jsonResponse(502, { error: "Upstream fetch failed", detail: msg });
    }

    // レスポンスをそのまま返す (body も status も)
    const respHeaders = new Headers();
    respHeaders.set("Content-Type", upstream.headers.get("Content-Type") ?? "application/json");
    return new Response(await upstream.text(), {
      status: upstream.status,
      headers: respHeaders,
    });
  },
};
