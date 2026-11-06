# 字詞表

程式、文件、工單、PR、跟 AI 溝通時都用左欄的詞。同一個東西不要換說法。

| 用語 | 英文／程式名稱 | 定義 |
|---|---|---|
| 城市通 / 台北通 / TownPass | TownPass | 臺北市政府的市民 App（開源）。本專案 fork 自 `taipei-doit/TownPass` |
| 微服務 | microservice | 在 TownPass App 的 WebView 裡執行的網頁服務；本專案的作品 |
| 服務入口 | `MyServiceItem` | App「服務」頁上的一個圖示，點了開啟微服務網址 |
| 橋接 / bridge | `flutterObject`、`platform/bridge.ts` | App 與網頁互傳 `{name, data}` 訊息的通道 |
| 功能 | feature, `defineFeature` | `web/src/features/<id>/` 一個資料夾＝一個可疊加的功能 |
| 功能代碼 | `code` | 功能的 2–4 字母代碼，元件編號前綴（例：`EX`） |
| 模組 | module | 跨功能共用的能力（`web/src/modules/<x>/`：search、recent、tools、assistant、env）；後端的 feature 套件也稱模組 |
| 加購件 | add-on | 預先寫好、預設關閉的模組（`addons/<x>/`：auth、model、rag、agent），依 `09-addons.md` 載入 |
| 工具 | tool, `defineTool` | 對話框能執行的動作，回傳文字與區塊 |
| 區塊 | block | 畫在對話裡的內容：地圖 `map`、圖片 `image`、原文 `quote` |
| 觸發詞 | `triggers` | 工具的關鍵詞規則，符合就呼叫，不需要模型 |
| 語意路由 | semantic routing | 比對問題與工具 `examples` 的向量來選工具，只需要向量模型 |
| 集合 | collection | `pnpm rag:build` 產生的文件檔（`public/rag/<名稱>.json`），含文字與預先算好的向量 |
| 原文 | original text | 來源文件的逐字內容，由程式直接顯示，不經語言模型 |
| 公開介面 | public interface | 模組對外唯一入口：前端 `index.ts`／`logic/index.ts`，後端套件 `__init__.py` |
| 私有函數 | `__name` | 介面內部用的工具函數，以 `__` 開頭，不匯出、不給別人用 |
| 顯示層 | presentation | 畫面：`ui/`、`pages/`、`features/x/ui/`；後端的 `api.py`、`deps.py` |
| 邏輯層 | logic | 行為與規則：`modules/x/logic.ts`、`features/x/logic/`；後端 `service.py` |
| 資料層 | data | 資料存取：`platform/`、`modules/x/data.ts`、`features/x/data/`；後端 `repo.py`、`models.py` |
| 框架 | framework | 功能註冊與自動發現（`web/src/framework/`），不屬於任何一層 |
| 元件編號 | component ID | 元件唯一代號：A##／M##／O##／T##／P##／`XX-P##`／`XX-C##` |
| 原子／分子／有機體／模板 | atom / molecule / organism / template | 共用元件的四個等級（A／M／O／T） |
| 頁面 | page | 一個路由對應的畫面（P## 或 `XX-P##`） |
| 對話框入口 | assistant / chat box | 首頁的單一入口：輸入→裝置端搜尋→回覆＋結果卡片 |
| 搜尋項目 | `FeatureItem` | 功能提供給對話框搜尋的一筆資料（標題、副標、標籤、關鍵字、連結） |
| 快捷選項 | quick action | 首頁輸入框上方的 chips |
| 近期使用 | recent | 裝置上記錄的最近造訪頁面（最多 8 筆） |
| 注意事項 | notices | 詳細頁的可展開提醒（O03 NoticeList） |
| 資料來源 | sources | 功能使用的開放資料清單；規則要求標示 |
| 模擬資料 | mock | 後端不可用時的本地資料；必須明顯標示「範例」 |
| 種子資料 | seed | 後端啟動時寫入的初始資料（`seed(session)`，需可重複執行） |
| 動態欄位擴充 | schema sync | 啟動時自動補上模型新增的表／欄位／索引，只增不減 |
| 工作階段 / 登入 | session | 以 TownPass 身分向後端換取 token 的流程（auth 加購件） |
| 測試帳號 | test user | 測試用假身分（`test-user-a`…），不得用真實帳號 |
| 工單 | ticket | 派發給一個人或 AI 的工作單位（GitHub Issue），含提示詞、必讀、驗收、回報方式 |
| 偏離 | deviation | 執行工單時與工單內容不同的決定，必須在 PR 回報 |
| 隔離環境 | dev shell | `tools/dev-shell.ps1` 啟用的、只影響目前終端機的工具鏈 |
| 設計 tokens | design tokens | 官方色票、字體、陰影（`web/src/style.css`） |
