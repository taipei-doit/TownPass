/**
 * LOGIC LAYER - add-on rag: on-device retrieval-augmented answers.
 *   1. vectorise what features provide, split into single facts (one notice / line per chunk)
 *   2. embed the question, take the most similar chunks (cosine)
 *   3. a small local LLM answers ONLY from them; a grounding guard (isGrounded) replaces English,
 *      invented or garbled answers with the best fact; without the LLM -> extractive answer
 * Every answer also carries the source document, so callers can show its original text, images
 * and location. Models come from the model add-on.
 */
import { ref } from 'vue'
import type { RouteLocationRaw } from 'vue-router'
import { featureEntry, features, type Feature, type FeatureItem, type GeoPoint, type ItemImage } from '@/framework'
import {
  complete,
  embedPassages,
  embedQuery,
  activeEmbedding,
  inspectDevice,
  languageModelId,
  languageModelReady,
  prepareEmbedding,
  prepareLanguageModel,
  useModel,
  type ChatMessage,
  type ModelKey,
} from '@/addons/model'
import { fetchCollection, loadVectors, saveVectors } from './data'

/** Longest original text returned with an answer; the source page has the rest. */
const __MAX_ORIGINAL_CHARS = 1200

export interface RagSource {
  key: string
  title: string
  subtitle?: string
  score: number
  to: RouteLocationRaw
}
/** The best-matching document, word for word. */
export interface RagDocument {
  key: string
  title: string
  text: string
  geo?: GeoPoint
  images?: ItemImage[]
  validFrom?: string
  validTo?: string
  source?: string
}
export interface RagAnswer {
  answer: string
  sources: RagSource[]
  /** 'guarded' = the model answered but failed the grounding check, so the best fact is shown instead */
  mode: 'llm' | 'extractive' | 'guarded'
  /** what the model said when mode is 'guarded' (for debugging / the lab page) */
  rejected?: string
  /** false when nothing retrieved is close enough to the question */
  relevant: boolean
  document?: RagDocument
  model: string
  ms: number
}

/** One document of a collection built by `pnpm rag:build`. */
export interface RagCollectionDocument {
  id: string
  title: string
  subtitle?: string
  text: string
  geo?: GeoPoint
  images?: ItemImage[]
  validFrom?: string
  validTo?: string
  source?: string
  sourceUrl?: string
}
interface __Collection {
  model: string
  documents: RagCollectionDocument[]
  vectors: Record<string, number[]>
}

// ---------------------------------------------------------------- state (shared singleton)
type Status = 'idle' | 'probing' | 'downloading' | 'indexing' | 'ready' | 'error'
const status = ref<Status>('idle')
const docsCount = ref(0)
const error = ref('')
let __chunks: __Chunk[] = []
let __docs = new Map<string, __Doc>()
const __prebuilt: Record<string, Record<string, number[]>> = {}

export function useRag() {
  return { status, docsCount, error, inspect, prepare, ask, bestScore }
}

/** Probe the phone and pick a model without downloading anything. */
export async function inspect(override?: ModelKey) {
  status.value = 'probing'
  const choice = await inspectDevice(override)
  status.value = 'idle'
  return choice
}

/** Download (first time) + load models and vectorise the documents. Safe to call again. */
export async function prepare(override?: ModelKey): Promise<void> {
  try {
    await inspect(override)
    status.value = 'downloading'
    await prepareEmbedding()
    status.value = 'indexing'
    useModel().message.value = '建立向量索引'
    __chunks = await __indexChunks()
    docsCount.value = __chunks.length
    status.value = 'downloading'
    await prepareLanguageModel(override)
    status.value = 'ready'
  } catch (err) {
    status.value = 'error'
    error.value = err instanceof Error ? err.message : String(err)
  }
}

/**
 * Documents from a collection built by `pnpm rag:build`, as items for a feature's searchItems.
 * The same items feed the chat box's search, so they work before any model is loaded; the
 * pre-computed vectors save the phone from calculating them.
 */
export async function collectionItems(url: string, to: (doc: RagCollectionDocument) => RouteLocationRaw): Promise<FeatureItem[]> {
  const collection = await fetchCollection<__Collection>(url)
  __prebuilt[collection.model] = { ...__prebuilt[collection.model], ...collection.vectors }
  return collection.documents.map((d) => ({ ...d, to: to(d) }))
}

/** How close the best line in the data is to the question; lets callers compare it with other options. */
export async function bestScore(question: string): Promise<number> {
  return __topK(await embedQuery(question), __chunks.filter(__isCurrent), 1)[0]?.score ?? 0
}

