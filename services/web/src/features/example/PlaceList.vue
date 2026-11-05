<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { MapPin } from 'lucide-vue-next'
import { featureRoute } from '@/core/feature'
import { BaseChip, EmptyState, ListItem, PageContainer, SkeletonBlock } from '@/ui'
import { listPlaces, type Place } from './data'

const route = useRoute()
const router = useRouter()
const places = ref<Place[]>()
const categories = computed(() => ['全部', ...new Set((places.value ?? []).map((p) => p.category))])
const active = computed(() => (route.query.category as string) || '全部')
const shown = computed(() => (places.value ?? []).filter((p) => active.value === '全部' || p.category === active.value))

const setCategory = (c: string) => router.replace({ query: c === '全部' ? {} : { category: c } })
onMounted(async () => (places.value = await listPlaces()))
</script>

<template>
  <PageContainer title="範例：找設施" back>
    <div class="-mx-4 flex gap-2 overflow-x-auto px-4 py-2">
      <BaseChip v-for="c in categories" :key="c" :active="active === c" @click="setCategory(c)">{{ c }}</BaseChip>
    </div>

    <SkeletonBlock v-if="!places" :lines="4" class="mt-4" />
    <EmptyState v-else-if="!shown.length" title="這個分類沒有資料" />
    <div v-else class="divide-y divide-grey-100">
      <ListItem
        v-for="p in shown"
        :key="p.id"
        :title="p.name"
        :subtitle="`${p.district}・${p.hours}`"
        :icon="MapPin"
        :to="featureRoute('example', 'detail', { id: p.id })"
      />
    </div>
  </PageContainer>
</template>
