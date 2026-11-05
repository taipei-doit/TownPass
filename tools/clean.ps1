# Cleans the Flutter app's build outputs. Run it once after switching toolchains
# (e.g. from a global Flutter to the isolated one) or when a build fails with
# "Unable to delete directory", "AccessDeniedException" or "PathAccessException".
#   powershell -ExecutionPolicy Bypass -File tools\clean.ps1
#
# - stops Gradle and Kotlin daemons (they keep files in build\ open)
# - clears read-only flags (build_runner marks its output read-only)
# - deletes build\ and .dart_tool\ using the \\?\ prefix (paths there exceed 260 chars)

$repo = (Resolve-Path "$PSScriptRoot\..").Path

Get-CimInstance Win32_Process -Filter "Name='java.exe'" |
  Where-Object { $_.CommandLine -match 'GradleDaemon|KotlinCompileDaemon' } |
  ForEach-Object { Stop-Process -Id $_.ProcessId -Force; Write-Host "stopped daemon $($_.ProcessId)" }
Start-Sleep -Seconds 1

foreach ($name in 'build', '.dart_tool') {
  $dir = Join-Path $repo $name
  if (-not (Test-Path -LiteralPath $dir)) { continue }
  $long = '\\?\' + $dir
  Get-ChildItem -LiteralPath $long -Recurse -Force -ErrorAction SilentlyContinue |
    Where-Object { $_.Attributes -band [IO.FileAttributes]::ReadOnly } |
    ForEach-Object { $_.Attributes = $_.Attributes -band (-bnot [IO.FileAttributes]::ReadOnly) }
  Remove-Item -LiteralPath $long -Recurse -Force -ErrorAction SilentlyContinue
  if (Test-Path -LiteralPath $dir) { Write-Host "could not fully remove $name - close Android Studio/VS Code and retry" -ForegroundColor Red }
  else { Write-Host "removed $name" -ForegroundColor Green }
}
Write-Host "Next: flutter pub get; dart run build_runner build --delete-conflicting-outputs; flutter run"
