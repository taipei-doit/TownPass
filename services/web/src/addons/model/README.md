# 加購件：模型 model

裝置端模型的共用入口。其他模組要用模型都透過這裡，不直接碰 Transformers.js。預設關閉。

## 做什麼
- 偵測手機硬體（WebGPU、記憶體、核心數、可用空間），決定跑哪個模型
- 下載一次後存在 OPFS，之後斷網可用
- 提供向量（embedding）與文字生成
- 提供比賽要求的模型揭露表

執行環境在第一次使用時才載入，啟用這個模組不會讓每位使用者都下載它。

## 模型

| 用途 | 模型 | 廠商／授權 | 大小（q4f16） |
|---|---|---|---|
| 向量 | `Xenova/multilingual-e5-small`（q8） | Microsoft／MIT | 118 MB |
| 語言（預設） | `onnx-community/granite-4.0-350m-ONNX-web` | IBM／Apache-2.0 | 334 MB |
| 語言（只能手動指定） | `onnx-community/granite-4.0-1b-ONNX-web` | IBM／Apache-2.0 | 1.2 GB |

規則：
- 有 WebGPU 且支援 fp16 → 350M
- 沒有 WebGPU → 不用語言模型，只做向量檢索與摘錄（CPU 生成每題約 30 秒）
- 1B 只在手動指定時使用，載入失敗自動退回 350M

### 實測比較（筆電 Radeon 780M WebGPU，範例資料）

同一批 5 題、同一個提示，看回答是否真的回答了問題：

| | Granite 350M | Granite 1B |
|---|---|---|
| 檔案（q4f16） | 334 MB | 1.2 GB |
| 第一次下載＋載入 | 28 秒（含向量模型） | 53 秒 |
| 每題時間 | 0.9–1.4 秒 | 0.8–8.1 秒 |
| 可用的回答 | 2／5（免費、自習） | 0／5（重複字、亂碼「免貨」、英文、簡體） |
| 接地檢查擋下 | 3／5，改顯示原文 | 4／5，另有 1 題亂碼沒被擋下 |
| 語言模型選工具（該呼叫工具的題目） | 0／5 | 0／5 |

向量語意路由在 15 題上選對 12 題，所以對話框用語意路由選工具（[agent](../agent/README.md)）。
兩個模型都無法保證內文正確，所以原文一律由程式直接顯示（ADR-016）。**樣本很小，換上真實資料要重測。**

## 載入與使用

```ts
import { complete, embedPassages, embedQuery, prepareEmbedding, prepareLanguageModel, useModel } from '@/addons/model'

await prepareEmbedding()                 // 第一次會下載
await prepareLanguageModel()             // 自動選；可傳 'none' | 'small' | 'large'

const query = await embedQuery('公園可以帶寵物嗎')
const passages = await embedPassages(['寵物須繫牽繩'])
const answer = await complete([{ role: 'user', content: '…' }], { maxNewTokens: 120, onText: (t) => show(t) })

const { progress, message, hardware, choice, disclosure, isOffline } = useModel() // 給畫面用的狀態
```

管理模型的畫面可用 `DeviceModelCard`（ML-C01，硬體、模型、理由、揭露表）。

## 限制
- WebGPU、OPFS **只在安全來源可用**：`https://` 或 `localhost`。模擬器不能用 `http://10.0.2.2`（`docs/system/07-testing.md` §5）
- 模擬器沒有真實 GPU，只能測到「無語言模型」的路徑；語言模型的速度要用實體手機量
- `repetition_penalty` 必須是 1.0：1.1 會懲罰抄資料的行為，導致模型亂答英文
- 比賽規則：只能在裝置端執行，不可用大陸廠牌模型，要揭露模型名稱、版本、量化、框架、來源

## 測試
`tests/addon-rag.test.ts` 的 `chooseGenerator`（硬體規則）與揭露表測試。
