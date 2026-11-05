<script setup lang="ts">
/** @component O05 ChatThread — 對話紀錄（泡泡 + 結果卡片 + 找不到時的建議） */
import { nextTick, ref, watch, type Component } from 'vue'
import type { RouteLocationRaw } from 'vue-router'
import BaseChip from '../atoms/BaseChip.vue'
import ChatBubble from '../molecules/ChatBubble.vue'
import ResultCard from '../molecules/ResultCard.vue'

export type ThreadResult = { key: string; title: string; subtitle?: string; tags?: string[]; icon: Component; to: RouteLocationRaw }
export type ThreadSuggestion = { key: string; label: string; icon: Component }
export type ThreadMessage = {
  id: number
  role: 'user' | 'bot'
  text: string
  results?: ThreadResult[]
  suggestions?: ThreadSuggestion[]
}

const props = defineProps<{ messages: ThreadMessage[] }>()
const emit = defineEmits<{ suggest: [key: string] }>()

const list = ref<HTMLElement>()
watch(
  () => props.messages.length,
  async () => {
    await nextTick()
    list.value?.lastElementChild?.scrollIntoView({ behavior: 'smooth', block: 'start' })
  },
)
</script>

<template>
  <ol ref="list" class="space-y-4" aria-live="polite">
    <li v-for="m in messages" :key="m.id" class="space-y-2">
      <ChatBubble :role="m.role">{{ m.text }}</ChatBubble>
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
