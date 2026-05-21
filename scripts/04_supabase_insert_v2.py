#!/usr/bin/env python3
"""
Research Hub - Supabase投入スクリプト v2
階層タグ対応版

新しい記事HTMLをSupabaseに投入する汎用スクリプト。
ダウンロードフォルダの未投入HTML記事を検出して投入。

使い方:
  cd ~/Downloads
  python 04_supabase_insert_v2.py
"""

import os
import sys
import re
import time
import json
from pathlib import Path

from dotenv import load_dotenv
load_dotenv(Path(__file__).parent / ".env")

try:
    import requests
except ImportError:
    print("pip install requests")
    sys.exit(1)

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

# TAG_RULES と同じマッピング（phase2c_retag_articles.pyと共通）
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

def api_get(path, params=None):
    r = requests.get(f"{API}/{path}", headers=HEADERS_READ, params=params or {})
    r.raise_for_status()
    return r.json()

def api_post(path, data):
    r = requests.post(f"{API}/{path}", headers=HEADERS_WRITE, json=data)
    if r.status_code >= 400:
        if 'duplicate' not in r.text.lower():
            print(f"  ERROR {r.status_code}: {r.text[:200]}")
        return None
    return r.json()

def detect_tags(text, tag_map):
    text_lower = text.lower()
    tag_ids = []
    for tag_name, keywords in TAG_RULES.items():
        for kw in keywords:
            if kw.lower() in text_lower:
                if tag_name in tag_map:
                    tag_ids.append(tag_map[tag_name])
                break
    return tag_ids

def extract_article(filepath, filename):
    with open(filepath, 'r', encoding='utf-8') as f:
        html = f.read()

    h1 = re.search(r'<h1>(.*?)</h1>', html, re.DOTALL)
    title_ja = re.sub(r'<[^>]+>', '', h1.group(1).replace('<br>', ' ')).strip() if h1 else filename

    date_match = re.search(r'(\d{4}-\d{2}-\d{2})', filename)
    source_date = date_match.group(1) if date_match else None

    if 'ai-accounting' in filename or 'accounting' in filename.lower():
        category_name = 'ai_accounting'
    elif 'claude-code-tips' in filename:
        category_name = 'claude_code'
    else:
        category_name = 'claude_code_official'

    body_match = re.search(r'<body>(.*?)</body>', html, re.DOTALL)
    body_html = body_match.group(1).strip() if body_match else ''

    text = re.sub(r'<style>.*?</style>', '', html, flags=re.DOTALL)
    text = re.sub(r'<[^>]+>', ' ', text)
    text = re.sub(r'\s+', ' ', text).strip()

    lead = re.search(r'class="lead"[^>]*>(.*?)</div>', html, re.DOTALL)
    summary = re.sub(r'<[^>]+>', '', lead.group(1)).strip()[:200] if lead else ''

    sources = []
    for link in re.finditer(r'<a[^>]+href="([^"]+)"[^>]*target="_blank"[^>]*>(.*?)</a>', html):
        url, title = link.group(1), re.sub(r'<[^>]+>', '', link.group(2)).strip()
        if url not in [s['url'] for s in sources]:
            domain = re.search(r'https?://([^/]+)', url)
            sources.append({'url': url, 'title': title, 'domain': domain.group(1) if domain else ''})

    slug = filename.replace('.html', '')

    return {
        'title_ja': title_ja, 'slug': slug, 'category_name': category_name,
        'source_date': source_date, 'summary': summary,
        'body_html': body_html, 'body_text': text, 'sources': sources,
    }

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    print("=" * 60)
    print("Research Hub - Supabase投入 v2（階層タグ対応）")
    print("=" * 60)

    # マスタ取得
    categories = api_get("categories", {"select": "*"})
    cat_map = {c['name']: c['id'] for c in categories}

    tags = api_get("tags", {"select": "id,name"})
    tag_map = {t['name']: t['id'] for t in tags}

    templates = api_get("css_templates", {"select": "id", "is_default": "eq.true"})
    css_id = templates[0]['id'] if templates else None

    # 既存slug取得
    existing = api_get("articles", {"select": "slug"})
    existing_slugs = set(a['slug'] for a in existing)

    # HTMLファイル検出
    html_files = sorted([
        f for f in os.listdir(script_dir)
        if f.endswith('.html')
        and not f.startswith('architecture')
        and not f.startswith('research-hub')
        and not f.startswith('detailed-plan')
        and (f.startswith('2026-') or f.startswith('ai-accounting') or f.startswith('claude-code-tips'))
    ])

    new_files = [f for f in html_files if f.replace('.html', '') not in existing_slugs]
    print(f"\n全HTML: {len(html_files)} 件 / 未投入: {len(new_files)} 件")

    if not new_files:
        print("新しい記事はありません。")
        return

    success = 0
    for i, filename in enumerate(new_files):
        data = extract_article(os.path.join(script_dir, filename), filename)
        category_id = cat_map.get(data['category_name'])
        if not category_id:
            print(f"  [{i+1}] SKIP: カテゴリ不明 {data['category_name']}")
            continue

        result = api_post("articles", {
            'title': data['title_ja'], 'title_ja': data['title_ja'],
            'slug': data['slug'], 'category_id': category_id,
            'css_template_id': css_id,
            'body_html': data['body_html'], 'body_text': data['body_text'],
            'summary': data['summary'], 'source_date': data['source_date'],
            'source_type': 'auto_research', 'status': 'published',
        })
        if not result:
            continue

        article_id = result[0]['id']

        # 階層タグ付与
        tag_ids = detect_tags(data['body_text'], tag_map)
        for tid in tag_ids:
            api_post("article_tags", {"article_id": article_id, "tag_id": tid})

        # ソースURL
        for src in data['sources']:
            api_post("research_sources", {
                "article_id": article_id, "url": src['url'],
                "title": src['title'], "domain": src['domain']
            })

        success += 1
        print(f"  [{i+1}/{len(new_files)}] OK ({len(tag_ids)} tags): {data['title_ja'][:40]}")
        time.sleep(0.2)

    print(f"\n完了! {success} 件投入")

if __name__ == '__main__':
    main()