/** Retrieve + answer. Works with only the embedder (extractive) if the LLM isn't loaded. */
export async function ask(
  question: string,
  onText?: (t: string) => void,
  { k = 4, minRelevance = activeEmbedding().minRelevance }: { k?: number; minRelevance?: number } = {},
): Promise<RagAnswer> {
  const t0 = performance.now()
  if (!__chunks.length) throw new Error('請先準備模型（prepare）')
  const top = __topK(await embedQuery(question), __chunks.filter(__isCurrent), k)
  const best = top[0]
  const relevant = !!best && best.score >= minRelevance
  const base = { sources: __sourcesOf(top), relevant, document: best && relevant ? __documentOf(best.chunk) : undefined }
  const extractive = best && relevant ? `「${best.chunk.title}」${best.chunk.text}` : '目前資料沒有提到。'
  if (!relevant || !languageModelReady()) {
    if (relevant) onText?.(extractive)
    return { ...base, answer: extractive, mode: 'extractive', model: activeEmbedding().id, ms: performance.now() - t0 }
  }
  const facts = top.map(({ chunk }) => `${chunk.title}：${chunk.text}`)
  const answer = __tidied(await complete(__messages(question, facts), { onText }))
  const model = languageModelId()
  if (!isGrounded(answer, facts)) {
    return { ...base, answer: extractive, mode: 'guarded', rejected: answer, model, ms: performance.now() - t0 }
  }
  return { ...base, answer, mode: 'llm', model, ms: performance.now() - t0 }
}

/**
 * Grounding guard for small models. An answer is accepted only if it is mostly Chinese and at
 * least `minOverlap` of its 2-character pairs appear in the retrieved facts. Measured failure
 * modes it catches: English replies, invented facts, garbled characters.
 */
export function isGrounded(answer: string, facts: string[], minOverlap = 0.35): boolean {
  const cjk = answer.match(/[㐀-鿿]/g)?.length ?? 0
  const latin = answer.match(/[A-Za-z]/g)?.length ?? 0
  if (cjk < 4 || latin > cjk) return false
  const pairs = __cjkPairs(answer)
  if (!pairs.length) return false
  const context = new Set(facts.flatMap(__cjkPairs))
  return pairs.filter((p) => context.has(p)).length / pairs.length >= minOverlap
}

// ---------------------------------------------------------------- internals
/** One retrievable fact: a document's header, or one line of its text (one notice, the hours...). */
interface __Chunk {
  key: string
  docKey: string
  title: string
  subtitle?: string
  text: string
  validTo?: string
  to: RouteLocationRaw
  vec: number[]
}
type __Doc = {
  key: string
  title: string
  subtitle?: string
  /** the facts to search */
  lines: string[]
  /** the original text, without the generated lines */
  body: string
  geo?: GeoPoint
  images?: ItemImage[]
  validFrom?: string
  validTo?: string
  source?: string
  to: RouteLocationRaw
}

async function __indexChunks(): Promise<__Chunk[]> {
  const docs = await __docsFromFeatures()
  __docs = new Map(docs.map((d) => [d.key, d]))
  const raw = docs.flatMap(__chunksOf)
  const model = activeEmbedding().id
  const cacheKey = `vectors.${model}`
  const cache = { ...(await loadVectors(cacheKey)), ...__prebuilt[model] }
  const id = (c: Omit<__Chunk, 'vec'>) => __hash(`${c.title}\n${c.text}`)
  const missing = raw.filter((c) => !cache[id(c)])
  const { progress } = useModel()
  for (let i = 0; i < missing.length; i += 16) {
    const batch = missing.slice(i, i + 16)
    const vecs = await embedPassages(batch.map((c) => `${c.title}：${c.text}`))
    batch.forEach((c, j) => (cache[id(c)] = vecs[j]!.map((x) => Math.round(x * 1e4) / 1e4)))
    progress.value = Math.min(1, (i + batch.length) / missing.length)
  }
  if (missing.length) await saveVectors(cacheKey, cache)
  return raw.map((c) => ({ ...c, vec: cache[id(c)]! }))
}

