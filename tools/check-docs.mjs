#!/usr/bin/env node
/**
 * CI gate: code changes must come with documentation changes (docs/WORKFLOW.md step 8).
 *   node tools/check-docs.mjs <base-commit>
 * Passes when the PR also changes docs/, data/SOURCES.md, AGENTS.md, a README or a skill, or when
 * the PR description (env PR_BODY) has a line starting with: 無需更新文件：<reason>
 */
import { execFileSync } from 'node:child_process'

const base = process.argv[2] ?? 'origin/main'
const changed = execFileSync('git', ['diff', '--name-only', `${base}...HEAD`], { encoding: 'utf8' }).split('\n').filter(Boolean)

const isTest = (f) => /(^|\/)tests?\//.test(f)
const isCode = (f) => /^(services\/(web|backend)\/(src|scripts|public)\/|lib\/|android\/|tools\/|\.github\/workflows\/)/.test(f) && !isTest(f)
const isDoc = (f) => /^docs\//.test(f) || f === 'data/SOURCES.md' || f === 'AGENTS.md' || /(^|\/)README\.md$/.test(f) || /^\.claude\/skills\//.test(f)

const code = changed.filter(isCode)
const docs = changed.filter(isDoc)
const excuse = (process.env.PR_BODY ?? '').match(/^\s*無需更新文件[:：]\s*\S.*$/m)

if (!code.length) console.log('no code changes')
else if (docs.length) console.log(`code changes come with docs: ${docs.join(', ')}`)
else if (excuse) console.log(`docs skipped: ${excuse[0].trim()}`)
else {
  console.error(`This PR changes code but no documentation:\n  ${code.slice(0, 10).join('\n  ')}`)
  console.error('\nUpdate the system docs (docs/WORKFLOW.md step 8), or add this line to the PR description:')
  console.error('  無需更新文件：<reason>')
  process.exit(1)
}
