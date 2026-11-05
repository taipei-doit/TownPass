<script setup lang="ts">
/** @component O03 NoticeList — 注意事項清單（第一項預設展開） */
import { AlertCircle } from 'lucide-vue-next'
import CollapseItem from '../molecules/CollapseItem.vue'

export type Notice = { title: string; body: string }
withDefaults(defineProps<{ notices: Notice[]; title?: string }>(), { title: '注意事項' })
</script>

<template>
  <section>
    <h2 class="mb-1 text-lg font-semibold text-grey-900">{{ title }}</h2>
    <CollapseItem v-for="(n, i) in notices" :key="n.title" :title="n.title" :icon="AlertCircle" :default-open="i === 0">
      {{ n.body }}
    </CollapseItem>
  </section>
</template>
