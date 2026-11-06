/**
 * LOGIC LAYER - runs chat tools: registry, argument checks, rule routing and block clean-up.
 * Works without any model. Built-in tools read the `geo` and `images` of feature items, so a
 * feature with located or illustrated data needs no tool code of its own.
 */
import {
  defineTool,
  features,
  type ToolArgs,
  type ToolBlock,
  type ToolCard,
  type ToolDefinition,
  type ToolParameters,
  type ToolResult,
  type ToolRoute,
} from '@/framework'
import { search, searchDocuments, type SearchDoc } from '@/modules/search'

const __MAX_MARKERS = 30
const __MAX_IMAGES = 4
/** Search matches single characters too; hits far below the best one are noise. */
const __MIN_RELATIVE_SCORE = 0.35
const __QUERY_PARAMETERS: ToolParameters = {
  type: 'object',
  properties: { query: { type: 'string', description: '要找的主題或地區，例如「信義區施工」；要全部就留空' } },
}

const __showMap = defineTool<{ query?: string }>({
  name: 'show_map',
  description: '在對話框的地圖上標出地點，例如施工、活動、設施的位置',
  parameters: __QUERY_PARAMETERS,
  triggers: [/地圖|標點|標出|標示|標給|在哪|位置在|地點在|什麼地方/],
  examples: ['在地圖上標出施工的位置', '這個活動在什麼地方', '幫我標出地點', '哪裡有道路施工', '顯示這個地方的位置', '指給我看在哪一帶'],
  toArgs: (question) => ({ query: __topicOf(question) }),
  run: ({ query }) => {
    const docs = __matching(query, (d) => !!d.geo && !__isFinished(d)).slice(0, __MAX_MARKERS)
    const topic = query ? `和「${query}」相關的` : ''
    if (!docs.length) return { text: `目前沒有${topic}地點資料可以標在地圖上。` }
    return {
      text: `在地圖上標出 ${docs.length} 個${topic}地點：`,
      blocks: [{ type: 'map', markers: docs.map(__markerOf) }],
      cards: docs.map(__cardOf),
    }
  },
})

const __showImage = defineTool<{ query?: string }>({
  name: 'show_image',
  description: '在對話框顯示資料附帶的圖片，例如公文附圖、活動海報',
  parameters: __QUERY_PARAMETERS,
  triggers: [/圖片|照片|相片|附圖|示意圖|流程圖|宣傳圖|須知圖|那張圖|海報|長什麼樣子|長怎樣/],
  examples: ['給我看圖片', '顯示公文的附圖', '看現場照片', '這個地方長什麼樣子', '活動海報給我看', '有沒有流程圖'],
  toArgs: (question) => ({ query: __topicOf(question) }),
  run: ({ query }) => {
    const docs = __matching(query, (d) => !!d.images?.length)
    const blocks: ToolBlock[] = docs
      .flatMap((d) => (d.images ?? []).map((image) => ({ type: 'image' as const, ...image, source: d.source })))
      .slice(0, __MAX_IMAGES)
    const topic = query ? `和「${query}」相關的` : ''
    if (!blocks.length) return { text: `目前沒有${topic}圖片。` }
    return { text: `找到 ${blocks.length} 張${topic}圖片：`, blocks, cards: docs.slice(0, 3).map(__cardOf) }
  },
})

/** Feature tools first, so a feature can answer a phrase before the built-in tools do. */
export function listTools(): ToolDefinition[] {
  const seen = new Set<string>()
  return [...features.flatMap((f) => f.tools ?? []), __showMap, __showImage].filter((tool) => {
    if (seen.has(tool.name)) {
      console.warn(`[tools] duplicate tool name "${tool.name}" ignored`)
      return false
    }
    seen.add(tool.name)
    return true
  })
}

/** The first tool whose trigger matches, or null. */
export function routeByRules(question: string): ToolRoute | null {
  for (const tool of listTools()) {
    if (tool.triggers?.some((t) => t.test(question))) {
      return { tool, args: tool.toArgs ? tool.toArgs(question) : { query: question } }
    }
  }
  return null
}

