# 模型評測

換模型、換資料、調門檻之前先跑這裡，用數字決定。

| 檔案 | 內容 |
|---|---|
| `corpus.json` | 測試文件：24 筆**虛構**的施工、活動、公文、設施，含 2 筆已過期 |
| `questions.json` | 48 題有答案、12 題沒答案、28 題工具選擇；`holdout` 是調門檻時不看的另一批（20／8／16） |
| `compare.mjs` | 比較向量模型與檢索策略，不需要 GPU |
| `llm-compare.js` | 比較語言模型，需要 WebGPU，在瀏覽器執行 |

## 向量模型與檢索

```powershell
cd services/web
pnpm rag:eval                                                  # 全部模型
pnpm rag:eval onnx-community/embeddinggemma-300m-ONNX@q4       # 指定模型與量化
```

| 指標 | 意思 |
|---|---|
| `doc@1`、`doc@3` | 正確文件排第一、在前三 |
| `fact@1`、`fact@4` | 含答案的那一行排第一、在前四；**沒有語言模型時，回答就是 fact@1 那一行** |
| `unanswerable` | 最佳門檻下，保留多少有答案的問題、擋下多少沒答案的問題 |
| `tool routing` | 語意路由選對工具的題數、誤觸工具、選錯工具 |
| `HOLDOUT` | 用上面選出的門檻跑沒看過的題目；**這個最接近真實表現** |

## 語言模型

```powershell
cd services/web; pnpm dev
```
在瀏覽器主控台：
```js
const m = await import('/eval/llm-compare.js')
m.start(['onnx-community/granite-4.0-350m-ONNX-web'])
m.state   // 進度與結果
```
第一次載入後頁面可能重載一次，重新執行即可。執行中不要改 `src/`，否則 Vite 會重載頁面。

## 換上真實資料後
1. 把真實文件轉成 `corpus.json` 的格式，至少寫 30 題有答案、10 題沒答案的問題；**問題用使用者會講的話，不要抄原文**
2. 跑 `pnpm rag:eval`，用結果更新 `MIN_RELEVANCE`（`addons/rag/logic.ts`）與 `SEMANTIC_ROUTING`（`addons/agent/logic.ts`）
3. 把數字寫進 `addons/model/README.md`
