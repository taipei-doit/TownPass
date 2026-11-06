# 資料層

> 原則：**模組只宣告自己需要的欄位；不存在就新增，資料庫動態擴充、只增不減。**

## 1. 前端資料層

| 位置 | 內容 |
|---|---|
| `platform/http.ts` | `api<T>(path, init)`：呼叫後端，自動帶 token；錯誤丟 `HttpError(status)` |
| `platform/bridge.ts` | `request(name, data)`、`send(name, data)`：與 App 溝通；瀏覽器自動用 mock |
| `platform/storage.ts` | `readJson`、`writeJson`：裝置端儲存，永遠不丟例外 |
| `platform/offline.ts` | 註冊 Service Worker（`public/sw.js`），讓網站與隨附底圖斷網可用 |
| `modules/x/data.ts`、`features/x/data/` | 各模組／功能的資料存取 |

**規則**
- 只有資料層能用 `fetch`、`localStorage`、bridge。
- **後端失敗要有後備**：讀取 → 回傳 mock；寫入 → 存裝置端（見 `features/example/data`）。但 **401/403 不可吞掉**，要往上丟讓邏輯層處理登入。
- Mock 必須明顯標示（名稱含「範例」），且形狀與後端回應完全一致（同一個 TS 型別）。
- 型別定義在資料層並由邏輯層轉出（`export type { Place }`），顯示層從邏輯層拿型別。
- 呼叫 bridge 只取需要的欄位（auth 加購件只取 `id`、`realName`）。

## 2. 後端資料層

| 檔案 | 內容 |
|---|---|
| `models.py` | SQLModel 資料表：**只放這個模組需要的欄位** |
| `repo.py` | 查詢與寫入（`select`、`add`、`commit`），不含商業規則 |
| `db.py`（共用） | `engine`、`SessionDep`、`sync_schema()` |

### 動態欄位擴充（`sync_schema`，ADR-009）
啟動時自動：
1. 建立不存在的資料表
2. 對已存在的表，**補上模型有但資料庫沒有的欄位**（可為 NULL；純量預設值 → 資料庫 DEFAULT，舊資料也會有值）
3. 建立缺少的索引

**不會**：刪欄位、改名、改型別、加 NOT NULL、加主鍵。因此：
| 想做的事 | 做法 |
|---|---|
| 加欄位 | 直接在 `models.py` 加，重開後端 |
| 改欄位名 | 加新欄位，邏輯層改用新欄位（舊欄位留著） |
| 改型別 | 加新欄位（例：`price_v2`） |
| 需要必填 | 模型給預設值；必填檢查放在 `schemas.py` |
| 別的模組也要這張表的資料 | 呼叫對方的公開介面，不直接查對方的表 |

### 命名
- 資料表：`<功能名>_<名詞>`（`example_place`）；auth 加購件的使用者表 `app_user`
- 外鍵：`<表>_id`，指向 `app_user.id` 時用 `user_id`
- JSON 欄位：`Field(sa_column=Column(JSON))`（SQLite 與 Postgres 都可用）

### 種子資料 `seed(session)`
- 在功能套件 `__init__.py` 匯出；啟動時執行；**必須冪等**（先檢查再寫入）
- 單一功能的 seed 失敗只記錄錯誤，不影響其他功能

## 3. 開放資料
- 地點要能標在對話框地圖：項目帶 `geo`（WGS84 經緯度）；開放資料若是 TWD97 或只有地址，先在匯入時轉好，不要在手機上呼叫商用地理編碼
- 上游 API 只在資料層呼叫（例：`features/opendata/repo.py`，有 10 分鐘快取）
- 每個資料集同時登記在：功能的 `sources`、`data/SOURCES.md`、頁面上的 `SourceNote`
- 臺北資料大平台 API：`https://data.taipei/api/v1/dataset/<resource_id>?scope=resourceAquire`

## 4. 個資與安全
- 不存：身分證字號、電話、地址、生日、email（`LoginRequest` 設 `extra="forbid"`，送了就 422）
- 不記錄 token；`SECRET_KEY` 只從環境變數讀
- 每個查詢個人資料的 repo 函數都要有 `user_id` 參數
