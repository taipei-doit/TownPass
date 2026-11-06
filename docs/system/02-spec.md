# 系統規格（Spec）

版本 0.3｜範圍：題目公布前的**框架**。題目公布後，各功能規格寫在自己的工單裡，並引用本文件。

## 1. 目標與範圍
- 提供一個「對話框單一入口」的城市通微服務框架，比賽當天以**新增功能資料夾**的方式疊加功能。
- 不在範圍：題目相關的業務功能（當天決定）、正式上線的身分驗證（見 ADR-008）。

## 2. 使用者情境（框架層）
| 編號 | 情境 | 預期結果 |
|---|---|---|
| S1 | 從 App「服務」頁點「城市任務」 | 開啟首頁（P01），顯示問候、近期使用、服務卡片、快捷選項、輸入框 |
| S2 | 在輸入框輸入問題送出 | 顯示使用者泡泡與回覆；有結果時列出結果卡片（最多 8 筆，最相關在前） |
| S3 | 問題沒有結果 | 回覆「找不到」並以 chips 建議所有功能 |
| S4 | 點結果卡片或快捷選項 | 進入對應功能頁；該頁加入「近期使用」 |
| S5 | 啟用 auth 加購件的功能，執行需要登入的動作 | 已登入→成功；未取得身分→顯示「需要登入台北通」 |
| S6 | 斷網或後端休眠 | 首頁、搜尋、範例資料仍可用（mock 後備）；不出現白畫面或未處理錯誤 |
| S7 | 開啟「資料來源」頁 | 列出所有功能宣告的開放資料與授權 |
| S8 | 問「把信義區的施工標在地圖上」 | 對話框內出現地圖與標點，過期的不標 |
| S9 | 問「公文附圖給我看」 | 對話框內出現圖片、圖說與來源；載入失敗時顯示替代文字 |
| S10 | 連網開過一次後斷網再開 | 網站可開啟；地圖改用隨附底圖 |

## 3. 功能合約（前端 Feature）
每個功能是 `services/web/src/features/<id>/`，`index.ts` 以 `defineFeature()` 宣告：

| 欄位 | 必填 | 規格 |
|---|---|---|
| `id` | ✔ | 等於資料夾名稱，小寫英數與 `-` |
| `code` | ✔ | 2–4 個大寫英文字母，全專案唯一，為元件編號前綴 |
| `title` / `description` / `icon` | ✔ | 首頁卡片內容；icon 用 lucide |
| `routes` | ✔ | 相對路徑；實際網址 `/#/f/<id>/<path>`；route name 自動加 `<id>.` 前綴；第一個是入口 |
| `keywords` |  | 讓對話框推薦此功能的詞 |
| `quickActions` |  | 首頁快捷 chips（全部功能合計最多顯示 8 個） |
| `searchItems()` |  | 回傳 `FeatureItem[]`；啟動時呼叫一次；失敗不影響其他功能。項目可帶 `geo`、`images`、`validFrom`、`validTo`、`source` |
| `tools` |  | 對話框可呼叫的工具（`defineTool`），見 [09-addons.md](09-addons.md) §3 |
| `assistant` |  | 對話框的進階回答提供者（通常是 `createAgent()`）；全專案只用第一個 |
| `sources` |  | 使用的開放資料（**用到就必填**） |
| `order` / `hidden` |  | 排序／暫時隱藏 |

資料夾結構固定：`index.ts`、`ui/*.vue`、`logic/*.ts`、`data/*.ts`（W9 檢查）。

