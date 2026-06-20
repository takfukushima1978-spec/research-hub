# glossary 学習マップ — 基礎用語・コマンド解説

> 非エンジニア（Tak）が Claude Code / research-hub を扱う中で出会う **基礎用語** と、
> Claude Code が承認を求める **頻出コマンド** を、意味と「承認時の注意点」で解説する常緑記事のマップ。
> seed: `node scripts/seed-learning-topics.mjs glossary` / 記事化: headless auto-basics-fill。
> コマンド系の「承認時の注意点」は Tak の **R77 4層設計**（公開できない/読めない/送れない/入れない）に紐づけて書く。
>
> スキーマ（固定）: `| topic_id | title | doc_url | priority | description |`（area は `### 見出し`）

### 言語・データ記法

| topic_id | title | doc_url | priority | description |
|---|---|---|---|---|
| glossary.python | Python の特徴 ― なぜAI・データ処理の定番言語なのか | https://www.python.org/ | 5 | 読みやすさと豊富なライブラリ。research-hub のスクリプトでも使う |
| glossary.json | JSON とは ― データを運ぶ標準フォーマット | https://www.json.org/json-ja.html | 5 | APIの入出力・設定で頻出。波括弧と角括弧の意味 |
| glossary.markdown | Markdown 記法 ― 軽い記号で文書を構造化する | https://www.markdownguide.org/ | 4 | Claudeの出力やメモの標準。見出し・箇条書き・リンク |
| glossary.yaml-toml | YAML / TOML ― 設定ファイルの書式 | | 3 | インデントで階層を表すYAML、wrangler.toml等のTOML |
| glossary.html-css | HTML / CSS ― Webページの骨と化粧 | | 3 | index.html や thinking-map.html の中身。タグとスタイル |

### 開発の基礎概念

| topic_id | title | doc_url | priority | description |
|---|---|---|---|---|
| glossary.git | Git・リポジトリ・コミット ― 変更履歴のセーブポイント | https://git-scm.com/book/ja/v2 | 5 | commit/push/pull の意味。なぜ origin/main が正本か |
| glossary.cli-terminal | ターミナル・CLI・シェル ― 黒い画面の正体 | | 5 | コマンドを打つ場所。GUIとの違い。PowerShellとBashの違い |
| glossary.api | API とは ― システム同士をつなぐ窓口 | | 4 | リクエストとレスポンス。Edge Function や Worker も API |
| glossary.env-vars | 環境変数・.env ― 設定と秘密の入れ物 | | 4 | なぜAPIキーを .env に置きコミットしないか（秘密の分離） |
| glossary.database-sql | データベース・SQL ― データの保管と問い合わせ | | 3 | Supabase(PostgreSQL)・テーブル・行/列・SELECTの考え方 |
| glossary.node-npm | Node.js・npm ― JavaScriptの実行環境とパッケージ | | 3 | ブラウザ外でJSを動かす。npm install が何をするか |

### Claude Code コマンド（承認の判断）

| topic_id | title | doc_url | priority | description |
|---|---|---|---|---|
| glossary.cmd-permission-basics | 「Allow Bash(...)?」の読み方 ― 権限プロンプトとR77 4層 | | 5 | Bashは入れ物、中身が実コマンド。allow/deny/ask とTakの4層設計 |
| glossary.cmd-readonly | 読み取り・移動系コマンド（cd / ls / cat / grep / pwd） | | 4 | 基本は低危険。ただし cat は .env 読みの裏口になりうる（R77第②層） |
| glossary.cmd-destructive | 書き込み・破壊系コマンド（rm / mv / cp / printf > / mkdir） | | 5 | rm -rf と上書きリダイレクトの怖さ。承認前に必ずパスを見る |
| glossary.cmd-git | Git操作コマンド（add / commit / push / reset / switch） | | 4 | push=本番(origin/main)への反映は不可逆。reset --hard / force push の注意 |
| glossary.cmd-network-install | ネットワーク・導入系（curl / wget / npm install / npx） | | 5 | R77第③層(送れない)・第④層(入れない)。外部送信と未審査コード実行はAllow Once |
| glossary.cmd-exec | 実行系コマンド（node / python / bash -c / 複合コマンド） | | 4 | 任意コード実行の入口。allowlistとbash-advisorで守る考え方 |
