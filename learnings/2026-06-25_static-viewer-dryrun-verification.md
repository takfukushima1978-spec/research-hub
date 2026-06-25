---
date: 2026-06-25
project: research-hub
promote_to_global: true
affects:
  - index.html
  - thinking-map.html
tags: [static-html, verification, anon-rest, dry-run, viewer]
---

# 静的HTMLビューワーのUI追加は「実データ node dry-run」でロジック先行検証する

## 学び（確証度: 確認済み）

静的HTML（ビルド無し・ブラウザでしか動かない）に新ビューを足すとき、CSS を書く前に
**ブラウザの取得ロジックと同じ経路（anon REST 直叩き）で実データを取り、集計ロジックだけ node で再現して dry-run** すると、
ブラウザを一度も開かずに論理バグ（並び順・件数集計・リンク解決の取りこぼし）を潰せる。

今回（学習マップ スタンプラリーUI）の実例:
1. `node --check` で埋め込みJSの構文を検証（HTML から `<script>` 最大ブロックを抽出して通す）
2. `learning_topics` / `tags` / `articles` を anon key + `Accept-Profile: research` で取得し、
   ジャンル並び（L1タグ sort_order）・done/total・%・`related_article_ids[0]`→記事slug 解決を node で再現
3. 結果「7ジャンルが sort_order 順／記事リンク **127/127 解決**／全体100%」を確認してから commit

→ 残る未検証は CSS の見た目だけに絞れる（実機確認のスコープが小さくなる）。

## 根拠

- ブラウザ実行前提のコードは tsc/vitest のような自動検証が無く、目視デプロイ確認に頼りがち（app-dev-lessons「worktree≠本番」「実機確認は環境明示」）。
- 取得経路が anon REST 直叩きなので、同じ HTTP を curl で叩けば**ブラウザと同一データ**が node で再現できる。
- 集計はクライアント側の純粋関数（fetch 結果 → 集計）なので、ロジックだけ切り出して検証可能。

## 再検討トリガー

- ビューワーがサーバサイドレンダリング/ビルド工程を持つようになったら、本手法より通常のテスト/型検査を優先する。
- 取得が anon で再現できない（認証必須・RLS でユーザー文脈依存）場合は dry-run の前提が崩れる。

## 関連
- design-patterns「調査は3段（DB→ロジック→UI派生）」の UI 実装前検証版
- memory [[postgrest-accept-profile-schema-binding]]（research スキーマ取得時のヘッダ規律）
- 同セッションの別学び: クリーンアップは navigator 記載件数を信じずシグネチャで全件洗い出す（DIAGNOSTIC_* が記載1件→実3件。design-patterns「構造問題は全部grep」のデータ版）
