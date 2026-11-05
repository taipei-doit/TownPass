<script setup lang="ts">
// Starter page: proves the app bridge, the backend and the map all work.
// Replace with the real feature once the topic is announced.
import { onMounted, ref } from 'vue'
import { isInApp, request } from '@/bridge/townpass'
import { api } from '@/api/client'
import OsmMap from '@/components/OsmMap.vue'

const user = ref<{ realName?: string } | null>(null)
const here = ref<[number, number]>([25.0375, 121.5637])
const backend = ref('checking…')

onMounted(async () => {
  user.value = await request<{ realName?: string }>('userinfo').catch(() => null)
  backend.value = await api<{ status: string }>('/health')
    .then((r) => r.status)
    .catch(() => 'unreachable')
})

const locError = ref('')

async function locate() {
  // The app replies [] when location permission is denied
  const loc = await request<{ latitude?: number; longitude?: number }>('location').catch(() => null)
  if (loc?.latitude == null || loc.longitude == null) {
    locError.value = '無法取得位置，請確認已允許定位權限'
    return
  }
  locError.value = ''
  here.value = [loc.latitude, loc.longitude]
}
</script>

<template>
  <main class="mx-auto max-w-md space-y-4 p-4">
    <h1 class="text-xl font-semibold text-primary-700">城市通微服務</h1>

    <section class="space-y-1 rounded-xl bg-primary-50 p-4 text-sm">
      <p>執行環境：{{ isInApp() ? 'TownPass App' : '瀏覽器（使用模擬資料）' }}</p>
      <p>使用者：{{ user?.realName ?? '—' }}</p>
      <p>後端：{{ backend }}</p>
    </section>

    <OsmMap :center="here" :markers="[{ lat: here[0], lng: here[1], label: '目前位置' }]" />
    <button class="w-full rounded-xl bg-primary-500 py-3 font-medium text-white active:bg-primary-600" @click="locate">
      取得目前位置
    </button>
    <p v-if="locError" class="text-sm text-red-600">{{ locError }}</p>
  </main>
</template>
