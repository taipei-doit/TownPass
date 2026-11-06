# One command to get a machine ready to work: checks the toolchain (installs it if missing),
# GitHub login and permission, syncs with GitHub, installs dependencies, lists the open tickets.
# Safe to run any time, it never discards work.
#   powershell -ExecutionPolicy Bypass -File tools\start.ps1
#   powershell -ExecutionPolicy Bypass -File tools\start.ps1 -CheckOnly      # report only, change nothing
#   powershell -ExecutionPolicy Bypass -File tools\start.ps1 -SkipEmulator   # no Android emulator (saves ~2 GB)
# Exit code: 0 ready | 2 needs the user (login, permission) | 1 failed.
# Workflow: docs/WORKFLOW.md. AI assistants: .claude/skills/townpass-start/SKILL.md

param([switch]$CheckOnly, [switch]$SkipEmulator)
$Repo = 'hackathon-taipei/TownPass'
$RepoRoot = (Resolve-Path "$PSScriptRoot\..").Path
Set-Location $RepoRoot
$script:NeedsUser = @()
$script:Failed = @()

function Section($text) { Write-Host "`n=== $text" -ForegroundColor Cyan }
function Ok($text) { Write-Host "[ OK ] $text" -ForegroundColor Green }
function Warn($text) { Write-Host "[WARN] $text" -ForegroundColor Yellow }
function Fail($text) { Write-Host "[FAIL] $text" -ForegroundColor Red; $script:Failed += $text }
function Ask($text) { Write-Host "[USER] $text" -ForegroundColor Magenta; $script:NeedsUser += $text }

Section '1/5 Toolchain'
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  Ask 'Install git first: https://git-scm.com/download/win'
  exit 2
}
$env:TOWNPASS_QUIET = '1'; . "$PSScriptRoot\dev-shell.ps1"; Remove-Item Env:TOWNPASS_QUIET
$installed = (Test-Path "$ToolsRoot\flutter\bin\flutter.bat") -and (Test-Path "$ToolsRoot\node\pnpm.cmd") -and (Test-Path "$ToolsRoot\uv\uv.exe")
$hasGh = [bool](Get-Command gh -ErrorAction SilentlyContinue)
if ($installed -and $hasGh) {
  Ok "isolated toolchain in $ToolsRoot"
} elseif ($CheckOnly) {
  Fail 'toolchain not installed (run without -CheckOnly to install)'
} else {
  Warn 'toolchain missing: installing, about 10 GB and 20-40 minutes'
  $setupArgs = @('-ExecutionPolicy', 'Bypass', '-File', "$PSScriptRoot\setup-windows.ps1")
  if ($SkipEmulator) { $setupArgs += '-SkipEmulator' }
  & powershell @setupArgs
  if ($LASTEXITCODE -ne 0) { Fail "setup failed, see $ToolsRoot\setup.log"; exit 1 }
  $env:TOWNPASS_QUIET = '1'; . "$PSScriptRoot\dev-shell.ps1"; Remove-Item Env:TOWNPASS_QUIET
  Ok 'toolchain installed'
}

Section '2/5 GitHub'
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
  Fail 'gh not found'
} else {
  & gh auth status *> $null
  if ($LASTEXITCODE -ne 0) {
    Ask 'Log in to GitHub: gh auth login --web --git-protocol https   (then run this script again)'
  } else {
    if (-not $CheckOnly) { & gh auth setup-git *> $null }
    $login = & gh api user --jq .login 2>$null
    $permission = & gh repo view $Repo --json viewerPermission --jq .viewerPermission 2>$null
    Ok "logged in as $login, permission on $Repo`: $permission"
    if ($permission -notin 'ADMIN', 'MAINTAIN', 'WRITE') {
      Ask "Ask the repo owner to add '$login' to $Repo with write access: you can't push branches yet"
    }
  }
}

