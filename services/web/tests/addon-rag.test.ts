import { describe, expect, it, vi } from 'vitest'
import type { HardwareProfile } from '@/addons/model'

// The data layer (Transformers.js, WebGPU probe) is replaced by a deterministic fake:
// "embedding" = bag of 2-character pairs, so similar Chinese text gets similar vectors.
vi.mock('@/addons/model/data', () => {
  const DIM = 8192
  const vec = (s: string) => {
    const v = new Array(DIM).fill(0)
    const t = s.replace(/^(task: search result \| query: |title: none \| text: |query: |passage: )/, '')
    for (let i = 0; i < t.length - 1; i++) v[(t.charCodeAt(i) * 31 + t.charCodeAt(i + 1)) % DIM] += 1
    const n = Math.hypot(...v) || 1
    return v.map((x) => x / n)
  }
  let gen = ''
  return {
    probeHardware: vi.fn(async () => ({ webgpu: false, shaderF16: false, maxBufferMB: 0, memoryGB: 4, cores: 8, freeStorageMB: 9000, gpuName: '' })),
    loadEmbedder: vi.fn(async () => {}),
    embed: vi.fn(async (texts: string[]) => texts.map(vec)),
    loadGenerator: vi.fn(async (id: string) => {
      gen = id
    }),
    loadedGenerator: () => gen,
    unloadGenerator: vi.fn(async () => {
      gen = ''
    }),
    // fake model: copies the first fact of the prompt (what a well-behaved small model does)
    generate: vi.fn(async (messages: { content: string }[], options: { onText?: (t: string) => void }) => {
      const answer = `根據資料，${messages[0]!.content.match(/\[1\] ([^\n]+)/)?.[1]}`
      options.onText?.(answer)
      return answer
    }),
    cachedModelIds: vi.fn(async () => []),
    requestPersistentStorage: vi.fn(async () => true),
  }
})
vi.mock('@/addons/rag/data', () => ({
  loadVectors: async () => ({}),
  saveVectors: async () => {},
  fetchCollection: async () => ({ model: 'other', documents: [], vectors: {} }),
}))

const base: HardwareProfile = { webgpu: true, shaderF16: true, maxBufferMB: 2048, memoryGB: 8, cores: 8, freeStorageMB: 8000, gpuName: 'test' }

describe('chooseGenerator (hardware policy)', async () => {
  const { chooseGenerator, GENERATORS } = await import('@/addons/model')

  it('embedding model: light under 4 GB, because the standard one ran a 2 GB phone out of memory', async () => {
    const { chooseEmbedding, EMBEDDING_MODELS } = await import('@/addons/model')
    expect(chooseEmbedding({ ...base, memoryGB: 2 })).toBe(EMBEDDING_MODELS.light)
    expect(chooseEmbedding({ ...base, memoryGB: 4 })).toBe(EMBEDDING_MODELS.standard)
    expect(chooseEmbedding({ ...base, memoryGB: null })).toBe(EMBEDDING_MODELS.standard)
  })

  it('by default no language model, on any phone: original text is more accurate', () => {
    expect(chooseGenerator(base)).toMatchObject({ key: 'none', sizeMB: 0 })
    expect(chooseGenerator({ ...base, webgpu: false, shaderF16: false })).toMatchObject({ key: 'none', sizeMB: 0 })
  })

  it('a language model is an explicit choice, and runs on the GPU when there is one', () => {
    const c = chooseGenerator(base, 'large')
    expect([c.key, c.device, c.dtype, c.id]).toEqual(['large', 'webgpu', 'q4f16', GENERATORS.large.id])
    expect(chooseGenerator(base, 'small')).toMatchObject({ key: 'small', device: 'webgpu', id: GENERATORS.small.id })
    expect(chooseGenerator(base, 'none').key).toBe('none')
  })

  it('without WebGPU or fp16: 350M on the CPU when asked, never Gemma 3 1B', () => {
    for (const hw of [{ ...base, webgpu: false, shaderF16: false }, { ...base, shaderF16: false }]) {
      expect(chooseGenerator(hw, 'small')).toMatchObject({ key: 'small', device: 'wasm', dtype: 'q4' })
      expect(chooseGenerator(hw, 'large').key).toBe('small')
    }
  })

  it.each([
    ['memory', { memoryGB: 3 }],
    ['storage', { freeStorageMB: 800 }],
    ['gpu buffer', { maxBufferMB: 512 }],
  ])('choosing Gemma 3 1B on a phone with weak %s warns but obeys', (_n, patch) => {
    const c = chooseGenerator({ ...base, ...patch }, 'large')
    expect(c.key).toBe('large')
    expect(c.reasons.length).toBe(2)
  })
})

