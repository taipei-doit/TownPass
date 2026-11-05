<script setup lang="ts">
// Build pages only from '@/ui' components so everything matches the TownPass look.
// Gallery of all components: /#/dev/ui    Full example: src/features/example/
import { BaseCard, PageContainer, SectionTitle } from '@/ui'
</script>

<template>
  <PageContainer title="新功能" back>
    <SectionTitle title="區塊標題" />
    <BaseCard>開始寫你的功能</BaseCard>
  </PageContainer>
</template>
