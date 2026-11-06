# 加購件：代理 agent

把裝置端模型接進首頁對話框。需要 [model](../model/README.md) 與 [rag](../rag/README.md)。預設關閉。

## 做什麼
對話框收到問題時，依序：
1. **觸發詞**：符合工具的 `triggers` 就直接呼叫，不跑模型
2. **語意路由**：比對問題與工具 `examples` 的向量，只需要向量模型，沒有 WebGPU 的手機也能用
3. **語言模型選工具**：預設關閉（`toolCalling: true` 才開），而且要手動載入語言模型
4. **檢索回答**：回答加上文件原文、圖片、地圖標點

模型還沒載入，或這裡回答不了時，會自動交回框架內建的規則與搜尋，對話框不會壞。

## 載入

```ts
// services/web/src/features/ai/index.ts
import { createAgent } from '@/addons/agent'

export default defineFeature({
  // ...
  assistant: createAgent(),                      // 預設：語意路由開、語言模型選工具關
  // assistant: createAgent({ toolCalling: true }),
})
```

模型要先準備好才會接手（`useRag().prepare()`，或請使用者在 `RagLabPage` 按一次）。

## 新增工具
在功能的 `tools` 加一筆就會自動生效，寫法見 [docs/system/09-addons.md](../../../../../docs/system/09-addons.md) §3。
`examples` 寫 3–5 句使用者可能的講法，語意路由才找得到。

## 為什麼語言模型選工具預設關閉
原生函式呼叫在 7 個模型上都不可靠。Gemma 3 1B 改用英文少量範例分類可以 26／28，但要 728 MB 和 WebGPU；語意路由不用語言模型，所以預設用語意路由。數字見 [model README](../model/README.md)。

## 公開介面
| 名稱 | 用途 |
|---|---|
| `createAgent(options)` | 建立給 `Feature.assistant` 的提供者 |
| `routeByMeaning(question, tools)` | 語意選工具，只需要向量模型 |
| `chooseTool(question, tools)` | 語言模型選工具 |
| `parseToolCall(text)` | 解析模型輸出的 `<tool_call>` |
| `answerToResult(answer)` | 把 RAG 回答轉成對話內容 |

## 限制
- 模型只能傳查詢字串，座標與圖片網址一定來自資料
- `SEMANTIC_ROUTING` 門檻是用虛構資料量的，工具變多或換資料要重測（[eval/README.md](../../../eval/README.md)）
- 工具的範例句不要寫「怎麼去」這種也可能是問事實的講法：會把該回答的問題搶走

## 測試
`tests/addon-agent.test.ts`：解析、語意門檻、呼叫順序與退回行為。
