# Verifies the isolated toolchain: every tool must resolve INSIDE the tools folder at the pinned version.
#   powershell -ExecutionPolicy Bypass -File tools\doctor.ps1

$env:TOWNPASS_QUIET = '1'; . "$PSScriptRoot\dev-shell.ps1"; Remove-Item Env:TOWNPASS_QUIET
$V = $Versions; $R = $ToolsRoot
$fail = 0

function Check($name, $cmd, $want, [scriptblock]$version) {
  $c = Get-Command $cmd -ErrorAction SilentlyContinue
  if (-not $c) { Write-Host ("[FAIL] {0,-8} not found - run tools\setup-windows.ps1" -f $name) -ForegroundColor Red; $script:fail++; return }
  $v = try { (& $version 2>&1 | Select-Object -First 1).ToString().Trim() } catch { 'error' }
  $inside = $c.Source.StartsWith($R, [StringComparison]::OrdinalIgnoreCase)
  if ($inside -and $v -match [regex]::Escape($want)) {
    Write-Host ("[ OK ] {0,-8} {1}" -f $name, $v) -ForegroundColor Green
  } else {
    $why = if (-not $inside) { "resolves OUTSIDE the tools folder: $($c.Source)" } else { "want $want" }
    Write-Host ("[FAIL] {0,-8} {1}  ({2})" -f $name, $v, $why) -ForegroundColor Red; $script:fail++
  }
}

Check node    node.exe    $V.Node                 { node -v }
Check pnpm    pnpm.cmd    $V.Pnpm                 { pnpm -v }
Check uv      uv.exe      $V.Uv                   { uv --version }
Check java    java.exe    ($V.Jdk -replace '\+.*') { java -version }
Check flutter flutter.bat $V.Flutter              { flutter --version }
Check adb     adb.exe     ''                      { adb version }

if (Get-Command gh -ErrorAction SilentlyContinue) { Write-Host "[ OK ] gh       $((gh --version | Select-Object -First 1))" -ForegroundColor Green }
else { Write-Host '[FAIL] gh       not found - run tools\setup-windows.ps1' -ForegroundColor Red; $fail++ }

$py = uv python find $V.Python 2>$null
if ($py -and $py.StartsWith($R, [StringComparison]::OrdinalIgnoreCase)) { Write-Host "[ OK ] python   $py" -ForegroundColor Green }
else { Write-Host "[WARN] python   uv will use: $py (not the isolated one; fine if it is $($V.Python)+)" -ForegroundColor Yellow }

foreach ($p in @("platforms\$($V.AndroidPlatform)", "build-tools\$($V.AndroidBuildTool)", "ndk\$($V.AndroidNdk)")) {
  if (Test-Path "$env:ANDROID_HOME\$p") { Write-Host "[ OK ] sdk      $p" -ForegroundColor Green }
  else { Write-Host "[FAIL] sdk      $p missing" -ForegroundColor Red; $fail++ }
}
$avds = if (Test-Path "$env:ANDROID_HOME\emulator\emulator.exe") { & "$env:ANDROID_HOME\emulator\emulator.exe" -list-avds } else { @() }
if ($avds -contains 'townpass') { Write-Host '[ OK ] avd      townpass' -ForegroundColor Green }
else { Write-Host '[WARN] avd      townpass missing (fine if you use a real phone)' -ForegroundColor Yellow }

Write-Host "`n--- flutter doctor ---"
flutter doctor 2>&1 | Where-Object { $_ -match '^\[|^\s+[X!]' }

if ($fail) { Write-Host "`n$fail problem(s). Rerun tools\setup-windows.ps1" -ForegroundColor Red; exit 1 }
Write-Host "`nAll good - isolated toolchain in $R" -ForegroundColor Green
