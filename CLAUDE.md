@AGENTS.md

## Claude Code specifics
- Project skills in `.claude/skills/` load automatically: `townpass-start` at the start of every session, `townpass-ticket` when dispatching or executing a ticket, `townpass-feature` for feature work (web + backend), `townpass-ui` for screens.
- Implementation goes to a subagent (Agent tool with `isolation: "worktree"`); this session checks, updates docs and merges.
- Glossary: `docs/system/03-glossary.md` - use those terms in code comments, PRs and replies.
