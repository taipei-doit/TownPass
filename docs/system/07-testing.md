# 測試準則

> 每個 PR 都要附「怎麼驗證的」。能自動測的就寫測試；畫面在模擬器上走過並截圖。

## 1. 層級與工具

| 層級 | 測什麼 | 工具／位置 | 指令 |
|---|---|---|---|
| 架構 | 分層、`__` 私有、元件編號 | `tools/check-arch.mjs` | `node tools/check-arch.mjs` |
| 後端 API | 端點、權限、錯誤碼、資料隔離 | pytest + TestClient，`services/backend/tests/` | `uv run pytest -q` |
| 後端資料 | 動態欄位擴充、seed 冪等 | 同上（`test_schema_sync.py`） | 同上 |
| 前端邏輯／資料 | composable、模組介面、隱私 | Vitest + happy-dom，`services/web/tests/` | `pnpm test` |
| 型別 | 前端型別 | vue-tsc | `pnpm build` |
| 畫面 | 實際操作 | Android 模擬器（本機後端） | 見 §5 |

CI 會跑全部自動測試；後端測試**在 SQLite 與 Postgres 17 各跑一次**。

## 2. 共通規則
- **測公開介面，不測 `__` 私有函數**（私有函數透過公開介面間接被測到）。
- 測試資料只用假資料：測試帳號 `test-user-a`／`test-user-b`（`tests/conftest.py`），**不得使用真實台北通帳號、真實姓名、身分證字號**。
- 每個測試獨立：自己準備狀態（例：先清空收藏），不依賴執行順序。
- 失敗要能看懂：一個測試驗一件事，名稱寫情境（`test_favorites_are_per_user`）。
- 外部服務（data.taipei、bridge）一律 mock；測試不連網。
- 新功能至少要有：1 個成功路徑、1 個錯誤路徑（404/422）、需要登入的端點再加 §3 的檢查。

## 3. 後端登入與權限驗證清單

**每個需要登入的端點**都要涵蓋下列項目（範例：`tests/test_auth.py`、`tests/test_examples.py`）：

| # | 檢查 | 預期 |
|---|---|---|
| A1 | 沒帶 token | 401，且有 `WWW-Authenticate: Bearer` |
| A2 | 亂碼 token、被竄改的內容或簽章、空字串 | 401 |
| A3 | 過期 token（`issue_token_for_tests(uid, ttl=-1)`） | 401 |
| A4 | 用別的 SECRET_KEY 簽的 token | 401 |
| A5 | 正確 token | 200／204，回應是**自己的**資料 |
| A6 | 資料隔離：A 建立的資料，B 看不到、改不到、刪不到 | B 的列表不含 A 的資料；B 的刪除不影響 A |
| A7 | 冪等：重複新增／刪除 | 不報錯、結果一致 |
| A8 | 資源不存在 | 404（不是 500） |
| A9 | 登入只接受 `townpass_id`、`name`；多送 `idNo`/`phoneNo`/`email` | 422 |
| A10 | 同一 `townpass_id` 重複登入 | 同一個使用者 id（名稱會更新） |

寫法：
```python
def test_my_endpoint_requires_login(client):
    assert client.get("/parks/mine").status_code == 401                      # A1

def test_my_endpoint_is_per_user(client, auth_headers):
    a, b = auth_headers(USER_A), auth_headers(USER_B)
    client.put("/parks/favorites/1", headers=a)
    assert 1 not in client.get("/parks/favorites", headers=b).json()       # A6
```

**前端**（`tests/session.test.ts`）：
- 登入請求的 body **只能**是 `{townpass_id, name}`（App 帳號物件含敏感欄位時也一樣）
- 後端不可用時 `ensureSession()` 回傳 `null` 不丟例外；`requireUser()` 丟出「需要登入台北通」
- 後端拒絕舊 token 時會清掉並重新登入

## 4. 手動驗證後端（Swagger）
1. 啟動後端，打開 `http://localhost:8000/docs`
2. `POST /auth/login`，body `{"townpass_id": "test-user-a", "name": "測試甲"}` → 複製 `token`
3. 右上 **Authorize** 貼上 token → 呼叫受保護端點應成功；按 **Logout** 再呼叫應 401
4. 用 `test-user-b` 重做一次，確認看不到 A 的資料
5. 部署後在 Render 網址重做 2–4（**不要**在正式環境用真實身分測）

## 5. 模擬器驗收清單（每個 PR 截圖附上相關項目）
前置：`. .\tools\dev-shell.ps1`、後端與網頁 dev server 都開著、`flutter run --dart-define=TEAM_WEB_URL=http://10.0.2.2:5173/`

- [ ] App「服務」→「城市任務」開出首頁；問候顯示 App 使用者名稱
- [ ] 快捷 chip → 功能列表；分類篩選正確
- [ ] 列表 → 詳細頁：資訊列、地圖、注意事項（第一項展開）、資料來源、底部按鈕
- [ ] 底部按鈕沒有壓到手勢列；只看到一個返回鍵（App 的）
- [ ] 在地圖上單指上下滑會捲動頁面
- [ ] 收藏：點愛心 → 變紅；重開頁面仍是紅色（後端 log 有 `PUT /…/favorites`）
- [ ] 回首頁 → 近期使用出現剛才的頁面
- [ ] 關掉後端再操作：頁面不白屏，資料改用範例資料
- [ ] 資料來源頁列出功能宣告的資料集

截圖：`adb exec-out screencap -p > shot.png`

## 6. 交 PR 前
```bash
node tools/check-arch.mjs
cd services/web && pnpm build && pnpm test
cd services/backend && uv run ruff check . && uv run pytest -q
```
