# Opens VS Code with the isolated toolchain, so its terminals and the Flutter/Dart
# extensions use the pinned versions too.
#   powershell -ExecutionPolicy Bypass -File tools\code.ps1
$env:TOWNPASS_QUIET = '1'; . "$PSScriptRoot\dev-shell.ps1"
code (Resolve-Path "$PSScriptRoot\..")
