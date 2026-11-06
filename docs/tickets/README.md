# 工單（平行開發）

工單 = 一個 GitHub Issue（標籤 `ticket`），一個人或一個 AI 拿到就能獨立完成並回報。
完整規則：[`.claude/skills/townpass-ticket/SKILL.md`](../../.claude/skills/townpass-ticket/SKILL.md)

| 檔案 | 用途 |
|---|---|
| [TEMPLATE.md](TEMPLATE.md) | 工單範本（用 `gh issue create --body-file`） |
| [T-000-example.md](T-000-example.md) | 填好的範例，示範每段要寫多細 |
| `.github/ISSUE_TEMPLATE/ticket.yml` | 網頁上開工單的表單（同樣欄位） |
| `.github/pull_request_template.md` | 回報格式 |

## 流程
```
派發者：定合約 → 依「檔案擁有權」切工單 → gh issue create（status:ready）
主代理：認領（status:in-progress）→ 分支 t-<編號>-<名稱> → 啟動子代理
子代理：在自己的 worktree 實作與測試 → 回報
主代理：讀 diff、自己重跑檢查 → 更新系統文件 → PR（Closes #）+ status:review → 回報隊員，不合併
整合者：檢查 PR、重跑檢查 → CI 綠燈 → 合併（部署）→ 工單自動關閉
派發者：看合併後的「偏離」與「後續」，需要時開新工單
```

## 標籤
標籤已在 GitHub 建好，不用自己建。`main` 要求 `arch`、`web`、`backend`、`app` 四項 CI 通過，只有整合者能合併（[DEPLOY.md](../DEPLOY.md)）。

| 標籤 | 意思 |
|---|---|
| `ticket` | 這是工單 |
| `status:ready` | 可以開始 |
| `status:in-progress` | 有人在做 |
| `status:review` | PR 已開，等審 |
| `blocked` | 卡住（依賴未完成、或要改合約） |
| `deviation` | PR 含偏離，審的人要特別看 |

## 交給 AI
- 跟 AI 說「請看 README 開始」，它會列出工單讓你選，完整流程見 [WORKFLOW.md](../WORKFLOW.md)
- 每個人的 AI 是**主代理**，負責檢查與開 PR，不合併；**實作由子代理完成**
- 沒有子代理功能的工具：另開一個 session 實作，原本的 session 負責檢查
- 一張工單一個分支；不要讓兩個 AI 同時做會改到同一檔案的工單
- 同一輪多個 AI 平行開發的做法見 [WORKFLOW.md](../WORKFLOW.md)「同一輪多個 AI 平行開發」