/** `pnpm rag:build` splits documents the same way, so its vectors match these chunks by hash. */
function __chunksOf(d: __Doc): Omit<__Chunk, 'vec'>[] {
  const base = { docKey: d.key, title: d.title, subtitle: d.subtitle, validTo: d.validTo, to: d.to }
  const header = { ...base, key: `${d.key}#0`, text: [d.subtitle, ...d.lines.slice(0, 1)].filter(Boolean).join('；') }
  return [header, ...d.lines.map((line, i) => ({ ...base, key: `${d.key}#${i + 1}`, text: line }))]
}

async function __docsFromFeatures(): Promise<__Doc[]> {
  const docs: __Doc[] = []
  for (const f of features) {
    docs.push({ key: `f:${f.id}`, title: f.title, subtitle: f.description, lines: __featureLines(f), body: f.description, to: featureEntry(f) })
    const items: FeatureItem[] = await Promise.resolve(f.searchItems?.() ?? []).catch(() => [])
    for (const it of items) {
      const lines = [it.tags?.length ? `特色：${it.tags.join('、')}` : '', ...(it.text ?? '').split('\n')].filter(Boolean)
      docs.push({
        key: `i:${f.id}:${it.id}`,
        title: it.title,
        subtitle: it.subtitle,
        lines,
        body: it.text ?? '',
        geo: it.geo,
        images: it.images,
        validFrom: it.validFrom,
        validTo: it.validTo,
        source: it.source,
        to: it.to,
      })
    }
  }
  return docs
}

function __featureLines(f: Feature): string[] {
  return f.keywords?.length ? [`相關：${f.keywords.join('、')}`] : []
}

/** Roadworks that have ended and events that are over don't answer questions about today. */
function __isCurrent(chunk: __Chunk): boolean {
  return !chunk.validTo || chunk.validTo >= new Date().toISOString().slice(0, 10)
}

function __documentOf(chunk: __Chunk): RagDocument {
  const d = __docs.get(chunk.docKey)!
  const text = d.body.length > __MAX_ORIGINAL_CHARS ? `${d.body.slice(0, __MAX_ORIGINAL_CHARS)}…` : d.body
  return { key: d.key, title: d.title, text, geo: d.geo, images: d.images, validFrom: d.validFrom, validTo: d.validTo, source: d.source }
}

function __topK(q: number[], chunks: __Chunk[], k: number): { chunk: __Chunk; score: number }[] {
  return chunks
    .map((chunk) => ({ chunk, score: __dot(q, chunk.vec) }))
    .sort((a, b) => b.score - a.score)
    .slice(0, k)
}

/** Unique documents in rank order (several chunks may come from the same place). */
function __sourcesOf(top: { chunk: __Chunk; score: number }[]): RagSource[] {
  const seen = new Set<string>()
  const out: RagSource[] = []
  for (const { chunk, score } of top) {
    if (seen.has(chunk.docKey)) continue
    seen.add(chunk.docKey)
    out.push({ key: chunk.docKey, title: chunk.title, subtitle: chunk.subtitle, score, to: chunk.to })
  }
  return out
}

function __dot(a: number[], b: number[]): number {
  let s = 0
  for (let i = 0; i < a.length; i++) s += a[i]! * b[i]!
  return s
}

/**
 * Prompt format chosen by measurement (Granite 4.0 350M/1B, q4f16, WebGPU): the facts go straight
 * into a short Chinese user message. Granite's own `documents` RAG template (English system text)
 * made both sizes answer in English or ignore the facts.
 */
function __messages(question: string, facts: string[]): ChatMessage[] {
  const context = facts.map((f, i) => `[${i + 1}] ${f}`).join('\n')
  return [{ role: 'user', content: `根據以下資料回答問題，用繁體中文、一句話。\n資料：\n${context}\n問題：${question.trim()}` }]
}

/** The token limit can cut an answer mid-character or mid-sentence: keep the complete sentences. */
function __tidied(answer: string): string {
  const text = answer.replace(/�+$/, '').trim()
  if (/[。！？.!?）」]$/.test(text)) return text
  const end = Math.max(...['。', '！', '？'].map((mark) => text.lastIndexOf(mark)))
  return end > 0 ? text.slice(0, end + 1) : text
}

function __cjkPairs(s: string): string[] {
  const out: string[] = []
  for (const run of s.match(/[㐀-鿿]+/g) ?? []) for (let i = 0; i < run.length - 1; i++) out.push(run.slice(i, i + 2))
  return out
}

function __hash(s: string): string {
  let h = 2166136261
  for (let i = 0; i < s.length; i++) h = Math.imul(h ^ s.charCodeAt(i), 16777619)
  return (h >>> 0).toString(36) + s.length.toString(36)
}
