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
| glossary.cmd-search-inspect | 検索・調査系コマンド（find / head / tail / wc / sort / uniq） | | 3 | 中身を見るだけの低危険系。ただし出力が外部送信に繋がらないか注意 |
| glossary.cmd-process | プロセス・実行管理（ps / kill / sleep / timeout / バックグラウンド &） | | 3 | 実行中の処理を見る・止める。kill の対象を間違えない |
| glossary.cmd-env-path | 環境・PATH系コマンド（export / env / which / source / $VAR） | | 4 | source は .env 読みの裏口になりうる（R77第②層）。env で秘密が出ないか |

<!-- ===== 2026-06-20 一括増補（+23）ここから ===== -->

### 言語・データ記法（増補）

| topic_id | title | doc_url | priority | description |
|---|---|---|---|---|
| glossary.regex | 正規表現 ― 文字のパターンで検索・抽出する | | 4 | grep / 検索で頻出。`.*` や `\d` の意味。research-hub の調査でも使う |
| glossary.csv-encoding | CSV と文字コード ― Excel文字化けの正体（UTF-8 / cp932） | | 3 | カンマ区切りデータ。なぜ UTF-8 BOM付きで出すか（会計データの文字化け防止） |
| glossary.diff | 差分（diff）の読み方 ― 何が変わったかを見る | | 3 | `+`追加 / `-`削除。git のコミット確認・コードレビューの基礎 |

### 開発の基礎概念（増補）

| topic_id | title | doc_url | priority | description |
|---|---|---|---|---|
| glossary.http-status | HTTPステータスコード ― 200/400/403/500 の意味 | | 5 | research-hub頻出（403=bot検知、400=品質ノルマ、200=OK）。成功か失敗かを表す番号 |
| glossary.webhook | Webhook ― 出来事を相手に押し通知する仕組み | | 4 | Discord通知の正体。ポーリングとの違い。URLを秘密にする理由 |
| glossary.oauth-token | OAuth・トークン・APIキー ― 「鍵」で本人確認する仕組み | | 5 | INTERNAL_TOKEN / anon key。なぜ秘密にしリポにコミットしないか（R77第②層） |
| glossary.localhost-port | localhost・ポート・開発サーバー ― 自分のPCの中のWeb | | 3 | `localhost:3000` の意味。手元で動かして確認する仕組み |
| glossary.dns-domain | ドメイン・DNS・allowed domains ― 名前を住所に変換する | | 3 | Routine の許可ドメイン設定の前提。なぜ allowlist が要るか |
| glossary.stdin-pipe | 標準入出力・パイプ ― コマンドを繋いでデータを流す | | 4 | パイプ（縦棒）とリダイレクト（大なり記号）。承認時に出力先パスを見る理由 |
| glossary.exit-code | 終了コード ― 成功は0、失敗は0以外 | | 3 | スクリプトが成功したか機械が判断する印。`&&` の前提 |
| glossary.serverless-edge | サーバーレス・Edge Function ― サーバーを持たずにコードを動かす | | 4 | insert-article / deep-research の正体。常駐サーバーとの違い |
| glossary.cdn-proxy | CDN・プロキシ・Cloudflare ― 間に立って中継・防御する層 | | 4 | research-hub-relay Worker の役割。bot検知回避の中継の意味 |
| glossary.migration | マイグレーション ― DBの構造を安全に変更する手順 | | 4 | テーブル/列/制約の変更を記録して再現可能にする。冪等の考え方 |
| glossary.embedding-vector | ベクトル・embedding・類似検索 ― 意味を数字にして近さを測る | | 3 | 重複記事検知の仕組み。なぜキーワード一致でなく「意味の近さ」か |

### ツール・実行環境

| topic_id | title | doc_url | priority | description |
|---|---|---|---|---|
| glossary.docker | Docker・コンテナ ― 環境ごと持ち運ぶ箱 | | 3 | 「自分のPCでは動く」問題を防ぐ。仮想環境との違いをかみ砕く |
| glossary.powershell-bash | PowerShell と Bash の違い ― 2つのシェルを使い分ける | | 4 | Windows環境で両方出てくる理由。同じことをする別の書き方 |
| glossary.supabase-stack | Supabase ― DB＋Edge Function＋認証の土台 | | 4 | research-hub の心臓。PostgreSQL・RPC・RLS をまとめて理解 |
| glossary.cloudflare-worker | Cloudflare Workers ― 世界中の端で動く小さなプログラム | | 3 | research-hub-relay の正体。Edge で動く中継・防御 |
| glossary.vscode | VS Code・エディタ・拡張 ― コードを書く道具 | | 3 | Claude Code拡張が動く場所。フォルダを開く＝作業対象を決める |
| glossary.github-repo-pages | GitHub・リポジトリ・GitHub Pages ― 保管庫と無料の公開場所 | | 3 | origin/main が正本の理由。ビューワーが公開される仕組み |

