# Installs the project's toolchain into ONE isolated folder (default %USERPROFILE%\.townpass-dev;
# tools\versions.ps1 explains why it must not be under AppData).
#   powershell -ExecutionPolicy Bypass -File tools\setup-windows.ps1
#
# - No admin rights, no winget, no global PATH/JAVA_HOME changes, no Android Studio needed.
# - Never touches tools you already have: your own Node/Java/Python/Flutter/Android SDK keep working.
# - Re-runnable: finished steps are skipped. Uninstall = delete the folder.
# - Custom location: set $env:TOWNPASS_TOOLS before running (and before dev-shell).
# Needs: git, ~10 GB disk, internet.

param([switch]$SkipEmulator)
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'   # Invoke-WebRequest is 10x slower with the progress bar
. "$PSScriptRoot\versions.ps1"
$V = $Versions; $R = $ToolsRoot
New-Item -ItemType Directory -Force $R | Out-Null

$Log = "$R\setup.log"
function Step($msg) { Write-Host "`n==> $msg" -ForegroundColor Cyan; Add-Content $Log "`n==> $msg" }
function Done($msg) { Write-Host "    ok: $msg" -ForegroundColor Green }
# Run a native command, send its output to setup.log, fail on a non-zero exit code.
# (PowerShell 5.1 turns stderr of native tools into terminating errors under 'Stop' - many tools
#  print progress on stderr, so we relax it just for the call and check the exit code instead.)
function Run([string]$what, [scriptblock]$cmd, [switch]$AllowFail) {
  $old = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
  try { & $cmd 2>&1 | ForEach-Object { "$_" } | Add-Content $Log; $code = $LASTEXITCODE }
  finally { $ErrorActionPreference = $old }
  if ($code -and -not $AllowFail) { throw "$what failed (exit $code) - see $Log" }
}
function Get-Zip($url, $dest) {
  # download + extract; if the zip has a single top folder, its contents become $dest.
  # Uses Windows' built-in curl.exe and tar.exe: Invoke-WebRequest/Expand-Archive in
  # PowerShell 5.1 can take tens of minutes (or appear to hang) on 100+ MB files.
  $zip = Join-Path $env:TEMP ([IO.Path]::GetFileName(([Uri]$url).LocalPath))
  $tmp = Join-Path $env:TEMP ("tp-" + [guid]::NewGuid())
  & "$env:SystemRoot\System32\curl.exe" -fsSL --retry 3 -o $zip $url   # full path: Git Bash ships its own curl/tar
  if ($LASTEXITCODE -ne 0) { throw "download failed: $url" }
  New-Item -ItemType Directory -Force $tmp | Out-Null
  & "$env:SystemRoot\System32\tar.exe" -xf $zip -C $tmp
  if ($LASTEXITCODE -ne 0) { throw "extract failed: $zip" }
  $items = @(Get-ChildItem $tmp)
  $src = if ($items.Count -eq 1 -and $items[0].PSIsContainer) { $items[0].FullName } else { $tmp }
  New-Item -ItemType Directory -Force (Split-Path $dest) | Out-Null
  if (Test-Path $dest) { Remove-Item $dest -Recurse -Force }
  Move-Item $src $dest
  Remove-Item $zip, $tmp -Recurse -Force -ErrorAction SilentlyContinue
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) { throw 'git is required: https://git-scm.com/download/win' }

Step "Node $($V.Node) + pnpm $($V.Pnpm)"
if (-not (Test-Path "$R\node\node.exe") -or ((& "$R\node\node.exe" -v) -ne $V.Node)) {
  Get-Zip "https://nodejs.org/dist/$($V.Node)/node-$($V.Node)-win-x64.zip" "$R\node"
}
if (-not (Test-Path "$R\node\pnpm.cmd")) {
  Run 'pnpm install' { & "$R\node\npm.cmd" install -g "pnpm@$($V.Pnpm)" --prefix "$R\node" --cache "$R\npm-cache" }
}
Done "$R\node"

Step "uv $($V.Uv) (Python packages)"
if (-not (Test-Path "$R\uv\uv.exe")) {
  Get-Zip "https://github.com/astral-sh/uv/releases/download/$($V.Uv)/uv-x86_64-pc-windows-msvc.zip" "$R\uv"
}
Done "$R\uv"

Step "GitHub CLI"
if (Get-Command gh -ErrorAction SilentlyContinue) {
  Done "using your existing gh"
} elseif (-not (Test-Path "$R\gh\bin\gh.exe")) {
  Get-Zip "https://github.com/cli/cli/releases/download/v$($V.Gh)/gh_$($V.Gh)_windows_amd64.zip" "$R\gh"
  Done "$R\gh"
}

