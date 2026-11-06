#!/usr/bin/env node
/**
 * Compares embedding models and retrieval strategies on eval/corpus.json + eval/questions.json.
 *   node eval/compare.mjs                      all models
 *   node eval/compare.mjs Xenova/multilingual-e5-small
 *   node eval/compare.mjs onnx-community/embeddinggemma-300m-ONNX@q4   a different quantisation
 * Prints: right document at rank 1 and in the top 3, right fact in the top chunk and top 4 chunks,
 * how well unanswerable questions separate, and tool routing accuracy.
 */
import { readFileSync } from 'node:fs'
import { pipeline } from '@huggingface/transformers'
import MiniSearch from 'minisearch'

const here = new URL('.', import.meta.url)
const corpus = JSON.parse(readFileSync(new URL('corpus.json', here), 'utf8'))
const questions = JSON.parse(readFileSync(new URL('questions.json', here), 'utf8'))
const TODAY = new Date().toISOString().slice(0, 10)

const E5 = { q: (t) => `query: ${t}`, p: (t) => `passage: ${t}` }
const NONE = { q: (t) => t, p: (t) => t }
const GEMMA = { q: (t) => `task: search result | query: ${t}`, p: (t) => `title: none | text: ${t}` }
// EmbeddingGemma's documented form with a real title (see passageOf)
const GEMMA_TITLED = { ...GEMMA, titled: true }
const MODELS = {
  'Xenova/multilingual-e5-small': [E5, 'q8'],
  'Xenova/multilingual-e5-base': [E5, 'q8'],
  'Xenova/paraphrase-multilingual-MiniLM-L12-v2': [NONE, 'q8'],
  'Xenova/paraphrase-multilingual-mpnet-base-v2': [NONE, 'q8'],
  'Xenova/distiluse-base-multilingual-cased-v2': [NONE, 'q8'],
  'onnx-community/embeddinggemma-300m-ONNX': [GEMMA, 'q8'],
  'titled:onnx-community/embeddinggemma-300m-ONNX': [GEMMA_TITLED, 'q8'],
}

const docs = corpus.filter((d) => !d.validTo || d.validTo >= TODAY)
const chunks = docs.flatMap((d) => {
  const lines = d.text.split('\n')
  const head = { doc: d.id, title: d.title, text: [d.subtitle, lines[0]].filter(Boolean).join('；') }
  return [head, ...lines.map((text) => ({ doc: d.id, title: d.title, text }))]
})

const CJK = /[㐀-鿿豈-﫿]/
function tokenize(text) {
  const out = []
  for (const part of text.toLowerCase().split(/[\s\p{P}\p{S}]+/u)) {
    let latin = ''
    for (let i = 0; i < part.length; i++) {
      const c = part[i]
      if (CJK.test(c)) {
        if (latin) out.push(latin)
        latin = ''
        out.push(c)
        if (part[i + 1] && CJK.test(part[i + 1])) out.push(c + part[i + 1])
      } else latin += c
    }
    if (latin) out.push(latin)
  }
  return out
}
const lexical = new MiniSearch({ idField: 'i', fields: ['title', 'text'], tokenize, searchOptions: { boost: { title: 2 }, combineWith: 'OR' } })
lexical.addAll(chunks.map((c, i) => ({ i, ...c })))

const dot = (a, b) => a.reduce((s, x, i) => s + x * b[i], 0)
const pct = (n, d) => `${Math.round((n / d) * 100)}%`

function rankVector(qv, vecs) {
  return vecs.map((v, i) => [i, dot(qv, v)]).sort((a, b) => b[1] - a[1]).map(([i]) => i)
}
function rankLexical(q) {
  return lexical.search(q).map((r) => r.id)
}
function fuse(lists, k = 60, weights = lists.map(() => 1)) {
  const score = new Map()
  lists.forEach((list, w) => list.forEach((id, r) => score.set(id, (score.get(id) ?? 0) + weights[w] / (k + r + 1))))
  return [...score.entries()].sort((a, b) => b[1] - a[1]).map(([i]) => i)
}
function grade(name, rank) {
  let top1 = 0, top3 = 0, fact1 = 0, fact4 = 0
  for (const t of questions.retrieval) {
    const order = rank(t.q)
    const docOrder = [...new Set(order.map((i) => chunks[i].doc))]
    if (docOrder[0] === t.doc) top1++
    if (docOrder.slice(0, 3).includes(t.doc)) top3++
    if (chunks[order[0]]?.text.includes(t.fact)) fact1++
    if (order.slice(0, 4).some((i) => chunks[i].text.includes(t.fact))) fact4++
  }
  const n = questions.retrieval.length
  console.log(`  ${name.padEnd(26)} doc@1 ${pct(top1, n).padStart(4)}  doc@3 ${pct(top3, n).padStart(4)}  fact@1 ${pct(fact1, n).padStart(4)}  fact@4 ${pct(fact4, n).padStart(4)}`)
}

