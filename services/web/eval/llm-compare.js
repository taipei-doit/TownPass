/**
 * Compares language models on the GPU. Needs a browser with WebGPU, so it runs in the page:
 *   pnpm dev, open the site, then in the browser console:
 *     const m = await import('/eval/llm-compare.js')
 *     m.start(['onnx-community/granite-4.0-350m-ONNX-web'])   // keep: true keeps the downloads
 *     m.state                                                 // progress and results
 * Don't edit files under src/ while it runs: Vite reloads the page.
 * Scores: RAG answers given the right facts (contains the fact and passes the grounding check), and
 * tool choice written three ways (function calling, Chinese few-shot, English few-shot).
 */
import { generate, loadGenerator, unloadGenerator } from '/src/addons/model/data.ts'
import { isGrounded } from '/src/addons/rag/logic.ts'

export const state = { done: false, current: '', results: {} }

const TOOLS = [
  { type: 'function', function: { name: 'show_map', description: '在對話框的地圖上標出地點，例如施工、活動、設施的位置', parameters: { type: 'object', properties: { query: { type: 'string', description: '要找的主題或地區' } } } } },
  { type: 'function', function: { name: 'show_image', description: '在對話框顯示資料附帶的圖片，例如公文附圖、活動海報', parameters: { type: 'object', properties: { query: { type: 'string', description: '要找的主題' } } } } },
]
const zhPrompt = (q) => `判斷使用者想要什麼，只回答一個詞：地圖、圖片、文字。\n問題：施工在哪裡\n答案：地圖\n問題：給我看附圖\n答案：圖片\n問題：幾點開放\n答案：文字\n問題：活動地點標給我看\n答案：地圖\n問題：現場長什麼樣子\n答案：圖片\n問題：要收費嗎\n答案：文字\n問題：${q}\n答案：`
const enPrompt = (q) => `Classify the Chinese question. Reply with one word only: MAP if the user wants a location, IMAGE if the user wants a picture, TEXT otherwise.\nQuestion: 施工在哪裡 -> MAP\nQuestion: 給我看附圖 -> IMAGE\nQuestion: 幾點開放 -> TEXT\nQuestion: 活動地點標給我看 -> MAP\nQuestion: 現場長什麼樣子 -> IMAGE\nQuestion: 要收費嗎 -> TEXT\nQuestion: ${q} ->`
const readZh = (s) => ({ 地圖: 'show_map', 圖片: 'show_image', 文字: null })[s.match(/地圖|圖片|文字/)?.[0]]
const readEn = (s) => ({ MAP: 'show_map', IMAGE: 'show_image', TEXT: null })[s.toUpperCase().match(/MAP|IMAGE|TEXT/)?.[0]]
const readNative = (s) => s.match(/show_map|show_image/)?.[0] ?? null

const METHODS = [
  ['native', (q) => q, readNative, { maxNewTokens: 48, tools: TOOLS, skipSpecialTokens: false }],
  ['zh', zhPrompt, readZh, { maxNewTokens: 6 }],
  ['en', enPrompt, readEn, { maxNewTokens: 6 }],
]

async function removeDownload(id) {
  const dir = await (await navigator.storage.getDirectory()).getDirectoryHandle('townpass-models')
  const key = id.replace(/[^a-zA-Z0-9._-]+/g, '~')
  for await (const [name] of dir.entries()) if (name.includes(key)) await dir.removeEntry(name)
}

async function testModel(id, corpus, questions, result) {
  const t0 = performance.now()
  await loadGenerator(id, 'webgpu', 'q4f16')
  result.loadSeconds = Math.round((performance.now() - t0) / 1000)

  const cases = questions.retrieval.filter((_, i) => i % 4 === 0)
  result.rag = []
  let total = 0
  for (const c of cases) {
    const d = corpus.find((x) => x.id === c.doc)
    const facts = d.text.split('\n').slice(0, 4).map((line) => `${d.title}：${line}`)
    const prompt = `根據以下資料回答問題，用繁體中文、一句話。\n資料：\n${facts.map((f, i) => `[${i + 1}] ${f}`).join('\n')}\n問題：${c.q}`
    const t1 = performance.now()
    const answer = await generate([{ role: 'user', content: prompt }], { maxNewTokens: 80 })
    total += performance.now() - t1
    result.rag.push({ q: c.q, hasFact: answer.includes(c.fact), grounded: isGrounded(answer, facts), answer: answer.slice(0, 90) })
  }
  result.ragPass = result.rag.filter((r) => r.hasFact && r.grounded).length
  result.ragHasFact = result.rag.filter((r) => r.hasFact).length
  result.ragCases = cases.length
  result.ragMs = Math.round(total / cases.length)

  for (const [name, prompt, read, options] of METHODS) {
    const score = { right: 0, n: questions.tools.length, falseCalls: 0, wrongTool: 0, unreadable: 0, samples: [] }
    for (const t of questions.tools) {
      let raw = ''
      try {
        raw = await generate([{ role: 'user', content: prompt(t.q) }], options)
      } catch (err) {
        raw = `ERROR ${String(err).slice(0, 60)}`
      }
      const read1 = read(raw)
      if (read1 === undefined) score.unreadable++
      const got = read1 ?? null
      if (got === t.tool) score.right++
      else if (got && !t.tool) score.falseCalls++
      else if (got && t.tool) score.wrongTool++
      if (score.samples.length < 3) score.samples.push([t.q, raw.slice(0, 50)])
    }
    result[name] = score
  }
}

export function start(ids, { keep = false } = {}) {
  state.done = false
  void (async () => {
    const corpus = await (await fetch('/eval/corpus.json')).json()
    const questions = await (await fetch('/eval/questions.json')).json()
    for (const id of ids) {
      state.current = id
      const result = (state.results[id] = {})
      try {
        await testModel(id, corpus, questions, result)
      } catch (err) {
        result.error = String(err).slice(0, 200)
      }
      await unloadGenerator().catch(() => {})
      if (!keep) await removeDownload(id).catch(() => {})
    }
    state.done = true
  })()
}
