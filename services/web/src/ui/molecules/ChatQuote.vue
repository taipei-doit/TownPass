<script setup lang="ts">
/** @component M11 ChatQuote — 對話框內的原文（逐字顯示、可朗讀） */
import { Volume2 } from 'lucide-vue-next'
import BaseCard from './BaseCard.vue'
import SourceNote from '../atoms/SourceNote.vue'

defineProps<{ title?: string; text: string; source?: string; speakable?: boolean }>()
defineEmits<{ speak: [text: string] }>()
</script>

<template>
  <BaseCard flat class="space-y-2 !p-3">
    <div class="flex items-center gap-2">
      <p class="min-w-0 flex-1 text-sm font-medium text-grey-900">{{ title ?? '原文' }}</p>
      <button
        v-if="speakable"
        type="button"
        class="-m-1 inline-flex size-9 items-center justify-center rounded-full text-primary-500"
        aria-label="朗讀原文"
        @click="$emit('speak', text)"
      >
        <Volume2 class="size-5" aria-hidden="true" />
      </button>
    </div>
    <p class="text-sm leading-relaxed whitespace-pre-line text-grey-700">{{ text }}</p>
    <SourceNote v-if="source" :source="source" />
  </BaseCard>
</template>
