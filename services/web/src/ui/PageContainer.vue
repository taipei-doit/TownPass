<script setup lang="ts">
/**
 * Standard page wrapper. The TownPass app already draws a title bar above the WebView,
 * so pages don't need their own top navigation - use `back` for nested pages.
 */
import { useRouter } from 'vue-router'
import { ChevronLeft } from 'lucide-vue-next'
import { isInApp } from '@/bridge/townpass'

defineProps<{ title?: string; back?: boolean }>()
const router = useRouter()
// Inside the app the native title bar already has a back arrow - don't show two.
const showBack = (back?: boolean) => back && !isInApp()
</script>

<template>
  <div class="mx-auto flex min-h-dvh max-w-md flex-col">
    <header v-if="title || back" class="sticky top-0 z-20 flex h-12 items-center gap-1 bg-white/95 px-2 backdrop-blur">
      <button v-if="showBack(back)" type="button" class="p-2 text-grey-700" aria-label="返回" @click="router.back()">
        <ChevronLeft class="size-6" />
      </button>
      <h1 class="truncate text-lg font-semibold text-grey-900" :class="!showBack(back) && 'px-2'">{{ title }}</h1>
    </header>
    <main class="flex-1 px-4 pb-6"><slot /></main>
    <!-- sticky bottom area (buttons / chat input). The app's WebView draws under Android's
         gesture bar and reports no safe-area inset, so keep a 1.5rem minimum. -->
    <div v-if="$slots.bottom" class="sticky bottom-0 z-20 border-t border-grey-100 bg-white px-4 pt-3 pb-[max(1.5rem,env(safe-area-inset-bottom))]">
      <slot name="bottom" />
    </div>
  </div>
</template>
