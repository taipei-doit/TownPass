<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { useRoute } from 'vue-router'
import { Navigation, Share2 } from 'lucide-vue-next'
import { send } from '@/bridge/townpass'
import { BaseButton, DetailPage, EmptyState, PageContainer, SkeletonBlock } from '@/ui'
import { getPlace, type Place } from './data'

const route = useRoute()
const place = ref<Place | null>()

onMounted(async () => (place.value = (await getPlace(Number(route.params.id))) ?? null))

// launch_map asks the app to open the phone's map app (see docs/bridge.md)
const navigate = (p: Place) => send('launch_map', `geo:${p.lat},${p.lng}?q=${encodeURIComponent(p.name)}`)

// Web Share API (Android WebView supports it); fall back to copying the link
async function share(p: Place) {
  const data = { title: p.name, text: `${p.name}｜${p.address}`, url: location.href }
  try {
    if (navigator.share) await navigator.share(data)
    else await navigator.clipboard.writeText(data.url)
  } catch {
    /* user cancelled */
  }
}
</script>

<template>
  <PageContainer v-if="place === undefined" back><SkeletonBlock class="mt-6" :lines="5" /></PageContainer>
  <PageContainer v-else-if="place === null" back><EmptyState title="找不到這個地點" /></PageContainer>
  <DetailPage
    v-else
    :title="place.name"
    :subtitle="`${place.district}・${place.category}`"
    :tags="place.tags"
    :info="[
      { label: '地址', value: place.address },
      { label: '開放時間', value: place.hours },
    ]"
    :location="{ lat: place.lat, lng: place.lng }"
    :notices="place.notices"
    source="（範例）臺北市公園基本資料，臺北資料大平台"
  >
    這是範例詳細頁：上方摘要、資訊列、地圖、注意事項與底部動作按鈕都由 DetailPage 提供，功能只需要填資料。
    <template #actions>
      <BaseButton variant="outline" :icon="Share2" class="flex-1" @click="share(place)">分享</BaseButton>
      <BaseButton :icon="Navigation" class="flex-1" @click="navigate(place)">導航</BaseButton>
    </template>
  </DetailPage>
</template>
