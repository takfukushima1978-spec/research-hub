# auto-research-collect スケジュールタスク用プロンプト (v2 / ローカル手動予備版)

このファイルは `auto-research-collect` の **ローカル手動予備版**。
**本番（毎晩 3:03 JST）はクラウド Routines（CONSOLE-READY 版）が動く**。本ファイルはクラウドが障害時に
**ローカル Claude Code で手動実行**するための版。

> **🔐 セキュリティ設計**: Step 0 で `.supabase-config` からトークンを**シェル変数に読み込む**ため、
> `INTERNAL_TOKEN` の実値は**コマンド行に出ない**（bash-advisor フックの「機密参照＋外部送信」を踏まない／
> settings.json に平文保存しない）。クラウド版はトークン埋込なのでローカルでは使わないこと。
> ローカル手動実行は **attended（人が見ている）** なので、curl 等の権限は **Allow Once** で都度承認する
> （`Bash(curl:*)` 等の広い Always-Allow は登録しない＝グローバル dont-do 準拠）。

> **⚠️ 本番仕様との同一性**: タグ語彙（controlled vocabulary）・曜日軸・演出レイヤー・自律運転ガードレールは
> **canonical 版 `prompts/auto-research-collect-CONSOLE.md` と `prompts/article-style-guide.md` に従う**こと。
> 本ファイルは骨子のみ記載。差異が出たら CONSOLE 版を正とする。

目的:
1. 同一テーマ/同一固有名詞の連日重複を排除する
2. 1記事あたりの情報量を品質ノルマ水準まで拡張する (body_text 1500〜2500字 / source 3 / tag 4)
3. 視点の偏りを抑える (新7ジャンルの曜日軸ローテーション・Claude Code偏重是正)
4. 新タクソノミーの確定スラッグで category/tag を自動分類する
5. 自律運転ガードレール（再生成最大2回でskip / 1記事失敗で止めない / 409・レートは想定内 / 1晩最大5件でクリーン停止）に従う

---

## Step 0. 設定読み込み

`.supabase-config` から `SUPABASE_URL` と `INTERNAL_TOKEN` を読み込む。

---

## Step 1. 既存記事ダイジェストの取得 (重複回避)

Supabase REST 経由で `get_recent_article_digests` RPC を呼び、直近 14 日分の記事ダイジェストを取得する。

```bash
curl -X POST "$SUPABASE_URL/rest/v1/rpc/get_recent_article_digests" \
  -H "apikey: $SUPABASE_ANON_KEY" \
  -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{"p_days": 14}'
```

返却は `[{id, title, summary, source_date, category_name, category_label, tags[]}]`。

このリストを **重複回避ブラックリスト** として保持し、以降のテーマ選定で:
- タイトルに含まれる固有名詞 (モデル名/企業名/論文名) が一致 → 除外
- summary の主題が酷似 (体感 Jaccard > 0.6) → 除外
- tags が 3 件以上一致 → 除外

のいずれかを満たす候補は採用しない。
ただし下記 Step 1.5 の「公式ニュース最優先」に該当する場合は、別アングルで必ず記事化する (重複回避より優先)。

---

## Step 1.5. 公式ニュース最優先ルール (絶対遵守)

過去 24〜48 時間以内に **以下の公式ソース** から新規リリース・発表があった場合は、
当日の軸 (Step 2) とは **別枠で必ず 1 記事** 作成する。
当日の軸記事と公式ニュース記事の **両方** を投入すること。

### 監視対象の公式ソース

