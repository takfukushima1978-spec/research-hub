# auto-basics-fill — 夜間自律「基礎の面埋め」プロンプト（ローカル /loop 用）

このプロンプトは **ローカル Claude Code の `/loop`** で夜間に回す想定。
学習マップ（`research.learning_topics`）の**未カバー基礎トピックを入門記事化**して、7ジャンルの「面」を埋める。
Routine（クラウド・最新ニュース）とは別系統＝**常緑（evergreen）の教科書的記事**を量産する。

## 実行方法

```
/loop auto-basics-fill   ← このファイル内容を渡して自走させる
```

自己ペースの /loop。1 回の起動で最大 3 トピックを処理し、残りは次の iteration へ。未カバーが尽きたら `DRY` を出して終了。

## 🔐 セキュリティ設計（無人運転・bash-advisor 安全）

- **DB I/O は必ず `scripts/learning-cli.mjs` を経由**。生の curl を叩かない
  （CLI 内部で `.supabase-config` からトークンを読む＝コマンド行に秘密が出ない＝bash-advisor を踏まない＝無人でも止まらない）
- settings.local.json に `Bash(node scripts/learning-cli.mjs:*)` が許可されている前提（narrow allow）
- 前提: ① migration `20260610000001_learning_topics.sql` 適用済 ② `node scripts/seed-learning-topics.mjs` 実行済

## 自律運転ガードレール（暴走/ループ防止）

- **1 iteration = 最大3トピック**。それ以上は処理せず終了（/loop が次回再開）
- **再生成は最大2回**: 品質ノルマ400 / 演出の薄さ検証（`prompts/article-style-guide.md` 再生成ゲート）に2回失敗したら **その topic を skip**（mark-covered しない＝次回再挑戦）してログへ
- **1トピックの失敗で止めない**: エラーはログして次トピックへ
- **409重複・レート超過は想定内**: 停止理由にしない
- **未カバーが0件**なら `=== DRY: <genre> 未カバーなし ===` を出して正常終了
- **承認を挟まない**（CLI が許可済みなので無人で完走）

## Step 1. 未カバートピック取得

ジャンルをローテーション（または全体 `all`）して未カバーを取る。
**充実方針**: AI領域・メタスキルを幅広く優先（`thinking_learning` / `ai_tech` / `tools`）。`accounting`（会計）はマップ無し＝対象外（専門領域）。`keiri_dx` は自動化/AI適用に限定。
priority フィールド（5高〜1低）と coverage に従って未カバーを選ぶ。

```bash
node scripts/learning-cli.mjs get-uncovered <genre|all> 3
```

返却 `[{topic_id, genre, area, title, description, doc_url, priority, ...}]` から処理対象を決める。
0 件なら別ジャンルへ。全ジャンル 0 件なら DRY 終了。

## Step 2. 概念リサーチ（一次ソース3本以上）

各トピックについて WebSearch で **一次ソース 3 本以上**（公式ドキュメント・標準・教科書的解説・原典）を集める。
基礎記事でも出典を明記する（品質ノルマ＝source 3 件以上）。`doc_url` があれば WebFetch して起点にする。

## Step 3. 入門記事生成（かみ砕き重視・常緑）

**ニュース型ではなく「教科書/入門」型**。半年後に読んでも価値がある内容にする。
入門記事の価値は **「情報の密度」ではなく「理解の密度」**。用語を並べるな、かみ砕け。

### 🔑 かみ砕き5原則（`article-style-guide.md` 準拠・必達）

1. **幹を1本に絞る**: 「この記事で持ち帰る1つ」を決め、冒頭・要所・締めで反復する
2. **専門語は日常語に翻訳 or 捨てる**: 用語を出したら直後に「＝要するに〜」で言い換える。幹に不要な専門語は**入門では捨てる**（暗記用語集は禁止）
3. **具体例で腑に落とす**: 抽象概念には必ず身近な具体例。できれば**1つの例を記事全体で通す**
4. **詰め込まない**: 新概念を絞る。深く少なく。認知負荷を下げる
5. **途中で「▶要するに」を挟む**: 難しい説明の直後に1行サマリの休符を置く

**トーンは上品（`article-style-guide.md`）**。冒頭フックは「問い or 一場面 1-2文＋具体に裏打ちした断定」。

### 入門の検証ゲート（再生成トリガー・最大2回）

> **読み終えて「結局、何が言いたかった?」に1文で答えられること。**
> 答えられない（幹が立たない／用語の羅列で終わる）なら再生成。news 型の「フック外し検証」と併用。

### セクション構成（かみ砕き版）

