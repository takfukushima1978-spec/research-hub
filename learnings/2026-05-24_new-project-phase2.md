---
date: 2026-05-24
project: research-hub
promote_to_global: true
related_commit: 3f2d78b
affects:
  - ~/.claude/skills/new-project/SKILL.md
tags: [meta, harness-design, skill-update]
---

# 2026-05-24: navigator.md と文書役割分担は「初期設定」に組み込む

## 何が起きたか

research-hub の大規模復旧セッション (2026-05-23) で、文書体系の役割分担が
曖昧になっていることが発覚した。具体的には:

- session-log の単体ファイルが無く、学びや残タスクの蓄積場所が曖昧
- decisions/ ディレクトリも未整備
- navigator.md も無かったため、プロジェクト現状を一目で把握する手段が無い
- CLAUDE.md には仕様も現状も運用ルールも混ざっており、肥大化していた

復旧の流れで navigator.md を新設し (commit 3f2d78b)、役割分担を以下に整理した:

| ファイル | 役割 |
|---|---|
| グローバル memory | 横断的な学び・気づき（再利用可能な技術知見） |
| navigator.md | プロジェクト現状ダッシュボード（残タスク・主要リソース・統計）|
| CLAUDE.md | プロジェクト仕様（アーキテクチャ・Edge Functions・RPC・設定）|
| scheduled-tasks.md | Routine 詳細（trigger ID・cron・プロンプト同期日）|

## 学び（自分の言葉）

**後付けで文書を整備するのは、ほぼ動機が消える。**
復旧セッションのような「現状把握が困難」と痛みを感じた瞬間にしか、
役割分担を整理するエネルギーは出ない。

逆に言えば、**プロジェクト立ち上げ時に強制的に navigator.md を作らせる仕組み**
さえあれば、この痛みは回避できる。

## グローバルへの反映

new-project スキル (~/.claude/skills/new-project/SKILL.md) に
**Phase 2「文書体系の整備」**を追加。新規プロジェクトで必ず
CLAUDE.md と navigator.md を初期作成するチェックリストとした。

## 関連
- 起点 commit: research-hub `3f2d78b`
- グローバル集約先: `My-Profile-and-Memory/learnings/2026-05-24_new-project-phase2.md`
