import { describe, expect, it, vi } from 'vitest'
import type { RagAnswer } from '@/addons/rag'
import type { AssistantContext } from '@/framework'

const state = vi.hoisted(() => ({
  status: 'ready',
  llm: true,
  modelOutput: '',
  answer: null as unknown,
  completeCalls: 0,
}))

// Fake embedding: each test question or example points along the axis of the word it contains.
const axes = ['地圖', '照片', '收費']
const fakeVector = (text: string) => axes.map((a) => (text.includes(a) ? 1 : 0))
vi.mock('@/addons/model', () => ({
  languageModelReady: () => state.llm,
  embedQuery: vi.fn(async (t: string) => fakeVector(t)),
  embedPassages: vi.fn(async (ts: string[]) => ts.map(fakeVector)),
  complete: vi.fn(async () => {
    state.completeCalls++
    return state.modelOutput
  }),
}))
vi.mock('@/addons/rag', () => ({
  useRag: () => ({ status: { value: state.status }, ask: vi.fn(async () => state.answer) }),
}))

const { answerToResult, chooseTool, createAgent, parseToolCall, pickBySimilarity, routeByMeaning } = await import('@/addons/agent')

const showMap = { name: 'show_map', description: 'x', parameters: { type: 'object' as const, properties: {} }, run: () => ({ text: '' }) }
const mapResult = { text: '地圖', blocks: [{ type: 'map' as const, markers: [{ lat: 25, lng: 121 }] }] }

function context(overrides: Partial<AssistantContext> = {}): AssistantContext {
  return {
    question: '公園可以帶寵物嗎',
    tools: [showMap],
    runTool: vi.fn(async () => mapResult),
    routeByRules: () => null,
    ...overrides,
  }
}

const answer: RagAnswer = {
  answer: '寵物須繫牽繩。',
  sources: [{ key: 'a', title: '範例公園', score: 0.9, to: '/a' }],
  mode: 'llm',
  relevant: true,
  document: {
    key: 'a',
    title: '範例公園',
    text: '寵物須繫牽繩，並清理排泄物。',
    geo: { lat: 25.03, lng: 121.56 },
    images: [{ src: '/p.png', alt: '須知' }],
    source: '公園處',
  },
  model: 'm',
  ms: 1,
}

describe('parseToolCall', () => {
  it.each([
    ['tagged', '<tool_call>\n{"name": "show_map", "arguments": {"query": "施工"}}\n</tool_call>'],
    ['no end tag (cut off by the token limit)', '<tool_call>{"name": "show_map", "arguments": {"query": "施工"}}'],
    ['bare JSON', '{"name": "show_map", "arguments": {"query": "施工"}}'],
  ])('%s', (_n, output) => expect(parseToolCall(output)).toEqual({ name: 'show_map', args: { query: '施工' } }))

  it.each([
    ['plain text', '公園可以帶寵物。'],
    ['broken JSON', '<tool_call>{"name": "show_map", "argum'],
    ['no name', '<tool_call>{"arguments": {}}</tool_call>'],
  ])('%s -> null', (_n, output) => expect(parseToolCall(output)).toBeNull())

  it('arguments that are not an object are dropped', () => {
    expect(parseToolCall('<tool_call>{"name": "x", "arguments": "y"}</tool_call>')).toEqual({ name: 'x', args: {} })
  })
})

describe('chooseTool', () => {
  it('ignores a tool the model made up', async () => {
    state.modelOutput = '<tool_call>{"name": "delete_everything", "arguments": {}}</tool_call>'
    expect(await chooseTool('x', [showMap])).toBeNull()
  })
  it('returns a real tool', async () => {
    state.modelOutput = '<tool_call>{"name": "show_map", "arguments": {"query": "施工"}}</tool_call>'
    expect(await chooseTool('x', [showMap])).toEqual({ name: 'show_map', args: { query: '施工' } })
  })
  it('without a language model it never asks', async () => {
    state.llm = false
    state.completeCalls = 0
    expect(await chooseTool('x', [showMap])).toBeNull()
    expect(state.completeCalls).toBe(0)
    state.llm = true
  })
})

