/**
 * Asks every evaluation question through the real chat box, the way a user would.
 * A local feature must serve eval/corpus.json as searchItems with assistant: createAgent() (README.md).
 *   Open /#/f/ai, load the models, go back to /#/, then in the browser console:
 *     const m = await import('/eval/chat-check.js'); m.start(); m.summary()
 */
export const state = { done: false, rows: [] }

const wait = (ms) => new Promise((r) => setTimeout(r, ms))

async function ask(input, text) {
  const setValue = Object.getOwnPropertyDescriptor(HTMLInputElement.prototype, 'value').set
  const index = document.querySelectorAll('ol > li').length + 1
  setValue.call(input, text)
  input.dispatchEvent(new Event('input', { bubbles: true }))
  await wait(30)
  const t0 = performance.now()
  input.closest('form').requestSubmit()
  let li
  for (let i = 0; i < 600; i++) {
    await wait(50)
    li = document.querySelectorAll('ol > li')[index]
    if (li?.innerText.trim() && !li.innerText.includes('▍')) break
  }
  const all = li?.innerText ?? ''
  const first = all.split('\n')[0]
  return { ms: Math.round(performance.now() - t0), first, all }
}

const toolOf = (first) => (first.includes('地圖上標出') ? 'show_map' : /張.*圖片/.test(first) ? 'show_image' : null)

export function start() {
  state.done = false
  state.rows = []
  void (async () => {
    const q = await (await fetch('/eval/questions.json')).json()
    const input = document.querySelector('input[type=search]')
    for (const c of [...q.retrieval, ...q.holdout.retrieval]) {
      const r = await ask(input, c.q)
      state.rows.push({ kind: 'fact', q: c.q, ms: r.ms, first: r.first, ok: r.first.includes(c.fact), visible: r.all.includes(c.fact), tool: toolOf(r.first) })
    }
    for (const text of [...q.unanswerable, ...q.holdout.unanswerable]) {
      const r = await ask(input, text)
      state.rows.push({ kind: 'none', q: text, ms: r.ms, first: r.first, ok: !r.first.startsWith('「') && !toolOf(r.first) })
    }
    for (const t of [...q.tools, ...q.holdout.tools]) {
      const r = await ask(input, t.q)
      const got = toolOf(r.first)
      // a tool question answered from a document still shows that document's map or picture
      state.rows.push({ kind: 'tool', q: t.q, want: t.tool, got, first: r.first, ok: got === t.tool, hasMap: r.all.includes('OpenStreetMap') })
    }
    state.done = true
  })()
}

export function summary() {
  const of = (kind) => state.rows.filter((r) => r.kind === kind)
  const count = (rows, test) => `${rows.filter(test).length}/${rows.length}`
  const facts = of('fact')
  return {
    done: state.done,
    answerLineHasFact: count(facts, (r) => r.ok),
    factVisibleInReply: count(facts, (r) => r.visible),
    factQuestionsTakenByTool: count(facts, (r) => r.tool),
    unanswerableHandled: count(of('none'), (r) => r.ok),
    toolsRight: count(of('tool'), (r) => r.ok),
    falseCalls: of('tool').filter((r) => r.got && !r.want).length,
    avgMs: Math.round(facts.reduce((s, r) => s + r.ms, 0) / Math.max(1, facts.length)),
    wrong: state.rows.filter((r) => !r.ok).map((r) => [r.q, r.first.slice(0, 36), r.want, r.got]),
  }
}
