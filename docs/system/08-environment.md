# 隔離開發環境（Windows）

> 所有工具裝在一個資料夾，只在你啟用的終端機生效。**不改系統 PATH、不需管理員、不需 Android Studio、不影響你已經裝的任何版本。**（ADR-010）

## 1. 安裝（第一次，約 10 GB、20–40 分鐘）
**通常不用手動裝**：`tools/start.ps1` 發現缺工具會自動執行這一步。

需要：git、網路。macOS／Linux 沒有安裝腳本，照 `tools/versions.ps1` 的版本自行安裝。
```powershell
powershell -ExecutionPolicy Bypass -File tools\setup-windows.ps1
```
- 預設裝到 `%USERPROFILE%\.townpass-dev`；要換位置先設 `$env:TOWNPASS_TOOLS = 'D:\townpass-dev'`（**不要**選 `AppData` 底下，見 §5）
- 過程記錄在 `%USERPROFILE%\.townpass-dev\setup.log`，失敗時看這個檔案
- 可重複執行：已完成的步驟會跳過
- 只用實體手機、不要模擬器：加 `-SkipEmulator`（省約 2 GB）

## 2. 每次開發
```powershell
. .\tools\dev-shell.ps1        # 注意前面的「點 + 空格」；提示字元會變成 (townpass)
powershell -ExecutionPolicy Bypass -File tools\doctor.ps1   # 檢查（每個工具都必須來自隔離資料夾）
```
VS Code（讓終端機與 Flutter 外掛都用隔離版本）：`powershell -ExecutionPolicy Bypass -File tools\code.ps1`

## 3. 內容與版本（`tools/versions.ps1` 是唯一來源）
| 工具 | 版本 | 位置 |
|---|---|---|
| Node.js + pnpm | 24.22.2 + 10.34.9 | `node\` |
| uv + Python | 0.13.7 + 3.12（uv 管理） | `uv\`、`python\` |
| GitHub CLI | 2.103.2（已有 `gh` 就用既有的） | `gh\` |
| JDK（Temurin） | 21.0.13 | `jdk\` |
| Flutter | 3.47.6（= TownPass `.fvmrc`） | `flutter\` |
| Android SDK | API 36、build-tools 36.0.0、NDK 29.0.13113456 | `android-sdk\` |
| 模擬器 | `townpass`（Pixel 7, API 36） | `android-user\avd\` |
| 快取 | Gradle、pub、npm、pnpm、uv | 各自子資料夾 |

`dev-shell` 設定的環境變數：`JAVA_HOME`、`ANDROID_HOME`、`ANDROID_SDK_ROOT`、`ANDROID_USER_HOME`、`ANDROID_AVD_HOME`、`GRADLE_USER_HOME`、`PUB_CACHE`、`UV_CACHE_DIR`、`UV_PYTHON_INSTALL_DIR`、`npm_config_cache`、`npm_config_store_dir`，並把工具資料夾放在 PATH **最前面**。關掉終端機就恢復原狀。

## 4. 移除
```powershell
Remove-Item -LiteralPath "\\?\$env:USERPROFILE\.townpass-dev" -Recurse -Force   # \\?\ 處理 Flutter 的超長路徑
```

## 5. 已知問題
| 狀況 | 處理 |
|---|---|
| 讓 AI（如 Claude 桌面版）代為安裝後，自己的終端機找不到工具 | 封裝式應用程式會把新建在 `AppData` 的檔案轉存到私有資料夾。預設路徑已避開 `AppData`；自訂 `TOWNPASS_TOOLS` 時也不要放在 `AppData` 底下 |
| 從 Git Bash 執行腳本 | 腳本已用完整路徑呼叫 Windows 的 `curl.exe`／`tar.exe`（Git Bash 自帶的 tar 不認得 `C:`） |
| Flutter clone 出現 `Filename too long` | 腳本已用 `core.longpaths`；若仍失敗，刪掉 `flutter` 資料夾重跑 |
| **第一次換成隔離環境**，或打包出現 `Unable to delete directory`／`AccessDeniedException`／`PathAccessException … .dart_tool` | 舊環境的 Gradle／Kotlin daemon 還開著、`build_runner` 的輸出是唯讀、`build\` 裡的路徑超過 260 字元。執行 `powershell -ExecutionPolicy Bypass -File tools\clean.ps1`，再 `flutter pub get` → `dart run build_runner build` → 打包 |
| 「應用程式控制原則已封鎖此檔案」（Windows 智慧型應用程式控制） | 它會擋下未簽章的 `.venv\Scripts\*.exe` 和套件的 `.pyd`（例：`DLL load failed while importing _immutabledict_cy`）。後端與測試用 `uv run python -m uvicorn ...`／`uv run python -m pytest -q`，不要直接執行 `.venv\Scripts\*.exe`；`dev-shell.ps1` 已設 `DISABLE_SQLALCHEMY_CEXT_RUNTIME=1` 讓 SQLAlchemy 改用純 Python。`psycopg`（只在 Render 用 Postgres 時需要）在本機無法載入，本機用 SQLite 不受影響。`uv sync` 偶爾也會被擋，重跑即可 |
| `build_runner` 出現 `Unable to read file: …\program.dill` 或 `Unable to write file: …build.dart.aot` | 路徑有中文等非 ASCII 字元（例：Windows 使用者名稱）時，預設的 AOT 編譯會失敗。改用 `dart run build_runner build --force-jit`（`start.ps1` 已內建） |
| **Windows 使用者名稱或專案路徑有中文**：模擬器一啟動就結束（exit 5，log 裡路徑變成 `C:\Users\?…`）、Gradle 說 `Your project path contains non-ASCII characters`、`ShaderCompilerException`、Kotlin `Could not close incremental caches` | Android 工具鏈不支援非 ASCII 路徑。① 工具：`New-Item -ItemType Junction C:\townpass-dev -Target "$env:USERPROFILE\.townpass-dev"`，每個終端機先 `$env:TOWNPASS_TOOLS='C:\townpass-dev'` 再 `. .\tools\dev-shell.ps1`；把 `android-user\avd\townpass.ini` 的 `path=` 改成 `C:\townpass-dev\android-user\avd\townpass.avd`。② 專案：`subst T: "<專案路徑>"`（重開機後要再執行一次），在 `T:\` 裡 `flutter pub get` 再 `flutter run`。③ 在 `C:\townpass-dev\gradle\gradle.properties` 加 `kotlin.incremental=false`（專案在 `T:`、套件在 `C:`，Kotlin 增量快取無法跨磁碟） |
| Gradle「Unable to delete directory … build\」 | `tools\clean.ps1`（見上一列），再 `flutter pub get`；確認看到 `Built build` 才安裝，否則裝到的是舊版 |
| 模擬器打不開網頁 `ERR_CLEARTEXT_NOT_PERMITTED` | 用 debug 版 App（已允許 http）；網址用 `localhost` 搭配 `adb reverse`（`07-testing.md` §5），不要用 `10.0.2.2` |
| 你另外裝過 Android Studio | Flutter 可能改用 Android Studio 內建的 JDK，一樣可以打包，不影響 |
| 你曾執行過 `flutter config --jdk-dir …` | 那是使用者全域設定，Flutter 會優先使用它；不需要的話 `flutter config --jdk-dir=""` |
| Mac／Linux 隊友 | 不提供安裝腳本：照 `tools/versions.ps1` 的版本自行安裝，再手動走 `tools/start.ps1` 的步驟 |
