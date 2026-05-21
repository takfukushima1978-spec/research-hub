#!/usr/bin/env python3
"""
Research Hub - Gmail下書き → Supabase自動投入スクリプト

スケジュールタスクが生成したGmail下書きを取得し、
記事データを抽出してSupabaseに投入する。

初回実行:
  pip install google-auth-oauthlib google-api-python-client requests
  python 05_gmail_to_supabase.py

初回はブラウザが開いてGoogleログインを求められます。
認証後、token.json が保存され、以降は自動で動きます。

Windowsタスクスケジューラで毎日11:00に実行設定推奨。
"""

import os
import sys
import re
import json
import base64
import time
from pathlib import Path

from dotenv import load_dotenv
load_dotenv(Path(__file__).parent / ".env")

try:
    import requests
except ImportError:
    print("pip install requests"); sys.exit(1)

try:
    from google.auth.transport.requests import Request
    from google.oauth2.credentials import Credentials
    from google_auth_oauthlib.flow import InstalledAppFlow
    from googleapiclient.discovery import build
except ImportError:
    print("pip install google-auth-oauthlib google-api-python-client")
    sys.exit(1)

# ============================================
# 設定
# ============================================
SCRIPT_DIR = Path(__file__).parent
CREDENTIALS_FILE = SCRIPT_DIR / "credentials.json"
TOKEN_FILE = SCRIPT_DIR / "token.json"

GMAIL_SCOPES = ["https://www.googleapis.com/auth/gmail.modify"]

SUPABASE_URL = os.environ["SUPABASE_URL"]
SUPABASE_KEY = os.environ["SUPABASE_KEY"]

HEADERS_READ = {
    "apikey": SUPABASE_KEY,
    "Authorization": f"Bearer {SUPABASE_KEY}",
    "Accept-Profile": "research",
}
HEADERS_WRITE = {
    "apikey": SUPABASE_KEY,
    "Authorization": f"Bearer {SUPABASE_KEY}",
    "Content-Type": "application/json",
    "Accept-Profile": "research",
    "Content-Profile": "research",
    "Prefer": "return=representation",
}

API = f"{SUPABASE_URL}/rest/v1"

# 対象の件名プレフィックス
SUBJECT_PREFIXES = [
    "[Claude Code Daily]",
    "[Claude Code公式]",
    "[AI会計Daily]",
    "[Notion Weekly]",
    "[Weekly Digest]",
]

# 件名プレフィックス → カテゴリ名マッピング
CATEGORY_MAP = {
    "[Claude Code Daily]": "claude_code",
    "[Claude Code公式]": "claude_code_official",
    "[AI会計Daily]": "ai_accounting",
    "[Notion Weekly]": "claude_code",  # 適切なカテゴリがなければ追加検討
    "[Weekly Digest]": "claude_code",
}

# タグ自動判定ルール
TAG_RULES = {
    'accounting': ['会計', '税務', '監査', '税理士', '会計士'],
    'audit': ['監査', 'audit', 'EY', 'KPMG'],
    'tax': ['税理士', '税務', '確定申告', '相続税', '国税'],
    'bookkeeping': ['記帳', '仕訳', 'AI-OCR', 'Digits'],
    'ai_tech': ['AI', 'LLM', 'モデル', 'Opus', 'Sonnet'],
    'agents': ['エージェント', 'Agent Teams', 'Managed Agents'],
    'computer_use': ['Computer Use', 'デスクトップ操作', 'Vercept'],
    'mcp': ['MCP', 'Elicitation', 'MCPサーバー'],
    'claude_code': ['Claude Code', '/compact', '/powerup', '/loop'],
    'hooks': ['Hooks', 'フック', 'PreToolUse', 'ガードレール'],
    'cowork': ['Cowork', 'コネクタ', 'Dispatch'],
    'security_risk': ['セキュリティ', '脆弱性', '攻撃', '流出'],
    'vulnerability': ['脆弱性', 'CVE', 'ゼロデイ', 'ソースコード流出'],
    'prompt_injection': ['プロンプトインジェクション', 'Claudy Day'],
    'policy': ['ポリシー', 'RSP', 'サードパーティ'],
    'dx': ['DX', '業務効率化', 'ROI', 'コスト削減'],
    'industry': ['業界動向', 'スタートアップ', '買収'],
}

# ============================================
# Gmail認証
# ============================================
def get_gmail_service():
    creds = None
    if TOKEN_FILE.exists():
        creds = Credentials.from_authorized_user_file(str(TOKEN_FILE), GMAIL_SCOPES)
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            if not CREDENTIALS_FILE.exists():
                print(f"ERROR: {CREDENTIALS_FILE} が見つかりません。")
                print("Google Cloud ConsoleからOAuthクライアントのJSONをダウンロードして")
                print(f"{CREDENTIALS_FILE} として保存してください。")
                sys.exit(1)
            flow = InstalledAppFlow.from_client_secrets_file(
                str(CREDENTIALS_FILE), GMAIL_SCOPES
            )
            creds = flow.run_local_server(port=0)
        with open(TOKEN_FILE, "w") as f:
            f.write(creds.to_json())
    return build("gmail", "v1", credentials=creds)

