# 加購件：登入 auth（前端）

以 TownPass 身分向後端換取本服務 token。預設關閉；後端要同時啟用，見[後端說明](../../../../backend/src/townpass_backend/addons/auth/README.md)。

## 做什麼
- 只讀 App 帳號的 `id` 與 `realName`，呼叫 `POST /auth/login` 換 token
- 之後每個 `api()` 呼叫自動帶上 token

## 載入與使用

```ts
// 功能的 logic 層
import { ensureSession, requireUser, user, profile, signOut } from '@/addons/auth'

async function toggleFavorite(id: number) {
  await requireUser()       // 沒登入會丟出「需要登入台北通」
  // ...呼叫受保護的 API
}

// （可選）進頁面先登入，避免第一次操作等太久
onMounted(() => ensureSession())
```

## 限制
- `townpass_id` **沒有經過密碼學驗證**，任何人都能冒用，只適合比賽展示（ADR-008）
- 隱私：不得讀取、儲存或傳送身分證字號、電話、地址、生日
- 上線前先寫該功能的測試計畫與 demo 腳本

## 測試
`tests/auth.test.ts`；後端 `services/backend/tests/test_addon_auth.py`（A1–A10，`docs/system/07-testing.md` §3）。
