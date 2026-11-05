# Checks that this machine can build every part of the project.
# Usage: powershell -ExecutionPolicy Bypass -File tools\doctor.ps1

$ok = $true
function Check($name, $cmd, $want) {
  $v = try { (& $cmd 2>&1 | Select-Object -First 1).ToString().Trim() } catch { $null }
  if ($v -and (-not $want -or $v -match [regex]::Escape($want))) {
    Write-Host ("[ OK ] {0,-10} {1}" -f $name, $v) -ForegroundColor Green
  } else {
    $got  = if ($v) { $v } else { 'not found' }
    $need = if ($want) { $want } else { 'installed' }
    Write-Host ("[FAIL] {0,-10} {1}  (want {2})" -f $name, $got, $need) -ForegroundColor Red
    $script:ok = $false
  }
}

Check git     { git --version }
Check node    { node -v }
Check pnpm    { pnpm -v }
Check uv      { uv --version }
Check flutter { flutter --version } '3.47.6'

Write-Host "`n--- flutter doctor (Android toolchain + devices) ---"
flutter doctor
flutter devices

if ($ok) { Write-Host "`nAll required tools found." -ForegroundColor Green }
else     { Write-Host "`nSome tools are missing - rerun tools\setup-windows.ps1" -ForegroundColor Red; exit 1 }
