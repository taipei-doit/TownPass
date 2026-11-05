# TownPass hackathon - Windows dev environment setup
# Usage (PowerShell, normal user):  powershell -ExecutionPolicy Bypass -File tools\setup-windows.ps1
# Safe to re-run: every step skips itself when already done.
# Android Studio install pops one UAC prompt; everything else is user-scope.

$ErrorActionPreference = 'Stop'
$FlutterVersion = '3.47.6'                      # must match TownPass .fvmrc
$FlutterDir     = Join-Path $HOME 'dev\flutter'

function Step($msg) { Write-Host "`n==> $msg" -ForegroundColor Cyan }
function Has($cmd)  { [bool](Get-Command $cmd -ErrorAction SilentlyContinue) }
function Add-UserPath($dir) {
  $p = [Environment]::GetEnvironmentVariable('Path', 'User')
  if (($p -split ';') -notcontains $dir) {
    [Environment]::SetEnvironmentVariable('Path', ($p.TrimEnd(';') + ";$dir"), 'User')
  }
  if (($env:Path -split ';') -notcontains $dir) { $env:Path += ";$dir" }
}

Step 'Checking base tools (git, node)'
if (-not (Has git))  { winget install --id Git.Git -e --scope user --accept-package-agreements --accept-source-agreements }
if (-not (Has node)) { winget install --id OpenJS.NodeJS.LTS -e --accept-package-agreements --accept-source-agreements }

Step 'pnpm'
if (-not (Has pnpm)) { npm install -g pnpm@10 }

Step 'uv (Python package manager for the backend)'
# (winget's uv package can fail on a VCRedist dependency, so use pip when Python exists)
if (-not (Has uv)) {
  if (Has python) {
    python -m pip install --user --quiet uv
    Add-UserPath (python -c "import sysconfig;print(sysconfig.get_path('scripts','nt_user'))")
  } else {
    winget install --id astral-sh.uv -e --scope user --accept-package-agreements --accept-source-agreements
  }
}

Step "Flutter $FlutterVersion"
if (-not (Test-Path "$FlutterDir\bin\flutter.bat")) {
  New-Item -ItemType Directory -Force (Split-Path $FlutterDir) | Out-Null
  git clone --depth 1 --branch $FlutterVersion https://github.com/flutter/flutter.git $FlutterDir
  # flutter doctor will warn "unknown channel [user-branch]" - harmless, it's from pinning an exact tag
}
Add-UserPath "$FlutterDir\bin"
Add-UserPath (Join-Path $env:LOCALAPPDATA 'Pub\Cache\bin')

Step 'Android Studio (bundles the JDK Gradle needs + emulator manager)'
$studio = @("$env:ProgramFiles\Android\Android Studio", "$env:LOCALAPPDATA\Programs\Android Studio") | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $studio) {
  winget install --id Google.AndroidStudio -e --accept-package-agreements --accept-source-agreements
  $studio = "$env:ProgramFiles\Android\Android Studio"
}
$env:JAVA_HOME = "$studio\jbr"   # Gradle needs Android Studio's JDK; a newer system Java can break it

Step 'Android SDK (headless, no SDK Manager clicking needed)'
$sdk = Join-Path $env:LOCALAPPDATA 'Android\Sdk'
$sm  = "$sdk\cmdline-tools\latest\bin\sdkmanager.bat"
$acli = "$sdk\cmdline-tools\latest\bin\android.exe"   # cmdline-tools 23+: sdkmanager is deprecated, package names use '/'
if (-not (Test-Path $sm)) {
  # cmdline-tools 23.0 - newer builds are listed at https://dl.google.com/android/repository/repository2-3.xml
  $zip = Join-Path $env:TEMP 'clt.zip'; $tmp = Join-Path $env:TEMP 'clt'
  Invoke-WebRequest https://dl.google.com/android/repository/commandlinetools-win-16111833_latest.zip -OutFile $zip
  Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
  Expand-Archive $zip $tmp
  New-Item -ItemType Directory -Force "$sdk\cmdline-tools" | Out-Null
  Move-Item "$tmp\cmdline-tools" "$sdk\cmdline-tools\latest"
}
[Environment]::SetEnvironmentVariable('ANDROID_HOME', $sdk, 'User'); $env:ANDROID_HOME = $sdk
Add-UserPath "$sdk\platform-tools"; Add-UserPath "$sdk\emulator"; Add-UserPath "$sdk\cmdline-tools\latest\bin"
$yes = ('y' + [Environment]::NewLine) * 20
$yes | & $sm --licenses | Out-Null
if (Test-Path $acli) {
  # ndk version must match android/app/build.gradle in TownPass (Gradle can't auto-install it with cmdline-tools 23+)
  & $acli sdk install platform-tools emulator platforms/android-36 build-tools/36.0.0 ndk/29.0.13113456 system-images/android-36/google_apis/x86_64
} else {
  & $sm 'platform-tools' 'platforms;android-36' 'build-tools;36.0.0' 'ndk;29.0.13113456' 'emulator' 'system-images;android-36;google_apis;x86_64'
}
flutter config --jdk-dir "$studio\jbr" --android-sdk $sdk | Out-Null
$yes | flutter doctor --android-licenses | Out-Null

Step 'Android emulator (Pixel, API 36)'
$avdmanager = "$sdk\cmdline-tools\latest\bin\avdmanager.bat"
if (-not ((& "$sdk\emulator\emulator.exe" -list-avds) -contains 'townpass')) {
  'no' | & $avdmanager create avd -n townpass -k 'system-images;android-36;google_apis;x86_64' -d pixel_7 | Out-Null
}

Write-Host @"

==> Done. Open a NEW terminal, then:
  powershell -File tools\doctor.ps1          # verify everything
  flutter emulators --launch townpass         # start the emulator (or plug in a phone with USB debugging)
  flutter pub get; dart run build_runner build --delete-conflicting-outputs
  flutter run                                 # run from the repo root; first build takes ~10 min
"@ -ForegroundColor Yellow