Section '3/5 Sync with GitHub'
& git fetch origin --prune 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) { Fail 'git fetch failed (network or login?)' }
$branch = (& git branch --show-current).Trim()
$dirty = @(& git status --porcelain)
$counts = (& git rev-list --left-right --count "origin/main...HEAD") -split '\s+'
$behind = [int]$counts[0]; $ahead = [int]$counts[1]
Write-Host "branch $branch | $behind behind origin/main, $ahead ahead | $($dirty.Count) changed files"
if ($branch -eq 'main' -and $ahead -gt 0) {
  Warn 'local main has commits that are not on GitHub. main only changes through PRs: move them to a branch'
} elseif ($branch -eq 'main' -and $behind -gt 0 -and -not $CheckOnly) {
  if ($dirty.Count) { Warn 'not updating main: there are uncommitted changes. Commit them to a branch or stash, then run again' }
  else {
    & git pull --ff-only origin main 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) { Ok 'main updated' } else { Fail 'git pull failed' }
  }
} elseif ($branch -ne 'main' -and $behind -gt 0) {
  Warn "your branch is behind main. Before the PR: git fetch origin; git rebase origin/main"
} else { Ok 'up to date' }

Section '4/5 Dependencies'
if ($CheckOnly) {
  Write-Host 'skipped (-CheckOnly)'
} elseif ($script:Failed.Count) {
  Warn 'skipped: fix the failures above first'
} else {
  # no prompt when node_modules came from another pnpm store
  $env:npm_config_confirm_modules_purge = 'false'
  Push-Location services\web
  & pnpm install --frozen-lockfile *> "$env:TEMP\townpass-web.log"
  if ($LASTEXITCODE -eq 0) { Ok 'web (pnpm)' } else { Fail "web install failed, see $env:TEMP\townpass-web.log" }
  Pop-Location
  Push-Location services\backend
  & uv sync *> "$env:TEMP\townpass-backend.log"
  if ($LASTEXITCODE -eq 0) { Ok 'backend (uv)' } else { Fail "backend install failed, see $env:TEMP\townpass-backend.log" }
  Pop-Location
  & flutter pub get *> "$env:TEMP\townpass-app.log"
  if ($LASTEXITCODE -eq 0) { Ok 'app (flutter pub)' } else { Fail "app install failed, see $env:TEMP\townpass-app.log" }
  if (-not (Test-Path 'lib\gen\assets.gen.dart')) {
    & dart run build_runner build --delete-conflicting-outputs *> "$env:TEMP\townpass-gen.log"
    if ($LASTEXITCODE -eq 0) { Ok 'app generated code' } else { Fail "build_runner failed, see $env:TEMP\townpass-gen.log" }
  }
  & node tools\check-arch.mjs *> $null
  if ($LASTEXITCODE -eq 0) { Ok 'architecture check' } else { Fail 'architecture check failed: node tools/check-arch.mjs' }
}

Section '5/5 Tickets'
if (Get-Command gh -ErrorAction SilentlyContinue) {
  $tickets = & gh issue list -R $Repo --label ticket --state open --limit 50 --json number,title,labels,assignees 2>$null | ConvertFrom-Json
  if (-not $tickets) {
    Write-Host 'no open tickets'
  } else {
    foreach ($t in $tickets) {
      $names = @($t.labels | ForEach-Object { $_.name })
      $state = if ($names -contains 'blocked') { 'blocked' }
               elseif ($names -contains 'status:in-progress') { 'in-progress' }
               elseif ($names -contains 'status:review') { 'review' }
               elseif ($names -contains 'status:ready') { 'READY' } else { '-' }
      $who = (@($t.assignees | ForEach-Object { $_.login }) -join ',')
      Write-Host ("#{0,-4} {1,-11} {2} {3}" -f $t.number, $state, $t.title, $(if ($who) { "(@$who)" }))
    }
  }
}

Section 'Result'
if ($script:Failed.Count) {
  $script:Failed | ForEach-Object { Write-Host "FAILED: $_" -ForegroundColor Red }
  exit 1
}
if ($script:NeedsUser.Count) {
  $script:NeedsUser | ForEach-Object { Write-Host "NEEDS YOU: $_" -ForegroundColor Magenta }
  exit 2
}
Write-Host 'Ready. Next: read the docs listed in .claude/skills/townpass-start/SKILL.md, then pick a ticket.' -ForegroundColor Green
Write-Host 'In each new terminal: . .\tools\dev-shell.ps1'
