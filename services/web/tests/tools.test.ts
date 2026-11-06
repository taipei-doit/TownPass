import { afterAll, beforeAll, describe, expect, it, vi } from 'vitest'
import { Sparkles } from 'lucide-vue-next'
import type { Feature } from '@/framework'

// One fake feature with everything a tool can use; the real features stay registered.
vi.mock('@/framework', async (importOriginal) => {
  const real = await importOriginal<typeof import('@/framework')>()
  const roadworks: Feature = {
    id: 'roads',
    code: 'RD',
    title: '施工資訊',
    description: '道路施工',
    icon: Sparkles,
    routes: [],
    searchItems: () => [
      { id: 'a', title: '信義路施工', subtitle: '信義區', text: '管線工程', geo: { lat: 25.03, lng: 121.56 }, validFrom: '2026-11-01', validTo: '2026-12-31', to: '/a' },
      { id: 'b', title: '和平路施工', subtitle: '大安區', text: '已結束的工程', geo: { lat: 25.02, lng: 121.54 }, validTo: '2020-01-01', to: '/b' },
      { id: 'c', title: '封路公文', text: '公文內容', images: [{ src: '/doc.png', alt: '封路範圍圖' }, { src: 'javascript:alert(1)', alt: '壞圖' }, { src: '/no-alt.png', alt: '' }], to: '/c' },
    ],
    tools: [
      real.defineTool<{ line: number }>({
        name: 'bus_arrival',
        description: '查公車到站',
        parameters: { type: 'object', properties: { line: { type: 'integer' } }, required: ['line'] },
        triggers: [/公車/],
        toArgs: () => ({ line: 307 }),
        run: ({ line }) => ({ text: `${line} 還有 3 分鐘`, cards: [{ key: 'x', title: String(line), to: '/x' }] }),
      }),
      real.defineTool({ name: 'broken', description: '一定失敗', parameters: { type: 'object', properties: {} }, run: () => { throw new Error('boom') } }),
      real.defineTool({
        name: 'bad_blocks',
        description: '回傳壞資料',
        parameters: { type: 'object', properties: {} },
        run: () => ({ text: 'x', blocks: [{ type: 'map', markers: [{ lat: 999, lng: 0 }] }, { type: 'quote', text: '' }] }),
      }),
    ],
  }
  return { ...real, features: [...real.features, roadworks] }
})

