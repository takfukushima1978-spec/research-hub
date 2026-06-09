# AI・基盤技術 学習マップ（基礎の面・幅広版）

> genre=`ai_tech`。SSOT。`node scripts/seed-learning-topics.mjs ai_tech` で DB 同期。
> AI領域はTakの重点学習領域＝**基礎を幅広く充実**させる。表スキーマ: `| topic_id | title | doc_url | priority | description |`。

### 🤖 モデルの基礎

| topic_id | title | doc_url | priority | description |
|---|---|---|---|---|
| ai_tech.llm-basics | LLM（大規模言語モデル）の仕組み |  | 5 | トークン・パラメータ・事前学習と微調整、確率的予測としての文章生成 |
| ai_tech.tokenization-embeddings | トークン化と埋め込み（embedding） |  | 4 | サブワード分割、ベクトル表現、意味を数値で扱う仕組み |
| ai_tech.transformer | Transformerとattentionの基礎 |  | 4 | self-attention、なぜ長文脈に強いか、エンコーダ/デコーダ |
| ai_tech.training-pipeline | モデルの作られ方（事前学習・SFT・RLHF） |  | 4 | データ収集→事前学習→微調整→アラインメント、なぜ"賢く"なるか |
| ai_tech.context-window | コンテキストウィンドウとは |  | 4 | 長文脈、KVキャッシュ、限界とコスト、prompt caching |
| ai_tech.inference-params | 推論パラメータ（temperature等） |  | 3 | temperature・top-p・max tokens が出力に与える影響 |

### 🤖 能力と限界

| topic_id | title | doc_url | priority | description |
|---|---|---|---|---|
| ai_tech.hallucination | ハルシネーションの基礎 |  | 5 | なぜ起きるか、検出・低減策、業務で使う際の心構え |
| ai_tech.evaluation | LLM評価・ベンチマークの基礎 |  | 4 | 主要ベンチマーク、evals、評価の落とし穴、リーダーボードの読み方 |
| ai_tech.multimodal | マルチモーダルAIの基礎 |  | 3 | 画像・音声・動画、VLM、テキスト以外の入出力 |
| ai_tech.reasoning-models | 推論モデル（thinking）の基礎 |  | 4 | 思考の連鎖、test-time compute、いつ効くか |

### 🤖 エージェントと拡張

| topic_id | title | doc_url | priority | description |
|---|---|---|---|---|
| ai_tech.agents-basics | AIエージェントとは |  | 5 | ツール使用・計画・ループ・自律性、ワークフローとの違い |
| ai_tech.agent-patterns | エージェント設計パターン |  | 4 | ReAct・plan-execute・reflection・マルチエージェント |
| ai_tech.mcp-basics | MCP（Model Context Protocol）の基礎 |  | 4 | ツール接続の標準、クライアント/サーバー、なぜ標準化が重要か |
| ai_tech.rag-basics | RAG（検索拡張生成）の基礎 |  | 5 | 埋め込み・ベクトル検索、ハルシネーション低減、知識の外部化 |
| ai_tech.fine-tuning-vs-rag | 微調整 vs RAG vs プロンプトの使い分け |  | 4 | いつどれを選ぶか、コストと精度のトレードオフ |

### 🤖 周辺・ハードウェア

| topic_id | title | doc_url | priority | description |
|---|---|---|---|---|
| ai_tech.semiconductor-basics | AI半導体の基礎 |  | 3 | GPU/TPU、HBM、学習と推論の違い、地政学リスクの概観 |
| ai_tech.quantum-basics | 量子コンピューティングの基礎 |  | 2 | 量子ビット、重ね合わせ、AIとの接点 |
| ai_tech.physical-ai | フィジカルAI・ロボティクスの基礎 |  | 2 | 身体性、VLA（Vision-Language-Action）、世界モデル |
