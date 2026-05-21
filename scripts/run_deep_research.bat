@echo off
REM Deep Research Executor - ローカル実行版
REM Windowsタスクスケジューラから呼び出される

cd /d "%USERPROFILE%\Downloads"

REM 実行ログを追記
echo. >> deep_research.log
echo [%date% %time%] === Deep Research開始 === >> deep_research.log

REM プロンプトファイルを読み込んでClaude Codeに渡す
type deep_research_prompt.txt | "C:\Users\user\AppData\Roaming\npm\claude.cmd" -p --dangerously-skip-permissions >> deep_research.log 2>&1

echo [%date% %time%] === Deep Research終了 === >> deep_research.log
