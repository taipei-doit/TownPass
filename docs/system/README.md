# 系統文件

> 城市通微服務（2026 臺北秋季程式設計節）的架構、規格與開發準則。
> 人與 AI 都以這裡為準；程式與文件不一致時，**先改文件再改程式**（或同一個 PR 一起改）。

| 文件 | 內容 | 什麼時候讀 |
|---|---|---|
| [01-decisions.md](01-decisions.md) | 決策紀錄（ADR）：為什麼這樣設計 | 想改架構、選技術之前 |
| [02-spec.md](02-spec.md) | 系統規格：功能、介面合約、非功能需求、驗收標準 | 開發任何功能之前 |
| [03-glossary.md](03-glossary.md) | 字詞表：統一用語 | 寫程式、文件、工單時 |
| [04-presentation-layer.md](04-presentation-layer.md) | 顯示層：元件分級、編號、組合規則、設計 tokens | 做畫面時 |
| [05-logic-layer.md](05-logic-layer.md) | 邏輯層：模組介面、`__` 私有規則、composable | 寫功能行為時 |
| [06-data-layer.md](06-data-layer.md) | 資料層：API、mock 後備、資料表、動態欄位擴充 | 接資料、加欄位時 |
| [07-testing.md](07-testing.md) | 測試準則：層級、登入驗證清單、手動驗收 | 交 PR 之前 |
| [08-environment.md](08-environment.md) | 隔離開發環境：安裝、啟用、排錯 | 第一次開發、環境出問題時 |
| [components.md](components.md) | 元件目錄（自動產生） | 找現成元件時 |

其他：[團隊流程](../WORKFLOW.md)・[部署](../DEPLOY.md)・[App ↔ 網頁訊息](../bridge.md)・[工單](../tickets/README.md)・[資料來源](../../data/SOURCES.md)

## 一張圖看懂

```
TownPass App (Flutter) ── WebView ──┐
                                    ▼
 services/web (Vue)                                            services/backend (FastAPI)
 ┌──────────────────────────────────────────────┐              ┌──────────────────────────────────┐
 │ 顯示層  ui/ (A M O T)  pages/ (P)  features/x/ui (XX-P/C)   │  HTTP  │ 顯示層  features/x/api.py, deps.py │
 │    ↓ 只呼叫                                    │  ─────▶ │    ↓                              │
 │ 邏輯層  modules/x/logic.ts  features/x/logic/  │              │ 邏輯層  features/x/service.py      │
 │    ↓                                          │              │    ↓                              │
 │ 資料層  modules/x/data.ts  features/x/data/   │              │ 資料層  features/x/repo.py         │
 │         platform/ (http, bridge, storage)     │              │         models.py → Postgres/SQLite │
 └──────────────────────────────────────────────┘              └──────────────────────────────────┘
 framework/ = 功能註冊（自動發現 features/*）                    features/__init__.py = 自動發現 features/*
```

規則由 `node tools/check-arch.mjs` 在 CI 自動檢查。
