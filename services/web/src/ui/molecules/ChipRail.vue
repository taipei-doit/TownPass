<script setup lang="ts">
/** @component M09 ChipRail — 可橫向捲動的 chips 列（放 BaseChip） */
</script>

<template>
  <div class="-mx-4 flex gap-2 overflow-x-auto px-4 pb-1 [scrollbar-width:none]">
    <slot />
  </div>
</template>
