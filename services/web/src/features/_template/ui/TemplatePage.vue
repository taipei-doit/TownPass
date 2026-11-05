<script setup lang="ts">
/** @component XX-P01 TemplatePage — 新功能首頁 */
// Pages only compose '@/ui' components and call ../logic. Never import ../data or '@/platform' here.
// Gallery of all components: /#/dev/ui    Full example: src/features/example/
import { EmptyState, ListItem, PageContainer, SectionTitle, SkeletonBlock } from '@/ui'
import { useTemplateItems } from '../logic'

const { items } = useTemplateItems()
</script>

<template>
  <PageContainer title="新功能" back>
    <SectionTitle title="區塊標題" />
    <SkeletonBlock v-if="!items" />
    <EmptyState v-else-if="!items.length" title="還沒有資料" />
    <ListItem v-for="it in items" v-else :key="it.id" :title="it.name" />
  </PageContainer>
</template>