describe('isGrounded', async () => {
  const { isGrounded } = await import('@/addons/rag')
  const facts = ['範例公園：寵物須繫牽繩，並清理排泄物。', '範例公園：特色：免費、無障礙']
  it.each([
    ['copied fact', '範例公園的寵物須繫牽繩，並清理排泄物。', true],
    ['English', 'Yes, public parks can provide entertainment.', false],
    ['garbled', '寄物公團', false],
    ['invented', '公園晚上十點關門，禁止烤肉。', false],
  ])('%s', (_n, answer, ok) => expect(isGrounded(answer, facts)).toBe(ok))
})

describe('RAG over feature data (logic layer)', async () => {
  vi.stubGlobal('fetch', vi.fn().mockRejectedValue(new TypeError('offline'))) // features fall back to mock data
  const { useRag } = await import('@/addons/rag')
  const { useModel } = await import('@/addons/model')
  const rag = useRag()
  const model = useModel()
  const FAKE = { minRelevance: 0.05 } // the fake embedding scores lower than the real model

  it('fake phone without WebGPU -> extractive answer from the best chunk', async () => {
    await rag.prepare()
    expect(rag.status.value).toBe('ready')
    expect(model.choice.value?.key).toBe('none')
    expect(rag.docsCount.value).toBeGreaterThanOrEqual(10) // facts split into chunks
    const res = await rag.ask('公園可以帶寵物嗎？', undefined, FAKE)
    expect(res.mode).toBe('extractive')
    expect(res.answer).toContain('寵物')
  })

  it('vectorises features + searchItems and loads the requested model', async () => {
    await rag.prepare('small')
    expect(rag.status.value).toBe('ready')
    expect(model.choice.value?.key).toBe('small')
  })

  it('answers from the most relevant document and cites it', async () => {
    const streamed: string[] = []
    const res = await rag.ask('公園可以帶寵物嗎？', (t) => streamed.push(t), FAKE)
    expect(res.mode).toBe('llm')
    expect(res.sources[0]?.title).toBe('範例公園') // its text contains the pet notice
    expect(res.answer).toContain('寵物') // the pet-notice chunk was handed to the model as a document
    expect(streamed.join('')).toBe(res.answer)
  })

  it('grounding guard rejects English / invented answers and shows the best fact', async () => {
    const data = await import('@/addons/model/data')
    vi.mocked(data.generate).mockResolvedValueOnce('Yes, public parks can provide entertainment for visitors.')
    const res = await rag.ask('公園可以帶寵物嗎？', undefined, FAKE)
    expect(res.mode).toBe('guarded')
    expect(res.rejected).toContain('Yes')
    expect(res.answer).toContain('寵物')
  })

  it('an answer cut off by the token limit keeps only complete sentences', async () => {
    const data = await import('@/addons/model/data')
    vi.mocked(data.generate).mockResolvedValueOnce('範例公園的寵物須繫牽繩。並清理排泄物，還有�')
    const res = await rag.ask('公園可以帶寵物嗎？', undefined, FAKE)
    expect(res.answer).toBe('範例公園的寵物須繫牽繩。')
  })

  it('returns the source document word for word, with its location and images', async () => {
    const res = await rag.ask('公園可以帶寵物嗎？', undefined, FAKE)
    expect(res.document?.title).toBe('範例公園')
    expect(res.document?.text).toContain('寵物：寵物須繫牽繩，並清理排泄物。')
    expect(res.document?.geo).toEqual({ lat: 25.0375, lng: 121.5637 })
    expect(res.document?.images?.[0]?.alt).toBeTruthy()
  })

  it('a question the data does not cover is marked as not relevant', async () => {
    const res = await rag.ask('zzzz qqqq xxxx', undefined, FAKE)
    expect(res.relevant).toBe(false)
    expect(res.document).toBeUndefined()
    expect(res.answer).toBe('目前資料沒有提到。')
  })

  it('discloses the on-device models (competition rule)', () => {
    const rows = model.disclosure.value.map((r) => r.label)
    expect(rows).toEqual(expect.arrayContaining(['向量模型', '語言模型', '語言量化', '推論框架', '執行位置']))
  })
})
