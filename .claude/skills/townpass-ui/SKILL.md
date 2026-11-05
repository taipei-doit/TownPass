---
name: townpass-ui
description: Build or change screens in the TownPass microservice web app (services/web) using the official TownPass design tokens and the numbered component kit (A/M/O/T, P, XX-P/XX-C). Use for any UI work - new page, new component, layout tweak, styling, mobile/WebView issues - so screens are composed from existing numbered components instead of hand-written styled HTML.
---

# TownPass UI development

You are working on the **presentation layer** of `services/web`. The look is fixed by the official TownPass design system; your job is to **compose numbered components**, adjusting the existing structure rather than inventing new styles.

## Read first (in this order)
1. `docs/system/04-presentation-layer.md` - levels, numbering, composition rules, tokens
2. `docs/system/components.md` - every existing component with its ID (generated)
3. The closest existing example: `services/web/src/features/example/ui/` (list page EX-P01, detail page EX-P02)
4. `services/web/src/ui/index.ts` - what the kit exports

## Hard rules (CI fails otherwise - `node tools/check-arch.mjs`)
- Every `.vue` starts with `/** @component <ID> <Name> — 中文說明 */` inside `<script setup>`.
  IDs: `ui/atoms` A##, `ui/molecules` M##, `ui/organisms` O##, `ui/templates` T##, `pages` P##, `features/<f>/ui` `<CODE>-P##` (route page) / `<CODE>-C##` (component). Never reuse a number.
- Pages/components never import `@/platform/*`, `modules/*/data`, or another feature. Get data and actions from the feature's own `../logic` (or `@/modules/<x>`).
- `src/ui/**` never imports `modules/`, `platform/`, `features/` - use props/emits/inject.
- Colours only from tokens (`primary-*`, `secondary-*`, `grey-*`, `main-*`, `mid-*`, `orange-*`, `warn-*`, `success`, `shadow-card`, `text-h1`). No hex codes, no Tailwind default palette (`blue-500`), no other UI library.

## How to build a screen
1. Sketch the screen as a tree of existing components first (write it in your plan with IDs), e.g.
   `EX-P02 = T02 DetailPage { headerAction: EX-C02, info: M06, map: O02, notices: O03, actions: A01×2 }`.
2. Reuse > extend > create:
   - existing component fits → use it
   - nearly fits → add an optional prop/slot (backwards compatible; mention it in the PR)
   - only your feature needs it → new `<CODE>-C##` file in `features/<f>/ui/`
   - 2+ features need it → new shared component at the next free A/M/O number, export it in `ui/index.ts` with `// ID` comment, add it to `pages/UiGalleryPage.vue` (P03)
3. One component per file. If a template grows past ~80 lines or has a second nameable block, split it.
4. Stateless components: props in, emits out. State lives in the logic layer composable (`useXxx()`).
5. Route pages: wrap in `PageContainer` (T01) with `title` and `back`; put sticky buttons/inputs in its `#bottom` slot. Detail screens use `DetailPage` (T02).

## Mobile / in-app specifics
- Runs inside the TownPass WebView (375px wide). The app draws its own title bar + back arrow; T01 hides ours in-app automatically.
- Bottom areas: always via T01 `#bottom` (handles the gesture bar).
- Maps: only `OsmMap` (O02) - Google Maps is forbidden by the competition rules.
- Touch targets: primary buttons `h-11`, chips `h-9`. Every icon-only button needs `aria-label`.
- All visible text in Traditional Chinese.

## Verify before you report
```bash
node tools/check-arch.mjs --catalog     # rules + refresh docs/system/components.md
cd services/web && pnpm build && pnpm test
```
Then check it on the emulator (docs/system/07-testing.md §5) and attach a screenshot
(`adb exec-out screencap -p > shot.png`). Look at the screenshot: overflow at 375px, text cut off,
buttons hidden behind the gesture bar, two back arrows = not done.

## Report
In the PR: the component tree you built (with IDs), any new/changed shared components and why,
screenshots, and deviations from the ticket.
