@AGENTS.md

## Gemini specifics
- Read `AGENTS.md` and `.claude/skills/townpass-start/SKILL.md` first; the skills are plain markdown.
- No subagent feature: start a separate session for the implementation and keep this one for checking.
- Never merge. Never delete or weaken a test, or edit `.github/` or `tools/check-*`, to make a check pass: report the failure instead.
