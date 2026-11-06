# Activates the project's isolated toolchain for THIS terminal only.
#   . .\tools\dev-shell.ps1        (note the leading dot + space)
# Nothing global is changed: no system/user PATH, no JAVA_HOME, no registry. Close the
# terminal and you're back to whatever Node/Java/Flutter/Android you had before.

. "$PSScriptRoot\versions.ps1"
$R = $ToolsRoot

$env:TOWNPASS_TOOLS     = $R
$env:JAVA_HOME          = "$R\jdk"
$env:ANDROID_HOME       = "$R\android-sdk"
$env:ANDROID_SDK_ROOT   = "$R\android-sdk"
$env:ANDROID_USER_HOME  = "$R\android-user"      # adb keys, emulator prefs
$env:ANDROID_AVD_HOME   = "$R\android-user\avd"  # our emulator lives here, not in ~/.android
$env:GRADLE_USER_HOME   = "$R\gradle"
$env:PUB_CACHE          = "$R\pub-cache"
$env:UV_CACHE_DIR       = "$R\uv-cache"
$env:UV_PYTHON_INSTALL_DIR = "$R\python"
$env:npm_config_cache   = "$R\npm-cache"
$env:npm_config_store_dir = "$R\pnpm-store"
$env:FLUTTER_SUPPRESS_ANALYTICS = 'true'

$ours = @(
  "$R\node", "$R\uv", "$R\gh\bin", "$R\jdk\bin", "$R\flutter\bin", "$R\pub-cache\bin",
  "$R\android-sdk\platform-tools", "$R\android-sdk\emulator", "$R\android-sdk\cmdline-tools\latest\bin"
)
if (-not $env:TOWNPASS_ORIGINAL_PATH) { $env:TOWNPASS_ORIGINAL_PATH = $env:Path }
# Ours first, so an older global Node/Java/Flutter can never shadow the pinned ones
$env:Path = (($ours | Where-Object { Test-Path $_ }) + @($env:TOWNPASS_ORIGINAL_PATH)) -join ';'

if (-not $env:TOWNPASS_QUIET) {
  Write-Host "townpass dev shell active  ->  $R" -ForegroundColor Cyan
  if (-not (Test-Path "$R\flutter\bin\flutter.bat")) {
    Write-Host 'toolchain not installed yet: run  powershell -ExecutionPolicy Bypass -File tools\setup-windows.ps1' -ForegroundColor Yellow
  }
}

function global:prompt { "(townpass) PS $($executionContext.SessionState.Path.CurrentLocation)> " }
