# 團隊開發流程

> 2026 臺北秋季程式設計節｜11/7–11/8｜初選 demo 2 分鐘、決選 demo 5 分鐘 + Q&A，**禁用簡報**

## 完整開發流程

**隊員只要做一件事：把 repo 給自己的 AI，說「請看 README 開始」。** 以下是 AI 會帶你走的流程，也是人工操作時的步驟。

### 角色
| 誰 | 負責 | 不做 |
|---|---|---|
| 隊員 | 登入 GitHub、選工單、回答問題、看結果 | |
| **主代理**（你對話的 AI） | 環境、同步、讀文件、寫任務說明、**檢查、更新系統文件、開 PR、合併** | **不寫實作** |
| **子代理** | 在自己的 worktree **實作與測試**，回報結果 | 不開 PR、不合併、不改工單範圍外的檔案 |

工具沒有子代理功能時：另開一個 session 實作，原本的 session 負責檢查。

### 1. 連結 GitHub
```powershell
git clone https://github.com/hackathon-taipei/TownPass.git
cd TownPass
gh auth login --web --git-protocol https     # 只有第一次；要用瀏覽器登入，所以要由隊員自己完成
```
要能推分支需要寫入權限。`tools/start.ps1` 會檢查，沒有就請 repo 擁有者把你加進去。

### 2. 安裝環境並同步
```powershell
powershell -ExecutionPolicy Bypass -File tools\start.ps1
```
依序：檢查工具（缺了自動裝，約 10 GB、20–40 分鐘）→ 檢查 GitHub 登入與權限 → 同步 `main` → 裝依賴 → 列出工單。**不會丟掉任何未提交的工作**，隨時可以重跑。環境細節與排錯：[08-environment.md](system/08-environment.md)。

每個新的 PowerShell 終端機先執行：`. .\tools\dev-shell.ps1`

### 3. 保持雲端與地端同步
| 什麼時候 | 做什麼 |
|---|---|
| 每次開工 | 重跑 `tools\start.ps1`（`main` 自動更新） |
| 開新分支前 | `git switch main`、`git pull --ff-only origin main`，再 `git switch -c t-<編號>-<名稱>` |
| 開 PR 前，或別人合併了東西 | `git fetch origin`、`git rebase origin/main`、`git push --force-with-lease` |
| 合併之後 | `git switch main`、`git pull --ff-only origin main` |

規則：`main` 只透過 PR 改；`--force-with-lease` 只用在自己的分支，**絕不對 `main`**；衝突自己解，解不了就在工單留言。

### 4. 開發前：先看有什麼能用
不要重寫已經有的東西：

| 先看 | 內容 |
|---|---|
| [10-architecture.md](system/10-architecture.md) | 技術棧、原始碼結構、所有介面、新東西放哪裡 |
| [AGENTS.md](../AGENTS.md) | 不能違反的規則（含比賽規則） |
| [09-addons.md](system/09-addons.md) | 現成模組：登入、模型、RAG、代理；對話框地圖與圖片 |
| [components.md](system/components.md) | 所有 UI 元件；開發模式下 `/#/dev/ui` 看實際樣子 |
| [02-spec.md](system/02-spec.md)、[03-glossary.md](system/03-glossary.md) | 規格、統一用語 |
| [01-decisions.md](system/01-decisions.md) | 為什麼這樣設計；想改架構先看 |
| `services/web/src/features/example/` | 完整的範例功能 |

### 5. 取得工單
```powershell
gh issue list -R hackathon-taipei/TownPass --label ticket --state open
gh issue view <編號> -R hackathon-taipei/TownPass
```
工單是 GitHub Issue（標籤 `ticket`），寫法與規則見 [tickets/README.md](tickets/README.md)。AI 會列出 `status:ready` 的工單，**由隊員選**；認領：
```powershell
gh issue comment <編號> --body "開始處理"
gh issue edit <編號> --add-assignee "@me" --add-label status:in-progress --remove-label status:ready
git switch -c t-<編號>-<名稱>
```
沒有工單時由派發者開（`townpass-ticket` skill 的 A 節）。

### 6. 實作（子代理）
主代理把工單網址、分支、範圍、合約、驗收標準、可重用的東西交給子代理（Claude Code：Agent 工具 + `isolation: "worktree"`）。子代理照分層規則實作、寫測試，然後回報：改了哪些檔案、跑了哪些指令與結果、偏離、沒驗證到的部分。

