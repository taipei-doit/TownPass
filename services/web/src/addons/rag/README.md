# 加購件：RAG rag

產生與查詢裝置端的文件集合。需要 [model](../model/README.md)。預設關閉。

## 做什麼
- 把各功能的 `searchItems`（含 `text`）切成「一行一事實」的片段並向量化
- 問題進來時取最相近的片段，交給語言模型回答；沒有語言模型就摘錄原文
- `isGrounded` 檢查回答：大多是英文、或跟資料重疊太少，就改顯示原文
- 回傳來源文件的**原文**、圖片、座標，由呼叫端顯示
- 過期的文件（`validTo` 已過）不拿來回答

## 載入與使用

```ts
import { useRag } from '@/addons/rag'

const rag = useRag()
await rag.prepare()                 // 下載模型、建立索引；可重複呼叫
const a = await rag.ask('公園可以帶寵物嗎？', (partial) => show(partial))

a.answer     // 回答
a.mode       // 'llm' | 'extractive' | 'guarded'（模型回答沒通過檢查，改顯示原文）
a.relevant   // false 代表資料沒有涵蓋這個問題
a.document   // 來源文件原文、images、geo
a.sources    // 引用來源（分數由高到低）
```

現成頁面：`RagLabPage`（RG-P01）。接到首頁對話框請用 [agent](../agent/README.md)。

## 把公文做成集合

只要資料已經是功能的 `searchItems`，不需要這一步。文件很多或是 PDF 時，先在電腦上產生集合，手機就不必自己算向量：

```bash
# 1.（PDF 才需要）PDF → Markdown ＋ 圖片（圖片存到 public/rag/img/）
cd services/web
uv run --no-project --with pymupdf python scripts/rag-pdf.py ../../data/rag/pdf ../../data/rag/notices

# 2. 補上 Markdown 開頭的 alt、caption、lat、lng、validFrom、validTo

# 3. Markdown → public/rag/notices.json（含預先算好的向量）
pnpm rag:build ../../data/rag/notices notices
```

Markdown 格式：

```markdown
---
title: 信義路封路公告
subtitle: 臺北市政府工務局
source: 臺北市政府公文
sourceUrl: https://...
validFrom: 2026-11-01
validTo: 2026-12-31
lat: 25.033
lng: 121.564
images: [{"src":"rag/img/road-1.png","alt":"封路範圍圖","caption":"附圖一"}]
---
一行一件事。太長的段落會在句號斷開。
```

在功能裡接上集合。這些文件也會進入對話框的一般搜尋，所以模型還沒載入時也查得到：

```ts
import { collectionItems } from '@/addons/rag'

export default defineFeature({
  // ...
  searchItems: () => collectionItems(`${import.meta.env.BASE_URL}rag/notices.json`, (doc) => featureRoute('notices', 'detail', { id: doc.id })),
})
```

## 限制
- 掃描版 PDF 沒有文字層，要先 OCR；`rag-pdf.py` 會指出哪些檔案
- `MIN_RELEVANCE = 0.85` 是用範例資料量的，換上真實資料要重測：拿幾題資料有涵蓋、幾題沒涵蓋的問題，看 `a.sources[0].score`
- 向量存在 OPFS；沒有 OPFS 的舊 WebView 每次都要重算
- 比賽規則：核心資料要是開放資料並標示來源（`source`、`data/SOURCES.md`）

## 測試
`tests/addon-rag.test.ts`：檢索、原文回傳、相關度、接地檢查。
