<script setup lang="ts">
/**
 * Standard "detail" screen: title -> tags -> summary -> info rows -> map -> 注意事項 -> source -> sticky actions.
 * Every section is optional, so a feature fills in only what it has and gets a consistent page for free.
 *
 *   <DetailPage title="..." :tags="['免費']" :info="[{label:'地址', value:'...'}]" :notices="[{title:'...', body:'...'}]">
 *     <p>summary text</p>
 *     <template #actions><BaseButton block>導航</BaseButton></template>
 *   </DetailPage>
 */
import { AlertCircle } from 'lucide-vue-next'
import PageContainer from './PageContainer.vue'
import BaseTag from './BaseTag.vue'
import CollapseItem from './CollapseItem.vue'
import OsmMap from './OsmMap.vue'

export type InfoRow = { label: string; value: string }
export type Notice = { title: string; body: string }

defineProps<{
  title: string
  subtitle?: string
  tags?: string[]
  info?: InfoRow[]
  notices?: Notice[]
  location?: { lat: number; lng: number }
  /** Open-data citation shown at the bottom (competition rule) */
  source?: string
}>()
</script>

<template>
  <PageContainer :title="title" back>
    <div class="space-y-5 pt-2">
      <section>
        <p v-if="subtitle" class="text-sm text-grey-500">{{ subtitle }}</p>
        <div v-if="tags?.length" class="mt-2 flex flex-wrap gap-1.5">
          <BaseTag v-for="t in tags" :key="t">{{ t }}</BaseTag>
        </div>
        <div v-if="$slots.default" class="mt-3 leading-relaxed text-grey-700"><slot /></div>
      </section>

      <dl v-if="info?.length" class="divide-y divide-grey-100 rounded-xl bg-grey-50 px-4">
        <div v-for="row in info" :key="row.label" class="flex gap-4 py-3 text-sm">
          <dt class="w-20 shrink-0 text-grey-500">{{ row.label }}</dt>
          <dd class="flex-1 text-grey-800">{{ row.value }}</dd>
        </div>
      </dl>

      <OsmMap v-if="location" :center="[location.lat, location.lng]" :markers="[{ ...location, label: title }]" />

      <section v-if="notices?.length">
        <h2 class="mb-1 text-lg font-semibold text-grey-900">注意事項</h2>
        <CollapseItem v-for="(n, i) in notices" :key="n.title" :title="n.title" :icon="AlertCircle" :default-open="i === 0">
          {{ n.body }}
        </CollapseItem>
      </section>

      <slot name="extra" />

      <p v-if="source" class="text-xs text-grey-400">資料來源：{{ source }}</p>
    </div>

    <template v-if="$slots.actions" #bottom>
      <div class="flex gap-2"><slot name="actions" /></div>
    </template>
  </PageContainer>
</template>
