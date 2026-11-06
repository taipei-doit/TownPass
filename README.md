# 城市通微服務｜2026 臺北秋季程式設計節

> **隊員：** 把這個 repo 給你的 AI，跟它說「請看 README 開始」。環境、同步、工單它都會帶你走完。
>
> **AI：** 你的第一件事是照 [`.claude/skills/townpass-start/SKILL.md`](.claude/skills/townpass-start/SKILL.md) 做。還沒 clone 就先：
> `git clone https://github.com/hackathon-taipei/TownPass.git && cd TownPass`
> 然後執行 `powershell -ExecutionPolicy Bypass -File tools/start.ps1`，它會檢查並自動安裝環境、同步 GitHub、列出工單。
> 你是主代理：**實作交給子代理，你負責檢查與開 PR，不自行合併**；做完要更新系統文件再推回去。合併與部署由整合者統一處理。

> Fork 自 [taipei-doit/TownPass](https://github.com/taipei-doit/TownPass)。我們的作品是一個城市通微服務：在 App 的 WebView 中執行的網頁，加上後端 API。

![App 開啟微服務的畫面](docs/images/e2e-emulator.png)

| 資料夾 | 內容 |
|---|---|
| `lib/` `android/` `ios/` | TownPass Flutter App（上游程式碼，僅做最小修改） |
| `services/web/` | 微服務前端：Vue 3 + Vite + TypeScript + Tailwind + Leaflet/OSM |
| `services/backend/` | 後端：FastAPI + SQLModel，Postgres（Render）／本機 SQLite |
| `data/SOURCES.md` | 使用的開放資料與出處 |
| `docs/system/` | **系統文件**：[架構與技術棧](docs/system/10-architecture.md)、[決策](docs/system/01-decisions.md)、[規格](docs/system/02-spec.md)、[字詞表](docs/system/03-glossary.md)、[顯示層](docs/system/04-presentation-layer.md)／[邏輯層](docs/system/05-logic-layer.md)／[資料層](docs/system/06-data-layer.md)、[測試](docs/system/07-testing.md)、[環境](docs/system/08-environment.md)、[加購件與工具](docs/system/09-addons.md) |
| `docs/` | [團隊流程](docs/WORKFLOW.md)、[UI 框架](docs/FRAMEWORK.md)、[部署](docs/DEPLOY.md)、[App ↔ 網頁訊息](docs/bridge.md)、[工單](docs/tickets/README.md) |
| `.claude/skills/` | 給 AI 的工作流程：`townpass-start`、`townpass-ticket`、`townpass-feature`、`townpass-ui`（其他 AI 從 [AGENTS.md](AGENTS.md) 開始） |
| `tools/` | `start.ps1` 一鍵開工、隔離開發環境、架構與文件檢查 |

## 快速開始

```powershell
powershell -ExecutionPolicy Bypass -File tools/start.ps1   # 檢查並安裝環境、登入檢查、同步、裝依賴、列工單；隨時可重跑
. .\tools\dev-shell.ps1                                    # 每個新終端機：只在這個終端機啟用工具
```

完整開發流程見 [docs/WORKFLOW.md](docs/WORKFLOW.md)。工具全部裝在 `%USERPROFILE%\.townpass-dev`，不影響既有安裝。

| 上線網址 | |
|---|---|
| 微服務 | https://hackathon-taipei.github.io/TownPass/ |
| 後端 | https://townpass-backend-dmk2.onrender.com（[API 文件](https://townpass-backend-dmk2.onrender.com/docs)） |

## 授權 License

- 本隊於競賽期間開發之成果（`services/`、`data/`、`docs/`、`tools/` 及對 App 的修改）依競賽規則以 **GNU AGPL-3.0** 授權，全文見 [LICENSE-AGPL](LICENSE-AGPL)。
- 上游 TownPass 程式碼維持其原授權 GNU GPL-3.0，見 [LICENSE](LICENSE)。GPL-3.0 第 13 條允許與 AGPL-3.0 作品結合。

```
城市通微服務 — 2026 臺北秋季程式設計節參賽作品，以台北通為基礎之市政微服務。
Copyright (C) 2026 hackathon-taipei
This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.
You should have received a copy of the GNU Affero General Public License along with this program. If not, see https://www.gnu.org/licenses/.
```

---

> 以下是上游 TownPass 的原始說明。**開發本專案請用上面的 `tools/start.ps1`**，不要照下面的步驟裝全域工具。

# What is Town Pass?

Town Pass is an open-source project developed by the Taipei City Government. With the growth of smart cities, the demand for digitalization in city management and citizen services continues to rise. As we enter a new digital era, our goal is to involve citizens in the process, combining third-party expertise and innovation to make digital life in Taipei more convenient.

Town Pass is not just an application; it is an open community project. Through open-source, every citizen can participate in the ideation, development, and optimization of the application. This not only enhances citizen engagement and satisfaction but also leverages collective intelligence to continuously improve the application, making it truly serve the people. Furthermore, we hope that various municipalities can widely adopt the open-source framework of Town Pass, integrate it with their existing municipal service systems, and quickly have their own applications to enhance digital governance.

Open source is a key driver of technological progress and social development. Through open-source, Town Pass will become an ever-evolving platform, attracting developers from all backgrounds to contribute. We welcome experts to submit code, report issues, provide suggestions, and even develop new features and creative ideas, working together to perfect Town Pass as we advance toward a smart city.

# Getting Started

We highly recommend to read through our [document](https://tpe-guideline.web.app/en/docs/) for more detail.

Here are some quick setup guide.

## Requirement

- [Flutter](https://docs.flutter.dev/get-started/install) or [FVM](https://fvm.app/documentation/getting-started/installation)
- [XCode](https://developer.apple.com/xcode/) (for iOS)
- [Android SDK](https://developer.android.com/studio/index.html) (for Android, with or without Android Studio)

## Build the Project

1. Get the packages project needed:

   ``` bash
   flutter pub get
   ```

2. Generate additional needed dart code for the project.

   ``` bash
   dart run build_runner build
   ```

3. You are all set now, Run the project from your IDE or the through the command line:

   ``` bash
   flutter run
   ```
