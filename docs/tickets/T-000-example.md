<!-- 範例工單：示範每一段該寫到多細。題目公布後照這個格式寫真正的工單。 -->

# [T-000] 範例：設施收藏（EX-C02 + 收藏 API）

## 目標
市民在設施詳細頁按愛心收藏；重開頁面仍保留；只看得到自己的收藏。（spec S5）

## 範圍（只能改這些路徑）
- `services/web/src/features/example/**`
- `services/backend/src/townpass_backend/features/examples/**`
- `services/backend/tests/test_examples.py`、`services/web/tests/`（新增檔案）

**不可改**：其他功能資料夾、`services/web/src/ui/**`、`addons/auth/**`、CI、`tools/`

## 依賴
auth 加購件（已提供 `CurrentUser` 與前端 `requireUser()`，要先依 `docs/system/09-addons.md` 啟用）

## 必讀
- `AGENTS.md`
- `docs/system/02-spec.md` §3 §5、`docs/system/03-glossary.md`
- `docs/system/06-data-layer.md` §2（動態欄位）、`docs/system/07-testing.md` §3（A1–A10）
- 現有程式：`features/examples/api.py`、`features/example/ui/PlaceDetailPage.vue`

## 要用的 skill
- [x] `townpass-feature`
- [x] `townpass-ui`

## 合約（必須完全遵守）
| 方法 | 路徑 | 認證 | 回應 |
|---|---|---|---|
| GET | `/examples/favorites` | 需要 | `number[]`（place id，依加入順序） |
| PUT | `/examples/favorites/{place_id}` | 需要 | 204；重複加入也 204；place 不存在 404 |
| DELETE | `/examples/favorites/{place_id}` | 需要 | 204；不存在也 204 |

資料表 `example_favorite(id, user_id→app_user.id, place_id→example_place.id, created_at)`，(user_id, place_id) 唯一。
前端元件 `EX-C02 FavoriteButton`（props `active`、`busy`；emit `toggle`），放在 T02 的 `#headerAction`。

## 要做的事
- [x] 後端 models / repo / service / api（依分層）
- [x] 前端 data（API + 裝置端後備）、logic（`usePlaceDetail().toggleFavorite`，先 `requireUser()`）、ui（EX-C02）
- [x] 測試：A1、A5、A6、A7、A8

## 驗收標準
- [x] 未登入呼叫三個端點都 401
- [x] A 收藏的地點 B 看不到、刪不掉
- [x] 重複 PUT/DELETE 不報錯
- [x] 模擬器：點愛心變紅、重開仍紅
- [x] arch／build／test 全過

## 驗證方式
```bash
node tools/check-arch.mjs --catalog
cd services/web && pnpm build && pnpm test
cd services/backend && uv run ruff check . && uv run pytest -q
```
模擬器：首頁 →「找公園」→ 範例公園 → 點愛心 → 返回 → 再進入，愛心仍是紅色；後端 log 有 `PUT /examples/favorites/1 204`

## 提示詞（貼給 AI 執行者）
```
你是 hackathon-taipei/TownPass 的開發者，負責工單 #<編號>（設施收藏）。
先讀 AGENTS.md，載入 skill townpass-ticket（B. 執行）、townpass-feature、townpass-ui。
讀完「必讀」後開始。只改「範圍」內的路徑；合約表格中的路徑、狀態碼、欄位不可更動。
收藏屬於個人資料：每個查詢都要帶 user_id，並寫 A6 資料隔離測試。
完成後跑「驗證方式」全部指令、在模擬器截圖，用 PR 範本回報並逐條對照驗收標準。
```

## 回報方式
PR（`Closes #<編號>`，標籤 `status:review`）＋ 本工單留言 PR 連結與摘要。

## 偏離規則
依 skill D 節；本工單額外規定：若需要改 `ui/` 共用元件，先在工單留言再做。

## 優先級／預估
P1｜2 小時
