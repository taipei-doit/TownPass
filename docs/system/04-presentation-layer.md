# 顯示層

> 原則：**在既有架構上微調，用編號元件組合畫面，不在單一檔案裡堆畫面。**
> 完整元件清單：[components.md](components.md)（自動產生）・實際樣子：`/#/dev/ui`（開發模式）

## 1. 位置與分級

| 等級 | 編號 | 位置 | 定義 | 例 |
|---|---|---|---|---|
| 原子 Atom | A## | `ui/atoms/` | 不可再拆、無業務意義 | A01 BaseButton、A03 BaseChip |
| 分子 Molecule | M## | `ui/molecules/` | 數個原子的小組合 | M02 ListItem、M07 ResultCard |
| 有機體 Organism | O## | `ui/organisms/` | 獨立的介面區塊 | O04 ChatComposer、O05 ChatThread |
| 模板 Template | T## | `ui/templates/` | 頁面骨架，用插槽填內容 | T01 PageContainer、T02 DetailPage |
| 頁面 Page | P## | `pages/` | 框架層級的路由頁 | P01 HomePage |
| 功能頁面 | `XX-P##` | `features/x/ui/` | 功能的路由頁 | EX-P02 PlaceDetailPage |
| 功能元件 | `XX-C##` | `features/x/ui/` | 只有該功能用的元件 | EX-C02 FavoriteButton |

**編號規則**
- 每個 `.vue` 檔第一行（`<script setup>` 內）：`/** @component A06 IconBadge — 圓形圖示底 */`
- 新增時取該等級下一個號碼；**號碼不重用**（刪掉的元件號碼空著）
- 共用元件（A/M/O/T）要從 `ui/index.ts` 匯出並在行尾註記編號
- 改完執行 `node tools/check-arch.mjs --catalog` 更新目錄

## 2. 組合規則

1. **一個元件一個檔案。** 一個檔案超過約 80 行模板，或出現第二個可獨立命名的區塊，就拆。
2. **頁面只做組合與接線**：從 `@/ui` 拿元件、從自己的 `../logic` 拿資料與動作。頁面裡不寫 fetch、不碰 localStorage、不呼叫 bridge（W1）。
3. **由小往大組**：原子 → 分子 → 有機體 → 模板 → 頁面。下層元件不 import 上層。
4. **先找現成的**：需要新外觀先看 `components.md`。共用元件不夠用時：
   - 只差一點 → 加 prop／slot（向下相容，不改變既有用法）
   - 只有你的功能用 → 做成 `XX-C##` 放在功能的 `ui/`
   - 兩個以上功能會用 → 提升成共用元件（下一個 A/M/O 號碼），在 PR 說明
5. **元件無狀態優先**：資料從 props 進、事件從 emits 出；狀態放在邏輯層的 composable。
6. **UI kit 不依賴應用程式**：`ui/` 不 import `modules/`、`platform/`、`features/`。需要環境資訊用 `inject`（例：`inApp`）。

## 3. 設計 tokens（官方 TownPass）

來源：TownPass-Services `tailwind.config.js`（實作官方 Figma UI Kit）。定義在 `services/web/src/style.css`。

| 類別 | 用法 |
|---|---|
| 主色 | `primary-50…950`（主要 `primary-500 #2eb6c7`；按下 `-600`；淡底 `-50`） |
| 輔色 | `secondary-*`（黃）、`orange-*`、`mango`、`banana`、`grape` |
| 中性 | `grey-*`（文字 `grey-800/900`、次要 `grey-500`、分隔 `grey-100`）、`main-*`、`mid-*` |
| 狀態 | `warn-100/200`（錯誤）、`success` |
| 陰影 | `shadow-card` |
| 字體 | `font-sans` = PingFang TC, Roboto… |
| 大標 | `text-h1`（1.75rem） |

**禁止**：自己寫 hex 色碼、使用 Tailwind 預設色（`blue-500` 等）、引入其他 UI 框架。

## 4. 行動裝置與 App 內注意事項
- App 已有原生標題列與返回鍵：`PageContainer` 在 App 內自動隱藏我們的返回鍵。
- 固定在底部的區塊用 `PageContainer` 的 `#bottom` 插槽（已處理手勢列留白）。
- 地圖用 O02 OsmMap（手機上單指捲頁面、雙指縮放）。
- 觸控目標：主要按鈕 `h-11`（44px），chips `h-9`。
- 文字一律繁體中文；數字、英文與中文之間不加空格以外的標點規則依官方 App。

## 5. 新增共用元件檢查清單
- [ ] 放在正確等級資料夾，`@component` 編號正確且未重複
- [ ] 只用設計 tokens；有 hover/active/disabled 狀態
- [ ] 互動元素有文字或 `aria-label`
- [ ] 從 `ui/index.ts` 匯出（行尾註編號）
- [ ] 加到 UI 元件總覽（P03）並標編號
- [ ] `node tools/check-arch.mjs --catalog`
