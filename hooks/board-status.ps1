# board-status - SessionStart hook: show the project board when the repo has one.
# Prints plain text that Claude Code adds to the session's context. Never fails a session.
#
# This script deliberately does NOT read stdin. Under "powershell.exe -File" a read of
# $input blocks until the pipe closes, which hangs the whole session start when the host
# keeps stdin open. It takes the directory from -Path or CLAUDE_PROJECT_DIR instead.
# Where Git Bash exists, prefer the board-status.sh twin: it reads the hook payload.
#
# Keep this file ASCII-only: Windows PowerShell reads .ps1 as ANSI unless it has a BOM,
# so non-ASCII literals here would reach the session as mojibake.
# Test directly with:  ./board-status.ps1 -Path C:\some\repo
param([string]$Path)

try {
    [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding $false
} catch {}

try {
    $cwd = $Path
    if (-not $cwd) { $cwd = $env:CLAUDE_PROJECT_DIR }

    # No directory we can trust: say nothing rather than report some other repo's board.
    if (-not $cwd -or -not (Test-Path -LiteralPath $cwd -PathType Container)) { exit 0 }

    $state = Join-Path $cwd "docs/state/active-work.json"
    $board = Join-Path $cwd "docs/progress.md"
    $hasState = Test-Path -LiteralPath $state -PathType Leaf
    $hasBoard = Test-Path -LiteralPath $board -PathType Leaf

    if (-not $hasState -and -not $hasBoard) {
        if (Test-Path -LiteralPath (Join-Path $cwd ".git")) {
            Write-Output "[board] This repo has no status board. Say 'set up the board' to create one with the project-board skill."
        }
        exit 0
    }

    Write-Output "[board] Project status - read these before proposing work, and update them in the same commit as any change."

    if ($hasState) {
        $s = (Get-Content -LiteralPath $state -Raw -Encoding UTF8) | ConvertFrom-Json
        $updatedAt = if ($s.updated_at) { $s.updated_at } elseif ($s.updated_at_kst) { $s.updated_at_kst } else { "?" }
        Write-Output ("  updated: " + $updatedAt + "   stage: " + (("" + $s.stage) -replace '\s+', ' '))
        foreach ($f in @("active_tasks", "queued_tasks", "pending_decisions", "user_todo")) {
            $v = @($s.$f)
            if ($v.Count -gt 0) {
                Write-Output ("  " + $f + " (" + $v.Count + "):")
                foreach ($item in ($v | Select-Object -First 3)) {
                    if ($item -is [string]) { $line = $item }
                    elseif ($item.summary) { $line = "" + $item.id + ": " + $item.summary }
                    else { $line = ($item | ConvertTo-Json -Compress) }
                    $line = ($line -replace '\s+', ' ')
                    if ($line.Length -gt 120) { $line = $line.Substring(0, 120) + "..." }
                    Write-Output ("    - " + $line)
                }
            }
        }
    }

    if ($hasBoard) {
        $updated = Get-Content -LiteralPath $board -Encoding UTF8 -TotalCount 40 |
            Where-Object { $_ -match "Last updated" } | Select-Object -First 1
        if ($updated -and -not $hasState) { Write-Output ("  " + ($updated -replace '^[>\s]+', '')) }
        Write-Output "  board: docs/progress.md"
    }
} catch {
    # A hook must never break a session.
}
exit 0
