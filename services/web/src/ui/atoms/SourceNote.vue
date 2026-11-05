<script setup lang="ts">
/** @component A07 SourceNote — 資料來源註記（競賽規則要求標示出處） */
defineProps<{ source: string }>()
</script>

<template>
  <p class="text-xs text-grey-400">資料來源：{{ source }}</p>
</template>
