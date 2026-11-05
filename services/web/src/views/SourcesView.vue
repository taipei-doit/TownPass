<script setup lang="ts">
// Competition rule: cite the open data we use. Each feature lists its own `sources`.
import { computed } from 'vue'
import { ExternalLink } from 'lucide-vue-next'
import { features } from '@/core/registry'
import { EmptyState, PageContainer } from '@/ui'

const rows = computed(() => features.flatMap((f) => (f.sources ?? []).map((s) => ({ ...s, feature: f.title }))))
</script>

<template>
  <PageContainer title="資料來源" back>
    <p class="mb-4 text-sm text-grey-500">本服務使用以下公開資料，依各資料集授權條款使用。</p>
    <ul v-if="rows.length" class="divide-y divide-grey-100">
      <li v-for="s in rows" :key="s.feature + s.name" class="py-3">
        <a :href="s.url" target="_blank" rel="noopener" class="flex items-start gap-2">
          <span class="flex-1">
            <span class="block font-medium text-grey-800">{{ s.name }}</span>
            <span class="block text-sm text-grey-500">{{ s.provider }}<template v-if="s.licence">・{{ s.licence }}</template></span>
            <span class="block text-xs text-grey-400">用於：{{ s.feature }}</span>
          </span>
          <ExternalLink class="mt-1 size-4 shrink-0 text-grey-400" aria-hidden="true" />
        </a>
      </li>
    </ul>
    <EmptyState v-else title="尚未登錄資料來源" description="在 defineFeature 的 sources 欄位加入使用的資料集" />
  </PageContainer>
</template>
