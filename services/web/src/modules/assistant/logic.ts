/**
 * LOGIC LAYER - the chat box on the home screen.
 * Turns a question into a reply (text + result cards, or feature suggestions when nothing matches).
 * Deterministic and on-device: no LLM.
 */
import { computed, ref } from 'vue'
import type { Component } from 'vue'
import type { RouteLocationRaw } from 'vue-router'
import { MessageCircle } from 'lucide-vue-next'
import { featureEntry, features } from '@/framework'
import { search, searchReady } from '@/modules/search'

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
  results?: AssistantResult[]
  /** key = feature id */
  suggestions?: { key: string; label: string; icon: Component }[]
}

/** One conversation per page instance. */
export function useAssistant() {
  const messages = ref<AssistantMessage[]>([])
  let seq = 0

  function ask(text: string): void {
    const q = text.trim()
    if (!q) return
    messages.value.push({ id: ++seq, role: 'user', text: q })
    messages.value.push({ id: ++seq, role: 'bot', ...__reply(q) })
  }

  const quickActions = computed(() => features.flatMap((f) => f.quickActions ?? []).slice(0, 8))

  return { messages, ask, quickActions, ready: searchReady }
}

/** Entry route of a feature by id (for suggestion chips). */
export function featureEntryRoute(id: string): RouteLocationRaw | undefined {
  const f = features.find((x) => x.id === id)
  return f && featureEntry(f)
}

function __reply(q: string): Omit<AssistantMessage, 'id' | 'role'> {
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

function __iconOf(featureId: string): Component {
  return features.find((f) => f.id === featureId)?.icon ?? MessageCircle
}
