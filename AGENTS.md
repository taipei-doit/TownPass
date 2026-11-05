# AGENTS.md - instructions for AI assistants (and humans)

Project: **城市通微服務** for 2026 臺北秋季程式設計節 (Taipei Codefest). A web microservice that runs
inside the TownPass app's WebView, plus a FastAPI backend. Fork of `taipei-doit/TownPass`.
Write user-facing text and docs in **Traditional Chinese**.

## Where things are
| Path | What |
|---|---|
| `services/web/` | Vue 3 + Vite + TS + Tailwind microservice (the product) |
| `services/backend/` | FastAPI + SQLModel (Postgres on Render, SQLite locally) |
| `lib/`, `android/` | TownPass Flutter app - change only the service entry / bridge handlers |
| `docs/system/` | **Specs, decisions, glossary, layer rules, testing** - read README there first |
| `docs/tickets/` | Ticket template + example; tickets themselves are GitHub issues labelled `ticket` |
| `.claude/skills/` | `townpass-ui`, `townpass-feature`, `townpass-ticket` - workflows (plain markdown, any AI can read them) |
| `tools/` | isolated toolchain setup (`setup-windows.ps1`, `dev-shell.ps1`, `doctor.ps1`), `check-arch.mjs` |

## Non-negotiable rules
1. **Layers:** presentation → logic → data, calls only go down. Modules are used only through their public interface (`index.ts` / package `__init__.py`). Helpers inside an interface are named `__xxx` and are private. → `docs/system/05-logic-layer.md`
2. **UI:** compose numbered components (A/M/O/T, P, `XX-P##`/`XX-C##`), one component per file, official TownPass tokens only. → `.claude/skills/townpass-ui/SKILL.md`
3. **DB:** a module declares only the columns it needs in its `models.py`; missing tables/columns are added on startup; never drop/rename/retype. → `docs/system/06-data-layer.md`
4. **Competition rules:** no cloud LLM calls at runtime (on-device only, no PRC-brand models), no commercial SDKs (no Google Maps), core data must be open data with cited sources, our code is AGPL-3.0.
5. **Privacy:** from the TownPass account use only `id` and `realName`. Never store/send ID number, phone, address, birthday.
6. **Working on a ticket:** follow `.claude/skills/townpass-ticket/SKILL.md` - stay inside the ticket's scope, report deviations in the PR.

## Before you say "done"
```bash
node tools/check-arch.mjs --catalog
cd services/web && pnpm build && pnpm test
cd services/backend && uv run ruff check . && uv run pytest -q
```
UI changes: run on the Android emulator and look at a screenshot (`docs/system/07-testing.md` §5).
Windows: open terminals with `. .\tools\dev-shell.ps1` first (isolated toolchain, `docs/system/08-environment.md`).
