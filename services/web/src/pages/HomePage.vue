<script setup lang="ts">
/** @component P01 HomePage — 首頁（對話框單一入口） */
/**
 * Composition only: greeting + RecentStrip + FeatureGrid before the first question,
 * ChatThread after, ChatComposer pinned at the bottom. Behaviour lives in modules/assistant.
 */
import { computed, onMounted, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { Database, Palette } from 'lucide-vue-next'
import { featureEntry, features } from '@/framework'
import { featureEntryRoute, useAssistant } from '@/modules/assistant'
import { recent } from '@/modules/recent'
import { buildSearchIndex } from '@/modules/search'
import { appUserName, canSpeak, loadAppUserName, speak } from '@/modules/env'
import { ChatComposer, ChatThread, FeatureGrid, PageContainer, RecentStrip, type GridItem } from '@/ui'

const router = useRouter()
const route = useRoute()
const { messages, ask, quickActions, ready } = useAssistant()
const query = ref('')
const isDev = import.meta.env.DEV

const gridItems = computed<GridItem[]>(() =>
  features.map((f) => ({ key: f.id, title: f.title, description: f.description, icon: f.icon, to: featureEntry(f) })),
)

function submit(text: string) {
  void ask(text)
  query.value = ''
}
const pickQuick = (i: number) => router.push(quickActions.value[i]!.to)
const openSuggestion = (featureId: string) => {
  const to = featureEntryRoute(featureId)
  if (to) router.push(to)
}

onMounted(async () => {
  void loadAppUserName()
  await buildSearchIndex()
  if (typeof route.query.q === 'string' && route.query.q) submit(route.query.q) // deep link: #/?q=公園
})
</script>

<template>
  <PageContainer>
    <section class="pt-5 pb-3">
      <p class="text-sm text-grey-500">{{ appUserName ? `嗨，${appUserName}` : '嗨！' }}</p>
      <h1 class="mt-1 text-h1 leading-tight font-bold text-grey-900">今天想找什麼資訊？</h1>
    </section>

    <div v-if="!messages.length" class="space-y-6">
      <RecentStrip :items="recent" @open="router.push($event)" />
      <FeatureGrid :items="gridItems" />
      <nav class="flex justify-center gap-4 pb-2 text-xs text-grey-400">
        <RouterLink to="/sources" class="inline-flex items-center gap-1"><Database class="size-3.5" />資料來源</RouterLink>
        <RouterLink v-if="isDev" to="/dev/ui" class="inline-flex items-center gap-1"><Palette class="size-3.5" />UI 元件</RouterLink>
      </nav>
    </div>
    <ChatThread v-else :messages="messages" :speakable="canSpeak" class="pt-2" @suggest="openSuggestion" @speak="speak" />

    <template #bottom>
      <ChatComposer v-model="query" :quick-actions="quickActions" :ready="ready" @submit="submit" @pick="pickQuick" />
    </template>
  </PageContainer>
</template>
