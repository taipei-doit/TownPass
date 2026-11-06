/**
 * LOGIC LAYER - the chat box on the home screen.
 * Answers in this order, and the rules and search below never need a model:
 *   1. an optional assistant provider from a feature (e.g. the agent add-on); it may pass with null
 *   2. a tool whose trigger phrase matches (map, image...)
 *   3. on-device search: text + result cards, or feature suggestions when nothing matches
 */
import { computed, ref } from 'vue'
import type { Component } from 'vue'
import type { RouteLocationRaw } from 'vue-router'
import { MessageCircle } from 'lucide-vue-next'
import { featureEntry, features, type ToolBlock, type ToolResult } from '@/framework'
import { search, searchReady } from '@/modules/search'
import { listTools, routeByRules, runTool } from '@/modules/tools'

export interface AssistantResult {
  key: string
  title: string
  subtitle?: string
  tags?: string[]
  icon: Component
  to: RouteLocationRaw
}
export interface AssistantMessage {
  id: number
  role: 'user' | 'bot'
  text: string
  /** true while the answer is being worked out */
  pending?: boolean
  results?: AssistantResult[]
  /** maps, images and original text drawn inside the conversation */
  blocks?: ToolBlock[]
  /** key = feature id */
  suggestions?: { key: string; label: string; icon: Component }[]
}

/** One conversation per page instance. */
export function useAssistant() {
  const messages = ref<AssistantMessage[]>([])
  let seq = 0

  async function ask(text: string): Promise<void> {
    const q = text.trim()
    if (!q) return
    messages.value.push({ id: ++seq, role: 'user', text: q })
    const id = ++seq
    messages.value.push({ id, role: 'bot', text: '', pending: true })
    const current = () => messages.value.find((m) => m.id === id)!
    const reply = await __reply(q, (partial) => {
      current().text += partial
    })
    Object.assign(current(), reply, { pending: false })
  }

  const quickActions = computed(() => features.flatMap((f) => f.quickActions ?? []).slice(0, 8))

  return { messages, ask, quickActions, ready: searchReady }
}

/** Entry route of a feature by id (for suggestion chips). */
export function featureEntryRoute(id: string): RouteLocationRaw | undefined {
  const f = features.find((x) => x.id === id)
  return f && featureEntry(f)
}

type __Reply = Omit<AssistantMessage, 'id' | 'role'>

async function __reply(q: string, onText: (partial: string) => void): Promise<__Reply> {
  const answered = (await __fromProvider(q, onText)) ?? (await __fromRules(q))
  return answered ? __toReply(answered) : __fromSearch(q)
}

async function __fromProvider(q: string, onText: (partial: string) => void): Promise<ToolResult | null> {
  const provider = features.find((f) => f.assistant)?.assistant
  if (!provider) return null
  try {
    return await provider.answer({ question: q, tools: listTools(), runTool, routeByRules, onText })
  } catch (err) {
    console.warn(`[assistant] provider ${provider.id} failed`, err)
    return null
  }
}

/** A tool with nothing to show falls through to search, which can still suggest something. */
async function __fromRules(q: string): Promise<ToolResult | null> {
  const route = routeByRules(q)
  if (!route) return null
  const result = await runTool(route.tool.name, route.args)
  return result.blocks?.length || result.cards?.length ? result : null
}

function __toReply(result: ToolResult): __Reply {
  return {
    text: result.text,
    blocks: result.blocks,
    results: result.cards?.map((c) => ({ ...c, icon: __iconOf(c.featureId) })),
  }
}

function __fromSearch(q: string): __Reply {
  const hits = search(q)
  if (!hits.length) {
    return {
      text: `目前找不到和「${q}」相關的資訊，試試下面的功能：`,
      suggestions: features.map((f) => ({ key: f.id, label: f.title, icon: f.icon })),
    }
  }
  return {
    text: `找到 ${hits.length} 筆和「${q}」相關的資訊：`,
    results: hits.map((h) => ({
      key: h.key,
      title: h.title,
      subtitle: h.subtitle,
      tags: h.tags,
      icon: __iconOf(h.featureId),
      to: h.to,
    })),
  }
}

function __iconOf(featureId?: string): Component {
  return features.find((f) => f.id === featureId)?.icon ?? MessageCircle
}
