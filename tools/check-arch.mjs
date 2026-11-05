#!/usr/bin/env node
/**
 * Architecture guard - run in CI and before every PR:
 *   node tools/check-arch.mjs                 check rules (exit 1 on violations)
 *   node tools/check-arch.mjs --catalog       also (re)write docs/system/components.md
 *
 * Rules (docs/system/02-spec.md §4, 05/06 layer docs):
 *   W1 presentation (ui/, pages/, features/x/ui/) must not import the data layer (platform/, modules/x/data.ts, features/x/data/)
 *   W2 logic (modules/x/logic.ts, features/x/logic/) must not import presentation (.vue, ui/, pages/)
 *   W3 data (platform/, modules/x/data.ts, features/x/data/) must not import logic or presentation
 *   W4 other code reaches a module only through its index (@/modules/x)
 *   W5 a feature must not import another feature
 *   W6 modules/x/index.ts only re-exports from ./logic
 *   W7 names starting with "__" are private: never exported, never imported
 *   W8 every component has a unique `@component <ID>` matching its folder
 *   B1-B4 backend layers: api/deps -/-> repo, service -/-> api/deps, repo -/-> service/api, models -/-> others
 *   B5 another backend feature is used only through its package root
 *   B6 backend "__" names are never imported or called from another module
 * Uses only Node built-ins (no install needed).
 */
import { existsSync, readdirSync, readFileSync, statSync, writeFileSync } from 'node:fs'
import { dirname, join, relative, resolve, sep } from 'node:path'
import { fileURLToPath } from 'node:url'

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), '..')
const WEB = join(ROOT, 'services/web/src')
const BE = join(ROOT, 'services/backend/src/townpass_backend')
const violations = []
const norm = (p) => p.split(sep).join('/')
const rel = (p) => norm(relative(ROOT, p))
const flag = (rule, file, line, msg) => violations.push(`${rel(file)}:${line}  [${rule}] ${msg}`)

function walk(dir, exts, out = []) {
  if (!existsSync(dir)) return out
  for (const name of readdirSync(dir)) {
    const p = join(dir, name)
    if (statSync(p).isDirectory()) walk(p, exts, out)
    else if (exts.some((e) => name.endsWith(e))) out.push(p)
  }
  return out
}
const lineOf = (text, index) => text.slice(0, index).split('\n').length

