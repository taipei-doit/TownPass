<script setup lang="ts">
/** @component EX-P02 PlaceDetailPage — 範例：設施詳細頁 */
import { useRoute } from 'vue-router'
import { Navigation, Share2 } from 'lucide-vue-next'
import { BaseButton, DetailPage, EmptyState, PageContainer, SkeletonBlock } from '@/ui'
import { usePlaceDetail } from '../logic'

const route = useRoute()
const { place, message, navigate, share } = usePlaceDetail(Number(route.params.id))
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
    這是範例詳細頁：摘要、資訊列、地圖、注意事項與底部按鈕都由 DetailPage（T02）組合而成，功能只需要填資料。
    <p v-if="message" class="mt-2 text-sm text-warn-200" role="status">{{ message }}</p>
    <template #actions>
      <BaseButton variant="outline" :icon="Share2" class="flex-1" @click="share">分享</BaseButton>
      <BaseButton :icon="Navigation" class="flex-1" @click="navigate">導航</BaseButton>
    </template>
  </DetailPage>
</template>