```html
<p class="lead">(上品フック: 問い or 一場面 1-2文 + 具体に裏打ちした断定 1文)</p>
<h2>1. ひとことで言うと</h2><p>(幹を平易に1〜3文。専門語は使わず、身近なたとえを1つ)</p>
<h2>2. ○○ と △△ を比べると分かる</h2><p>(対比で理解させる。具体例を必ず添える。末尾に「▶要するに」1行)</p>
<h2>3. どんなときに効くか</h2><p>(Takの文脈=会計/副業/学習の身近な具体例。最低150字。末尾に「▶要するに」)</p>
<h2>4. やり方／仕組み（3ステップ程度）</h2><p>(手順を噛み砕く。1つの例で通す。最低200字)</p>
<h2>5. つまずきやすいポイント</h2><ul><li>(初学者がハマる点を最低3つ、平易に)</li></ul>
<h2>6. 最初の一歩</h2><ul><li>(具体的アクション最低2つ)</li></ul>
<h2>7. もっと知る</h2><ul><li><a href="...">一次ソース</a></li>...（次に読む関連トピックも）</ul>
<div class="highlight">▶ つまり: (幹を1〜2文で再提示＝冒頭と同じ一言に戻る)</div>
```

> セクション名・数は題材に合わせて調整可（「2. 比べると分かる」が効かない題材なら別の切り口でよい）。
> **守るのは構成ではなく5原則**。用語を並べた瞬間に失格＝再生成。

品質ノルマ（insert-article が強制）: **body_text 1500〜2500字 / source 3件以上 / tag 4件以上**。
※ かみ砕いても 1500字は具体例を厚くすれば自然に超える。字数稼ぎの用語羅列はしない。

## Step 4. category / tag の確定（controlled vocab・厳密一致）

- `category_name` = **topic の `genre`**（7ジャンルL1スラッグそのまま）
- `tag_names`（4件以上）= **genre L1スラッグ + 配下L2を2〜3個**（下表の確定スラッグに厳密一致。発明禁止）

| genre | 配下 L2 スラッグ |
|---|---|
| accounting | consolidation / management_accounting / regulation / audit / tax / bookkeeping / ma_valuation |
| keiri_dx | bpr / accounting_automation / dx / ic_automation |
| ai_tech | generative_ai / agents / computer_use / mcp / semiconductor / quantum / robotics / biotech_ai |
| tools | claude_code / codex_chatgpt / gemini / grok / notion / slack / developer_tools / accounting_sw / other_ai_tools |
| business | ai_strategy / industry / ai_policy / ai_criticism / ai_human / talent |
| security_risk | vulnerability / prompt_injection / data_protection / policy |
| thinking_learning | metacognition / learning_science / brain_dopamine / self_management / voice_externalize / knowledge_design / career_sidebiz |

## Step 5. 投入（CLI経由）

記事 JSON を一時ファイル（例 `/tmp/basics.json`）に書き、CLI で投入する:

```bash
node scripts/learning-cli.mjs insert /tmp/basics.json
```

payload 例:
```json
{
  "title": "<入門タイトル>",
  "category_name": "<topic.genre>",
  "body_html": "<入門8セクションHTML>",
  "summary": "<3行サマリー>",
  "source_date": "<TZ=Asia/Tokyo date +%F>",
  "tag_names": ["<genre>", "<L2>", "<L2>", "<L2>"],
  "source_urls": [{"url":"https://...","title":"...","domain":"..."}, ...3件以上]
}
```

レスポンスの `id` を控える。400（ノルマ未達）なら最大2回まで補強再投入、2回失敗で skip しログへ。

### ⚠️ 量産で詰まらないための実装メモ（実運用で判明）

- **body_text は 1500字必達。目安 1700字で書く**: かみ砕くと短くなりがち。**箇条書きは字数が稼げない**ので、地の文（具体例・たとえ）を厚くして1500を確実に超える。1500ギリギリを狙うと EF のカウント差で弾かれる
- **本文中の引用符は「」を使う。ASCII の `"` は禁止**: JSON 文字列を途中で壊し `Invalid JSON` 400 になる。強調は `<strong>` か `「」`
- **URL に日本語を入れない**（source_urls）: 一部で JSON パースが不安定。英数字URLを使う
- **投入前にローカル検証**: JSON妥当性と本文字数を `node -e` 等で確認してから insert すると、無駄な往復が減る

## Step 6. カバレッジ更新（基礎記事のリンク記録）

投入成功したら topic を covered にマークする（`related_article_ids` に article_id が記録され、基礎記事として識別可能になる）:

```bash
node scripts/learning-cli.mjs mark-covered <topic_id> <article_id>
```

## Step 7. ログ（HANDOFF）

1 iteration の末尾に出力:

```
=== auto-basics-fill iteration 完了 ===
処理: N トピック
- [1] topic_id=... genre=... title=... → article_id=... (covered)
skip: K 件
- skip-1: topic_id=... 理由（再生成ゲート2回失敗 / 400 / 409）
残り未カバー（coverage より）: genre別 X 件
次アクション: 継続 / DRY(全ジャンル未カバーなし)
```

カバレッジ確認:
```bash
node scripts/learning-cli.mjs coverage all
```
