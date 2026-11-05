<script setup lang="ts">
/** @component T02 DetailPage — 詳細頁模板 */
/**
 * Standard "detail" screen: title -> tags -> summary -> info rows -> map -> 注意事項 -> source -> sticky actions.
 * Every section is optional, so a feature fills in only what it has and gets a consistent page for free.
 *
 *   <DetailPage title="..." :tags="['免費']" :info="[{label:'地址', value:'...'}]" :notices="[{title:'...', body:'...'}]">
 *     <p>summary text</p>
 *     <template #actions><BaseButton block>導航</BaseButton></template>
 *   </DetailPage>
 */
import BaseTag from '../atoms/BaseTag.vue'
import SourceNote from '../atoms/SourceNote.vue'
import InfoTable, { type InfoRow } from '../molecules/InfoTable.vue'
import NoticeList, { type Notice } from '../organisms/NoticeList.vue'
import OsmMap from '../organisms/OsmMap.vue'
import PageContainer from './PageContainer.vue'

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
        <div class="flex items-start gap-2">
          <p v-if="subtitle" class="flex-1 text-sm text-grey-500">{{ subtitle }}</p>
          <slot name="headerAction" />
        </div>
        <div v-if="tags?.length" class="mt-2 flex flex-wrap gap-1.5">
          <BaseTag v-for="t in tags" :key="t">{{ t }}</BaseTag>
        </div>
        <div v-if="$slots.default" class="mt-3 leading-relaxed text-grey-700"><slot /></div>
      </section>

      <InfoTable v-if="info?.length" :rows="info" />
      <OsmMap v-if="location" :center="[location.lat, location.lng]" :markers="[{ ...location, label: title }]" />
      <NoticeList v-if="notices?.length" :notices="notices" />
      <slot name="extra" />
      <SourceNote v-if="source" :source="source" />
    </div>

    <template v-if="$slots.actions" #bottom>
      <div class="flex gap-2"><slot name="actions" /></div>
    </template>
  </PageContainer>
</template>