/** Keeps declared arguments only and checks their types, so model output can't reach a tool unchecked. */
export function validateToolArgs(tool: ToolDefinition, args: unknown): { args: ToolArgs; errors: string[] } {
  const errors: string[] = []
  const clean: ToolArgs = {}
  const input = (args && typeof args === 'object' ? args : {}) as ToolArgs
  for (const [name, rule] of Object.entries(tool.parameters.properties)) {
    const value = input[name]
    if (value === undefined || value === null) continue
    const wanted = rule.type === 'integer' ? 'number' : rule.type
    if (typeof value !== wanted || (rule.type === 'integer' && !Number.isInteger(value))) errors.push(`${name} 必須是 ${rule.type}`)
    else if (rule.enum && !rule.enum.includes(value as string | number)) errors.push(`${name} 不在允許的值內`)
    else clean[name] = value
  }
  for (const name of tool.parameters.required ?? []) {
    if (clean[name] === undefined && !errors.some((e) => e.startsWith(name))) errors.push(`缺少 ${name}`)
  }
  return { args: clean, errors }
}

/** Never throws: a failing tool becomes a message in the conversation. */
export async function runTool(name: string, args: ToolArgs = {}): Promise<ToolResult> {
  const tool = listTools().find((t) => t.name === name)
  if (!tool) return { text: `沒有「${name}」這個工具。` }
  const checked = validateToolArgs(tool, args)
  if (checked.errors.length) return { text: `無法執行：${checked.errors.join('、')}。` }
  try {
    const result = await tool.run(checked.args)
    return { ...result, blocks: (result.blocks ?? []).flatMap(__cleanBlock) }
  } catch (err) {
    console.warn(`[tools] ${name} failed`, err)
    return { text: '這個功能暫時無法使用，請稍後再試。' }
  }
}

/** The search topic left after removing the words that only ask for a map or a picture. */
function __topicOf(question: string): string {
  return question
    .replace(/地圖|標點|標出|標示|標給|標在|在哪裡?|位置在|地點在|什麼地方|位置|地點|圖片|照片|相片|附圖|示意圖|流程圖|宣傳圖|須知圖|那張圖|海報|長什麼樣子|長怎樣/g, ' ')
    .replace(/請|幫我|幫忙|給我看|給我|我想|我要|想看|看看|有沒有|顯示|列出|查詢|告訴我|有哪些|哪些|所有|全部|可以|把|在|上面?|的|嗎|呢|[?？!！,，。、]/g, ' ')
    .replace(/\s+/g, '')
}

function __matching(query: string | undefined, wanted: (d: SearchDoc) => boolean): SearchDoc[] {
  if (!query) return searchDocuments().filter(wanted)
  const hits = search(query, 100)
  const floor = (hits[0]?.score ?? 0) * __MIN_RELATIVE_SCORE
  return hits.filter((d) => (d.score ?? 0) >= floor && wanted(d))
}

function __isFinished(d: SearchDoc): boolean {
  return !!d.validTo && d.validTo < new Date().toISOString().slice(0, 10)
}

function __markerOf(d: SearchDoc) {
  const when = d.validFrom || d.validTo ? `${d.validFrom ?? ''}～${d.validTo ?? ''}` : ''
  return { ...d.geo!, label: d.title, detail: [d.subtitle, when].filter(Boolean).join('・') }
}

function __cardOf(d: SearchDoc): ToolCard {
  return { key: d.key, title: d.title, subtitle: d.subtitle, tags: d.tags, featureId: d.featureId, to: d.to }
}

/** Drops anything unusable or unsafe that a tool returned instead of breaking the conversation. */
function __cleanBlock(block: ToolBlock): ToolBlock[] {
  if (block.type === 'map') {
    const markers = block.markers.filter((m) => Math.abs(m.lat) <= 90 && Math.abs(m.lng) <= 180).slice(0, __MAX_MARKERS)
    return markers.length ? [{ ...block, markers }] : []
  }
  if (block.type === 'image') return block.alt && __isSafeImage(block.src) ? [block] : []
  return block.text ? [block] : []
}

function __isSafeImage(src: string): boolean {
  if (/^data:image\/(png|jpe?g|webp|gif);/i.test(src)) return true
  return /^https:\/\//i.test(src) || (!/^[a-z][a-z0-9+.-]*:/i.test(src) && !src.startsWith('//'))
}
