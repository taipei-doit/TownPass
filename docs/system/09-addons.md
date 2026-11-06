# 加購件與對話框工具

> 加購件是預先寫好、**預設關閉**的模組。框架不會 import 它們，需要時照這份文件載入。
> 對話框工具（地圖、圖片）是框架內建能力，不需要任何模型，所有手機都能用。

## 1. 有哪些模組

| 模組 | 位置 | 做什麼 | 依賴 | 說明文件 |
|---|---|---|---|---|
| 登入 auth | `web/src/addons/auth`、`backend/.../addons/auth` | 以 TownPass 身分換取本服務 token | 後端 | [前端](../../services/web/src/addons/auth/README.md)・[後端](../../services/backend/src/townpass_backend/addons/auth/README.md) |
| 模型 model | `web/src/addons/model` | 裝置端模型：硬體判斷、選模型、下載與離線快取、向量、文字生成、模型揭露 | 無 | [README](../../services/web/src/addons/model/README.md) |
| RAG rag | `web/src/addons/rag`、`web/scripts/rag-*` | 把文件做成集合、切段、向量化、檢索、接地檢查 | model | [README](../../services/web/src/addons/rag/README.md) |
| 代理 agent | `web/src/addons/agent` | 把模型接進對話框：語意選工具、回答附原文、圖片、地圖 | model、rag | [README](../../services/web/src/addons/agent/README.md) |

## 2. 依需求載入

| 想要 | 載入 |
|---|---|
| 對話框顯示地圖、圖片 | 不用載入：資料加上 `geo`／`images` 就有（§3） |
| 需要登入的動作 | auth |
| 別的功能要用模型（摘要、分類…） | model |
| 語意搜尋公文或資料 | model + rag |
| 首頁對話框用 AI 回答 | model + rag + agent（下方範例） |

開啟「AI 問答」的完整範例，只要新增一個功能資料夾：

```ts
// services/web/src/features/ai/index.ts
import { Sparkles } from 'lucide-vue-next'
import { defineFeature } from '@/framework'
import { createAgent } from '@/addons/agent'
import { RagLabPage } from '@/addons/rag'

export default defineFeature({
  id: 'ai',
  code: 'AI',
  title: 'AI 問答',
  description: '在手機上執行的模型，只根據 App 內資料回答',
  icon: Sparkles,
  routes: [{ path: '', name: 'lab', component: RagLabPage }], // 硬體資訊、下載模型、模型揭露
  assistant: createAgent(), // 模型就緒後，首頁對話框由它回答；就緒前仍用規則與搜尋
})
```

**上線前必做**：寫該功能的測試計畫與 demo 腳本；用到語言模型要在畫面揭露模型資訊（`RagLabPage` 已內建）；用實體手機量過速度。

## 3. 對話框工具

### 不寫程式：資料加欄位
功能的 `searchItems` 回傳的項目加上欄位，內建工具就會處理：

```ts
{
  id: '12',
  title: '信義路管線施工',
  subtitle: '信義區',
  text: '施工內容與注意事項，一行一件事',
  geo: { lat: 25.033, lng: 121.564 },         // → show_map 標點
  images: [{ src: 'rag/img/road-1.png', alt: '封路範圍圖', caption: '附圖一' }], // → show_image 顯示
  validFrom: '2026-11-01',
  validTo: '2026-12-31',                       // 過期的不會標在地圖上，RAG 也不會拿來回答
  source: '臺北市政府工務局',
  to: featureRoute('roads', 'detail', { id: 12 }),
}
```

使用者問「把信義區的施工標在地圖上」或「公文附圖給我看」，對話框裡就會出現地圖或圖片。

### 新增工具
在功能的 `index.ts` 加一筆，不用改任何共用檔案：

