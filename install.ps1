# orca-skills - install into ~/.claude/skills (Windows)
# Every project on this machine loads skills from there.
$ErrorActionPreference = "Stop"
$dst = Join-Path $HOME ".claude\skills"
New-Item -ItemType Directory -Force $dst | Out-Null
$src = Join-Path $PSScriptRoot "skills"
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"

Get-ChildItem $src -Directory | ForEach-Object {
    $target = Join-Path $dst $_.Name
    if (Test-Path $target) {
        $backup = "$target.backup-$stamp"
        Move-Item $target $backup
        Write-Host ("  backed up   " + $_.Name + "  ->  " + (Split-Path $backup -Leaf)) -ForegroundColor Yellow
    }
    Copy-Item -Recurse $_.FullName $dst
    Write-Host ("  installed   " + $_.Name)
}

Write-Host ""
Write-Host "Installed to : $dst"
Write-Host "Restart Claude Code to pick them up."