| カテゴリ | ソース |
| --- | --- |
| AI ラボ公式ブログ | Anthropic news, OpenAI blog/news, Google DeepMind blog, Meta AI blog, xAI announcements, Mistral AI news, Cohere blog |
| プラットフォーマー公式 | Microsoft AI blog, Apple Newsroom (AI関連), AWS AI/ML blog, Google Cloud AI blog |
| ハードウェア公式 | NVIDIA blog/newsroom, AMD AI press, Intel AI press |
| 規制・公的機関 | EU AI Act 公式更新, US AI Safety Institute (AISI), NIST AI RMF, 英国 AISI, 日本AI制度研究会等 |
| 学術プレプリント | arXiv cs.AI / cs.CL / cs.LG の Trending、主要会議 (NeurIPS/ICML/ICLR/ACL) のアクセプト発表 |
| 主要 OSS リリース | LangChain, LlamaIndex, vLLM, Ollama, Hugging Face Transformers のメジャーバージョンリリース |

### 該当判定

- **新モデル発表** / **新API・新機能リリース** / **価格改定** / **重大な政策発表** / **規制発効** のいずれか
- 公式アナウンスが一次ソースとして存在すること (リーク・噂は除外)

### 既存記事と重複する場合

公式ニュース対象テーマが既に直近で記事化済みの場合でも、**別アングル** で再記事化する:
- 技術詳細の深掘り (アーキテクチャ / ベンチマーク数値)
- 競合比較 (他社同等プロダクトとの並列分析)
- 業界インパクト分析 (誰が得をして誰が損をするか)
- 反対意見 / 批判的論考 / リスク評価

---

## Step 2. 当日の「軸」を決定 (曜日別ローテーション)

JST 曜日に基づき、**当日のメイン軸を 1 つ**選ぶ。サブとして異なる軸の記事を 1 本混ぜてもよいが、メインは厳守。

> **2026-06-10 タクソノミー再編**: 軸を新7ジャンルに刷新。category/tag は確定スラッグで分類する。
> canonical な運用版は `prompts/auto-research-collect-CONSOLE.md`（Step 2.5 にタグ語彙表あり）。本ファイルはリポジトリ参照用。

| JST 曜日 | メイン軸（ジャンル）        | category            | 重点トピック                                          |
| -------- | -------------------------- | ------------------- | ----------------------------------------------------- |
| 月       | AI・基盤技術               | `ai_tech`           | フロンティアモデル, 論文, 新モデル発表, ベンチマーク  |
| 火       | AIツール・開発（CC以外）   | `tools`             | Codex, Gemini, Grok, Notion, Slack, 開発者ツール      |
| 水       | 会計・財務・税務 ★重点     | `accounting`        | 連結, 管理会計FP&A, IFRS開示, 監査内統, 税務, M&A     |
| 木       | 経理DX・業務改善 ★重点     | `keiri_dx`          | 業務設計BPR, 経理自動化, 内統×自動化                  |
| 金       | AI戦略・社会・倫理         | `business`          | 政策, 規制, 業界動向, 批評, AIと人間                  |
| 土       | 周辺技術＆セキュリティ     | `ai_tech`/`security_risk` | 半導体, 量子, ロボ, バイオ, 脆弱性, インジェクション |
| 日       | 思考・学習・メタスキル ★重点 | `thinking_learning` | 思考法, 学習科学, 脳科学, 時間管理, ナレッジ設計＋週次振り返り |

> ※ 姉妹タスク `auto-claude-code-watch`（4:00）が Claude Code を毎日カバーするため、本タスクは CC を外しコア関心を強化する。

---

## Step 3. ソース収集

各記事につき **一次ソース 3 本以上**、かつ **異なる立場のソースを 1 本以上** 含める。

- 一次ソース = 公式リリース / 論文 / 規制機関 / 原データ / 開発元ブログ
- ブログのまとめ記事や他社による解説のみで完結させない
- 同テーマで 3〜5 本のソースをクロスリファレンスして 1 記事に統合する (同一トピック単発要約は禁止)

---

## Step 4. 記事生成 (演出フック層 + 構成テンプレート厳守)

> **2026-06-10 演出レイヤー追加**: 本文の前に `<p class="lead">` で「冒頭フック」を置く。背骨は B（結論ファースト＋専門家視点＋「つまり」）に A（情景）/ C（引き）を少量ブレンド。**デフォルト上品**・フックは「具体に裏打ちされた断定」（抽象的煽り禁止）・**演出予算は冒頭のみで本文は具体性UP**・**フックを削っても本文だけで成立**（検証ルール）。詳細仕様は canonical 版 `prompts/auto-research-collect-CONSOLE.md` Step 4-0 を参照。

