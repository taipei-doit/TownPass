<script setup lang="ts">
/** @component M08 ChatBubble — 對話泡泡（使用者靠右、系統靠左） */
defineProps<{ role: 'user' | 'bot' }>()
</script>

<template>
  <div v-if="role === 'user'" class="flex justify-end">
    <p class="max-w-[80%] rounded-2xl rounded-br-sm bg-primary-500 px-4 py-2.5 text-white"><slot /></p>
  </div>
  <p v-else class="text-grey-700"><slot /></p>
</template>