/** The threshold that best splits answerable from unanswerable by top similarity. */
function separation(answerable, unanswerable) {
  let best = { t: 0, a: 0, u: 0, score: -1 }
  for (let t = 0.3; t < 1; t += 0.005) {
    const a = answerable.filter((s) => s >= t).length / answerable.length
    const u = unanswerable.filter((s) => s < t).length / unanswerable.length
    if (a + u > best.score) best = { t, a, u, score: a + u }
  }
  return best
}

const examples = {
  show_map: ['在地圖上標出施工的位置', '這個活動在什麼地方', '幫我標出地點', '哪裡有道路施工', '顯示這個地方的位置', '指給我看在哪一帶'],
  show_image: ['給我看圖片', '顯示公文的附圖', '看現場照片', '這個地方長什麼樣子', '活動海報給我看', '有沒有流程圖'],
  none: ['這個要收費嗎', '幾點開放', '有什麼規定', '要怎麼申請', '內容是什麼', '要準備哪些文件', '多少錢', '可以帶寵物嗎', '什麼時候結束', '有什麼節目', '需要報名嗎'],
}

async function run(id) {
  const [model, wanted] = id.split('@')
  const [prefix, defaultDtype] = MODELS[model]
  const dtype = wanted ?? defaultDtype
  const t0 = performance.now()
  const embedder = await pipeline('feature-extraction', model.replace('titled:', ''), { dtype, device: 'cpu' })
  const embed = async (texts) => {
    const out = []
    for (let i = 0; i < texts.length; i += 16) out.push(...(await embedder(texts.slice(i, i + 16), { pooling: 'mean', normalize: true })).tolist())
    return out
  }
  const passageOf = (c) => (prefix.titled ? `title: ${c.title} | text: ${c.text}` : prefix.p(`${c.title}：${c.text}`))
  const vecs = await embed(chunks.map(passageOf))
  const load = performance.now() - t0
  const speed0 = performance.now()
  await embed([prefix.q('公園可以帶寵物嗎？')])
  const queryMs = performance.now() - speed0
  const H = questions.holdout
  const all = [...questions.retrieval, ...H.retrieval].map((t) => t.q).concat(questions.unanswerable, H.unanswerable, questions.tools.map((t) => t.q), H.tools.map((t) => t.q))
  const qvs = new Map((await embed(all.map(prefix.q))).map((v, i) => [all[i], v]))
  console.log(`\n${id}  (${Math.round(load / 1000)}s, ${vecs.length} chunks)`)
  grade('vector', (q) => rankVector(qvs.get(q), vecs))
  grade('lexical (bigram BM25)', rankLexical)
  grade('hybrid RRF', (q) => fuse([rankVector(qvs.get(q), vecs), rankLexical(q)]))
  grade('hybrid RRF, vector x2', (q) => fuse([rankVector(qvs.get(q), vecs), rankLexical(q)], 60, [2, 1]))

  const top = (q) => Math.max(...vecs.map((v) => dot(qvs.get(q), v)))
  const sep = separation(questions.retrieval.map((t) => top(t.q)), questions.unanswerable.map(top))
  console.log(`  unanswerable: threshold ${sep.t.toFixed(3)} keeps ${pct(sep.a, 1)} answerable, rejects ${pct(sep.u, 1)} unanswerable`)

  const exVecs = {}
  for (const [k, list] of Object.entries(examples)) exVecs[k] = await embed(list.map(prefix.p))
  const scores = questions.tools.map((t) => {
    const s = Object.fromEntries(Object.entries(exVecs).map(([k, vs]) => [k, Math.max(...vs.map((v) => dot(qvs.get(t.q), v)))]))
    return { ...t, s }
  })
  let best = { acc: -1 }
  for (let min = 0.3; min < 1; min += 0.01) for (const margin of [0, 0.005, 0.01, 0.02, 0.03, 0.05]) {
    const picks = scores.map(({ s }) => {
      const [a, b] = s.show_map >= s.show_image ? ['show_map', 'show_image'] : ['show_image', 'show_map']
      return s[a] >= min && s[a] - Math.max(s[b], s.none) >= margin ? a : null
    })
    const right = picks.filter((p, i) => p === scores[i].tool).length
    const falseCalls = picks.filter((p, i) => p && !scores[i].tool).length
    const wrongTool = picks.filter((p, i) => p && scores[i].tool && p !== scores[i].tool).length
    if (right > (best.acc ?? -1) || (right === best.acc && falseCalls < best.falseCalls)) best = { acc: right, falseCalls, wrongTool, min, margin, n: scores.length }
  }
  console.log(`  tool routing: ${best.acc}/${best.n} right, ${best.falseCalls} false calls, ${best.wrongTool} wrong tool (min ${best.min.toFixed(2)}, margin ${best.margin})`)

  // Unseen questions, scored with the values chosen on the set above
  const pick = (s, min, margin) => {
    const [a, b] = s.show_map >= s.show_image ? ['show_map', 'show_image'] : ['show_image', 'show_map']
    return s[a] >= min && s[a] - Math.max(s[b], s.none) >= margin ? a : null
  }
  let doc1 = 0, fact1 = 0, fact4 = 0, kept = 0
  for (const t of H.retrieval) {
    const order = rankVector(qvs.get(t.q), vecs)
    if (chunks[order[0]].doc === t.doc) doc1++
    if (chunks[order[0]].text.includes(t.fact)) fact1++
    if (order.slice(0, 4).some((i) => chunks[i].text.includes(t.fact))) fact4++
    if (top(t.q) >= sep.t) kept++
  }
  const rejected = H.unanswerable.filter((q) => top(q) < sep.t).length
  const toolRows = H.tools.map((t) => {
    const s = Object.fromEntries(Object.entries(exVecs).map(([k, vs]) => [k, Math.max(...vs.map((v) => dot(qvs.get(t.q), v)))]))
    return { ...t, got: pick(s, best.min, best.margin) }
  })
  const misses = toolRows.filter((t) => t.got !== t.tool)
  console.log(`  HOLDOUT doc@1 ${doc1}/${H.retrieval.length}  fact@1 ${fact1}  fact@4 ${fact4}  kept ${kept}/${H.retrieval.length}  rejected ${rejected}/${H.unanswerable.length}  tools ${toolRows.length - misses.length}/${toolRows.length}  false calls ${misses.filter((t) => t.got && !t.tool).length}`)
  for (const m of misses) console.log(`    miss: ${m.q} -> ${m.got} (want ${m.tool})`)
  const everyTool = [...questions.tools, ...H.tools].map((t) => ({ ...t, s: Object.fromEntries(Object.entries(exVecs).map(([k, vs]) => [k, Math.max(...vs.map((v) => dot(qvs.get(t.q), v)))])) }))
  for (const margin of [0, 0.01, 0.02, 0.03, 0.05]) {
    const got = everyTool.map((t) => pick(t.s, 0.3, margin))
    const right = got.filter((g, i) => g === everyTool[i].tool).length
    const falseCalls = got.filter((g, i) => g && !everyTool[i].tool).length
    const wrong = got.filter((g, i) => g && everyTool[i].tool && g !== everyTool[i].tool).length
    const missed = got.filter((g, i) => !g && everyTool[i].tool).length
    console.log(`  all tools margin ${margin}: ${right}/${got.length} right, false calls ${falseCalls}, wrong tool ${wrong}, missed ${missed}`)
  }
  // The whole chat box: fact questions must stay with retrieval, tool questions must reach the tool.
  // A tool also has to be closer to the question than the best line in the data, by `delta`.
  const scored = [
    ...[...questions.retrieval, ...H.retrieval].map((t) => ({ q: t.q, want: null, kind: 'fact' })),
    ...[...questions.unanswerable, ...H.unanswerable].map((q) => ({ q, want: null, kind: 'none' })),
    ...[...questions.tools, ...H.tools].map((t) => ({ q: t.q, want: t.tool, kind: 'tool' })),
  ].map((t) => ({ ...t, top: top(t.q), s: Object.fromEntries(Object.entries(exVecs).map(([k, vs]) => [k, Math.max(...vs.map((v) => dot(qvs.get(t.q), v)))])) }))
  for (const delta of [-1, 0, 0.02, 0.04, 0.06, 0.08, 0.1, 0.12]) for (const margin of [0.01, 0.03]) {
    const got = scored.map((t) => {
      const tool = pick(t.s, 0.3, margin)
      return tool && t.s[tool] >= t.top + delta ? tool : null
    })
    const stolen = got.filter((g, i) => g && scored[i].kind === 'fact').length
    const none = got.filter((g, i) => g && scored[i].kind === 'none').length
    const toolRows = scored.map((t, i) => [t, got[i]]).filter(([t]) => t.kind === 'tool')
    const right = toolRows.filter(([t, g]) => g === t.want).length
    const falseCalls = toolRows.filter(([t, g]) => g && !t.want).length
    const wrong = toolRows.filter(([t, g]) => g && t.want && g !== t.want).length
    const missed = toolRows.filter(([t, g]) => !g && t.want).length
    console.log(`  CHAT delta ${String(delta).padEnd(5)} margin ${margin}: facts stolen ${stolen}/68, unanswerable routed ${none}/20, tools ${right}/${toolRows.length} (false ${falseCalls}, wrong ${wrong}, missed ${missed})`)
  }
  const tops = [...questions.retrieval, ...H.retrieval].map((t) => top(t.q)).sort((a, b) => a - b)
  const noneTops = [...questions.unanswerable, ...H.unanswerable].map(top).sort((a, b) => b - a)
  console.log(`  lowest answerable ${tops.slice(0, 4).map((x) => x.toFixed(3)).join(' ')} | highest unanswerable ${noneTops.slice(0, 4).map((x) => x.toFixed(3)).join(' ')}`)
  await embedder.dispose()
}

for (const id of process.argv[2] ? [process.argv[2]] : Object.keys(MODELS)) {
  try {
    await run(id)
  } catch (err) {
    console.log(`\n${id}: FAILED ${err.message?.slice(0, 120)}`)
  }
}
