/**
 * LOGIC LAYER - add-on agent: the chat box's answers when on-device models are loaded.
 *   1. a tool whose trigger phrase matches runs straight away (fast, no model)
 *   2. semantic routing: the question's vector is compared with each tool's `examples`.
 *      Needs only the embedding model, so it works on phones without WebGPU
 *   3. optionally the language model picks a tool (function calling); off by default because
 *      Granite 350M and 1B both got 0 of 5 right in Chinese when measured (model/README.md)
 *   4. retrieval: the answer plus the source document's original text, images and location
 * A model only ever passes search text. Coordinates and image addresses come from the data.
 */
import type { AssistantContext, AssistantProvider, ToolArgs, ToolBlock, ToolCard, ToolDefinition, ToolResult } from '@/framework'
import { complete, embedPassages, embedQuery, languageModelReady, type ModelTool } from '@/addons/model'
import { useRag, type RagAnswer } from '@/addons/rag'

export interface AgentOptions {
  /** Pick tools by meaning when no trigger phrase matches. Default on. */
  semanticRouting?: boolean
  /** Let the language model pick tools. Costs one extra model run per question. Default off. */
  toolCalling?: boolean
}

/**
 * Chosen by measurement with multilingual-e5-small on 15 Chinese questions: with these values no
 * ordinary question reached a tool by mistake. A question below them goes to retrieval, which
 * still shows the document's images and location.
 */
export const SEMANTIC_ROUTING = { minScore: 0.85, minMargin: 0.01 }

/** Ordinary questions: a tool has to beat these to be chosen. */
const __NO_TOOL_EXAMPLES = ['這個要收費嗎', '幾點開放', '有什麼規定', '要怎麼申請', '內容是什麼']

export function createAgent(options: AgentOptions = {}): AssistantProvider {
  return { id: 'agent', answer: (context) => __answer(context, options) }
}

export interface ToolCall {
  name: string
  args: ToolArgs
}

/** Scores are each tool's best similarity to the question. Null when nothing clearly wins. */
export function pickBySimilarity(toolScores: { name: string; score: number }[], noToolScore: number): string | null {
  const [best, second] = [...toolScores].sort((a, b) => b.score - a.score)
  if (!best || best.score < SEMANTIC_ROUTING.minScore) return null
  const rival = Math.max(noToolScore, second?.score ?? -1)
  return best.score - rival >= SEMANTIC_ROUTING.minMargin ? best.name : null
}

/** The tool whose examples are closest in meaning to the question, or null. */
export async function routeByMeaning(question: string, tools: ToolDefinition[]): Promise<ToolDefinition | null> {
  const withExamples = tools.filter((t) => t.examples?.length)
  if (!withExamples.length) return null
  const q = await embedQuery(question)
  const best = async (key: string, examples: string[]) => Math.max(...(await __vectorsOf(key, examples)).map((v) => __dot(q, v)))
  const toolScores = await Promise.all(withExamples.map(async (t) => ({ name: t.name, score: await best(`tool:${t.name}`, t.examples!) })))
  const name = pickBySimilarity(toolScores, await best('no-tool', __NO_TOOL_EXAMPLES))
  return withExamples.find((t) => t.name === name) ?? null
}

/** Ask the language model whether a tool fits the question. Null when it answers with plain text. */
export async function chooseTool(question: string, tools: ToolDefinition[]): Promise<ToolCall | null> {
  if (!languageModelReady()) return null
  const output = await complete([{ role: 'user', content: question }], {
    maxNewTokens: 64,
    tools: tools.map(__toModelTool),
    keepSpecialTokens: true,
  })
  const call = parseToolCall(output)
  return call && tools.some((t) => t.name === call.name) ? call : null
}

/** Reads `<tool_call>{"name": ..., "arguments": {...}}</tool_call>`; a missing end tag is fine. */
export function parseToolCall(output: string): ToolCall | null {
  const json = output.match(/<tool_call>\s*(\{[\s\S]*\})/)?.[1] ?? output.match(/^\s*(\{[\s\S]*"name"[\s\S]*\})\s*$/)?.[1]
  if (!json) return null
  try {
    const parsed = JSON.parse(json) as { name?: unknown; arguments?: unknown }
    if (typeof parsed.name !== 'string') return null
    return { name: parsed.name, args: parsed.arguments && typeof parsed.arguments === 'object' ? (parsed.arguments as ToolArgs) : {} }
  } catch {
    return null
  }
}

/** Turns a retrieval answer into chat content: what was said, then the source itself. */
export function answerToResult(answer: RagAnswer): ToolResult {
  const d = answer.document
  const blocks: ToolBlock[] = []
  if (d?.text) blocks.push({ type: 'quote', title: `原文：${d.title}`, text: d.text, source: d.source })
  for (const image of d?.images ?? []) blocks.push({ type: 'image', ...image, source: d?.source })
  if (d?.geo) {
    const detail = d.validFrom || d.validTo ? `${d.validFrom ?? ''}～${d.validTo ?? ''}` : undefined
    blocks.push({ type: 'map', markers: [{ ...d.geo, label: d.title, detail }] })
  }
  const cards: ToolCard[] = answer.sources.slice(0, 3).map((s) => ({ key: s.key, title: s.title, subtitle: s.subtitle, to: s.to }))
  return { text: answer.answer, blocks, cards }
}

async function __answer(context: AssistantContext, options: AgentOptions): Promise<ToolResult | null> {
  const rag = useRag()
  if (rag.status.value !== 'ready') return null // models not loaded: the built-in rules and search answer

  const { question, tools } = context
  const route = context.routeByRules(question)
  if (route) {
    const result = await context.runTool(route.tool.name, route.args)
    if (__hasContent(result)) return result
  }
  if (options.semanticRouting !== false) {
    const tool = await routeByMeaning(question, tools)
    if (tool) {
      const result = await context.runTool(tool.name, tool.toArgs ? tool.toArgs(question) : { query: question })
      if (__hasContent(result)) return result
    }
  }
  if (options.toolCalling) {
    const call = await chooseTool(question, tools)
    if (call) {
      const result = await context.runTool(call.name, call.args)
      if (__hasContent(result)) return result
    }
  }
  const answer = await rag.ask(question, context.onText)
  return answer.relevant ? answerToResult(answer) : null
}

const __hasContent = (result: ToolResult): boolean => !!result.blocks?.length || !!result.cards?.length

const __vectorCache = new Map<string, Promise<number[][]>>()

function __vectorsOf(key: string, examples: string[]): Promise<number[][]> {
  if (!__vectorCache.has(key)) __vectorCache.set(key, embedPassages(examples))
  return __vectorCache.get(key)!
}

function __dot(a: number[], b: number[]): number {
  let s = 0
  for (let i = 0; i < a.length; i++) s += a[i]! * b[i]!
  return s
}

function __toModelTool(tool: ToolDefinition): ModelTool {
  return { type: 'function', function: { name: tool.name, description: tool.description, parameters: tool.parameters } }
}
