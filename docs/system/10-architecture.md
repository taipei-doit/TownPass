# 架構總覽

> 第一次看專案從這裡開始。**技術或結構有變動，要在同一個 PR 更新這份文件。**

## 1. 一張圖

```
TownPass App（Flutter）                      lib/、android/：只改服務入口與 bridge
  └─ WebView ── 微服務網頁（Vue）             services/web：功能都在這裡
       │  │
       │  ├─ bridge（window.flutterObject）   使用者名稱、定位、朗讀…（docs/bridge.md）
       │  ├─ HTTP ── 後端（FastAPI）          services/backend：資料與開放資料代理
       │  │            └─ Postgres（Render）／SQLite（本機）
       │  └─ Service Worker                  網站與底圖離線可用
       └─ 裝置端模型（Transformers.js）        addons/model：全部在手機上跑，不呼叫雲端
```

上線位置：網頁 https://hackathon-taipei.github.io/TownPass/ ・ 後端 https://townpass-backend-dmk2.onrender.com

## 2. 技術棧

| 部分 | 技術 | 版本 | 為什麼（ADR） |
|---|---|---|---|
| App | Flutter、flutter_inappwebview | Flutter 3.47.6 | 上游 TownPass（001） |
| 前端 | Vue 3、Vite、TypeScript、Tailwind、Pinia、Vue Router | 3.5／8.3／6.0／4.3／4.1／5.4 | 同官方範本（002） |
| 圖示 | lucide-vue-next | 1.x | |
| 搜尋 | MiniSearch（中文 bigram） | 7.2 | 裝置端、離線（005） |
| 地圖 | Leaflet + OpenStreetMap；離線 protomaps-leaflet + PMTiles | 1.9／5.1 | 禁用商用地圖（012、017） |
| 後端 | FastAPI、SQLModel、httpx、Python | Python 3.12 | （003） |
| 資料庫 | Postgres 17（Render）／SQLite（本機） | | （003） |
| 部署 | GitHub Pages（網頁）、Render（後端）、GitHub Actions（CI） | | （004） |
| 前端測試 | Vitest + happy-dom、vue-tsc | 5.1 | |
| 後端測試 | pytest、ruff | | |
| 環境 | uv、pnpm、Node、JDK、Android SDK（隔離安裝） | `tools/versions.ps1` | （010） |

### AI 與語音

**全部在裝置上執行**；後端不做任何模型推論；不用大陸廠牌模型。AI 問答目前關閉，範本在 `features/_ai`（[09-addons.md](09-addons.md) §2）。

| 用途 | 使用 | 授權 | 大小 | 備註 |
|---|---|---|---|---|
| 向量（檢索、語意選工具） | `intfloat/multilingual-e5-small`（`Xenova/multilingual-e5-small`，q8） | MIT | 118 MB | 在 WASM 上跑，**目前使用** |
| 向量（授權確認後） | `google/embeddinggemma-300m`（`onnx-community/embeddinggemma-300m-ONNX`，q8） | Gemma Terms | 295 MB | `ONLY_OPEN_SOURCE_MODELS = false` 才用；記憶體 4 GB 以上（ADR-020） |
| 生成（語言模型） | **預設不用**：回答是檢索到的原文（ADR-019）。可手動選 `ibm-granite/granite-4.0-350m`（q4f16，334 MB，Apache-2.0）；授權確認後另可選 `google/gemma-3-1b-it`（q4f16，728 MB） | | | 需要 WebGPU |
| 選工具 | 不用語言模型：觸發詞，加上向量語意比對 | | | |
| 推論框架 | Transformers.js 4.3.2 + ONNX Runtime Web | Apache-2.0 | | WebGPU 或 WASM |
| 語音（文字轉語音） | **不用語音模型**：手機內建引擎，透過 `flutter_tts` 4.2.5 呼叫（Android 上通常是 Google TTS 的 `cmn-TW` 語音） | | 引擎自行下載 | WebView 沒有 `speechSynthesis`（016） |
| 語音辨識 | 無 | | | 尚未實作 |

模型實測數字見 [model README](../../services/web/src/addons/model/README.md)。換模型要改 `addons/model/logic.ts`，並更新這張表與 `modelDisclosure`。

## 3. 原始碼結構

