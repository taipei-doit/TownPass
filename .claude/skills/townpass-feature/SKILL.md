---
name: townpass-feature
description: Add or change a feature end-to-end in the TownPass microservice repo - web feature folder (ui/logic/data layers), backend feature package (api/service/repo/models), dynamic DB columns, login-protected endpoints, open data, and the tests that prove it. Use whenever work touches services/web/src/features, services/web/src/modules, or services/backend/src/townpass_backend/features.
---

# Building a TownPass feature (layered)

Three layers, calls only go **down**: presentation → logic → data. Modules are used only through
their public interface. Helpers inside an interface are named `__xxx` and are private.
CI enforces this with `node tools/check-arch.mjs`.

## Read first
1. `docs/system/02-spec.md` (feature contract §3, rules §4, API contract §5)
2. `docs/system/05-logic-layer.md` and `docs/system/06-data-layer.md`
3. `docs/system/07-testing.md` §3 if anything needs login
4. The reference implementation: web `services/web/src/features/example/`, backend `services/backend/src/townpass_backend/features/examples/`
5. `docs/system/03-glossary.md` - use these words

## Web feature (`services/web/src/features/<id>/`)
```
cp -r services/web/src/features/_template services/web/src/features/<id>
```
| file | layer | may import |
|---|---|---|
| `index.ts` | wiring | `@/framework`, `./logic` |
| `ui/*.vue` | presentation | `@/ui`, `../logic`, `@/modules/<x>` |
| `logic/*.ts` | logic | `vue`, `vue-router`, `@/framework`, `@/modules/<x>`, `../data` |
| `data/*.ts` | data | `@/platform/*` only |

- `index.ts`: `defineFeature({ id: '<folder>', code: 'XX', title, description, icon, routes, keywords, quickActions, searchItems, tools, sources })`. `code` = 2-4 capitals, unique (component ID prefix).
- Map or pictures in the chat box: give search items `geo` / `images` (built-in `show_map`, `show_image`), or add `tools: [defineTool({...})]`. Tools take search text or ids, never coordinates or image URLs. See `docs/system/09-addons.md` §3.
- logic exports the interface (`useXxx()` composables, `xxxSearchItems()`, route helpers). Private helpers `function __x()` - never exported.
- data: try backend via `api()`, fall back to clearly-labelled mock (`範例`) for reads / device storage for writes; **re-throw 401/403**.
- Protected actions: enable the auth add-on (`docs/system/09-addons.md`), then `await requireUser()` from `@/addons/auth` in the logic layer.
- On-device models, RAG, AI in the chat box: pre-written add-ons in `src/addons/`, off by default. Load them as `docs/system/09-addons.md` says; don't write new model code.
- Never import another feature. Need something shared → it belongs in `src/modules/<x>/` (index.ts, logic.ts, data.ts only).

## Backend feature (`services/backend/src/townpass_backend/features/<name>/`)
```
cp -r services/backend/src/townpass_backend/features/_template services/backend/src/townpass_backend/features/<name>
```
| file | role | must not import |
|---|---|---|
| `__init__.py` | public interface: `router`, optional `seed`, functions others may use | - |
| `api.py` / `deps.py` | HTTP only; map exceptions to status codes | `.repo` |
| `service.py` | business rules; returns `schemas` types | `.api`, `.deps`, FastAPI HTTP classes |
| `repo.py` | queries only | `.service`, `.api` |
| `models.py` | SQLModel tables - ONLY the columns this feature needs | other layers |
| `schemas.py` | request/response Pydantic models | - |

- Table names `<feature>_<noun>`; user FK `user_id -> app_user.id`.
- **Need a column? Add it to `models.py` and restart** - `sync_schema()` adds missing tables/columns/indexes (additive only: never rename/drop/retype; rename = new column).
- Protect an endpoint: enable the auth add-on, then `from townpass_backend.addons.auth import CurrentUser` and `def x(user: CurrentUser, ...)`. Always filter personal data by `user.id`.
- Another feature's functionality: import from its package root only (`from townpass_backend.features.opendata import taipei_dataset`).
- Private helpers are module-level `def __x()` (not class methods - Python name-mangles `__` in classes).
- `seed(session)` must be idempotent.
- No LLM inference in the backend (competition rule). No personal data beyond townpass_id + name.

## Tests you must add
- Backend `services/backend/tests/test_<name>.py`: success path, 404/422 path; for protected endpoints the A1-A10 checklist in `docs/system/07-testing.md` §3 (use fixtures `client`, `auth_headers(USER_A)`).
- Web `services/web/tests/<name>.test.ts`: logic-layer behaviour through the public interface (mock `fetch`).
- Open data used → `sources` in `index.ts` + row in `data/SOURCES.md` + `SourceNote` on the page.

## Verify (all must pass) then report
```bash
node tools/check-arch.mjs --catalog
cd services/web && pnpm build && pnpm test
cd services/backend && uv run ruff check . && uv run pytest -q
```
Run it on the emulator (07-testing.md §5). In the PR: layers touched, public interface added/changed,
new DB columns, test evidence, screenshots, deviations.