```ts
import { defineTool } from '@/framework'

const showShelters = defineTool<{ query?: string }>({
  name: 'show_shelters',                       // 全專案唯一
  description: '在地圖上標出避難所',             // 給語言模型看
  parameters: { type: 'object', properties: { query: { type: 'string', description: '行政區' } } },
  triggers: [/避難所|避難處/],                  // 這些詞出現就直接呼叫，不需要模型
  examples: ['附近哪裡可以避難', '地震要去哪裡'], // agent 用來比對語意
  run: async ({ query }) => {
    const shelters = await findShelters(query)  // 座標來自自己的資料
    return {
      text: `找到 ${shelters.length} 處避難所：`,
      blocks: [{ type: 'map', markers: shelters.map((s) => ({ lat: s.lat, lng: s.lng, label: s.name, tone: 'warning' })) }],
      cards: shelters.map((s) => ({ key: String(s.id), title: s.name, to: detailRoute(s.id) })),
    }
  },
})

export default defineFeature({ /* ... */ tools: [showShelters] })
```

### 工具回傳的區塊

| `type` | 欄位 | 畫面 |
|---|---|---|
| `map` | `markers: {lat, lng, label?, detail?, tone?}[]`、`title?` | O08 ChatMap：自動縮放到所有標點，點標點看說明 |
| `image` | `src`、`alt`（必填）、`caption?`、`source?` | M10 ChatImage：載入失敗時顯示替代文字 |
| `quote` | `text`、`title?`、`source?` | M11 ChatQuote：逐字顯示原文，可朗讀 |

### AI 怎麼呼叫工具

```
問題
 ├─ 1. 觸發詞 triggers          不需要模型，所有手機都能用
 ├─ 2. 語意路由 examples         只需要向量模型（需 agent）
 ├─ 3. 語言模型 function calling 預設關閉（需 agent，toolCalling: true）
 └─ 4. 檢索與搜尋               回答附原文；文件有圖片或座標就一併顯示
```

程式直接呼叫：`runTool('show_map', { query: '施工' })`（`@/modules/tools`）。

### 安全規則（必須遵守）
- **工具參數只收查詢字串或 id，座標與圖片網址一律從資料查。** 模型會編造，所以不能由模型提供。
- `runTool` 會驗證參數型別、丟掉沒宣告的參數；地圖座標超出範圍、圖片不是同站／`https:`／`data:image` 或沒有 `alt` 都會被丟棄。
- 工具失敗不會中斷對話，只會顯示一句提示。

## 4. 為什麼這樣選（實測）

筆電 Chrome、Radeon 780M WebGPU，範例資料。樣本很小，只能看方向；換上真實資料要重測。

| 項目 | 結果 |
|---|---|
| Android WebView 133（模擬器） | `navigator.gpu` 存在，但模擬器取不到 GPU；OPFS、Service Worker 可用；**沒有** `speechSynthesis` |
| 相關度門檻 | 資料涵蓋的問題 0.86–0.90，無關問題 0.82–0.84 → `MIN_RELEVANCE = 0.85` |
| 語意路由（15 題） | 12 題選對；加上門檻後一般問題不會誤觸工具 |
| 語言模型選工具 | 350M、1B 都是該呼叫工具的 5 題全錯 → 預設關閉；完整比較見 [model README](../../services/web/src/addons/model/README.md) |
| 語言模型回答 | 會抄錯或重複問題，所以**原文一定由程式直接顯示**，模型只補一句話 |
| 斷網（模擬器 WebView，關閉網路與伺服器） | 網站可開、繁中街道底圖、標點、圖片都正常 |
| 朗讀 | 模擬器確認有送到手機語音引擎，沒有驗到聲音。Google 引擎第一次念繁中時會自動下載語音包；App 在非行動網路下開啟就會觸發。`RagLabPage` 的「繁中語音」列顯示是否已可離線，demo 前要確認並開飛航模式試一次 |
| 尚未實測 | 實體手機的 WebGPU 與語言模型速度（模擬器沒有真實 GPU） |

## 5. 新增一個加購件

1. 建立 `services/web/src/addons/<x>/`：只能有 `index.ts`、`logic.ts`、`data.ts`、`ui/*.vue`、`README.md`（W9）
2. `index.ts` 匯出 `ADDON_CODE`（2–4 大寫字母，元件編號前綴 `<CODE>-P##`／`-C##`）
3. 其他程式只能從 `@/addons/<x>` 使用；核心（`framework/`、`app/`、`modules/`、`ui/`、`platform/`）不得 import（W10）
4. README 寫清楚：做什麼、怎麼載入、公開介面、限制、測試
5. 在本文件 §1、§2 加一列