```
TownPass/
├─ README.md                 入口：給隊員與 AI
├─ AGENTS.md / CLAUDE.md     給 AI 的規則
├─ .claude/skills/           townpass-start、townpass-ticket、townpass-feature、townpass-ui
├─ .github/                  CI、Pages 部署、工單與 PR 範本
├─ tools/                    start.ps1、setup-windows.ps1、dev-shell.ps1、doctor.ps1、clean.ps1、
│                            versions.ps1、check-arch.mjs、check-docs.mjs
├─ data/SOURCES.md           開放資料與出處
├─ docs/
│  ├─ WORKFLOW.md            完整開發流程
│  ├─ FRAMEWORK.md、DEPLOY.md、bridge.md
│  ├─ system/                本目錄：架構、決策、規格、名詞、各層規則、測試、環境、加購件
│  └─ tickets/               工單範本與範例
├─ lib/、android/、ios/       TownPass App（上游，只做最小修改）
│  └─ lib/util/web_message_handler/   bridge 訊息處理（含朗讀）
└─ services/
   ├─ web/
   │  ├─ public/             sw.js、maps/taipei.pmtiles、examples/
   │  ├─ scripts/            build-basemap.mjs、rag-build.mjs、rag-pdf.py
   │  ├─ tests/              Vitest
   │  ├─ eval/               模型評測：測試集、compare.mjs、llm-compare.js、chat-check.js
   │  └─ src/
   │     ├─ main.ts、App.vue、style.css（官方色票）
   │     ├─ app/router.ts
   │     ├─ framework/       功能與工具合約、自動註冊（feature.ts、tool.ts、registry.ts）
   │     ├─ platform/        資料層轉接：bridge.ts、http.ts、storage.ts、offline.ts
   │     ├─ modules/         共用能力：assistant、search、tools、recent、env
   │     ├─ ui/              共用元件：atoms、molecules、organisms、templates（components.md）
   │     ├─ pages/           框架頁面：HomePage、SourcesPage、UiGalleryPage
   │     ├─ features/        一個資料夾一個功能：example、_template、_ai（底線開頭的不會啟用）
   │     └─ addons/          預設關閉：auth、model、rag、agent（各有 README）
   └─ backend/
      ├─ tests/              pytest
      └─ src/townpass_backend/
         ├─ main.py、db.py、config.py
         ├─ features/        自動發現：examples、opendata、_template（api、service、repo、models、schemas）
         └─ addons/auth/     預設關閉
```

## 4. 邏輯層介面一覽

**用既有的，不要重寫。** 其他程式只能從這些入口使用（CI 檢查）。

### 前端共用模組（永遠可用）
| 入口 | 介面 | 功能 |
|---|---|---|
| `@/framework` | `defineFeature`、`featureRoute`、`defineTool`、`features`、`getFeature`、`featureEntry` | 註冊功能與工具 |
| `@/modules/assistant` | `useAssistant()`、`featureEntryRoute(id)` | 首頁對話框：問→答＋地圖／圖片／卡片／建議 |
| `@/modules/tools` | `listTools()`、`routeByRules(q)`、`runTool(name, args)`、`validateToolArgs(tool, args)` | 對話框工具；內建 `show_map`、`show_image` |
| `@/modules/search` | `buildSearchIndex()`、`search(q, limit)`、`searchDocuments()`、`searchReady` | 裝置端搜尋 |
| `@/modules/recent` | `recent`、`addRecent()`、`clearRecent()` | 近期使用 |
| `@/modules/env` | `inApp`、`appUserName`、`loadAppUserName()`、`openMap()`、`shareLink()`、`speak()`、`stopSpeaking()`、`canSpeak`、`voiceStatus()`、`enableOfflineUse()` | 平台能力 |

### 前端加購件（要先載入，見 [09-addons.md](09-addons.md)）
| 入口 | 介面 | 功能 |
|---|---|---|
| `@/addons/auth` | `requireUser()`、`ensureSession()`、`user`、`profile`、`signOut()` | 登入 |
| `@/addons/model` | `prepareEmbedding()`、`prepareLanguageModel()`、`embedQuery()`、`embedPassages()`、`complete()`、`chooseEmbedding()`、`activeEmbedding()`、`chooseGenerator()`、`inspectDevice()`、`useModel()`、`modelDisclosure()` | 裝置端模型 |
| `@/addons/rag` | `useRag()`（`prepare`、`ask`、`bestScore`）、`bestScore()`、`collectionItems()`、`isGrounded()`、`RagLabPage` | 檢索與回答 |
| `@/addons/agent` | `createAgent()`、`routeByMeaning()`、`pickBySimilarity()`、`chooseTool()`、`parseToolCall()`、`answerToResult()` | 模型接進對話框 |

### 後端
| 入口 | 介面 | 功能 |
|---|---|---|
| `townpass_backend.features.opendata` | `taipei_dataset()`、`UpstreamError` | 臺北資料大平台（有快取） |
| `townpass_backend.addons.auth` | `CurrentUser`、`AppUser`、`router` | 登入（要先載入） |
| `townpass_backend.db` | `SessionDep`、`sync_schema()` | 資料庫、動態欄位 |

### 端點
`GET /health`、`GET /examples/places`、`GET /examples/places/{id}`、`GET /opendata/taipei/{resource_id}`；完整合約看後端 `/docs`。

### App ↔ 網頁訊息
見 [bridge.md](../bridge.md)。

## 5. 新增東西放哪裡

| 要加 | 放哪裡 | 說明 |
|---|---|---|
| 新功能 | `web/src/features/<id>/`、`backend/.../features/<name>/` | 複製 `_template`；[FRAMEWORK.md](../FRAMEWORK.md) |
| 對話框能做的事 | 功能的 `tools` | [09-addons.md](09-addons.md) §3 |
| 地圖標點、圖片 | 資料項目加 `geo`、`images` | 同上，不用寫程式 |
| 多個功能共用的能力 | `web/src/modules/<x>/` | 先開工單，並列為偏離 |
| 共用元件 | `web/src/ui/`（A／M／O／T） | [04-presentation-layer.md](04-presentation-layer.md) |
| App 的新能力 | `lib/util/web_message_handler/` | [bridge.md](../bridge.md) |
| 開放資料 | 後端資料層 + 功能的 `sources` + `data/SOURCES.md` | [06-data-layer.md](06-data-layer.md) |
