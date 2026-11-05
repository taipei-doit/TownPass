<script setup lang="ts">
/** @component M06 InfoTable — 標籤/值資訊列 */
export type InfoRow = { label: string; value: string }
defineProps<{ rows: InfoRow[] }>()
</script>

<template>
  <dl class="divide-y divide-grey-100 rounded-xl bg-grey-50 px-4">
    <div v-for="row in rows" :key="row.label" class="flex gap-4 py-3 text-sm">
      <dt class="w-20 shrink-0 text-grey-500">{{ row.label }}</dt>
      <dd class="flex-1 text-grey-800">{{ row.value }}</dd>
    </div>
  </dl>
</template>