以下のセクション構成を **必ず全て** 含めて HTML を生成する（先頭に演出フックの `<p class="lead">` を付す）:

```html
<p class="lead">(演出フック: 情景/問い 1〜2文 + 具体に裏打ちされた断定 1文)</p>
<h2>1. TL;DR</h2>
<p>(3 行で核心を要約)</p>

<h2>2. 背景・文脈</h2>
<p>(なぜ今か / これまでの経緯 / 関連する過去事象。最低 200 字)</p>

<h2>3. 事実・データ</h2>
<ul>
  <li>(数値・引用は最低 3 点。出典を明記)</li>
</ul>

<h2>4. 仕組み・技術解説 / ビジネスモデル</h2>
<p>(アーキテクチャ説明、価格、契約形態、技術スタック等。最低 300 字)</p>

<h2>5. 比較・対立軸</h2>
<p>(類似サービス、反対意見、批判的論考。最低 1 つの反対視点を含める)</p>

<h2>6. インパクト分析</h2>
<p>(誰に / 何が / いつ効くか。短期・中期で分けて記述)</p>

<h2>7. 自分の業務への示唆</h2>
<ul>
  <li>(具体的アクションアイテムを最低 3 つ)</li>
</ul>

<h2>8. 一次ソース・関連リンク</h2>
<ul>
  <li><a href="...">ソース1</a></li>
  <li><a href="...">ソース2</a></li>
  <li><a href="...">ソース3</a></li>
</ul>
```

---

## Step 5. 量的ノルマ (Edge Function 側で強制)

- `body_text`: **1500〜2500 字**
- `source_urls`: **3 件以上** (一次ソース)
- `tag_names`: **4 件以上**

これらを満たさない投入は `insert-article` Edge Function が 400 で弾く
(`MIN_BODY_TEXT_LENGTH` / `MIN_SOURCE_URLS` / `MIN_TAG_NAMES` で運用調整可能)。

---

## Step 6. 投入

```bash
curl -X POST "$SUPABASE_URL/functions/v1/insert-article" \
  -H "X-Internal-Token: $INTERNAL_TOKEN" \
  -H "Content-Type: application/json" \
  -d @article.json
```

- 400 が返り `details` に「本文が短すぎます」「source_urls が不足」等が含まれる場合、
  該当セクションを補強して再投入する (3 リトライまで)
- 連日重複と判定されたテーマは別軸 (Step 2 の表) から再選定

---

## Step 7. 重要記事の自動 Deep Research 起動

投入直後に重要度を自己評価し、以下のいずれかを満たす場合は **Deep Research を自動起動** する。

### 自動 Deep Research の発火条件 (いずれか)

- Step 1.5 の **公式ニュース最優先** で記事化したもの (=ほぼ全件)
- 新モデル / 新製品 / 新規制発表で業界インパクトが大きいと判断したもの
- 自分の業務 (Claude Code / AI会計 / プロダクト開発) に直接影響しうるもの

### 起動方法

`deep-research` Edge Function に `action: "request"` で POST する:

```bash
curl -X POST "$SUPABASE_URL/functions/v1/deep-research" \
  -H "X-Internal-Token: $INTERNAL_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "action": "request",
    "article_id": "<insert-article のレスポンスID>",
    "focus_point": "技術詳細とベンチマーク、競合比較",
    "additional_context": "公式リリースの一次ソースを優先、業務影響を分析",
    "priority": 2
  }'
```

`priority`: 1=低 / 2=通常 / 3=高。公式メジャーリリースは 3。

---

## 補足: 緊急回避

手動投入で品質ノルマを一時的に外したい場合のみ、ペイロードに `"quality_override": true` を付けて投入する。
auto-research-collect の通常運用では使用しない。
