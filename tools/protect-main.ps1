# Makes GitHub enforce docs/DEPLOY.md: only the integrator (and backup) can merge to main, which is what deploys.
#   powershell -ExecutionPolicy Bypass -File tools\protect-main.ps1 -Merger <login> [-Backup <login>] [-Teammates a,b] [-DryRun]
# -Teammates also turns those people from organisation owners into members with write access to the repo,
# because an owner can switch the protection off. Needs an owner's login. Replaces the whole protection rule.
param(
  [Parameter(Mandatory)][string]$Merger,
  [string]$Backup,
  [string[]]$Teammates = @(),
  [switch]$DryRun
)
$ErrorActionPreference = 'Stop'
$Org = 'hackathon-taipei'
$Repo = "$Org/TownPass"

$Mergers = @($Merger)
if ($Backup) { $Mergers += $Backup }
$Teammates = @($Teammates | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
foreach ($login in $Teammates) {
  if ($Mergers -contains $login) { throw "$login is in both -Teammates and the merger list" }
}

$rule = @{
  required_status_checks        = @{ strict = $true; contexts = @('arch', 'web', 'backend', 'app') }
  enforce_admins                = $true
  required_pull_request_reviews = @{ required_approving_review_count = 0 }
  restrictions                  = @{ users = $Mergers; teams = @(); apps = @() }
  required_linear_history       = $true
  allow_force_pushes            = $false
  allow_deletions               = $false
} | ConvertTo-Json -Depth 5

function Gh-Api([string]$Method, [string]$Path, [string[]]$Fields) {
  if ($DryRun) { Write-Host "would call: $Method $Path $Fields"; return }
  & gh api -X $Method $Path @($Fields | ForEach-Object { '-f'; $_ }) | Out-Null
  if ($LASTEXITCODE -ne 0) { throw "gh api $Method $Path failed" }
}

if ($DryRun) { Write-Host "would set the main protection on $Repo to:`n$rule" }
else {
  $rule | & gh api -X PUT "repos/$Repo/branches/main/protection" --input - | Out-Null
  if ($LASTEXITCODE -ne 0) { throw 'setting the branch protection failed' }
}

# Repo access first, so nobody is left without write access if the second call fails.
foreach ($login in $Teammates) {
  Gh-Api PUT "repos/$Repo/collaborators/$login" @('permission=push')
  Gh-Api PUT "orgs/$Org/memberships/$login" @('role=member')
}

if ($DryRun) { Write-Host 'Dry run: nothing changed.' } else { Write-Host "Done. Only $($Mergers -join ', ') can merge. Check it: a teammate's gh pr merge must fail." }
