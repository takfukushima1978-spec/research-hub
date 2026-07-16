# Deep Research Executor - Local run
# Executed by Windows Task Scheduler on weekdays at 3 AM

# Task Scheduler は -NoProfile で起動するため、対話シェル（$PROFILE）で設定している
# CLAUDE_CONFIG_DIR を継承しない。未設定のまま `claude -p` を呼ぶと既定の ~/.claude
# （C:\Users\user\.claude・rules/CLAUDE.md が陳腐化スナップショット）にフォールバックする
# （night-ops.ps1 と同一の問題・2026-07-16 R120グループ3で横展開確認）。
$env:CLAUDE_CONFIG_DIR = "C:\dev\.claude"

$ErrorActionPreference = "Continue"
$LogPath = Join-Path $PSScriptRoot "deep_research.log"
$PromptPath = Join-Path $PSScriptRoot "deep_research_prompt.txt"
$ClaudePath = "C:\Users\user\AppData\Roaming\npm\claude.cmd"

Set-Location $PSScriptRoot

# Log start
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
"" | Out-File -FilePath $LogPath -Append -Encoding UTF8
"[$timestamp] === Deep Research Start ===" | Out-File -FilePath $LogPath -Append -Encoding UTF8

# Read prompt and pipe to claude
try {
    $prompt = Get-Content -Path $PromptPath -Raw -Encoding UTF8
    $output = $prompt | & $ClaudePath -p --dangerously-skip-permissions 2>&1
    $output | Out-File -FilePath $LogPath -Append -Encoding UTF8
} catch {
    "ERROR: $($_.Exception.Message)" | Out-File -FilePath $LogPath -Append -Encoding UTF8
}

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
"[$timestamp] === Deep Research End ===" | Out-File -FilePath $LogPath -Append -Encoding UTF8
