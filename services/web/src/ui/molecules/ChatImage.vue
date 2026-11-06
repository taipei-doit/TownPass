<script setup lang="ts">
/** @component M10 ChatImage — 對話框內的圖片（圖說 + 來源，載入失敗時顯示替代文字） */
import { ref } from 'vue'
import { ImageOff } from 'lucide-vue-next'
import SourceNote from '../atoms/SourceNote.vue'

defineProps<{ src: string; alt: string; caption?: string; source?: string }>()
const failed = ref(false)
</script>

<template>
  <figure class="space-y-1">
    <div v-if="failed" class="flex items-center gap-2 rounded-xl bg-grey-50 p-3 text-sm text-grey-500" role="img" :aria-label="alt">
      <ImageOff class="size-5 shrink-0" aria-hidden="true" />{{ alt }}
    </div>
    <img v-else :src="src" :alt="alt" loading="lazy" class="w-full rounded-xl bg-grey-50 object-contain" @error="failed = true" />
    <figcaption v-if="caption" class="text-sm text-grey-600">{{ caption }}</figcaption>
    <SourceNote v-if="source" :source="source" />
  </figure>
</template>
