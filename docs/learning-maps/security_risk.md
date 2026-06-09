# セキュリティ・ガバナンス 学習マップ（基礎の面）

> genre=`security_risk`。SSOT。`node scripts/seed-learning-topics.mjs security_risk` で DB 同期。
> 表スキーマ: `| topic_id | title | doc_url | priority | description |`。priority 1〜5。

### 🔒 基礎・概念

| topic_id | title | doc_url | priority | description |
|---|---|---|---|---|
| security_risk.prompt-injection-basics | プロンプトインジェクションの基礎 |  | 5 | 直接/間接インジェクション、攻撃の仕組み、構造的防御の考え方 |
| security_risk.llm-owasp | LLM特有の脆弱性（OWASP LLM Top10） |  | 4 | 主要な攻撃カテゴリの概観、開発者が押さえる勘所 |
| security_risk.data-protection-basics | データ保護の基礎 |  | 4 | PII、最小権限、暗号化、AIにデータを渡す際の注意 |
| security_risk.ai-governance | AIガバナンスの基礎 |  | 4 | ポリシー・監査ログ・リスク管理、人間の最終承認 |
| security_risk.secret-management | シークレット管理の基礎 |  | 3 | APIキー・トークンの扱い、環境変数、コミット事故の防止 |