# ============================================
# Supabase API
# ============================================
def sb_get(path, params=None):
    r = requests.get(f"{API}/{path}", headers=HEADERS_READ, params=params or {})
    r.raise_for_status()
    return r.json()

def sb_post(path, data):
    r = requests.post(f"{API}/{path}", headers=HEADERS_WRITE, json=data)
    if r.status_code >= 400:
        if 'duplicate' not in r.text.lower():
            print(f"  POST error {r.status_code}: {r.text[:200]}")
        return None
    return r.json()

# ============================================
# Gmail下書き処理
# ============================================
def get_research_drafts(service):
    """リサーチ記事の下書きを取得"""
    results = service.users().drafts().list(userId="me").execute()
    drafts = results.get("drafts", [])
    research_drafts = []

    for draft_meta in drafts:
        draft = service.users().drafts().get(
            userId="me", id=draft_meta["id"], format="full"
        ).execute()
        msg = draft["message"]
        headers = {h["name"]: h["value"] for h in msg["payload"]["headers"]}
        subject = headers.get("Subject", "")

        # リサーチ記事の下書きかチェック
        matched_prefix = None
        for prefix in SUBJECT_PREFIXES:
            if subject.startswith(prefix):
                matched_prefix = prefix
                break
        if not matched_prefix:
            continue

        # HTMLボディを取得
        body_html = ""
        payload = msg["payload"]
        if payload.get("body", {}).get("data"):
            body_html = base64.urlsafe_b64decode(payload["body"]["data"]).decode("utf-8")
        elif payload.get("parts"):
            for part in payload["parts"]:
                if part["mimeType"] == "text/html" and part.get("body", {}).get("data"):
                    body_html = base64.urlsafe_b64decode(part["body"]["data"]).decode("utf-8")
                    break

        if not body_html:
            continue

        research_drafts.append({
            "draft_id": draft_meta["id"],
            "message_id": msg["id"],
            "subject": subject,
            "prefix": matched_prefix,
            "body_html": body_html,
            "date": headers.get("Date", ""),
        })

    return research_drafts

def extract_article_from_html(subject, prefix, body_html):
    """Gmail HTMLからSupabase投入用データを抽出"""
    # タイトル抽出（件名からプレフィックスと日付を除去）
    title = subject.replace(prefix, "").strip()
    # 末尾の日付 " - YYYY-MM-DD" を除去
    date_match = re.search(r' - (\d{4}-\d{2}-\d{2})$', title)
    source_date = date_match.group(1) if date_match else None
    if date_match:
        title = title[:date_match.start()].strip()

    # プレーンテキスト抽出
    text = re.sub(r'<style>.*?</style>', '', body_html, flags=re.DOTALL)
    text = re.sub(r'<[^>]+>', ' ', text)
    text = re.sub(r'&[a-zA-Z]+;', ' ', text)
    text = re.sub(r'\s+', ' ', text).strip()

    # サマリー（先頭200文字）
    summary = text[:200] if text else ""

    # slug生成
    slug_date = source_date or time.strftime("%Y-%m-%d")
    slug_title = re.sub(r'[^\w\s-]', '', title)[:40].strip().replace(' ', '-').lower()
    slug = f"{slug_date}_{slug_title or 'article'}"
    # ASCII以外を除去してslugをクリーンに
    slug = re.sub(r'[^\x00-\x7F]+', '', slug).strip('-_')
    if not slug or slug == slug_date + '_':
        slug = f"{slug_date}_research_{hash(title) % 10000:04d}"

    # カテゴリ
    category_name = CATEGORY_MAP.get(prefix, "claude_code")

    # ソースURL抽出
    sources = []
    for link in re.finditer(r'href="(https?://[^"]+)"', body_html):
        url = link.group(1)
        if url not in [s['url'] for s in sources]:
            domain_match = re.search(r'https?://([^/]+)', url)
            sources.append({
                'url': url,
                'title': '',
                'domain': domain_match.group(1) if domain_match else ''
            })

    return {
        'title': title,
        'title_ja': title,
        'slug': slug,
        'category_name': category_name,
        'source_date': source_date,
        'summary': summary,
        'body_html': body_html,
        'body_text': text,
        'sources': sources,
    }

def detect_tag_names(text):
    """テキストからマッチするタグ名のリストを返す"""
    text_lower = text.lower()
    matched = []
    for tag_name, keywords in TAG_RULES.items():
        for kw in keywords:
            if kw.lower() in text_lower:
                matched.append(tag_name)
                break
    return matched

