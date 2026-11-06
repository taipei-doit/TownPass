/**
 * LOGIC LAYER - add-on model: which on-device models to run, and the calls to run them.
 * Other add-ons and features use this for embeddings and text generation; they never touch the
 * runtime. Competition rule: everything runs on the device; modelDisclosure lists what to disclose.
 */
import { computed, ref } from 'vue'
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

export const EMBEDDING_MODEL = {
  id: 'Xenova/multilingual-e5-small',
  base: 'intfloat/multilingual-e5-small',
  vendor: 'Microsoft',
  licence: 'MIT',
  dtype: 'q8' as Dtype,
  sizeMB: 118,
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
    id: 'onnx-community/granite-4.0-1b-ONNX-web',
    base: 'ibm-granite/granite-4.0-1b',
    label: 'Granite 4.0 1B',
    vendor: 'IBM',
    licence: 'Apache-2.0',
    sizeMB: { q4f16: 1247, q4: 1781 } as Record<string, number>,
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

/**
 * Pure policy: which language model this phone should run.
 *   WebGPU + fp16     -> 350M on the GPU
 *   no usable WebGPU  -> no LLM (extractive answers): measured ~30 s per answer for 350M on a
 *                        laptop CPU - unusable in a demo. Override 'small' still runs it on the CPU.
 *   1B only when asked for: measured worse than 350M in Chinese (garbled text, English) at 3.7
 *   times the size, see README.md. It never runs on the CPU.
 */
export function chooseGenerator(hw: HardwareProfile, override?: ModelKey): ModelChoice {
  const gpu = hw.webgpu && hw.shaderF16
  const reasons: string[] = []
  let key: ModelKey

  if (!gpu) {
    reasons.push(hw.webgpu ? 'GPU 不支援 16 位元運算' : '這個 WebView 沒有 WebGPU', 'CPU 生成每題約 30 秒 → 預設只做向量檢索＋摘錄')
    key = 'none'
    if (override === 'small') (key = 'small'), reasons.unshift('手動指定 350M（CPU，回答很慢）')
    if (override === 'large') (key = 'small'), reasons.unshift('沒有 GPU 不能跑 1B，改用 350M（CPU，回答很慢）')
  } else {
    key = 'small'
    reasons.push('有 WebGPU → 在 GPU 上跑 350M')
    if (override && override !== key) {
      key = override
      reasons.unshift(`手動指定 ${override === 'none' ? '只摘錄' : GENERATORS[override].label}`)
    }
  }

  if (key === 'none') return { key, id: '', label: '只用向量檢索（摘錄）', device: 'wasm', dtype: 'q4', sizeMB: 0, reasons }
  const device: Device = gpu ? 'webgpu' : 'wasm'
  const dtype: Dtype = gpu ? 'q4f16' : 'q4'
  const g = GENERATORS[key]
  return { key, id: g.id, label: g.label, device, dtype, sizeMB: g.sizeMB[dtype] ?? 0, reasons }
}

/** What the competition requires us to disclose about on-device models. */
export function modelDisclosure(choice: ModelChoice | null) {
  const g = choice && choice.key !== 'none' ? GENERATORS[choice.key] : null
  return [
    { label: '向量模型', value: `${EMBEDDING_MODEL.base}（${EMBEDDING_MODEL.vendor}，${EMBEDDING_MODEL.licence}）` },
    { label: '向量量化', value: `${EMBEDDING_MODEL.dtype}，${EMBEDDING_MODEL.id}` },
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

export function useModel() {
  return {
    progress,
    message,
    hardware,
    choice,
    offlineReady,
    disclosure: computed(() => modelDisclosure(choice.value)),
    isOffline: computed(() => isOfflineReady(choice.value, offlineReady.value)),
    inspectDevice,
    prepareEmbedding,
    prepareLanguageModel,
  }
}

/** True when every file the choice needs is on the device, so it can run with the network off. */
export function isOfflineReady(c: ModelChoice | null, stored: string[]): boolean {
  return !!c && stored.includes(EMBEDDING_MODEL.id) && (c.key === 'none' || stored.includes(c.id))
}

/** Probe the phone and pick a model without downloading anything. */
export async function inspectDevice(override?: ModelKey): Promise<ModelChoice> {
  hardware.value = await probeHardware()
  choice.value = chooseGenerator(hardware.value, override)
  await __refreshOfflineReady()
  return choice.value
}

/** Download (first time) and load the embedding model. Safe to call again. */
export async function prepareEmbedding(): Promise<void> {
  void requestPersistentStorage() // keep downloaded models from being evicted before the demo
  message.value = '載入向量模型'
  await loadEmbedder(EMBEDDING_MODEL.id, EMBEDDING_MODEL.dtype, __onProgress)
  await __refreshOfflineReady()
}

/** Download (first time) and load the chosen language model. A failed 1B falls back to 350M. */
export async function prepareLanguageModel(override?: ModelKey): Promise<void> {
  const c = await inspectDevice(override)
  message.value = `載入 ${c.label}`
  try {
    if (c.key === 'none') await unloadGenerator()
    else await loadGenerator(c.id, c.device, c.dtype, __onProgress)
  } catch (err) {
    if (c.key !== 'large') throw err
    const fallback = chooseGenerator(hardware.value!, 'small')
    fallback.reasons.unshift(`1B 載入失敗（${err instanceof Error ? err.message : err}），改用 350M`)
    choice.value = fallback
    message.value = `載入 ${fallback.label}`
    await loadGenerator(fallback.id, fallback.device, fallback.dtype, __onProgress)
  }
  await __refreshOfflineReady()
  message.value = ''
}

/** Vectors for search: the prefixes are what the e5 models were trained with. */
export const embedQuery = async (text: string): Promise<number[]> => (await embed([`query: ${text.trim()}`]))[0]!
export const embedPassages = (texts: string[]): Promise<number[][]> => embed(texts.map((t) => `passage: ${t}`))

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
  offlineReady.value = await cachedModelIds([EMBEDDING_MODEL.id, GENERATORS.small.id, GENERATORS.large.id])
}

function __onProgress(p: { file: string; loaded: number; total: number }): void {
  progress.value = p.total ? p.loaded / p.total : 0
  message.value = `下載 ${p.file.split('/').at(-1)}（${Math.round(p.loaded / 2 ** 20)} / ${Math.round(p.total / 2 ** 20)} MB）`
}
