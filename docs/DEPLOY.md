# 部署

目前後端：https://townpass-backend-dmk2.onrender.com（倉庫變數 `API_BASE` 已設定）

| 部分 | 平台 | 何時更新 |
|---|---|---|
| 網頁 `services/web` | GitHub Pages：https://hackathon-taipei.github.io/TownPass/ | 合併到 `main` 自動部署 |
| 後端 `services/backend` | Render（免費 web service，Docker） | 合併到 `main` 且 CI 通過後自動部署 |
| 資料庫 | Render Postgres 17（免費） | — |

## 第一次設定 Render（只要做一次，由組織管理員操作）

1. 用 GitHub 登入 https://dashboard.render.com
2. **New → Blueprint** → 連接 GitHub，安裝 Render GitHub App 時選 **hackathon-taipei** 組織、允許 `TownPass` 倉庫
3. 選 `TownPass` 倉庫，Render 會讀取根目錄的 [`render.yaml`](../render.yaml)，建立 `townpass-backend` 與 `townpass-db` → **Apply**
4. 等部署完成，複製服務網址（像 `https://townpass-backend-xxxx.onrender.com`），打開 `/health` 應看到 `{"status":"ok","db":"postgresql"}`
5. 把網址設成 GitHub 倉庫變數，讓網頁連到它：
   ```bash
   gh variable set API_BASE -R hackathon-taipei/TownPass --body "https://townpass-backend-xxxx.onrender.com"
   gh workflow run pages.yml -R hackathon-taipei/TownPass
   ```
6. （建議）在 Render 的 workspace 設定把隊友加為成員，讓大家都能看 log。

設定完之後，**任何人合併 PR 都會觸發部署**，不需要特定人操作。

## 必須知道的限制

- **閒置 15 分鐘會休眠**，下一個請求要等約 1 分鐘喚醒。**Demo 前 5 分鐘打開一次 `/health`**，評審操作時才不會卡住。
- **免費 Postgres 建立 30 天後過期**（夠比賽用；得獎後若需要保留，升級或匯出資料）。
- 硬碟不保留檔案：上傳的檔案不要存在容器裡，存資料庫或外部儲存。
- 這些都來自 Render 官方說明：https://render.com/docs/free

## 本機開發（不需要 Postgres）

沒設 `DATABASE_URL` 時後端自動用 `services/backend/dev.db`（SQLite），隊友不用裝任何資料庫。
想在本機連 Postgres：`DATABASE_URL=postgres://user:pass@localhost:5432/db`。
CI 會用真的 Postgres 17 跑一次測試，確保跟 Render 一致。

## Demo 備案（現場網路掛掉時）

筆電跑後端與網頁，App 用 debug 版連筆電：
```bash
cd services/backend && uv run python -m uvicorn townpass_backend.main:app --host 0.0.0.0 --port 8000
cd services/web && pnpm dev
adb reverse tcp:5173 tcp:5173 && adb reverse tcp:8000 tcp:8000
flutter run --dart-define=TEAM_WEB_URL=http://localhost:5173/
```
