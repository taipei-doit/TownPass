# Single source of truth for toolchain versions. Change here, rerun tools\setup-windows.ps1.
# Must stay in sync with: TownPass .fvmrc (Flutter), android/app/build.gradle (NDK), CI workflows.
$Versions = @{
  Node             = 'v24.22.2'
  Pnpm             = '10.34.9'
  Uv               = '0.13.7'
  Gh               = '2.103.2'     # only installed when the machine has no gh
  Python           = '3.12'
  Jdk              = '21.0.13+9'   # Eclipse Temurin
  Flutter          = '3.47.6'
  AndroidCmdline   = '16111833'    # cmdline-tools 23.0
  AndroidPlatform  = 'android-36'
  AndroidBuildTool = '36.0.0'
  AndroidNdk       = '29.0.13113456'
  AndroidImage     = 'system-images/android-36/google_apis/x86_64'
}

# Where the isolated toolchain lives. Outside the repo so several clones share it,
# and separate from anything the user already installed.
# NOT under %LOCALAPPDATA%/%APPDATA%: when this runs inside a packaged (MSIX) app - e.g. an AI
# assistant in the Claude desktop app - Windows silently redirects new AppData files into a
# private per-app folder, so the tools would be invisible to your own terminals.
$ToolsRoot = if ($env:TOWNPASS_TOOLS) { $env:TOWNPASS_TOOLS } else { Join-Path $env:USERPROFILE '.townpass-dev' }
