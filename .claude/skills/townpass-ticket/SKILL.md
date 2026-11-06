---
name: townpass-ticket
description: Dispatch or execute work tickets (工單) for parallel development of the TownPass hackathon project. Use when splitting a feature into tickets for teammates/AI agents, writing a ticket, picking up a GitHub issue labelled "ticket", or reporting results and deviations back on a ticket.
---

# Tickets (工單) - parallel development

A ticket is a GitHub Issue (label `ticket`) that contains everything one person or one AI agent
needs to finish a piece of work **alone**, without asking: prompt, what to read, what to do,
which files it owns, the contract it must honour, how to verify, and how to report.
Format: `docs/tickets/TEMPLATE.md`. Example: `docs/tickets/T-000-example.md`.

---

## A. Dispatching (writing tickets)

1. **Contract first.** Before splitting, fix the shared contracts in docs: API endpoints + schemas
   (backend `/docs` or `docs/system/02-spec.md`), bridge messages (`docs/bridge.md`), feature ids/codes.
   Tickets reference these; they never "agree later".
2. **Split by ownership, not by step.** Each ticket owns disjoint paths (a web feature folder, a backend
   feature package, one shared component). Two tickets must never edit the same file. If they would,
   make a separate small ticket for the shared file and mark the others `blocked by` it.
3. **Size:** 1-3 hours. Bigger → split. Each ticket ends in one PR that passes CI on its own.
4. **Number:** `T-001`, `T-002`… (next free number in open+closed issues). Title `[T-012] 公園列表頁（EX-P01）`.
5. Fill **every** section of the template. The prompt section must work when pasted into a fresh AI
   session that has never seen this conversation.
6. Create it:
   ```bash
   gh issue create -R hackathon-taipei/TownPass --label ticket,status:ready --title "[T-012] ..." --body-file ticket.md
   ```
7. Dependencies: write `blocked by #<issue>`; label `blocked` until they merge.

## B. Executing a ticket

Each person's AI is the **main agent**: it delegates, checks, updates docs and opens the PR. It does not
write the implementation, and it does not merge: the integrator does (`docs/DEPLOY.md`). Merging deploys. A **subagent** does. No subagent feature in your tool: start a separate
session for the implementation, and keep this one for checking.

### Main agent
1. **Claim:** comment `開始處理`, assign yourself, swap the label to `status:in-progress`
   (`gh issue edit <n> --add-assignee @me --add-label status:in-progress --remove-label status:ready`),
   then branch `t-<number>-<short-name>` from the latest `origin/main`.
2. **Read** the ticket and everything under 必讀, and load the skills it names.
3. **Start a subagent** on that branch in its own worktree (Claude Code: Agent tool with
   `isolation: "worktree"`). Its brief needs: the ticket URL, the branch, 範圍, 合約, 驗收標準,
   what already exists and must be reused, and the report it must return (files changed, commands
   run with results, deviations, anything unverified). It may not merge or edit outside 範圍.
4. **Check its work yourself. Its report is a claim, not proof.**
   - Read the whole diff against 範圍, 合約 and each 驗收標準
   - Run every command in 驗證方式 again yourself
   - UI: run it on the emulator and look at the screenshot
   - Anything wrong: send it back to the same subagent with what to fix, and check again
5. **Update the system docs** (`docs/WORKFLOW.md` step 8) and commit them on the branch. This is the
   main agent's job, and CI fails a code PR that has none.
6. **Report:**
   - Sync: `git fetch origin && git rebase origin/main`, push
   - Open a PR with the template filled in, `Closes #<issue>`, label `status:review`; add
     `deviation` if there are any. Comment on the issue with the PR link and a 3-line summary
   - **Stop here. Don't merge**, even when CI is green, unless the integrator tells you in this session
     to merge that PR. GitHub refuses a merge from anyone else; don't try to get around it.
   - Fix what the integrator sends back, then push to the same branch
7. **Tell the user:** the PR link, deviations, what isn't verified.

### Integrator
Treat every PR as untrusted, whichever AI wrote it. Read the whole diff against the ticket, look for
deleted or weakened tests, and run the checks yourself on the PR's branch (`docs/WORKFLOW.md` step 9).
Merge one at a time, `gh pr merge <n> --squash --delete-branch`, then check the live site.

### Subagent
Stay inside 範圍: touching anything else (a shared component, `ui/index.ts`, another feature, CI) is a
**deviation** (see D). Follow the layer rules, keep the contract exactly, write the tests, run 驗證方式
and report honestly. Don't open the PR or merge.

## C. Report format (PR body)
- **做了什麼** - what changed, by layer (顯示/邏輯/資料), with component IDs and public interfaces
- **驗收對照** - each acceptance criterion from the ticket: ✅ / ❌ + evidence (test name, screenshot)
- **驗證** - commands run and their results (paste the last lines), screenshots
- **偏離** - every deviation (see D), or "無"
- **後續** - leftovers, risks, follow-up ticket suggestions

## D. Deviations (偏離)
A deviation is anything that differs from the ticket: different approach, extra file touched,
contract change, skipped criterion, new dependency.

| Situation | Do this |
|---|---|
| Small and inside your own folder (naming, internal structure) | Decide, list it under 偏離 in the PR |
| Need to edit a file outside 範圍, or add a shared component | Do the minimal backwards-compatible change, list it under 偏離 with the reason, tag the owner |
| Contract (API/bridge/feature id) must change | **Stop.** Comment on the issue with the proposed change and label `blocked`; continue only on other parts |
| Acceptance criterion impossible / ticket wrong | Comment on the issue explaining why + proposal; don't silently drop it |
| Competition rule risk (cloud LLM, commercial SDK, personal data) | **Stop** and ask - never work around it |

Never mark a ticket done with failing checks or unverified acceptance criteria - report them as ❌.
