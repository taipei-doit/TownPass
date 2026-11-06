<script setup lang="ts">
/** @component O05 ChatThread — 對話紀錄（泡泡 + 地圖／圖片／原文 + 結果卡片 + 建議） */
import { nextTick, ref, watch, type Component } from 'vue'
import type { RouteLocationRaw } from 'vue-router'
import BaseChip from '../atoms/BaseChip.vue'
import ChatBubble from '../molecules/ChatBubble.vue'
import ChatImage from '../molecules/ChatImage.vue'
import ChatQuote from '../molecules/ChatQuote.vue'
import ResultCard from '../molecules/ResultCard.vue'
import ChatMap from './ChatMap.vue'
import type { MapMarker } from './OsmMap.vue'

export type ThreadResult = { key: string; title: string; subtitle?: string; tags?: string[]; icon: Component; to: RouteLocationRaw }
export type ThreadSuggestion = { key: string; label: string; icon: Component }
export type ThreadBlock =
  | { type: 'map'; title?: string; markers: MapMarker[] }
  | { type: 'image'; src: string; alt: string; caption?: string; source?: string }
  | { type: 'quote'; title?: string; text: string; source?: string }
export type ThreadMessage = {
  id: number
  role: 'user' | 'bot'
  text: string
  pending?: boolean
  results?: ThreadResult[]
  blocks?: ThreadBlock[]
  suggestions?: ThreadSuggestion[]
}

const props = defineProps<{ messages: ThreadMessage[]; speakable?: boolean }>()
const emit = defineEmits<{ suggest: [key: string]; speak: [text: string] }>()

const list = ref<HTMLElement>()
// Answers arrive later than the question, so scroll again when the last one finishes.
watch(
  () => [props.messages.length, props.messages.at(-1)?.pending],
  async () => {
    await nextTick()
    list.value?.lastElementChild?.scrollIntoView({ behavior: 'smooth', block: 'start' })
  },
)
</script>

<template>
  <ol ref="list" class="space-y-4" aria-live="polite">
    <li v-for="m in messages" :key="m.id" class="space-y-2">
      <ChatBubble :role="m.role">{{ m.text }}<span v-if="m.pending" class="animate-pulse text-primary-500" aria-label="回答中">▍</span></ChatBubble>
      <template v-for="(b, i) in m.blocks" :key="i">
        <ChatMap v-if="b.type === 'map'" :title="b.title" :markers="b.markers" />
        <ChatImage v-else-if="b.type === 'image'" :src="b.src" :alt="b.alt" :caption="b.caption" :source="b.source" />
        <ChatQuote v-else :title="b.title" :text="b.text" :source="b.source" :speakable="speakable" @speak="emit('speak', $event)" />
      </template>
      <ResultCard
        v-for="r in m.results"
        :key="r.key"
        :title="r.title"
        :subtitle="r.subtitle"
        :tags="r.tags"
        :icon="r.icon"
        :to="r.to"
      />
      <div v-if="m.suggestions?.length" class="flex flex-wrap gap-2">
        <BaseChip v-for="s in m.suggestions" :key="s.key" :icon="s.icon" @click="emit('suggest', s.key)">{{ s.label }}</BaseChip>
      </div>
    </li>
  </ol>
</template>
