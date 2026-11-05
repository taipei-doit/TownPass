<script setup lang="ts">
/** @component EX-P01 PlaceListPage — 範例：設施列表 */
import { MapPin } from 'lucide-vue-next'
import { EmptyState, ListItem, PageContainer, SkeletonBlock } from '@/ui'
import { placeDetailRoute, usePlaceList } from '../logic'
import CategoryFilter from './CategoryFilter.vue'

const { places, categories, active, shown, setCategory } = usePlaceList()
</script>

<template>
  <PageContainer title="範例：找設施" back>
    <CategoryFilter :categories="categories" :active="active" @select="setCategory" />
    <SkeletonBlock v-if="!places" :lines="4" class="mt-4" />
    <EmptyState v-else-if="!shown.length" title="這個分類沒有資料" />
    <div v-else class="divide-y divide-grey-100">
      <ListItem
        v-for="p in shown"
        :key="p.id"
        :title="p.name"
        :subtitle="`${p.district}・${p.hours}`"
        :icon="MapPin"
        :to="placeDetailRoute(p.id)"
      />
    </div>
  </PageContainer>
</template>
