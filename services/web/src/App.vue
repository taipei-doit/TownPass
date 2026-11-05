<script setup lang="ts">
import { provide } from 'vue'
import { inApp } from '@/modules/env'

// The UI kit reads this instead of importing platform code (keeps presentation pure).
provide('inApp', inApp)
</script>

<template>
  <RouterView />
</template>
