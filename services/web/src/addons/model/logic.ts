/**
 * LOGIC LAYER - add-on model: which on-device models to run, and the calls to run them.
 * Other add-ons and features use this for embeddings and text generation; they never touch the
 * runtime. Competition rule: everything runs on the device; modelDisclosure lists what to disclose.
 */
import { computed, ref, shallowRef } from 'vue'
import {
  cachedModelIds,
  embed,
  generate,
  loadEmbedder,
  loadedGenerator,
  loadGenerator,
  probeHardware,
  requestPersistentStorage,
  unloadGenerator,
  type ChatMessage,
  type Device,
  type Dtype,
  type HardwareProfile,
  type ModelTool,
} from './data'

export type { ChatMessage, HardwareProfile, ModelTool }

export interface EmbeddingModel {
  id: string
  base: string
  vendor: string
  licence: string
  dtype: Dtype
  sizeMB: number
  queryPrefix: string
  passagePrefix: string
  /** a retrieved line below this similarity means "the data doesn't cover this" (eval/compare.mjs) */
  minRelevance: number
}

/**
 * Chosen by measurement on 68 Chinese questions (eval/compare.mjs): the right line ranks first for
 * 91% with EmbeddingGemma and 81% with e5-small. EmbeddingGemma killed the app on a 2 GB phone
 * (out of memory), so phones under EMBEDDING_NEEDS.memoryGB get the light model.
 */
export const EMBEDDING_MODELS: Record<'standard' | 'light', EmbeddingModel> = {
  standard: {
    id: 'onnx-community/embeddinggemma-300m-ONNX',
    base: 'google/embeddinggemma-300m',
    vendor: 'Google',
    licence: 'Gemma Terms of Use',
    // q4 is smaller but uses an operator (GatherBlockQuantized) the browser's WASM backend doesn't have
    dtype: 'q8',
    sizeMB: 295,
    queryPrefix: 'task: search result | query: ',
    passagePrefix: 'title: none | text: ',
    minRelevance: 0.63,
  },
  light: {
    id: 'Xenova/multilingual-e5-small',
    base: 'intfloat/multilingual-e5-small',
    vendor: 'Microsoft',
    licence: 'MIT',
    dtype: 'q8',
    sizeMB: 118,
    queryPrefix: 'query: ',
    passagePrefix: 'passage: ',
    minRelevance: 0.85,
  },
}
export const EMBEDDING_NEEDS = { memoryGB: 4 }

/**
 * The competition allows only open-source software and may penalise or disqualify otherwise, and it
 * doesn't address the Gemma Terms of Use (usage restrictions, not an OSI licence). So EmbeddingGemma
 * and Gemma 3 stay off. Set this to false only after the organiser confirms in writing (ADR-020).
 */
export const ONLY_OPEN_SOURCE_MODELS = true

/** Pure policy. Unknown memory counts as enough: browsers that hide it are not low-end Android. */
export function chooseEmbedding(hw: HardwareProfile, openSourceOnly = ONLY_OPEN_SOURCE_MODELS): EmbeddingModel {
  if (openSourceOnly) return EMBEDDING_MODELS.light
  return hw.memoryGB !== null && hw.memoryGB < EMBEDDING_NEEDS.memoryGB ? EMBEDDING_MODELS.light : EMBEDDING_MODELS.standard
}

export const GENERATORS = {
  small: {
    id: 'onnx-community/granite-4.0-350m-ONNX-web',
    base: 'ibm-granite/granite-4.0-350m',
    label: 'Granite 4.0 350M',
    vendor: 'IBM',
    licence: 'Apache-2.0',
    sizeMB: { q4f16: 350, q4: 576 } as Record<string, number>,
  },
  large: {
    id: 'onnx-community/gemma-3-1b-it-ONNX',
    base: 'google/gemma-3-1b-it',
    label: 'Gemma 3 1B',
    vendor: 'Google',
    licence: 'Gemma Terms of Use',
    sizeMB: { q4f16: 728 } as Record<string, number>,
  },
} as const
export type GeneratorKey = keyof typeof GENERATORS
/** 'none' = no language model: callers answer with retrieved text instead. */
export type ModelKey = GeneratorKey | 'none'

export interface ModelChoice {
  key: ModelKey
  id: string
  label: string
  device: Device
  dtype: Dtype
  sizeMB: number
  reasons: string[]
}

