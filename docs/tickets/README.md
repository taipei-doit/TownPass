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
執行者：留言「開始處理」+ status:in-progress → 分支 t-<編號>-<名稱> → 實作 → 驗證 → PR（Closes #）+ status:review
派發者：看 PR 的「驗收對照」與「偏離」→ 合併 → 工單自動關閉
```

## 標籤
| 標籤 | 意思 |
|---|---|
| `ticket` | 這是工單 |
| `status:ready` | 可以開始 |
| `status:in-progress` | 有人在做 |
| `status:review` | PR 已開，等審 |
| `blocked` | 卡住（依賴未完成、或要改合約） |
| `deviation` | PR 含偏離，審的人要特別看 |

## 交給 AI
- **本機 Claude Code**：在倉庫內開新 session，貼上工單的「提示詞」段落（skills 會自動載入）
- **雲端**（Claude Code on the web 等）：選這個倉庫，貼上提示詞與工單網址
- **其他 AI 工具**：讓它先讀 `AGENTS.md`，再貼提示詞
- 一張工單一個 session／一個分支；不要讓兩個 AI 同時做會改到同一檔案的工單
