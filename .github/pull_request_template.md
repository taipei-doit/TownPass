<!-- 回報格式：.claude/skills/townpass-ticket/SKILL.md C 節。不適用的段落寫「無」，不要刪。 -->

Closes #

## 做了什麼
<!-- 依層列出：顯示層（元件編號）／邏輯層（公開介面）／資料層（API、資料表、新欄位） -->
- 顯示層：
- 邏輯層：
- 資料層：

## 驗收對照
<!-- 逐條貼工單的驗收標準：✅/❌ + 證據（測試名稱、截圖） -->
- [ ]

## 驗證
```
node tools/check-arch.mjs        →
pnpm build && pnpm test          →
uv run ruff check . && pytest -q →
```
截圖：

## 偏離
<!-- 和工單不同的地方、改到範圍外的檔案、合約變更、跳過的驗收項目。沒有就寫「無」。有偏離請加標籤 deviation -->

## 後續
<!-- 剩下的事、風險、建議開的新工單 -->

---
- [ ] 只改了工單「範圍」內的路徑（或已列在偏離）
- [ ] 沒有雲端 LLM 呼叫、沒有商用 SDK、沒有新增個資欄位
- [ ] 用到的開放資料已登記（sources、data/SOURCES.md、SourceNote）
