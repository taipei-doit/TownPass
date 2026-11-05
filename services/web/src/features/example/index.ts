/**
 * Example feature - shows every extension point. Delete this folder once real features exist.
 * To start a new feature: copy src/features/_template to src/features/<your-id>.
 */
import { MapPinned } from 'lucide-vue-next'
import { defineFeature, featureRoute } from '@/core/feature'
import { listPlaces } from './data'

export default defineFeature({
  id: 'example',
  title: '範例：找設施',
  description: '列表 → 詳細頁 → 注意事項 → 地圖的完整範例',
  icon: MapPinned,
  order: 999,
  keywords: ['設施', '地點', '附近', '公園', '運動', '圖書館'],

  routes: [
    { path: '', name: 'list', component: () => import('./PlaceList.vue') },
    {
      path: ':id',
      name: 'detail',
      component: () => import('./PlaceDetail.vue'),
      meta: { recentTitle: () => '範例設施' },
    },
  ],

  quickActions: [
    { label: '找公園', to: { name: 'example.list', query: { category: '公園' } } },
    { label: '找圖書館', to: { name: 'example.list', query: { category: '圖書館' } } },
  ],

  // Everything returned here can be found from the chat box on the home screen
  searchItems: async () =>
    (await listPlaces()).map((p) => ({
      id: String(p.id),
      title: p.name,
      subtitle: `${p.district}・${p.category}`,
      tags: p.tags,
      keywords: [p.district, p.category, p.address],
      to: featureRoute('example', 'detail', { id: p.id }),
    })),

  sources: [
    {
      name: '（範例）臺北市公園基本資料',
      provider: '臺北市政府工務局公園路燈工程管理處',
      url: 'https://data.taipei/',
      licence: '政府資料開放授權條款 1.0',
    },
  ],
})