<!-- ===== 2026-06-20 仕上げ増補（+20・網羅~100%）ここから ===== -->

### 言語・データ記法（増補）

| topic_id | title | doc_url | priority | description |
|---|---|---|---|---|
| glossary.xml | XML ― タグで囲ってデータを表す古参フォーマット | | 2 | HTMLに似た角括弧の記法。JSONとの違いと、設定・データ交換で残る理由 |
| glossary.base64 | Base64 ― バイナリを文字に変換するエンコード | | 2 | 画像や鍵を文字列で運ぶ仕組み。暗号化ではない（誰でも戻せる）点に注意 |

### 開発の基礎概念（増補）

| topic_id | title | doc_url | priority | description |
|---|---|---|---|---|
| glossary.ssh | SSH ― 暗号化された安全なリモート接続 | | 3 | 遠くのサーバーに鍵で安全に入る仕組み。鍵ペアの考え方 |
| glossary.ip-network | IPアドレス・ネットワークの基礎 ― 機器の住所 | | 3 | データセンターIP（403の原因）と家庭IPの違い。住所で通信先を特定する |
| glossary.https-tls | HTTPS・TLS・SSL ― 通信を暗号化する鍵マーク | | 4 | なぜ https と鍵マークが安全の印か。盗み見・改ざんを防ぐ仕組み |
| glossary.cache | キャッシュ ― 一度使ったものを手元に置いて速くする | | 3 | プロンプトキャッシュ（コスト削減）やCDNの前提。古い表示が残る副作用 |
| glossary.rate-limit-idempotency | レート制限・冪等性 ― 出しすぎ防止と「何度やっても同じ」 | | 4 | API制限の意味と、seed/upsertが安全に再実行できる理由（冪等） |
| glossary.cors | CORS ― ブラウザの別サイトアクセス制限 | | 2 | フロントから別ドメインAPIを叩くと弾かれる理由。Worker中継の動機の一つ |
| glossary.dev-prod-env | 開発環境と本番環境 ― 試す場と本番の分離 | | 4 | dev/staging/prod の違い。本番への不可逆反映が承認ゲートの核な理由 |
| glossary.ci-cd | CI・CD ― 自動テストと自動デプロイの流れ | | 3 | push後にGitHub Actionsが走る仕組み。gh run watch で見届ける理由 |

### ツール・実行環境

| topic_id | title | doc_url | priority | description |
|---|---|---|---|---|
| glossary.claude-api-models | Claude API・モデル ― Opus / Sonnet / Haiku の使い分け | | 4 | 能力とコストの段階。重い設計はOpus、量産はSonnet/Haikuという考え方 |
| glossary.openai-chatgpt | OpenAI・ChatGPT・Codex ― もう一つの主要AI系統 | | 3 | クロスレビューで使う別系統。GPTsからresearch-hubへ投入する経路 |
| glossary.python-venv-pip | Python venv・pip ― 仮想環境とパッケージ管理 | | 3 | プロジェクトごとに環境を分ける理由。日本語パスでvenvを作らない教訓 |
| glossary.task-scheduler-cron | Task Scheduler・cron ― 決まった時刻に自動実行 | | 4 | night-opsや夜間バッチの土台。cron表記とウェイクタイマーの前提 |
| glossary.obsidian-notion | Obsidian・Notion ― ノート・第二の脳ツール | | 3 | ナレッジ設計の実装先。MCPでAIから繋ぐ「第二の脳」の入り口 |
| glossary.terminal-app | ターミナルアプリ ― Windows Terminal / iTerm など | | 2 | シェルを動かす「窓」。シェル（Bash/PowerShell）との違いをかみ砕く |
| glossary.build-make | Make・ビルドツール ― 手順をまとめて自動化する | | 2 | tsc -b などビルドの正体。「ソース→成果物」の片方向変換の考え方 |

### Claude Code コマンド（承認の判断）

| topic_id | title | doc_url | priority | description |
|---|---|---|---|---|
| glossary.cmd-archive | アーカイブ系コマンド（tar / zip / unzip / gzip） | | 2 | まとめる・圧縮する・展開する。展開先パスと上書きに注意 |
| glossary.cmd-git-advanced | git応用コマンド（rebase / stash / worktree / cherry-pick） | | 3 | 履歴を編集する強力系。worktree内でstashしない等の落とし穴 |
| glossary.cmd-permission-patterns | 権限パターン（settings.json の allow / deny / ask の書き方） | | 4 | Always AllowとAllow Onceの差。広いパターン（Bash全許可等）を入れない理由・R77 4層 |