/** What Gemma 3 1B needs: below this it may run out of memory, so choosing it comes with a warning. */
export const LARGE_MODEL_NEEDS = { memoryGB: 4, freeStorageMB: 1200, maxBufferMB: 1024 }

/**
 * Pure policy: which language model to run. By default none, on any phone: showing the retrieved
 * line word for word was right 91% of the time, the best model's answers about 67%, and some of its
 * wrong answers said the opposite of the source (README.md). A language model is an explicit choice.
 *   'large' Gemma 3 1B, GPU only
 *   'small' Granite 350M, on the GPU, or very slowly on the CPU when there is no GPU
 */
export function chooseGenerator(hw: HardwareProfile, override?: ModelKey, openSourceOnly = ONLY_OPEN_SOURCE_MODELS): ModelChoice {
  const gpu = hw.webgpu && hw.shaderF16
  const reasons: string[] = []
  const need = LARGE_MODEL_NEEDS
  let key: ModelKey = override ?? 'none'

  if (!override) {
    reasons.push('預設不用語言模型：逐字原文實測比模型回答準（91% 對 67%）')
    reasons.push(gpu ? '這支手機有 WebGPU，可以手動選用語言模型' : '這個 WebView 沒有可用的 WebGPU，語言模型會很慢')
  } else if (override === 'none') {
    reasons.push('手動指定只摘錄')
  } else if (override === 'large' && openSourceOnly) {
    key = 'small'
    reasons.push('Gemma 3 1B 的授權待主辦單位確認，改用 Granite 350M（Apache-2.0）')
  } else if (!gpu) {
    key = 'small'
    reasons.push(override === 'large' ? '沒有 GPU 不能跑 Gemma 3 1B，改用 350M（CPU，每題約 30 秒）' : '手動指定 350M（CPU，每題約 30 秒）')
  } else {
    reasons.push(`手動指定 ${GENERATORS[override].label}`)
    if (override === 'large') {
      if (hw.memoryGB !== null && hw.memoryGB < need.memoryGB) reasons.push(`記憶體約 ${hw.memoryGB} GB，可能不夠（建議 ${need.memoryGB} GB 以上）`)
      if (hw.freeStorageMB !== null && hw.freeStorageMB < need.freeStorageMB) reasons.push(`可用儲存空間 ${hw.freeStorageMB} MB 可能不夠`)
      if (hw.maxBufferMB < need.maxBufferMB) reasons.push(`GPU 緩衝上限 ${hw.maxBufferMB} MB，可能不夠`)
    }
  }

  if (key === 'none') return { key, id: '', label: '只用向量檢索（摘錄）', device: 'wasm', dtype: 'q4', sizeMB: 0, reasons }
  const device: Device = gpu ? 'webgpu' : 'wasm'
  const dtype: Dtype = gpu ? 'q4f16' : 'q4'
  const g = GENERATORS[key]
  return { key, id: g.id, label: g.label, device, dtype, sizeMB: g.sizeMB[dtype] ?? 0, reasons }
}

/** What the competition requires us to disclose about on-device models. */
export function modelDisclosure(choice: ModelChoice | null, embedding: EmbeddingModel = EMBEDDING_MODELS.light) {
  const g = choice && choice.key !== 'none' ? GENERATORS[choice.key] : null
  return [
    { label: '向量模型', value: `${embedding.base}（${embedding.vendor}，${embedding.licence}）` },
    { label: '向量量化', value: `${embedding.dtype}，${embedding.id}` },
    { label: '語言模型', value: g ? `${g.base}（${g.vendor}，${g.licence}）` : '未使用（只做向量檢索＋摘錄）' },
    { label: '語言量化', value: g ? `${choice!.dtype}，${choice!.id}` : '—' },
    { label: '推論框架', value: `Transformers.js 4.3.2 + ONNX Runtime Web（${choice?.device === 'webgpu' ? 'WebGPU' : 'WebAssembly'}）` },
    { label: '執行位置', value: '全部在手機上（裝置端），不連任何雲端模型' },
  ]
}

// ---------------------------------------------------------------- state (shared singleton)
const progress = ref(0)
const message = ref('')
const hardware = ref<HardwareProfile | null>(null)
const choice = ref<ModelChoice | null>(null)
const offlineReady = ref<string[]>([])
const embedding = shallowRef<EmbeddingModel>(ONLY_OPEN_SOURCE_MODELS ? EMBEDDING_MODELS.light : EMBEDDING_MODELS.standard)