## 4. 架構規則（CI 強制，`tools/check-arch.mjs`）
| 規則 | 內容 |
|---|---|
| W1 | 顯示層不得 import 資料層（`platform/`、`modules/x/data.ts`、`features/x/data/`） |
| W2 | 邏輯層不得 import 顯示層（`.vue`、`ui/`、`pages/`） |
| W3 | 資料層不得 import 邏輯層或顯示層 |
| W4 | 模組只能經由 `@/modules/<x>`（index）使用 |
| W5 | 功能彼此獨立，其他程式不得 import 功能內部 |
| W6 | `modules/x/index.ts` 只能從 `./logic` 重新匯出 |
| W7 | `__` 開頭名稱不得匯出、不得被 import |
| W8 | 每個元件有唯一、符合位置格式的 `@component` 編號 |
| W9 | 模組／功能／加購件資料夾只能有規定的檔案 |
| W10 | 核心不得 import 加購件；其他程式只能經由 `@/addons/<x>` 使用；加購件不得 import 功能 |
| B1–B4 | 後端：`api/deps` ✗→ `repo`；`service` ✗→ `api/deps`；`repo` ✗→ `service/api`；`models` ✗→ 其他層 |
| B5 | 跨功能只能用套件根（`townpass_backend.features.<x>`） |
| B6 | 後端 `__` 名稱不得被其他模組 import 或呼叫 |
| B7 | 後端核心不得 import 加購件；其他程式只能用套件根 |

## 5. 後端 API 合約
- 每個功能是 `features/<name>/` 套件：`__init__.py`（公開介面：`router`、可選 `seed`、給別人用的函式）、`api.py`、`deps.py`（可選）、`service.py`、`repo.py`、`models.py`、`schemas.py`。
- 路徑前綴＝功能名（`/examples/...`）；資料表名以功能名開頭（`example_place`）。
- 回應一律用 `schemas.py` 的 Pydantic 型別；錯誤用 HTTP 狀態碼＋`{"detail": "..."}`：

| 狀態 | 何時 |
|---|---|
| 200/204 | 成功（無內容用 204） |
| 401 | 未登入、token 無效／過期／被竄改（含 `WWW-Authenticate: Bearer`） |
| 403 | 已登入但無權限（目前以「只查自己的資料」避免需要 403） |
| 404 | 資源不存在 |
| 422 | 輸入格式錯誤，或送了不允許的欄位（`extra="forbid"`） |
| 502 | 上游開放資料 API 失敗 |

- 現有端點：`GET /health`、`GET /examples/places[?category]`、`GET /examples/places/{id}`、`GET /opendata/taipei/{resource_id}`；啟用 auth 加購件才有 `POST /auth/login`、`GET /auth/me`。完整合約：後端的 `/docs`。

## 6. App ↔ 網頁訊息
見 [../bridge.md](../bridge.md)。網頁只經由 `platform/bridge.ts`（資料層）與 `modules/env`（邏輯層）使用。

## 7. 非功能需求
| 項目 | 要求 |
|---|---|
| 離線／後端不可用 | 連網開過一次後，首頁、搜尋、範例功能、地圖標點與隨附底圖可用；受保護動作給出明確訊息 |
| 隱私 | 只取 TownPass `id`、`realName`；不得儲存或傳送身分證字號、電話、地址、生日 |
| AI 規則 | 執行時不得呼叫雲端 LLM；後端不得做 LLM 推論；模型參數不得決定座標或圖片網址 |
| 第三方 | 只用開源套件；禁止商用地圖等 |
| 資料來源 | 核心資料為開放資料並標示出處（`sources`、`SourceNote`、資料來源頁、`data/SOURCES.md`） |
| 行動裝置 | 寬 375px 正常顯示；底部按鈕不壓到手勢列；地圖不攔截頁面捲動 |
| 無障礙 | 可點元素有文字或 `aria-label`；觸控目標高度 ≥ 36px（主要按鈕 44px） |
| 效能 | 首頁可互動 < 2 秒（模擬器、本機）；搜尋在輸入送出後立即回應 |

## 8. 驗收標準（框架）
- [ ] CI 全綠：web build＋型別檢查、web 單元測試、backend ruff＋pytest（SQLite 與 Postgres）、arch 檢查
- [ ] 模擬器走過 S1–S7（手動清單見 07-testing.md §5）
- [ ] 新功能從 `_template` 複製後，不改任何共用檔就出現在首頁與搜尋
