# 加購件：登入 auth（後端）

TownPass 身分（只有 id 與名稱）換取 HMAC 簽章 token，用 `CurrentUser` 保護端點。
預設關閉：核心不會 import，沒啟用就不會有路由與資料表。前端見[前端說明](../../../../../web/src/addons/auth/README.md)。

## 載入

1. 新增 `features/account/__init__.py`：
   ```python
   from townpass_backend.addons.auth import router

   __all__ = ["router"]
   ```
   重啟後會掛上 `POST /auth/login`、`GET /auth/me`，並建立 `app_user` 資料表。

2. 需要登入的端點：
   ```python
   from townpass_backend.addons.auth import CurrentUser

   def endpoint(user: CurrentUser, session: SessionDep): ...  # 查詢一律帶 user.id
   ```

3. 正式環境要設 `SECRET_KEY`（`render.yaml` 已自動產生）。

## 限制
- `townpass_id` 沒有經過密碼學驗證，只適合比賽展示（ADR-008）
- `LoginRequest` 設 `extra="forbid"`：多送任何欄位就 422，避免敏感資料進來

## 測試
`services/backend/tests/test_addon_auth.py`：A1–A10 登入與權限清單（`docs/system/07-testing.md` §3）。