### 7. 檢查（主代理親自做）
**子代理的回報只是說法，不是證據。** 讀完整 diff，對照工單的範圍、合約、每條驗收標準，然後自己重跑：
```powershell
node tools/check-arch.mjs --catalog
cd services/web; pnpm build; pnpm test
cd ../backend; uv run ruff check .; uv run pytest -q
cd ../..; flutter analyze --no-fatal-infos --no-fatal-warnings   # 有改 App 才需要
```
有改畫面：在模擬器走一次並看截圖（[07-testing.md](system/07-testing.md) §5）。問題退回給同一個子代理修，再檢查一次。

### 8. 更新系統文件並推回去（必做）
**做完一定要更新文件，跟程式放在同一個 PR。** 下一個人和他的 AI 都靠這些文件工作。CI 會擋沒有更新文件的程式變更。

| 這次改了 | 要更新 |
|---|---|
| 新功能 | [02-spec.md](system/02-spec.md) 使用者情境、[10-architecture.md](system/10-architecture.md) 結構 |
| 公開介面（模組、加購件、後端） | [10-architecture.md](system/10-architecture.md) §4、[05-logic-layer.md](system/05-logic-layer.md) §5 |
| API 端點、資料表 | [02-spec.md](system/02-spec.md) §5、[06-data-layer.md](system/06-data-layer.md) |
| 元件 | `node tools/check-arch.mjs --catalog`（自動更新 components.md） |
| 技術、套件、模型 | [10-architecture.md](system/10-architecture.md) §2 |
| 設計決策 | [01-decisions.md](system/01-decisions.md) 新增一則 ADR，不改舊的 |
| 新用語 | [03-glossary.md](system/03-glossary.md) |
| App ↔ 網頁訊息 | [bridge.md](bridge.md) |
| 開放資料 | [data/SOURCES.md](../data/SOURCES.md)、功能的 `sources` |
| 開發流程、環境、工具 | 本文件、[08-environment.md](system/08-environment.md) |

真的不用更新（例如只修 bug）：在 PR 描述寫一行 `無需更新文件：<理由>`。

### 9. 推上 GitHub 並合併
```powershell
git fetch origin; git rebase origin/main
git push -u origin HEAD
gh pr create --fill-first --body-file <填好 PR 範本的檔案>
gh issue edit <編號> --add-label status:review --remove-label status:in-progress
```
PR 用 [範本](../.github/pull_request_template.md)，寫 `Closes #<編號>`，逐條對照驗收標準，**列出所有偏離**（有偏離加標籤 `deviation`）。

CI 全綠就由主代理合併，不強制人工 review：
```powershell
gh pr checks <編號>
gh pr merge <編號> --squash --delete-branch
git switch main; git pull --ff-only origin main
```
合併後網頁自動部署到 https://hackathon-taipei.github.io/TownPass/，後端部署到 https://townpass-backend-dmk2.onrender.com。打開確認一次。

**要停下來問人的情況**：要改 API／bridge 合約、驗收標準做不到、可能違反比賽規則、CI 修不好。細節見 `townpass-ticket` skill 的 D 節。

### 10. 回報
跟隊員說：合併了什麼、上線網址、有哪些偏離、哪些沒驗證、下一張可做的工單。

---

## 架構

```
TownPass App (Flutter)                       ← 只改：登記服務入口、需要時新增 bridge 訊息
  └─ WebView ── services/web (Vue 3)         ← 主要功能都在這裡
                   │  window.flutterObject   ← docs/bridge.md
                   └─ HTTP ── services/backend (FastAPI) ── 開放資料 (data/SOURCES.md)
```

本機開發時的網址：
| 誰連誰 | 網址 |
|---|---|
| 瀏覽器 → 網頁 | http://localhost:5173 |
| 瀏覽器 → 後端 / API 文件 | http://localhost:8000 / http://localhost:8000/docs |
| Android 模擬器 → 筆電 | 先 `adb reverse tcp:5173 tcp:5173`（後端再加 `tcp:8000`），網址維持 `localhost`；不要用 `10.0.2.2`（不是安全來源，WebGPU、OPFS 不能用） |
| 實體手機（同一個 Wi-Fi）→ 筆電 | 換成筆電的區網 IP |

