<!--
工單範本。複製後把每一段填完（不適用就寫「無」），再用：
  gh issue create -R hackathon-taipei/TownPass --label ticket,status:ready --title "[T-___] 標題" --body-file 這個檔案
寫法說明：.claude/skills/townpass-ticket/SKILL.md（A. 派發）
-->

## 目標
<!-- 一句話：誰、在什麼情境、得到什麼。附對應的使用者情境／題目段落 -->

## 範圍（只能改這些路徑）
- 
<!-- 例：services/web/src/features/parks/**、services/backend/src/townpass_backend/features/parks/**、services/backend/tests/test_parks.py -->

**不可改**：其他功能資料夾、`services/web/src/ui/**`（需要新共用元件請在 PR 列為偏離）、CI、`tools/`

## 依賴
<!-- blocked by #__ ／ 需要的合約已定在哪裡；沒有就寫「無」 -->

## 必讀
- `AGENTS.md`
- `docs/system/02-spec.md`、`docs/system/03-glossary.md`
- <!-- 這張工單特別需要的檔案、資料集網址、截圖 -->

## 要用的 skill
- [ ] `townpass-feature`
- [ ] `townpass-ui`

## 合約（必須完全遵守）
<!-- API 路徑、request/response 欄位與型別、bridge 訊息、feature id/code、元件編號。改合約＝偏離，要先停下來回報 -->

## 要做的事
- [ ] 
- [ ] 測試：
- [ ] 資料來源登記（有用到開放資料時）

## 驗收標準
- [ ] 
- [ ] `node tools/check-arch.mjs` 通過；web `pnpm build && pnpm test`、backend `uv run ruff check . && uv run pytest -q` 通過
- [ ] 模擬器截圖（列出要截哪些畫面）

## 驗證方式
```bash
node tools/check-arch.mjs --catalog
cd services/web && pnpm build && pnpm test
cd services/backend && uv run ruff check . && uv run pytest -q
```
模擬器：<!-- 要走的步驟 -->

## 提示詞（貼給 AI 執行者）
```
你是 hackathon-taipei/TownPass 的開發者，負責工單 #<issue 編號>。
先讀 AGENTS.md，並載入 skill townpass-ticket（B. 執行）與工單列出的其他 skill。
完整讀完工單的「必讀」後再開始。只修改「範圍」內的路徑；任何超出範圍或改到「合約」的需要，
依 townpass-ticket 的「D. 偏離」處理。完成後跑「驗證方式」的所有指令並截圖，
用 PR 範本回報（Closes #<issue 編號>），逐條對照「驗收標準」。
<!-- 這張工單特有的提醒：例如使用哪個資料集、注意哪個邊界情況 -->
```

## 回報方式
- 開 PR（填 `.github/pull_request_template.md`，`Closes #這張工單`），加標籤 `status:review`
- 在本工單留言：PR 連結 + 3 行摘要
- 卡住或要改合約：在本工單留言說明並加標籤 `blocked`

## 偏離規則
依 `.claude/skills/townpass-ticket/SKILL.md` D 節；本工單額外規定：<!-- 沒有就寫「無」 -->

## 優先級／預估
<!-- P0 必須 demo／P1 加分／P2 有空再做；預估 1–3 小時 -->
