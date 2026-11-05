# 團隊開發流程

> 2026 臺北秋季程式設計節｜11/7–11/8｜初選 demo 2 分鐘、決選 demo 5 分鐘 + Q&A，**禁用簡報**

## 架構

```
TownPass App (Flutter)                       ← 只改：登記服務入口、需要時新增 bridge 訊息
  └─ WebView ── services/web (Vue 3)         ← 主要功能都在這裡
                   │  window.flutterObject   ← docs/bridge.md
                   └─ HTTP ── services/backend (FastAPI) ── 開放資料 (data/SOURCES.md)
```

本機開發時的網址：
| 誰連誰 | 網址 |
|---|---|
| 瀏覽器 → 網頁 | http://localhost:5173 |
| 瀏覽器 → 後端 / API 文件 | http://localhost:8000 / http://localhost:8000/docs |
| Android 模擬器 → 筆電 | 把 `localhost` 換成 `10.0.2.2` |
| 實體手機（同一個 Wi-Fi）→ 筆電 | 換成筆電的區網 IP |

## 每天的指令

```bash
# 網頁（瀏覽器開發，bridge 自動用 mock）
cd services/web && pnpm install && pnpm dev

# 後端
cd services/backend && uv sync && uv run python -m uvicorn townpass_backend.main:app --reload --host 0.0.0.0 --port 8000

# App（模擬器開網頁 dev server）
flutter emulators --launch townpass
flutter pub get && dart run build_runner build --delete-conflicting-outputs
flutter run --dart-define=TEAM_WEB_URL=http://10.0.2.2:5173/
```

> Windows 若出現「應用程式控制原則已封鎖此檔案」：用 `python -m uvicorn`（如上），不要直接執行 `.venv` 裡的 `uvicorn.exe`。

## 分工（每人一個資料夾，避免衝突）

| 角色 | 負責 | 資料夾 |
|---|---|---|
| PM／資料／demo | 拆題目、找資料、寫 SOURCES.md、demo 腳本、主持排練 | `docs/` `data/` |
| Flutter 整合 | 服務入口、bridge 新訊息、打包 APK、準備 demo 手機 | `lib/` `android/` |
| 前端 ×2 | 依「頁面」分工，先用 mock 開發 | `services/web/src/views/<自己的頁面>` |
| 後端 | API、資料處理 | `services/backend/` |

## 題目公布後的前 2 小時：先定合約，不寫程式

1. **頁面流程**：每頁要顯示什麼、按了去哪（白板拍照放 `docs/`）
2. **API 合約**：後端先寫好 FastAPI 的 route + Pydantic model（回傳假資料也行），前端看 `/docs` 開發
3. **Bridge 合約**：需要 App 新能力就加到 `docs/bridge.md`
4. **資料**：確定用哪些開放資料集，填 `data/SOURCES.md`

定好之後大家同時開工，前端用 mock、後端照合約實作，互不等待。

## Git 規則

- `main` 受保護：只能透過 PR 合併，CI（`.github/workflows/ci.yml`）要過
- 分支命名：`feat/web-map`、`feat/be-search`、`fix/app-webview`
- **PR 要小、要快**：最多 2 小時合一次，squash merge；不強制 review（時間太趕），但可以互相 @
- 合併到 `main` 後網頁自動部署到 https://hackathon-taipei.github.io/TownPass/
- 先 `git pull --rebase` 再開 PR，衝突自己解

## 時程（相對於題目公布 T0）

| 時間 | 事情 |
|---|---|
| T0 – T+2h | 定合約（上面四件事） |
| T+2h – 隔天早上 | 開發；每 2–3 小時全員 5 分鐘同步 |
| 初選前 4 小時 | **功能凍結**，只修 bug |
| 初選前 3 小時 | 打包 demo 用 APK、裝到 demo 手機、離線測試 |
| 初選前 2 小時 | 排練 2 分鐘版 ×3、5 分鐘版 ×2、預想 Q&A |

## 規則檢查表（每個 PR 都想一下）

- [ ] 只用開源套件；**不用 Google Maps** 等商用 SDK（地圖用 `OsmMap.vue`）
- [ ] 核心資料是開放資料，並寫進 `data/SOURCES.md`
- [ ] 執行時**不呼叫任何雲端 LLM API**；若用 LLM 必須在手機上跑，並揭露模型名稱／版本／量化／框架／來源，不可用大陸廠牌模型
- [ ] 開發期用 AI 產生的固定內容，不可宣稱是即時 AI 功能
- [ ] 我們寫的程式採 AGPL-3.0（見 README 授權段落）
- [ ] demo 是直接操作作品，沒有投影片
