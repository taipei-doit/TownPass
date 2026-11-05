# UI 框架：用「疊加」的方式加功能

目標：比賽當天每個人只在**自己的資料夾**裡新增檔案，不改共用檔案，就能把功能接上首頁、對話框搜尋、近期使用和資料來源頁。

## 畫面結構

```
首頁（單一入口，對話框）           src/views/HomeView.vue
 ├─ 問候 + 近期使用（裝置上紀錄）  src/core/recent.ts
 ├─ 服務卡片（所有功能自動列出）    src/core/registry.ts
 ├─ 快捷選項 chips                 各功能的 quickActions
 └─ 輸入框 → 搜尋結果卡片           src/core/search.ts（裝置端、離線、不用 LLM）
      └─ 點卡片 → 功能的列表/詳細頁  src/features/<id>/
                    └─ DetailPage：摘要、資訊列、地圖、注意事項、資料來源、底部按鈕
資料來源頁 /#/sources              自動彙整各功能的 sources（規則要求註明出處）
UI 元件總覽 /#/dev/ui              所有元件與官方色票（開發模式首頁底部有連結）
```

<img src="images/e2e-emulator.png" width="240" alt="首頁：對話框單一入口"> <img src="images/detail-page.png" width="240" alt="詳細頁：資訊、地圖、注意事項">

## 新增一個前端功能（3 步）

1. 複製範本：`cp -r services/web/src/features/_template services/web/src/features/<id>`
2. 改 `index.ts` 的 `id`（= 資料夾名）、`title`、`description`、`icon`
3. 寫頁面（只用 `@/ui` 的元件）→ 存檔，首頁就會出現這個功能

`defineFeature` 可以填的東西（全部選填，除了 id/title/description/icon/routes）：

| 欄位 | 作用 |
|---|---|
| `routes` | 頁面；網址自動是 `/#/f/<id>/...`，route name 自動加前綴 `<id>.` |
| `keywords` | 使用者在對話框打這些字時會推薦這個功能 |
| `quickActions` | 首頁輸入框上方的 chips |
| `searchItems()` | 回傳可被搜尋的資料（地點、服務項目…），點了會進詳細頁 |
| `sources` | 用到的開放資料 → 出現在資料來源頁 |
| `order` / `hidden` | 首頁排序 / 暫時隱藏 |

完整示範：[`src/features/example/`](../services/web/src/features/example/)（列表 → 詳細頁 → 注意事項 → 地圖 → 導航）。正式功能做好後刪掉它。

## 新增一個後端功能（2 步）

1. 複製 `services/backend/src/townpass_backend/features/_template.py` 為 `features/<name>.py`
2. 改 `prefix`、定義資料表（SQLModel）與 API；需要預載資料就寫 `seed(session)`

重開 server，`http://localhost:8000/docs` 就會出現新 API —— 這頁就是前後端的合約。
示範：[`features/examples.py`](../services/backend/src/townpass_backend/features/examples.py)。

## 前端呼叫後端的慣例

`features/<id>/data.ts` 裡：**先打後端，失敗就用本地 mock**（見 example/data.ts）。這樣：
- 前端不用等後端完成就能開發
- GitHub Pages 沒有後端時頁面也能動
- Demo 現場網路不穩時不會整個壞掉

## 元件清單（`import { ... } from '@/ui'`）

`PageContainer`（頁面外框，`back` 顯示返回、`#bottom` 固定底部）、`DetailPage`、`BaseButton`、`BaseCard`、`BaseChip`、`BaseInput`、`BaseTag`、`BaseSheet`（底部面板）、`CollapseItem`、`ListItem`、`SectionTitle`、`EmptyState`、`SkeletonBlock`、`OsmMap`

**規則**：顏色只用官方色票的 class（`bg-primary-500`、`text-grey-700`、`shadow-card`…，定義在 `src/style.css`），不要自己寫 hex 色碼。圖示用 [lucide](https://lucide.dev/icons)。