## 本機執行指令

每個新終端機先啟用隔離環境（[說明](system/08-environment.md)）：`. .\tools\dev-shell.ps1`

```bash
# 網頁（瀏覽器開發，bridge 自動用 mock）
cd services/web && pnpm install && pnpm dev

# 後端
cd services/backend && uv sync && uv run python -m uvicorn townpass_backend.main:app --reload --host 0.0.0.0 --port 8000

# App（模擬器開網頁 dev server）
flutter emulators --launch townpass
flutter pub get && dart run build_runner build --force-jit
adb reverse tcp:5173 tcp:5173
flutter run --dart-define=TEAM_WEB_URL=http://localhost:5173/
```

> Windows 若出現「應用程式控制原則已封鎖此檔案」：用 `python -m uvicorn`（如上），不要直接執行 `.venv` 裡的 `uvicorn.exe`。

> 新增功能的方法見 [FRAMEWORK.md](FRAMEWORK.md)：前端一個功能一個 `src/features/<id>/` 資料夾，後端一個 `features/<name>/` 套件，都分顯示／邏輯／資料三層。部署見 [DEPLOY.md](DEPLOY.md)。
> 工作用**工單**派發（[docs/tickets](tickets/README.md)）：每張工單擁有不重疊的資料夾，可交給隊友或 AI 平行處理。

## 分工（每人一個資料夾，避免衝突）

| 角色 | 負責 | 資料夾 |
|---|---|---|
| PM／資料／demo | 拆題目、找資料、寫 SOURCES.md、demo 腳本、主持排練 | `docs/` `data/` |
| Flutter 整合 | 服務入口、bridge 新訊息、打包 APK、準備 demo 手機 | `lib/` `android/` |
| 前端 ×2 | 依「功能」分工，先用 mock 開發 | `services/web/src/features/<自己的功能>/` |
| 後端 | API、資料處理 | `services/backend/src/townpass_backend/features/<name>.py` |

## 題目公布後的前 2 小時：先定合約，不寫程式

1. **頁面流程**：每頁要顯示什麼、按了去哪（白板拍照放 `docs/`）
2. **API 合約**：後端先寫好 FastAPI 的 route + Pydantic model（回傳假資料也行），前端看 `/docs` 開發
3. **Bridge 合約**：需要 App 新能力就加到 `docs/bridge.md`
4. **資料**：確定用哪些開放資料集，填 `data/SOURCES.md`

定好之後大家同時開工，前端用 mock、後端照合約實作，互不等待。

## Git 規則

- `main` 受保護：只能透過 PR 合併，CI（`.github/workflows/ci.yml`）要過
- 分支命名：有工單用 `t-<編號>-<名稱>`，沒有用 `feat/…`、`fix/…`、`docs/…`
- **PR 要小、要快**：最多 2 小時合一次，squash merge
- 流程見上面「完整開發流程」第 3、9 步

## 時程（相對於題目公布 T0）

| 時間 | 事情 |
|---|---|
| T0 – T+2h | 定合約（上面四件事） |
| T+2h – 隔天早上 | 開發；每 2–3 小時全員 5 分鐘同步 |
| 初選前 4 小時 | **功能凍結**，只修 bug |
| 初選前 3 小時 | 打包 demo 用 APK、裝到 demo 手機、離線測試 |
| 初選前 2 小時 | 排練 2 分鐘版 ×3、5 分鐘版 ×2、預想 Q&A |

## 規則檢查表（每個 PR 都想一下）

- [ ] 只用開源套件；**不用 Google Maps** 等商用 SDK（地圖用 `OsmMap.vue`）
- [ ] 核心資料是開放資料，並寫進 `data/SOURCES.md`
- [ ] 執行時**不呼叫任何雲端 LLM API**；若用 LLM 必須在手機上跑，並揭露模型名稱／版本／量化／框架／來源，不可用大陸廠牌模型
- [ ] 開發期用 AI 產生的固定內容，不可宣稱是即時 AI 功能
- [ ] 我們寫的程式採 AGPL-3.0（見 README 授權段落）
- [ ] demo 是直接操作作品，沒有投影片