# ============================================
# ラベル管理（処理済みマーク）
# ============================================
def get_or_create_label(service, label_name="ResearchHub/Processed"):
    """処理済みラベルを取得または作成"""
    results = service.users().labels().list(userId="me").execute()
    for label in results.get("labels", []):
        if label["name"] == label_name:
            return label["id"]
    # 作成
    body = {"name": label_name, "labelListVisibility": "labelShow", "messageListVisibility": "show"}
    label = service.users().labels().create(userId="me", body=body).execute()
    return label["id"]

def mark_as_processed(service, message_id, label_id):
    """メッセージに処理済みラベルを付与"""
    service.users().messages().modify(
        userId="me", id=message_id,
        body={"addLabelIds": [label_id]}
    ).execute()

def is_processed(service, message_id, label_id):
    """メッセージが処理済みかチェック"""
    msg = service.users().messages().get(userId="me", id=message_id, format="minimal").execute()
    return label_id in msg.get("labelIds", [])

# ============================================
# メイン処理
# ============================================
def main():
    print("=" * 60)
    print("Research Hub - Gmail → Supabase 自動投入")
    print("=" * 60)

    # Gmail認証
    print("\n[1/5] Gmail認証...")
    service = get_gmail_service()
    print("  OK!")

    # 処理済みラベル取得
    label_id = get_or_create_label(service)
    print(f"  処理済みラベルID: {label_id}")

    # Supabaseマスタ取得
    print("\n[2/5] Supabaseマスタ取得...")
    templates = sb_get("css_templates", {"select": "id", "is_default": "eq.true"})
    css_id = templates[0]['id'] if templates else None
    print(f"  CSSテンプレート: {css_id}")

    # 既存slug取得（重複チェック用）
    existing = sb_get("articles", {"select": "slug"})
    existing_slugs = set(a['slug'] for a in existing)

    # Gmail下書き取得
    print("\n[3/5] Gmail下書き取得...")
    drafts = get_research_drafts(service)
    print(f"  リサーチ下書き: {len(drafts)} 件")

    # 未処理のみフィルタ
    unprocessed = []
    for d in drafts:
        if not is_processed(service, d['message_id'], label_id):
            unprocessed.append(d)
    print(f"  未処理: {len(unprocessed)} 件")

    if not unprocessed:
        print("\n新しい下書きはありません。")
        return

    # 投入
    print(f"\n[4/5] Supabase投入中...")
    success = 0
    skipped = 0

    for i, draft in enumerate(unprocessed):
        data = extract_article_from_html(draft['subject'], draft['prefix'], draft['body_html'])

        # slug重複チェック
        if data['slug'] in existing_slugs:
            print(f"  [{i+1}/{len(unprocessed)}] SKIP (重複): {data['slug']}")
            mark_as_processed(service, draft['message_id'], label_id)
            skipped += 1
            continue

        # タグ名リスト取得
        tag_names = detect_tag_names(data['body_text'])

        # ソースURLをJSONB形式に
        source_urls = json.dumps([
            {"url": s['url'], "title": s['title'], "domain": s['domain']}
            for s in data['sources'][:10]
        ], ensure_ascii=False)

        # RPC関数経由で投入（SECURITY DEFINERなのでanon keyでもOK）
        rpc_headers = {
            "apikey": SUPABASE_KEY,
            "Authorization": f"Bearer {SUPABASE_KEY}",
            "Content-Type": "application/json",
        }
        rpc_res = requests.post(f"{SUPABASE_URL}/rest/v1/rpc/insert_research_article",
            headers=rpc_headers,
            json={
                "p_title": data['title'],
                "p_slug": data['slug'],
                "p_category_name": data['category_name'],
                "p_body_html": data['body_html'],
                "p_body_text": data['body_text'],
                "p_summary": data['summary'],
                "p_source_date": data['source_date'],
                "p_css_template_id": css_id,
                "p_tag_names": tag_names,
                "p_source_urls": json.loads(source_urls),
            }
        )

        if rpc_res.status_code >= 400:
            print(f"  [{i+1}/{len(unprocessed)}] ERROR: {rpc_res.text[:200]}")
            continue

        existing_slugs.add(data['slug'])

        # 処理済みマーク
        mark_as_processed(service, draft['message_id'], label_id)

        success += 1
        print(f"  [{i+1}/{len(unprocessed)}] OK ({len(tag_names)} tags): {data['title'][:50]}")
        time.sleep(0.2)

    # 結果
    print(f"\n[5/5] 結果サマリー")
    print("=" * 60)
    print(f"  投入成功: {success} 件")
    print(f"  スキップ: {skipped} 件")
    print("=" * 60)

if __name__ == '__main__':
    main()
