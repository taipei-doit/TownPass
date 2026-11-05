<script setup lang="ts">
/**
 * Single entry point: a chat-style box. Answers come from on-device search over every
 * registered feature (src/core/search.ts) - deterministic, offline, no LLM.
 * Features plug in content via defineFeature({ searchItems, quickActions, keywords }).
 */
import { computed, nextTick, onMounted, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ArrowUp, Clock, Database, MessageCircle, Palette, SearchX } from 'lucide-vue-next'
import { request } from '@/bridge/townpass'
import { featureEntry, features } from '@/core/registry'
import { buildSearchIndex, search, searchReady, type SearchDoc } from '@/core/search'
import { recent } from '@/core/recent'
import { BaseCard, BaseChip, BaseTag, PageContainer, SectionTitle } from '@/ui'

type Message = { id: number; role: 'user' | 'bot'; text: string; results?: SearchDoc[] }

const router = useRouter()
const route = useRoute()
const userName = ref<string>()
const query = ref('')
const messages = ref<Message[]>([])
const listEl = ref<HTMLElement>()
let seq = 0
const isDev = import.meta.env.DEV

const quickActions = computed(() => features.flatMap((f) => f.quickActions ?? []).slice(0, 8))
const iconOf = (featureId: string) => features.find((f) => f.id === featureId)?.icon ?? MessageCircle

onMounted(async () => {
  request<{ realName?: string }>('userinfo')
    .then((u) => (userName.value = u?.realName))
    .catch(() => {})
  await buildSearchIndex()
  const q = route.query.q
  if (typeof q === 'string' && q) ask(q) // deep link: #/?q=公園
})

async function ask(text: string) {
  const q = text.trim()
  if (!q) return
  query.value = ''
  messages.value.push({ id: ++seq, role: 'user', text: q })
  const results = search(q)
  messages.value.push({
    id: ++seq,
    role: 'bot',
    text: results.length ? `找到 ${results.length} 筆和「${q}」相關的資訊：` : `目前找不到和「${q}」相關的資訊，試試下面的功能：`,
    results,
  })
  await nextTick()
  listEl.value?.lastElementChild?.scrollIntoView({ behavior: 'smooth', block: 'start' })
}
</script>

<template>
  <PageContainer>
    <!-- greeting -->
    <section class="pt-5 pb-3">
      <p class="text-sm text-grey-500">{{ userName ? `嗨，${userName}` : '嗨！' }}</p>
      <h1 class="mt-1 text-h1 leading-tight font-bold text-grey-900">今天想找什麼資訊？</h1>
    </section>

    <!-- before the first question: recent + feature shortcuts -->
    <div v-if="!messages.length" class="space-y-6">
      <section v-if="recent.length">
        <SectionTitle title="近期使用" />
        <div class="-mx-4 flex gap-2 overflow-x-auto px-4 pb-1">
          <BaseChip v-for="r in recent" :key="r.path" :icon="Clock" @click="router.push(r.path)">{{ r.title }}</BaseChip>
        </div>
      </section>

      <section>
        <SectionTitle title="服務" />
        <div class="grid grid-cols-2 gap-3">
          <BaseCard v-for="f in features" :key="f.id" :to="featureEntry(f)" class="!p-3.5">
            <component :is="f.icon" class="mb-2 size-7 text-primary-500" aria-hidden="true" />
            <p class="font-semibold text-grey-900">{{ f.title }}</p>
            <p class="mt-0.5 line-clamp-2 text-xs text-grey-500">{{ f.description }}</p>
          </BaseCard>
        </div>
      </section>

      <nav class="flex justify-center gap-4 pb-2 text-xs text-grey-400">
        <RouterLink to="/sources" class="inline-flex items-center gap-1"><Database class="size-3.5" />資料來源</RouterLink>
        <RouterLink v-if="isDev" to="/dev/ui" class="inline-flex items-center gap-1"><Palette class="size-3.5" />UI 元件</RouterLink>
      </nav>
    </div>

    <!-- conversation -->
    <ol v-else ref="listEl" class="space-y-4 pt-2" aria-live="polite">
      <li v-for="m in messages" :key="m.id" :class="m.role === 'user' ? 'flex justify-end' : ''">
        <p v-if="m.role === 'user'" class="max-w-[80%] rounded-2xl rounded-br-sm bg-primary-500 px-4 py-2.5 text-white">
          {{ m.text }}
        </p>
        <div v-else class="space-y-2">
          <p class="text-grey-700">{{ m.text }}</p>
          <BaseCard v-for="r in m.results" :key="r.key" :to="r.to" flat class="flex items-start gap-3 !p-3">
            <span class="grid size-9 shrink-0 place-items-center rounded-full bg-primary-50 text-primary-500">
              <component :is="iconOf(r.featureId)" class="size-5" aria-hidden="true" />
            </span>
            <span class="min-w-0 flex-1">
              <span class="block font-medium text-grey-900">{{ r.title }}</span>
              <span v-if="r.subtitle" class="block truncate text-sm text-grey-500">{{ r.subtitle }}</span>
              <span v-if="r.tags?.length" class="mt-1 flex flex-wrap gap-1">
                <BaseTag v-for="t in r.tags.slice(0, 3)" :key="t">{{ t }}</BaseTag>
              </span>
            </span>
          </BaseCard>
          <div v-if="!m.results?.length" class="flex flex-wrap gap-2">
            <BaseChip v-for="f in features" :key="f.id" :icon="f.icon ?? SearchX" @click="router.push(featureEntry(f))">
              {{ f.title }}
            </BaseChip>
          </div>
        </div>
      </li>
    </ol>

    <template #bottom>
      <div v-if="quickActions.length" class="-mx-4 mb-2.5 flex gap-2 overflow-x-auto px-4">
        <BaseChip v-for="a in quickActions" :key="a.label" @click="router.push(a.to)">{{ a.label }}</BaseChip>
      </div>
      <form class="flex items-center gap-2" @submit.prevent="ask(query)">
        <input
          v-model="query"
          type="search"
          enterkeyhint="send"
          :placeholder="searchReady ? '輸入想找的服務或地點…' : '準備中…'"
          aria-label="輸入問題"
          class="h-11 flex-1 rounded-full border border-grey-200 bg-grey-50 px-4 text-base outline-none focus:border-primary-500 focus:bg-white"
        />
        <button
          type="submit"
          class="grid size-11 shrink-0 place-items-center rounded-full bg-primary-500 text-white disabled:opacity-40"
          :disabled="!query.trim()"
          aria-label="送出"
        >
          <ArrowUp class="size-5" />
        </button>
      </form>
    </template>
  </PageContainer>
</template>