describe('pickBySimilarity', () => {
  const tools = (map: number, image: number) => [{ name: 'map', score: map }, { name: 'image', score: image }]
  it.each([
    ['clear winner', tools(0.9, 0.8), 0.8, 'map'],
    ['below the minimum', tools(0.84, 0.7), 0.7, null],
    ['too close to another tool', tools(0.88, 0.875), 0.7, null],
    ['too close to an ordinary question', tools(0.88, 0.7), 0.875, null],
    ['an ordinary question wins', tools(0.86, 0.7), 0.9, null],
    ['no tools', [], 0.5, null],
  ])('%s', (_n, scores, noTool, expected) => expect(pickBySimilarity(scores, noTool)).toBe(expected))
})

describe('routeByMeaning', () => {
  const examples = (name: string, word: string) => ({ ...showMap, name, examples: [`看${word}`] })
  it('finds the tool whose examples mean the same', async () => {
    const tool = await routeByMeaning('我要地圖', [examples('map', '地圖'), examples('image', '照片')])
    expect(tool?.name).toBe('map')
  })
  it('an ordinary question reaches no tool', async () => {
    expect(await routeByMeaning('要收費嗎', [examples('map', '地圖')])).toBeNull()
  })
  it('tools without examples are skipped', async () => {
    expect(await routeByMeaning('我要地圖', [showMap])).toBeNull()
  })
})

describe('answerToResult', () => {
  it('keeps the original text word for word and adds images and the location', () => {
    const r = answerToResult(answer)
    expect(r.text).toBe('寵物須繫牽繩。')
    expect(r.blocks?.map((b) => b.type)).toEqual(['quote', 'image', 'map'])
    expect(r.blocks?.[0]).toMatchObject({ text: '寵物須繫牽繩，並清理排泄物。', source: '公園處' })
    expect(r.cards?.[0]?.title).toBe('範例公園')
  })
})

describe('createAgent', () => {
  it('passes while the models are not loaded, so rules and search still answer', async () => {
    state.status = 'idle'
    expect(await createAgent().answer(context())).toBeNull()
    state.status = 'ready'
  })

  it('a trigger phrase runs the tool without the model', async () => {
    state.completeCalls = 0
    const ctx = context({ routeByRules: () => ({ tool: showMap, args: { query: '施工' } }) })
    expect(await createAgent({ toolCalling: true }).answer(ctx)).toEqual(mapResult)
    expect(state.completeCalls).toBe(0)
  })

  it('tool calling off: the model is not asked to pick tools', async () => {
    state.completeCalls = 0
    state.answer = answer
    await createAgent().answer(context())
    expect(state.completeCalls).toBe(0)
  })

  it('tool calling on: the model can pick a tool', async () => {
    state.modelOutput = '<tool_call>{"name": "show_map", "arguments": {"query": "活動"}}</tool_call>'
    const ctx = context()
    expect(await createAgent({ toolCalling: true }).answer(ctx)).toEqual(mapResult)
    expect(ctx.runTool).toHaveBeenCalledWith('show_map', { query: '活動' })
  })

  it('semantic routing runs a tool without the language model', async () => {
    state.completeCalls = 0
    const tool = { ...showMap, examples: ['看地圖'], toArgs: () => ({ query: '施工' }) }
    const ctx = context({ question: '我要地圖', tools: [tool] })
    expect(await createAgent().answer(ctx)).toEqual(mapResult)
    expect(ctx.runTool).toHaveBeenCalledWith('show_map', { query: '施工' })
    expect(state.completeCalls).toBe(0)
  })

  it('otherwise answers from retrieval', async () => {
    state.modelOutput = '不需要工具'
    state.answer = answer
    expect((await createAgent({ toolCalling: true }).answer(context()))?.text).toBe('寵物須繫牽繩。')
  })

  it('retrieval with nothing relevant passes to search', async () => {
    state.answer = { ...answer, relevant: false, document: undefined }
    expect(await createAgent().answer(context())).toBeNull()
  })
})
