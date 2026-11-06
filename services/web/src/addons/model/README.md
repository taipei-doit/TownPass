# 加購件：模型 model

裝置端模型的共用入口。其他模組要用模型都透過這裡，不直接碰 Transformers.js。預設關閉。

## 做什麼
- 偵測手機硬體（WebGPU、記憶體、核心數、可用空間），決定跑哪個模型
- 下載一次後存在 OPFS，之後斷網可用
- 提供向量（embedding）與文字生成
- 提供比賽要求的模型揭露表

執行環境在第一次使用時才載入，啟用這個模組不會讓每位使用者都下載它。

## 模型

| 用途 | 模型 | 廠商／授權 | 大小 | 何時用 |
|---|---|---|---|---|
| 向量（主要） | `onnx-community/embeddinggemma-300m-ONNX`（q8） | Google／Gemma Terms | 295 MB | 記憶體 4 GB 以上，或無法得知 |
| 向量（輕量） | `Xenova/multilingual-e5-small`（q8） | Microsoft／MIT | 118 MB | 記憶體不到 4 GB |
| 語言（手動） | `onnx-community/gemma-3-1b-it-ONNX`（q4f16） | Google／Gemma Terms | 728 MB | 只有手動選；需要 WebGPU |
| 語言（手動） | `onnx-community/granite-4.0-350m-ONNX-web`（q4f16） | IBM／Apache-2.0 | 334 MB | 只有手動選 |

**預設不用語言模型。** 回答是檢索到的那一行原文，下面再附文件原文、圖片、地圖。

### 為什麼（完整方法與重跑方式見 [eval/README.md](../../../eval/README.md)）

測試集是 24 筆虛構文件、68 題有答案、20 題沒答案、44 題工具選擇，其中一部分是調參數時不看的題目。**資料是虛構的，換上真實資料要重測。**

**向量模型**（`pnpm rag:eval`，含答案的那一行排第一的比例）

| 模型 | 大小（q8） | 第一批 48 題 | 沒看過的 20 題 | 沒答案的 20 題擋下 |
|---|---|---|---|---|
| **EmbeddingGemma** | 295 MB | 94% | 17／20 | 19／20 |
| e5-small | 118 MB | 83% | 15／20 | 19／20 |
| e5-base | 266 MB | 69% | 未測 | 83%（第一批） |
| MiniLM-L12 | 113 MB | 71% | 未測 | 100%（第一批，但保留率較低） |
| mpnet-base | 266 MB | 58% | 未測 | 83%（第一批） |
| distiluse | 129 MB | 69% | 未測 | 58%（第一批） |

向量加關鍵字的混合檢索（RRF）對 EmbeddingGemma 反而變差（94% → 79%），所以沒有採用。

**語言模型**（`eval/llm-compare.js`，筆電 Radeon 780M WebGPU，給定正確資料）

| 模型 | 大小 | RAG 自動評分（12 題） | 平均每題 | 工具：函式呼叫／中文範例／英文範例（28 題，其中 12 題不該呼叫） |
|---|---|---|---|---|
| **Gemma 3 1B** | 728 MB | 6（人工看 8 對、4 錯） | 1.2 秒 | 12／23／**26** |
| Granite 4.0 350M | 334 MB | 4 | 1.3 秒 | 12／12／14 |
| Gemma 3 270M | 260 MB | 3 | 3.0 秒 | 12／12／9 |
| LFM2 700M | 473 MB | 3 | 1.1 秒 | 15／13／18 |
| LFM2 1.2B | 725 MB | 2 | 2.5 秒 | 17／14／13 |
| FunctionGemma 270M | 406 MB | 1 | 4.3 秒 | 12／12／12 |
| LFM2 350M | 243 MB | 0 | 1.0 秒 | 14／13／11 |

函式呼叫一欄的 12 分等於從不呼叫工具，只答對「不該呼叫」的題目。

**語言模型為什麼不當預設**：即使最好的 Gemma 3 1B，12 題也有 4 題答錯，而且會講反，例如原文禁止外食卻回答「允許帶便當」。其中 3 題接地檢查擋不下來。逐字原文在真實對話框是 63／68 正確、且答案 68／68 出現在回覆中。

**真實對話框驗收**（`eval/chat-check.js`）

| 項目 | 4 GB 以上（EmbeddingGemma） | 2 GB（e5-small） |
|---|---|---|
| 回答那一行含答案 | 63／68 | 54／68 |
| 答案出現在回覆（含原文） | 68／68 | 64／68 |
| 問事實被工具搶走 | 0／68 | 0／68 |
| 沒答案的問題正確處理 | 19／20 | 14／20 |
| 工具誤觸 | 0 | 0 |
| 第一次載入 | 4 GB 模擬器 64 秒（模型已下載，含建立 127 個片段的索引）；桌面第二次 8 秒（向量已快取） |

## 載入與使用

```ts
import { complete, embedPassages, embedQuery, prepareEmbedding, prepareLanguageModel, useModel } from '@/addons/model'

await prepareEmbedding()                 // 第一次會下載
await prepareLanguageModel()             // 預設不載入；可傳 'small'（Granite 350M）或 'large'（Gemma 3 1B）

const query = await embedQuery('公園可以帶寵物嗎')
const passages = await embedPassages(['寵物須繫牽繩'])
const answer = await complete([{ role: 'user', content: '…' }], { maxNewTokens: 120, onText: (t) => show(t) })

const { progress, message, hardware, choice, disclosure, isOffline } = useModel() // 給畫面用的狀態
```

管理模型的畫面可用 `DeviceModelCard`（ML-C01，硬體、模型、理由、揭露表）。

## 限制
- WebGPU、OPFS **只在安全來源可用**：`https://` 或 `localhost`。模擬器不能用 `http://10.0.2.2`（`docs/system/07-testing.md` §5）
- 模擬器沒有真實 GPU；語言模型的速度要用實體手機量
- **EmbeddingGemma 在 2 GB 模擬器上把 App 撐到被系統砍掉**，所以不到 4 GB 改用 e5-small；別用 q4 量化，它的運算瀏覽器的 WASM 不支援
- 向量模型換手機等級時也會換，兩者的相關度門檻不同（`minRelevance`），預建向量也只適用同一個模型
- `repetition_penalty` 必須是 1.0：1.1 會懲罰抄資料的行為，導致模型亂答英文
- 比賽規則：只能在裝置端執行，不可用大陸廠牌模型，要揭露模型名稱、版本、量化、框架、來源

## 測試
`tests/addon-rag.test.ts` 的 `chooseGenerator`（硬體規則）與揭露表測試。

## 授權聲明
Gemma is provided under and subject to the Gemma Terms of Use found at https://ai.google.dev/gemma/terms
