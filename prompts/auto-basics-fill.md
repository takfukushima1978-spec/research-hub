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

## Step 3. 入門記事生成（入門8セクション + 演出フック）

**ニュース型ではなく「教科書/入門」型**。常緑で、半年後に読んでも価値がある内容にする。
冒頭フックは `prompts/article-style-guide.md` に従う（**上品トーン基本**・具体に裏打ちした断定・フックを削っても本文で成立）。

```html
<p class="lead">(上品フック: 問い or 一場面 1-2文 + 具体に裏打ちした断定 1文)</p>
<h2>1. ひとことで言うと</h2><p>(定義を1〜2文で端的に)</p>
<h2>2. なぜ重要か / どこで効くか</h2><p>(Takの文脈=会計/副業/学習に結びつける。最低150字)</p>
<h2>3. 全体像・位置づけ</h2><p>(構造・他概念との関係・どこに位置するか。最低200字)</p>
<h2>4. 基本用語</h2><ul><li>用語: 1行説明（5〜8語）</li></ul>
<h2>5. 仕組み・典型フロー</h2><p>(どう動くか / 手順 / 具体例。最低250字)</p>
<h2>6. よくある誤解・つまずき</h2><ul><li>(初学者がハマる点を最低3つ)</li></ul>
<h2>7. 最初の一歩</h2><ul><li>(具体的な学習/実践アクションを最低3つ)</li></ul>
<h2>8. 一次ソース・次に読む</h2><ul><li><a href="...">ソース</a></li>...（関連トピックも示す）</ul>
<div class="highlight">▶ つまり: (本文を1〜2文に圧縮)</div>
```

品質ノルマ（insert-article が強制）: **body_text 1500〜2500字 / source 3件以上 / tag 4件以上**。

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
