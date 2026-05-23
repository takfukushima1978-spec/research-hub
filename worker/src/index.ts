// Research Hub Relay Worker
// Cloudflare Workers 上で動く pass-through proxy。
// Anthropic Routines (data center IP) は Supabase 前段の bot 検知で 403 を食らうため、
// 一度この Worker を経由させて Cloudflare ファミリー間通信に変換する。
//
// エンドポイント (Supabase 中継):
//   POST /functions/v1/insert-article    → Supabase の同名 Edge Function に転送
//   POST /functions/v1/deep-research     → Supabase の同名 Edge Function に転送
//   POST /rest/v1/rpc/<name>             → Supabase の同名 RPC に転送
//   GET  /rest/v1/articles?<query>       → Supabase の同名 REST endpoint に転送（research スキーマ）
//
// エンドポイント (通知転送):
//   POST /notify/discord                 → DISCORD_WEBHOOK_URL に body をそのまま転送
//
// 認証: クライアントは X-Internal-Token を送る。Worker は env.INTERNAL_TOKEN と照合し、
// 一致した場合のみ転送する。

export interface Env {
  INTERNAL_TOKEN: string;
  SUPABASE_URL: string;
  SUPABASE_ANON_KEY: string;
  DISCORD_WEBHOOK_URL?: string;
}

// 許可ルート: [HTTP method, path regex] のタプル
const ALLOWED_ROUTES: Array<[string, RegExp]> = [
  ["POST", /^\/functions\/v1\/insert-article$/],
  ["POST", /^\/functions\/v1\/deep-research$/],
  ["POST", /^\/rest\/v1\/rpc\/[a-z0-9_]+$/],
  ["GET",  /^\/rest\/v1\/articles$/],
  ["POST", /^\/notify\/discord$/],
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
    if (req.method !== "POST" && req.method !== "GET") {
      return jsonResponse(405, { error: "Method not allowed" });
    }

    // パス・メソッドのホワイトリストチェック
    const url = new URL(req.url);
    const path = url.pathname;
    const allowed = ALLOWED_ROUTES.some(([m, re]) => m === req.method && re.test(path));
    if (!allowed) {
      return jsonResponse(404, { error: "Not found", method: req.method, path });
    }

    // クライアント認証
    const clientToken = req.headers.get("X-Internal-Token");
    if (!clientToken || clientToken !== env.INTERNAL_TOKEN) {
      return jsonResponse(401, { error: "Unauthorized at relay" });
    }

    // /notify/discord: Discord webhook に転送 (Supabase 経路とは別系統)
    if (path === "/notify/discord") {
      if (!env.DISCORD_WEBHOOK_URL) {
        return jsonResponse(503, { error: "DISCORD_WEBHOOK_URL not configured" });
      }
      try {
        const upstream = await fetch(env.DISCORD_WEBHOOK_URL, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: await req.text(),
        });
        // Discord は成功時 204 (No Content) を返す
        const respBody = upstream.status === 204 ? "" : await upstream.text();
        return new Response(respBody, {
          status: upstream.status,
          headers: { "Content-Type": "application/json" },
        });
      } catch (err) {
        const msg = err instanceof Error ? err.message : String(err);
        return jsonResponse(502, { error: "Discord webhook fetch failed", detail: msg });
      }
    }

    // Supabase 中継: 転送先 URL を構築 (クエリパラメータも転送)
    const targetUrl = env.SUPABASE_URL.replace(/\/$/, "") + path + url.search;

    // 転送ヘッダを構築 (元のヘッダは取り回しを単純化するため最小限のみ引き継ぐ)
    const forwardHeaders: Record<string, string> = {
      "Accept": "application/json",
      "X-Internal-Token": env.INTERNAL_TOKEN,
      "Authorization": `Bearer ${env.SUPABASE_ANON_KEY}`,
      "apikey": env.SUPABASE_ANON_KEY,
    };
    if (req.method === "POST") {
      forwardHeaders["Content-Type"] = req.headers.get("Content-Type") ?? "application/json";
    }

    // research スキーマ向けの REST RPC・articles テーブルは Accept-Profile が必要
    if (path.startsWith("/rest/v1/")) {
      forwardHeaders["Accept-Profile"] = "research";
      if (req.method === "POST") {
        forwardHeaders["Content-Profile"] = "research";
      }
    }

    // Supabase に転送
    let upstream: Response;
    try {
      const fetchInit: RequestInit = {
        method: req.method,
        headers: forwardHeaders,
      };
      if (req.method === "POST") {
        fetchInit.body = await req.text();
      }
      upstream = await fetch(targetUrl, fetchInit);
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
