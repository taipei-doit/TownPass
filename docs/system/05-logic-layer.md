# 邏輯層

> 原則：**模組提供功能介面；介面內用到的工具函數以 `__` 開頭、鎖在內部、不給別人用。**

## 1. 位置

| 地方 | 前端 | 後端 |
|---|---|---|
| 共用模組 | `web/src/modules/<x>/logic.ts`（介面由 `index.ts` 匯出） | `features/<x>/service.py`（介面由套件 `__init__.py` 匯出） |
| 功能 | `web/src/features/<id>/logic/index.ts`（可再拆檔，從 index 匯出） | `features/<name>/service.py` |

## 2. 公開介面 vs 私有函數

```ts
// features/parks/logic/index.ts
export function useParkList() { ... }          // 公開：頁面會用
export async function parkSearchItems() { ... } // 公開：index.ts 會用

function __distanceKm(a: LatLng, b: LatLng) { ... } // 私有：只在這個檔案用
```
```python
# features/parks/service.py
def nearby_parks(session, lat, lng) -> list[ParkOut]: ...   # 公開
def __distance_km(a, b) -> float: ...                        # 私有
```

- `__` 開頭的名稱**不匯出**（前端不加 `export`、後端不放進 `__all__`），**不被其他檔案 import 或呼叫**（W7／B6 自動檢查）。
- 後端注意：class 內部會把 `__name` 改名（name mangling），所以私有函數寫在**模組層級**，不要寫成 class 方法；`models.py` 的預設值用 lambda。
- 介面要穩定：改公開函數的參數或回傳型別＝改合約，要在 PR 說明並更新呼叫端。

## 3. 前端邏輯層寫法

| 種類 | 形式 | 例 |
|---|---|---|
| 頁面用的狀態＋動作 | composable `useXxx()` 回傳 refs 與函式 | `usePlaceList()`、`usePlaceDetail(id)`、`useAssistant()` |
| 給框架的資料 | async 函式 | `placeSearchItems()` |
| 共用狀態 | 模組層級 `ref`（單例） | `recent`、`appUserName` |
| 平台能力 | 包成有意義的動作 | `openMap()`、`shareLink()`（modules/env） |

- 可以用 `vue` 的反應式 API 與 `vue-router`；**不可以** import `.vue`、`@/ui`、`@/pages`（W2）。
- 呼叫資料層取得資料；**不直接** `fetch`、不碰 `localStorage`、不呼叫 bridge。
- 錯誤處理在這層：把資料層的例外轉成使用者看得懂的訊息（例：`requireUser()` 拋出「需要登入台北通…」）。
- 需要登入的動作先 `await requireUser()`（`@/addons/auth`，要先依 [09-addons.md](09-addons.md) 啟用）。

## 4. 後端邏輯層寫法

- `service.py` 的公開函數接收 `session`（以及 `user_id` 等），回傳 `schemas.py` 的型別，不回傳 ORM 物件給 api。
- 商業規則都在這層（冪等、權限、驗證跨欄位條件）；`repo.py` 只做查詢。
- 自訂例外（例：`NotFound`）由 `api.py` 轉成 HTTP 狀態碼；service 不 import FastAPI 的 HTTP 類別。
- 只能「自己的資料」：查詢一律帶 `user_id` 條件，避免越權（測試見 07-testing.md §3）。
- 用到別的功能 → 只 import 它的套件根：`from townpass_backend.features.opendata import taipei_dataset`（B5）。

## 5. 現有模組介面

| 模組 | 介面 | 說明 |
|---|---|---|
| `@/modules/assistant` | `useAssistant()`、`featureEntryRoute(id)` | 對話框：問→答＋地圖／圖片／結果卡片／建議 |
| `@/modules/tools` | `listTools()`、`routeByRules(q)`、`runTool(name, args)`、`validateToolArgs()` | 對話框工具；內建 `show_map`、`show_image` |
| `@/modules/search` | `buildSearchIndex()`、`search(q, limit)`、`searchDocuments()`、`searchReady` | 裝置端搜尋 |
| `@/modules/recent` | `recent`、`addRecent()`、`clearRecent()` | 近期使用 |
| `@/modules/env` | `inApp`、`appUserName`、`openMap()`、`shareLink()`、`speak()`、`stopSpeaking()`、`canSpeak`、`voiceStatus()`、`enableOfflineUse()` | 平台能力 |
| `features.opendata` | `taipei_dataset()`、`UpstreamError` | 臺北資料大平台 |

全部介面（含加購件與後端）見 [10-architecture.md](10-architecture.md) §4；加購件的載入方式見 [09-addons.md](09-addons.md)。
