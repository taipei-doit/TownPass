<script setup lang="ts">
/** @component RG-C02 AnswerCard — 模型回答（串流）＋引用來源 */
import { BookOpen } from 'lucide-vue-next'
import type { RouteLocationRaw } from 'vue-router'
import { BaseCard, BaseTag, ResultCard } from '@/ui'

defineProps<{
  text: string
  busy: boolean
  meta?: string
  sources: { key: string; title: string; subtitle?: string; score: number; to: RouteLocationRaw }[]
}>()
</script>

<template>
  <BaseCard class="space-y-3">
    <p class="leading-relaxed whitespace-pre-wrap text-grey-800" aria-live="polite">
      {{ text }}<span v-if="busy" class="animate-pulse text-primary-500">▍</span>
    </p>
    <p v-if="meta" class="text-xs text-grey-400">{{ meta }}</p>
    <div v-if="sources.length" class="space-y-2">
      <p class="text-sm font-medium text-grey-600">回答依據</p>
      <div v-for="s in sources" :key="s.key" class="relative">
        <ResultCard :title="s.title" :subtitle="s.subtitle" :icon="BookOpen" :to="s.to" />
        <BaseTag tone="grey" class="absolute top-3 right-3">{{ s.score.toFixed(2) }}</BaseTag>
      </div>
    </div>
  </BaseCard>
</template>