export function useModel() {
  return {
    progress,
    message,
    hardware,
    choice,
    offlineReady,
    embedding,
    disclosure: computed(() => modelDisclosure(choice.value, embedding.value)),
    isOffline: computed(() => isOfflineReady(choice.value, offlineReady.value, embedding.value)),
    inspectDevice,
    prepareEmbedding,
    prepareLanguageModel,
  }
}

/** True when every file the choice needs is on the device, so it can run with the network off. */
export function isOfflineReady(c: ModelChoice | null, stored: string[], embed: EmbeddingModel = embedding.value): boolean {
  return !!c && stored.includes(embed.id) && (c.key === 'none' || stored.includes(c.id))
}

/** The embedding model this phone uses; decided by inspectDevice. */
export const activeEmbedding = (): EmbeddingModel => embedding.value

/** Probe the phone and pick a model without downloading anything. */
export async function inspectDevice(override?: ModelKey): Promise<ModelChoice> {
  hardware.value = await probeHardware()
  choice.value = chooseGenerator(hardware.value, override)
  embedding.value = chooseEmbedding(hardware.value)
  await __refreshOfflineReady()
  return choice.value
}

/** Download (first time) and load the embedding model. Safe to call again. */
export async function prepareEmbedding(): Promise<void> {
  void requestPersistentStorage() // keep downloaded models from being evicted before the demo
  message.value = '載入向量模型'
  await loadEmbedder(embedding.value.id, embedding.value.dtype, __onProgress)
  await __refreshOfflineReady()
}

/** Download (first time) and load the chosen language model. A failed Gemma 3 1B falls back to 350M. */
export async function prepareLanguageModel(override?: ModelKey): Promise<void> {
  const c = await inspectDevice(override)
  message.value = `載入 ${c.label}`
  try {
    if (c.key === 'none') await unloadGenerator()
    else await loadGenerator(c.id, c.device, c.dtype, __onProgress)
  } catch (err) {
    if (c.key !== 'large') throw err
    const fallback = chooseGenerator(hardware.value!, 'small')
    fallback.reasons.unshift(`Gemma 3 1B 載入失敗（${err instanceof Error ? err.message : err}），改用 350M`)
    choice.value = fallback
    message.value = `載入 ${fallback.label}`
    await loadGenerator(fallback.id, fallback.device, fallback.dtype, __onProgress)
  }
  await __refreshOfflineReady()
  message.value = ''
}

let __lastQuery: { text: string; vector: Promise<number[]> } | null = null

/** Vectors for search; the prefixes are what each model was trained with. Asking for the same text twice in a row costs nothing. */
export function embedQuery(text: string): Promise<number[]> {
  const q = text.trim()
  if (__lastQuery?.text !== q) {
    __lastQuery = { text: q, vector: embed([`${embedding.value.queryPrefix}${q}`]).then((v) => v[0]!) }
  }
  return __lastQuery.vector
}
export const embedPassages = (texts: string[]): Promise<number[][]> => embed(texts.map((t) => `${embedding.value.passagePrefix}${t}`))

export const languageModelReady = (): boolean => !!loadedGenerator()
export const languageModelId = (): string => loadedGenerator()

export interface CompleteOptions {
  maxNewTokens?: number
  onText?: (text: string) => void
  /** offered through the model's chat template */
  tools?: ModelTool[]
  /** keep markers such as <tool_call> in the returned text */
  keepSpecialTokens?: boolean
}

/** One answer from the loaded language model. */
export function complete(messages: ChatMessage[], options: CompleteOptions = {}): Promise<string> {
  return generate(messages, {
    maxNewTokens: options.maxNewTokens ?? 120,
    onText: options.onText,
    tools: options.tools,
    skipSpecialTokens: !options.keepSpecialTokens,
  })
}

// ---------------------------------------------------------------- internals
async function __refreshOfflineReady(): Promise<void> {
  // only the weights this code loads count: another quantisation of the same model doesn't help offline
  offlineReady.value = await cachedModelIds([
    ...Object.values(EMBEDDING_MODELS).map((m) => ({ id: m.id, weights: /model_quantized\.onnx/ })),
    ...Object.values(GENERATORS).map((g) => ({ id: g.id, weights: /model_q4(f16)?\.onnx/ })),
  ])
}

function __onProgress(p: { file: string; loaded: number; total: number }): void {
  progress.value = p.total ? p.loaded / p.total : 0
  message.value = `下載 ${p.file.split('/').at(-1)}（${Math.round(p.loaded / 2 ** 20)} / ${Math.round(p.total / 2 ** 20)} MB）`
}
