<script setup lang="ts">
/** @component O04 ChatComposer — 對話輸入列（快捷 chips + 輸入框 + 送出） */
import { ArrowUp } from 'lucide-vue-next'
import BaseChip from '../atoms/BaseChip.vue'
import ChipRail from '../molecules/ChipRail.vue'

export type QuickAction = { label: string }

const query = defineModel<string>({ default: '' })
defineProps<{ quickActions?: QuickAction[]; ready?: boolean; placeholder?: string }>()
const emit = defineEmits<{ submit: [text: string]; pick: [index: number] }>()
</script>

<template>
  <div>
    <ChipRail v-if="quickActions?.length" class="mb-2.5">
      <BaseChip v-for="(a, i) in quickActions" :key="a.label" @click="emit('pick', i)">{{ a.label }}</BaseChip>
    </ChipRail>
    <form class="flex items-center gap-2" @submit.prevent="emit('submit', query)">
      <input
        v-model="query"
        type="search"
        enterkeyhint="send"
        :placeholder="ready === false ? '準備中…' : (placeholder ?? '輸入想找的服務或地點…')"
        aria-label="輸入問題"
        class="h-11 flex-1 rounded-full border border-grey-200 bg-grey-50 px-4 text-base outline-none focus:border-primary-500 focus:bg-white"
      />
      <button
        type="submit"
        class="grid size-11 shrink-0 place-items-center rounded-full bg-primary-500 text-white disabled:opacity-40"
        :disabled="!query.trim()"
        aria-label="送出"
      >
        <ArrowUp class="size-5" />
      </button>
    </form>
  </div>
</template>
