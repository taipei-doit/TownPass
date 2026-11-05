# 決策紀錄（ADR）

格式：背景 → 決策 → 後果。狀態：✅ 採用／🔁 已被取代。新增決策時加在最後，編號遞增，**不要改寫舊的**（被推翻就新增一則並把舊的標 🔁）。

---

### ADR-001 微服務 = WebView 裡的網頁 ✅
- **背景**：競賽要求「以台北通為基礎開發城市通微服務」。TownPass App 的服務是用 WebView 開網頁，透過 `flutterObject` 互傳訊息。
- **決策**：功能做在 `services/web`；App 只改「服務入口」與必要的 bridge 訊息。
- **後果**：Flutter 只需 1 人；前端可在一般瀏覽器開發（bridge 自動用 mock）；賽後併入官方較容易。

### ADR-002 前端：Vue 3 + Vite + TypeScript + Tailwind ✅
- **背景**：官方微服務範本 TownPass-Services 用 Vue 3 + Tailwind。
- **決策**：同技術棧；色票、字體、陰影採官方 tokens（`src/style.css`）。
- **後果**：視覺一致、評審「落地可能性」加分；TownPass-Services 沒有授權檔 → 元件**依 tokens 重寫**，不複製其程式碼。

### ADR-003 後端：FastAPI + SQLModel，Postgres（Render）／SQLite（本機） ✅
- **決策**：`DATABASE_URL` 決定資料庫；沒設就用 SQLite，隊友不必裝資料庫或 Docker。CI 兩種都跑。
- **後果**：SQL 方言差異由 SQLAlchemy 處理；避免使用只在單一資料庫有的語法。

### ADR-004 部署：網頁 GitHub Pages、後端 Render（Blueprint） ✅
- **背景**：GCP/Firebase 只有一人能部署，且 Firebase 屬商用封閉服務，有違反「不得使用會產生後續費用之商用模組」的風險；Vercel Hobby 只允許擁有者的 commit 部署。
- **決策**：合併到 `main` 自動部署；Render 以 `render.yaml` 定義，CI 通過才部署（`checksPass`）。
- **後果**：免費方案會休眠（demo 前先打 `/health`）、免費 Postgres 30 天到期。

### ADR-005 對話框入口用「裝置端搜尋」，不用 LLM／RAG ✅
- **背景**：規則規定執行時的 LLM 必須在裝置上跑、可能被斷網驗證；資訊多為結構化開放資料。
- **決策**：MiniSearch + 中文 bigram 斷詞，在裝置上比對各功能提供的 `searchItems`；回覆是固定模板＋結果卡片。
- **後果**：離線可用、沒有規則風險、結果可預期。若要加語意搜尋／生成，另立 ADR（只能裝置端、不可用大陸廠牌模型、需揭露模型資訊）。

### ADR-006 三層架構 + 模組介面 + `__` 私有規則 ✅
- **決策**：顯示層 → 邏輯層 → 資料層，只能往下呼叫。每個模組／功能只透過公開介面（前端 `index.ts`／`logic/index.ts`，後端套件 `__init__.py`）被使用；介面內部的工具函數以 `__` 開頭、不匯出、不被別人呼叫。由 `tools/check-arch.mjs` 在 CI 強制。
- **後果**：多人（與多個 AI）平行開發時不會互相依賴內部細節；換資料來源只改資料層。

### ADR-007 元件編號與組合 ✅
- **決策**：共用元件依 Atomic Design 分級並編號（A/M/O/T + 兩位數），頁面 P##，功能專屬元件 `<功能代碼>-P##`（頁面）／`-C##`（元件）。每個元件一個檔案，畫面用組合完成。
- **後果**：工單、討論、AI 指令都能用編號精準指到元件；目錄由 `--catalog` 自動產生。

### ADR-008 登入：以 TownPass 身分換取本服務 token（示範等級） ✅
- **背景**：App 透過 bridge 提供帳號物件（含身分證字號、電話、地址等敏感資料）。
- **決策**：前端只取 `id` 與 `realName`，呼叫 `/auth/login` 換取 HMAC 簽章 token（7 天）；後端 `LoginRequest` 設 `extra="forbid"`，多送任何欄位就 422。受保護 API 用 `CurrentUser` 依賴。
- **後果／已知限制**：`townpass_id` 未經密碼學驗證，**任何人可冒用他人 id**，只適合比賽展示。上線需改用台北通官方 OAuth／簽章 ID token（另立 ADR）。`SECRET_KEY` 由 Render 產生，不得寫進程式碼。

### ADR-009 資料表動態、只增不減 ✅
- **決策**：每個模組在自己的 `models.py` 宣告**它需要的欄位**；啟動時 `sync_schema()` 建立缺少的表、補上缺少的欄位與索引。不刪、不改名、不改型別；新欄位一律可為 NULL，純量預設值會成為資料庫 DEFAULT。
- **後果**：比賽中加欄位不必寫 migration、不會弄丟資料；改名＝新增欄位。賽後若要正式維運再導入 Alembic。

### ADR-010 隔離的開發環境 ✅
- **背景**：隊友電腦可能已有不同版本的 Node／Java／Flutter／Android SDK。
- **決策**：所有工具裝在 `%USERPROFILE%\.townpass-dev`（可用 `TOWNPASS_TOOLS` 改），版本鎖在 `tools/versions.ps1`；`tools/dev-shell.ps1` 只對目前終端機設定 PATH 與環境變數。不改系統 PATH、不需管理員、不需 Android Studio。
- **刻意不放 `AppData`**：在封裝式（MSIX）應用程式裡執行時（例如 Claude 桌面版的 AI 代為安裝），Windows 會把新建在 `AppData` 的檔案悄悄轉存到該應用程式的私有資料夾，你自己的終端機看不到；uv 的連結也會因此壞掉。實測發生過，故改到使用者目錄。
- **後果**：與既有安裝互不影響；刪資料夾即移除。缺點：約 10 GB；Flutter 的 `flutter config` 設定仍是使用者全域（我們不呼叫它）。

### ADR-011 授權：自寫部分 AGPL-3.0，上游維持 GPL-3.0 ✅
- **決策**：依競賽規則，隊伍成果以 AGPL-3.0 授權並附指定聲明（`LICENSE-AGPL`、README）；上游 TownPass 程式碼維持 GPL-3.0。

### ADR-012 地圖：Leaflet + OpenStreetMap ✅
- **背景**：規則明文禁止 Google Maps 等商用地圖。
- **決策**：`OsmMap`（O02）。手機上單指拖曳捲動頁面、雙指縮放地圖，避免使用者被地圖「卡住」。

### ADR-013 平行開發以「工單」派發 ✅
- **決策**：工作以 GitHub Issue 工單（`.github/ISSUE_TEMPLATE/ticket.yml`）派發，內含提示詞、必讀、要做的事、驗收、回報與偏離方式；執行者（人或 AI）照 `townpass-ticket` skill 完成並以 PR 回報。
- **後果**：任何人的 AI（本機或雲端）拿到工單就能獨立作業，回報格式一致、偏離可追蹤。
