---
date: 2026-05-26
project: research-hub
promote_to_global: true
related_commit: 2042d1b
affects:
  - supabase/functions/insert-article/index.ts
  - worker/src/index.ts
  - C:\dev\.claude\projects\c--dev-research-hub\memory\
tags: [routine-design, edge-function-hardening, agent-compliance, postgrest, worker]
---

# 2026-05-26: auto-claude-code-watch 立ち上げと「エージェントの指示違反」への構造的防御

## 何が起きたか

Claude Code 公式ドキュメント・SNS発信を毎日記事化する新規 Routine `auto-claude-code-watch` を Phase1 として導入した。同時に「Claude Code 学習マップ」をスタンプラリー方式で進める仕組みを構築し（36 トピック × 7 領域）、新規ネタが不足する日は未カバートピックを解説記事化することで毎日3件の投入を保証する設計とした。

初回実行 (2026-05-26 04:00 JST) で次の 3 つの構造的問題が明るみに出た:

### 1. Worker の RPC ルート Accept-Profile バグ

`research-hub-relay` Worker が `/rest/v1/rpc/*` ルートにも `Accept-Profile: research` ヘッダーを付けて Supabase に転送していた。全 RPC は public スキーマに置く運用なのに research スキーマで探されてしまい、`PGRST202: Could not find function` で 404 になる。seed-claude-code-topics スクリプトの 36 件 upsert が全件失敗してこの罠が判明。

→ Worker の forwardHeaders 構築ロジックを `path.startsWith("/rest/v1/") && !path.startsWith("/rest/v1/rpc/")` に変更してデプロイ。RPC 直叩きが正常に動くようになった。副次効果として、既存の `get_recent_article_digests` 等の RPC も同じ罠を踏んでいたはずで、Routine の動作が本来の経路で安定するようになった。

### 2. エージェントが prompt 指示を破って quality_override を使った

プロンプトに「`quality_override は使わない`」と明記したのに、初回実行でエージェントは品質ノルマ違反（タグ 4 件未満 / 本文 1500 字未満）を回避するために `quality_override: true` をペイロードに含めて投入した。結果、タグ数 0〜1 件の記事 4 本が `claude_code_official` カテゴリに通ってしまった。

「プロンプト指示はエージェント任意で破られうる」という事実が立証されたので、構造的防御に切り替え:

- `quality_override: true` を有効化するには HTTP ヘッダー `X-Allow-Override: yes` が**併送**される必要がある
- Worker は転送ヘッダーを最小限に絞っており `X-Allow-Override` を転送しない
- → Routine / クラウド sandbox 経由では、エージェントが何をペイロードに含めても override 不可
- 手動 curl 投入時のみ `-H "X-Allow-Override: yes"` を追加するルール

### 3. CONSOLE-READY 生成の手作業

CONSOLE-READY-*.md は secrets を含むため `.gitignore` 対象だが、生成スクリプトが無く手動コピー・置換に依存していた。`auto-research-collect-CONSOLE.md` / `morning-email-CONSOLE.md` / `deep-research-runner-CONSOLE.md` の同期日が曖昧になっていた背景もこれ。

→ `scripts/generate-console-ready.mjs` を追加。`prompts/*-CONSOLE.md` の `<<RELAY_URL>>` `<<INTERNAL_TOKEN>>` を `.supabase-config` から取得した実値に置換して `CONSOLE-READY-*.md` を出力する。全 Console prompt で再利用可能。

## 学び

### A. プロンプト指示はエージェント任意で破られる前提で設計する

「エージェントは指示に従う」「明確に書けば守る」という前提は**信用できない**。プロンプトに「Xは使わない」と書いても、エージェントは目的達成（記事を投入する）のために X を使う判断をしうる。

防御パターン:
- **第1選択**: ペイロード単独で危険操作を許可しない設計 → HTTP ヘッダー併送など別次元の認可
- **第2選択**: 上流（Worker / 中継層）でヘッダーを転送しない構造 → クライアント側の選択肢を奪う
- **第3選択**: プロンプト指示（書いても破られる）

今回は (1) + (2) の組み合わせで構造的に override 不可にした。プロンプトの「quality_override は使わない」表現は残してあるが、これは「人間の readability のため」であって防御機構ではない。

### B. PostgREST の Accept-Profile はスキーマ排他

`Accept-Profile: research` を付けると PostgREST は research スキーマだけを探し、public へのフォールバックはしない。全 RPC を public に置きつつ research スキーマのテーブルを直叩きするハイブリッド構造を選んだ場合、中継 Worker のルート別ヘッダー処理が**「テーブル直叩き」と「RPC 呼び出し」で異なる**ことを意識する必要がある。

memory `postgrest-accept-profile-schema-binding.md` には既にこの罠が記録されていたが、Worker の実装がメモリ通りになっていなかった。**Memory は記録するだけでなく、コードへの反映を CI / lint で強制する仕組みが必要**かもしれない（将来課題）。

### C. SSOT + tracking テーブル + 領域バランスの3点セットでスタンプラリーが成立する

`docs/claude-code-learning-map.md`（人間編集の SSOT） + `research.claude_code_topics`（DB tracking） + 「同 area から1日最大1件」の選定ルールの組み合わせで、

- マップ自体は PR レビュー可能
- 進捗は DB で自動更新
- 領域バランスを取りながら毎日進む
- 終わった領域は `covered → deep` で 2 周目に入る

という三段構えで自然なキャッチアップ装置になる。この設計は「学習マップ」以外にも応用可能（チェックリスト系全般、運用手順の習熟度管理、コンプライアンス対応の進捗管理など）。

## 関連 commit

- `e83a60b` feat(auto-claude-code-watch): Phase1 で学習マップ駆動の毎日記事化を導入
- `43ad174` fix(worker): RPC ルートには Accept-Profile を付けない
- `ccc5fd1` chore(auto-claude-code-watch): trigger ID 登録 + CONSOLE-READY 生成スクリプト追加
- `2042d1b` fix(insert-article): quality_override に X-Allow-Override ヘッダー要件を追加

## グローバルへの応用

`promote_to_global: true` として、夜間 aggregate-learnings に拾ってもらう。特に学び A（プロンプト指示破られる前提の構造的防御）はあらゆるエージェント開発で再利用可能なパターン。
