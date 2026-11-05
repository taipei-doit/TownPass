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

## B. Executing a ticket (you are the assignee - human or AI)

1. **Claim:** comment `開始處理`, add label `status:in-progress`, branch `t-<number>-<short-name>` from latest `main`.
2. **Read** everything under 必讀 before writing code. Load the skills the ticket names
   (`townpass-ui`, `townpass-feature`).
3. **Stay inside 範圍.** Only edit the paths the ticket owns. Need to touch anything else
   (a shared component, `ui/index.ts`, another feature, CI, docs outside your area) → that is a
   **deviation** (see D).
4. **Implement** following the layer rules; keep the contract exactly.
5. **Verify** with the commands in 驗證方式 (always includes `node tools/check-arch.mjs`, web build+test,
   backend ruff+pytest) and the emulator steps; take screenshots. Look at them.
6. **Report** - open a PR with `.github/pull_request_template.md` filled in, `Closes #<issue>`, label
   `status:review`. Comment on the issue with the PR link and a 3-line summary.

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