// ---------------------------------------------------------------- web
function webLayer(file) {
  const r = norm(relative(WEB, file))
  if (r === 'App.vue' || /^(ui|pages)\//.test(r) || /^features\/[^/]+\/ui\//.test(r)) return 'presentation'
  if (/^modules\/[^/]+\/logic\.ts$/.test(r) || /^features\/[^/]+\/logic\//.test(r)) return 'logic'
  if (/^platform\//.test(r) || /^modules\/[^/]+\/data\.ts$/.test(r) || /^features\/[^/]+\/data\//.test(r)) return 'data'
  return 'wiring'
}

function resolveWebImport(from, spec) {
  let base
  if (spec.startsWith('@/')) base = join(WEB, spec.slice(2))
  else if (spec.startsWith('.')) base = resolve(dirname(from), spec)
  else return null // package import
  for (const c of [base, `${base}.ts`, `${base}.vue`, join(base, 'index.ts')]) if (existsSync(c) && statSync(c).isFile()) return c
  return base
}

const IMPORT_RE = /(?:import|export)\s+(type\s+)?(?:([\s\S]*?)\s+from\s+)?['"]([^'"]+)['"]|import\(\s*['"]([^'"]+)['"]\s*\)/g

function checkWebFile(file) {
  const text = readFileSync(file, 'utf8')
  const layer = webLayer(file)
  const r = norm(relative(WEB, file))
  const myFeature = r.match(/^features\/([^/]+)\//)?.[1]
  const myModule = r.match(/^modules\/([^/]+)\//)?.[1]

  for (const m of text.matchAll(IMPORT_RE)) {
    const spec = m[3] ?? m[4]
    const clause = m[2] ?? ''
    const line = lineOf(text, m.index)
    // W7 importing private names
    for (const name of clause.replace(/[{}]/g, ' ').split(',')) {
      const imported = name.trim().replace(/^type\s+/, '').split(/\s+as\s+/)[0]?.trim()
      if (imported?.startsWith('__')) flag('W7', file, line, `imports private name ${imported}`)
    }
    const target = resolveWebImport(file, spec)
    if (!target) continue
    const t = norm(relative(WEB, target))
    const tLayer = webLayer(target)
    const tFeature = t.match(/^features\/([^/]+)\//)?.[1]
    const tModule = t.match(/^modules\/([^/]+)\//)?.[1]

    if (layer === 'presentation' && tLayer === 'data') flag('W1', file, line, `presentation imports data layer ${t}`)
    if (layer === 'logic' && tLayer === 'presentation') flag('W2', file, line, `logic imports presentation ${t}`)
    if (layer === 'data' && (tLayer === 'logic' || tLayer === 'presentation' || /^modules\/[^/]+\/index\.ts$/.test(t)))
      flag('W3', file, line, `data layer imports ${t}`)
    if (tModule && tModule !== myModule && !/^modules\/[^/]+\/index\.ts$/.test(t))
      flag('W4', file, line, `reach module "${tModule}" through @/modules/${tModule}, not ${t}`)
    if (tFeature && tFeature !== myFeature)
      flag('W5', file, line, `${myFeature ? `feature "${myFeature}"` : r} imports feature "${tFeature}" (features are independent)`)
    if (/^modules\/[^/]+\/index\.ts$/.test(r) && !spec.startsWith('./logic')) flag('W6', file, line, `module index re-exports from ${spec} (only ./logic allowed)`)
  }
  // W7 exporting private names
  for (const m of text.matchAll(/export\s+(?:const|let|var|function|async\s+function|class|type|interface)\s+(__\w+)/g))
    flag('W7', file, lineOf(text, m.index), `exports private name ${m[1]}`)
  for (const m of text.matchAll(/export\s*\{([^}]*)\}/g))
    for (const part of m[1].split(','))
      if (part.trim().split(/\s+as\s+/).at(-1)?.trim().startsWith('__')) flag('W7', file, lineOf(text, m.index), `exports private name ${part.trim()}`)
}

// W8 component IDs
const featureCodes = new Map()
for (const idx of walk(join(WEB, 'features'), ['index.ts'])) {
  const m = norm(relative(WEB, idx)).match(/^features\/([^/]+)\/index\.ts$/)
  if (!m) continue
  const code = readFileSync(idx, 'utf8').match(/\bcode:\s*['"]([^'"]+)['"]/)?.[1]
  if (!code || !/^[A-Z]{2,4}$/.test(code)) flag('W8', idx, 1, `feature "${m[1]}" needs code: 'XX' (2-4 capital letters)`)
  else if ([...featureCodes.values()].includes(code) && !m[1].startsWith('_')) flag('W8', idx, 1, `feature code ${code} already used`)
  featureCodes.set(m[1], code)
}
const catalog = []
const seenIds = new Map()
for (const file of walk(WEB, ['.vue'])) {
  const r = norm(relative(WEB, file))
  if (r === 'App.vue') continue
  const text = readFileSync(file, 'utf8')
  const m = text.match(/@component\s+(\S+)\s+(\S+)(?:\s+[—-]\s+([^*\n]+))?/)
  const expect =
    r.match(/^ui\/atoms\//) ? /^A\d{2}$/ : r.match(/^ui\/molecules\//) ? /^M\d{2}$/ : r.match(/^ui\/organisms\//) ? /^O\d{2}$/
    : r.match(/^ui\/templates\//) ? /^T\d{2}$/ : r.match(/^pages\//) ? /^P\d{2}$/ : null
  const feat = r.match(/^features\/([^/]+)\/ui\//)?.[1]
  const featRe = feat && featureCodes.get(feat) ? new RegExp(`^${featureCodes.get(feat)}-[PC]\\d{2}$`) : null
  if (!m) { flag('W8', file, 1, 'missing `/** @component <ID> <Name> — 說明 */` header'); continue }
  const [, id, name, desc] = m
  const re = expect ?? featRe
  if (re && !re.test(id)) flag('W8', file, 1, `component ID ${id} does not match ${re}`)
  if (seenIds.has(id) && !feat?.startsWith('_')) flag('W8', file, 1, `duplicate component ID ${id} (also ${seenIds.get(id)})`)
  seenIds.set(id, r)
  catalog.push({ id, name, desc: (desc ?? '').trim(), file: r })
}

for (const f of walk(WEB, ['.ts', '.vue'])) {
  checkWebFile(f)
  // W9 module/feature folders contain only their layer files, so every file has a known layer
  const r = norm(relative(WEB, f))
  if (/^modules\//.test(r) && !/^modules\/[^/]+\/(index|logic|data)\.ts$/.test(r))
    flag('W9', f, 1, 'a module folder may only contain index.ts, logic.ts, data.ts')
  if (/^features\//.test(r) && !/^features\/[^/]+\/(index\.ts|ui\/.+\.vue|(logic|data)\/.+\.ts)$/.test(r))
    flag('W9', f, 1, 'a feature folder may only contain index.ts, ui/*.vue, logic/*.ts, data/*.ts')
}

// ---------------------------------------------------------------- backend
const BE_LAYER_RULES = {
  'api.py': ['repo'],
  'deps.py': ['repo'],
  'service.py': ['api', 'deps'],
  'repo.py': ['service', 'api', 'deps'],
  'models.py': ['service', 'repo', 'api', 'deps'],
}
for (const file of walk(BE, ['.py'])) {
  const r = norm(relative(BE, file))
  const text = readFileSync(file, 'utf8')
  const feat = r.match(/^features\/([^/]+)\//)?.[1]
  const base = r.split('/').at(-1)
  for (const m of text.matchAll(/^\s*from\s+(\S+)\s+import\s+([^\n(]+|\([\s\S]*?\))/gm)) {
    const [mod, names] = [m[1], m[2]]
    const line = lineOf(text, m.index)
    const forbidden = feat && BE_LAYER_RULES[base]
    if (forbidden) for (const layer of forbidden) {
      if (mod === `.${layer}` || (mod === '.' && new RegExp(`\\b${layer}\\b`).test(names)))
        flag('B1-4', file, line, `${base} must not import ${layer}`)
    }
    const other = mod.match(/^townpass_backend\.features\.([^.]+)\.(.+)$/)
    if (other && other[1] !== feat) flag('B5', file, line, `use townpass_backend.features.${other[1]} (package root), not .${other[2]}`)
    for (const n of names.replace(/[()]/g, ' ').split(','))
      if (/^__[a-z]\w*[a-z0-9]$/.test(n.trim().split(/\s+as\s+/)[0])) flag('B6', file, line, `imports private name ${n.trim()}`)
  }
  for (const m of text.matchAll(/\b(?!self\b)\w+\.(__[a-z][a-z0-9_]*[a-z0-9])\s*\(/g))
    flag('B6', file, lineOf(text, m.index), `calls private ${m[1]} of another module`)
}

// ---------------------------------------------------------------- output
if (process.argv.includes('--catalog')) {
  const out = join(ROOT, 'docs/system/components.md')
  const rows = catalog.sort((a, b) => a.id.localeCompare(b.id)).map((c) => `| ${c.id} | ${c.name} | ${c.desc} | \`${c.file}\` |`)
  writeFileSync(
    out,
    `# 元件目錄（自動產生）\n\n> 由 \`node tools/check-arch.mjs --catalog\` 從各元件的 \`@component\` 標頭產生，請勿手動編輯。\n\n| 編號 | 元件 | 說明 | 檔案（services/web/src/） |\n|---|---|---|---|\n${rows.join('\n')}\n`,
  )
  console.log(`wrote ${rel(out)} (${catalog.length} components)`)
}
if (violations.length) {
  console.error(`architecture check: ${violations.length} violation(s)\n` + violations.map((v) => '  ' + v).join('\n'))
  process.exit(1)
}
console.log(`architecture check passed (${catalog.length} components, ${seenIds.size} IDs)`)
