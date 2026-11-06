---
name: townpass-start
description: Set up a teammate's machine and working session for the TownPass hackathon repo - checks and installs the toolchain, connects GitHub, syncs, reads the docs, lists tickets, lets the user pick one, then runs the ticket with a subagent through review, docs update and merge. Use at the start of a session in this repo, when the user says to read the README, start, 開始, 開工, set up the environment, or asks what to work on.
---

# Starting work in TownPass

You are the **main agent**. You set things up, delegate, check and merge. **Subagents write the
implementation.** Talk to the user in Traditional Chinese. Do the steps in order and report each
result briefly; only stop for what needs the user.

## 1. Environment and sync

Windows:
```powershell
powershell -ExecutionPolicy Bypass -File tools\start.ps1
```
It checks the toolchain (installs it if missing: about 10 GB, 20-40 minutes, so run it in the
background and tell the user), GitHub login and permission, syncs with GitHub, installs dependencies
and lists tickets. It never discards work. Exit codes: `0` ready, `2` needs the user, `1` failed.

| Script says | Do |
|---|---|
| `NEEDS YOU: Log in to GitHub` | Ask the user to run `gh auth login --web --git-protocol https`, wait, run the script again |
| `NEEDS YOU: Ask the repo owner` | Tell the user who to ask. They can read and plan, not push |
| `FAILED` | Read the log it names and fix the cause; known problems: `docs/system/08-environment.md` §5 |

macOS or Linux has no script: install the versions in `tools/versions.ps1` yourself, keep them out of
global settings where you can, then run the steps of `tools/start.ps1` by hand.

In every later PowerShell terminal, first run `. .\tools\dev-shell.ps1`.

## 2. Read before doing anything else

1. `AGENTS.md`: rules that are never broken
2. `docs/WORKFLOW.md`: the whole process
3. `docs/system/README.md`, then `10-architecture.md` (stack, source tree, interfaces), `02-spec.md`, `03-glossary.md`
4. `docs/system/09-addons.md` and `docs/system/components.md`: what already exists, so nothing gets rebuilt

Then give the user a short summary of what the project is and what is available.

## 3. Pick a ticket

Show the tickets from the script (or `gh issue list -R hackathon-taipei/TownPass --label ticket --state open`).
For each `READY` one give the number, title, priority and what it owns. **Ask the user which one to
take. Never choose for them.** No tickets: say so and ask whether they want to dispatch some
(`townpass-ticket` section A).

Claim it: `townpass-ticket` section B step 1.

## 4. Work: the main agent delegates, checks and merges

Follow `townpass-ticket` section B. The short version:

| Step | Who |
|---|---|
| Read the ticket and required docs, write the subagent's brief | main |
| Implement and test on the ticket's branch, in its own worktree | **subagent** |
| Read the diff against the ticket, run every check again, look at screenshots | main |
| Send problems back to the subagent to fix | main |
| Update the system docs, open the PR, report deviations | main |
| Merge when CI is green, then sync `main` and check the live site | main |

## 5. Before ending the session

Tell the user: what merged and the live URL, what isn't verified, deviations, and the next `READY` ticket.
