<script setup lang="ts">
/** @component O08 ChatMap — 對話框內的地圖（標點，點標點看說明） */
import { defineAsyncComponent } from 'vue'
import SkeletonBlock from '../atoms/SkeletonBlock.vue'
import type { MapMarker } from './OsmMap.vue'

defineProps<{ title?: string; markers: MapMarker[] }>()

// Loaded on demand: most conversations never show a map.
const OsmMap = defineAsyncComponent({
  loader: () => import('./OsmMap.vue'),
  loadingComponent: SkeletonBlock,
})
</script>

<template>
  <figure class="space-y-1">
    <figcaption v-if="title" class="text-sm font-medium text-grey-900">{{ title }}</figcaption>
    <OsmMap :markers="markers" fit :aria-label="`地圖，標出 ${markers.length} 個地點`" />
  </figure>
</template>