Step "JDK $($V.Jdk) (Eclipse Temurin)"
if (-not (Test-Path "$R\jdk\bin\java.exe")) {
  $jv = $V.Jdk -replace '\+', '_'
  $tag = [Uri]::EscapeDataString("jdk-$($V.Jdk)")
  Get-Zip "https://github.com/adoptium/temurin21-binaries/releases/download/$tag/OpenJDK21U-jdk_x64_windows_hotspot_$jv.zip" "$R\jdk"
}
Done "$R\jdk"

Step "Flutter $($V.Flutter)"
# A checkout that failed half-way still has bin\flutter.bat, so check the work tree is complete.
$flutterOk = (Test-Path "$R\flutter\bin\flutter.bat") -and -not (git -C "$R\flutter" status --porcelain 2>$null)
if (-not $flutterOk) {
  if (Test-Path "$R\flutter") { Remove-Item "$R\flutter" -Recurse -Force }
  # core.longpaths: some Flutter test files exceed Windows' 260-char path limit
  Run 'flutter clone' { git -c core.longpaths=true clone --quiet --depth 1 --branch $V.Flutter https://github.com/flutter/flutter.git "$R\flutter" }
  git -C "$R\flutter" config core.longpaths true
}
Done "$R\flutter"

# Everything below runs inside the isolated environment
$env:TOWNPASS_QUIET = '1'; . "$PSScriptRoot\dev-shell.ps1"; Remove-Item Env:TOWNPASS_QUIET

Step 'Python (managed by uv, inside the tools folder)'
Run 'python install' { uv python install $V.Python }
Done (uv python find $V.Python 2>$null)

Step 'Android SDK'
$sdk = "$R\android-sdk"
if (-not (Test-Path "$sdk\cmdline-tools\latest\bin\android.exe")) {
  Get-Zip "https://dl.google.com/android/repository/commandlinetools-win-$($V.AndroidCmdline)_latest.zip" "$sdk\cmdline-tools\latest"
}
# cmdline-tools 23+: `android sdk install` replaces sdkmanager, package names use '/'
$pkgs = @('platform-tools', "platforms/$($V.AndroidPlatform)", "build-tools/$($V.AndroidBuildTool)", "ndk/$($V.AndroidNdk)")
if (-not $SkipEmulator) { $pkgs += @('emulator', $V.AndroidImage) }
Run 'android sdk install' { & "$sdk\cmdline-tools\latest\bin\android.exe" sdk install @pkgs }
$yes = ('y' + [Environment]::NewLine) * 30
Run 'android licenses' { $yes | & "$sdk\cmdline-tools\latest\bin\sdkmanager.bat" --licenses } -AllowFail
foreach ($p in @("platforms\$($V.AndroidPlatform)", "build-tools\$($V.AndroidBuildTool)", "ndk\$($V.AndroidNdk)")) {
  if (-not (Test-Path "$sdk\$p")) { throw "Android SDK package missing after install: $p - see $Log" }
}
Done $sdk

if (-not $SkipEmulator) {
  Step 'Android emulator "townpass" (Pixel 7, API 36)'
  New-Item -ItemType Directory -Force $env:ANDROID_AVD_HOME | Out-Null
  if (-not ((& "$sdk\emulator\emulator.exe" -list-avds) -contains 'townpass')) {
    $img = $V.AndroidImage -replace '/', ';'
    Run 'create emulator' { 'no' | & "$sdk\cmdline-tools\latest\bin\avdmanager.bat" create avd -n townpass -k $img -d pixel_7 }
  }
  Done "$env:ANDROID_AVD_HOME\townpass.avd"
}

Step 'Flutter first run (downloads the Dart SDK)'
Run 'flutter first run' { flutter --version }
Run 'flutter licenses' { $yes | flutter doctor --android-licenses } -AllowFail
Done (Get-Content $Log | Select-String '^Flutter \d' | Select-Object -Last 1)

Write-Host @"

==> Toolchain ready in $R  (nothing outside this folder was changed)

Every new terminal:   . .\tools\dev-shell.ps1      then everything uses the pinned versions
Check:                powershell -ExecutionPolicy Bypass -File tools\doctor.ps1
VS Code with the env: powershell -ExecutionPolicy Bypass -File tools\code.ps1
Built this repo before with another Flutter? Run once: powershell -ExecutionPolicy Bypass -File tools\clean.ps1
Remove everything:    Remove-Item -LiteralPath "\\?\$R" -Recurse -Force
"@ -ForegroundColor Yellow