describe('chat tools', async () => {
  const { buildSearchIndex } = await import('@/modules/search')
  const { listTools, routeByRules, runTool, validateToolArgs } = await import('@/modules/tools')
  const { useAssistant } = await import('@/modules/assistant')

  beforeAll(async () => {
    vi.stubGlobal('fetch', vi.fn().mockRejectedValue(new TypeError('offline')))
    vi.useFakeTimers({ toFake: ['Date'] })
    vi.setSystemTime(new Date('2026-11-07T08:00:00+08:00'))
    await buildSearchIndex()
  })
  afterAll(() => vi.useRealTimers())

  it('a tool declared in a feature is registered next to the built-in ones', () => {
    expect(listTools().map((t) => t.name)).toEqual(expect.arrayContaining(['show_map', 'show_image', 'bus_arrival']))
  })

  describe('rule routing', () => {
    it.each([
      ['把信義區的施工標在地圖上', 'show_map'],
      ['信義路施工在哪裡', 'show_map'],
      ['封路公文的附圖給我看', 'show_image'],
      ['307 公車還要多久', 'bus_arrival'],
    ])('%s -> %s', (q, tool) => expect(routeByRules(q)?.tool.name).toBe(tool))

    it('圖書館 is not a request for a picture', () => expect(routeByRules('圖書館幾點開')).toBeNull())

    it('a picture request finds documents by what the picture shows', async () => {
      const r = await runTool('show_image', { query: '封路範圍圖' })
      expect(r.blocks?.[0]).toMatchObject({ src: '/doc.png' })
    })

    it('takes the topic out of the question', () => {
      expect(routeByRules('把信義區的施工標在地圖上')?.args).toEqual({ query: '信義區施工' })
    })
  })

  describe('show_map', () => {
    it('marks items that have a location, with coordinates from the data', async () => {
      const r = await runTool('show_map', { query: '信義路施工' })
      const map = r.blocks?.find((b) => b.type === 'map')
      expect(map).toMatchObject({ markers: [{ lat: 25.03, lng: 121.56, label: '信義路施工' }] })
      expect(r.cards?.[0]?.title).toBe('信義路施工')
    })

    it('leaves finished roadworks off the map', async () => {
      const r = await runTool('show_map', { query: '施工' })
      const map = r.blocks?.find((b) => b.type === 'map')
      const labels = map?.type === 'map' ? map.markers.map((m) => m.label) : []
      expect(labels).toContain('信義路施工')
      expect(labels).not.toContain('和平路施工')
    })

    it('an empty topic shows everything current', async () => {
      const r = await runTool('show_map', {})
      const map = r.blocks?.find((b) => b.type === 'map')
      expect(map?.type === 'map' && map.markers.length).toBeGreaterThan(1)
    })

    it('says so when nothing has a location', async () => {
      const r = await runTool('show_map', { query: 'zzzzqqqq' })
      expect(r.blocks).toEqual([])
      expect(r.text).toContain('沒有')
    })
  })

  describe('show_image', () => {
    it('shows pictures of the document and drops unsafe or unlabelled ones', async () => {
      const r = await runTool('show_image', { query: '封路公文' })
      const images = r.blocks?.filter((b) => b.type === 'image')
      expect(images).toEqual([expect.objectContaining({ src: '/doc.png', alt: '封路範圍圖' })])
    })
  })

  describe('arguments', () => {
    const tool = () => listTools().find((t) => t.name === 'bus_arrival')!

    it('keeps only declared arguments', () => {
      expect(validateToolArgs(tool(), { line: 307, lat: 1, src: 'x' })).toEqual({ args: { line: 307 }, errors: [] })
    })
    it.each([
      ['missing', {}],
      ['wrong type', { line: '307' }],
      ['not an integer', { line: 3.5 }],
      ['not an object', 'hello'],
    ])('rejects %s', (_n, args) => expect(validateToolArgs(tool(), args).errors.length).toBeGreaterThan(0))

    it('a tool never runs with bad arguments', async () => {
      expect((await runTool('bus_arrival', { line: 'x' })).text).toContain('無法執行')
    })
  })

  describe('failures stay inside the conversation', () => {
    it('unknown tool', async () => expect((await runTool('nope')).text).toContain('沒有'))
    it('a tool that throws', async () => expect((await runTool('broken')).text).toContain('暫時無法'))
    it('blocks with bad content are dropped', async () => expect((await runTool('bad_blocks')).blocks).toEqual([]))
  })

  describe('in the chat box', () => {
    it('a map request draws a map block in the conversation', async () => {
      const { messages, ask } = useAssistant()
      await ask('信義路施工在地圖上在哪')
      const reply = messages.value[1]!
      expect(reply.pending).toBe(false)
      expect(reply.blocks?.[0]?.type).toBe('map')
      expect(reply.results?.[0]?.icon).toBeTruthy()
    })

    it('a picture request draws an image block', async () => {
      const { messages, ask } = useAssistant()
      await ask('封路公文的圖片')
      expect(messages.value[1]!.blocks?.[0]).toMatchObject({ type: 'image', src: '/doc.png' })
    })

    it('a feature tool answers without any model', async () => {
      const { messages, ask } = useAssistant()
      await ask('公車')
      expect(messages.value[1]!.text).toContain('307')
    })

    it('a map request with no data falls back to search suggestions', async () => {
      const { messages, ask } = useAssistant()
      await ask('qqqqzzzz 地圖')
      expect(messages.value[1]!.blocks ?? []).toEqual([])
    })
  })
})
