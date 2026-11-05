/**
 * Example feature (wiring only) - shows every extension point and the three layers:
 *   ui/     presentation  (EX-P01, EX-P02 pages; EX-C01, EX-C02 components)
 *   logic/  use-cases     (usePlaceList, usePlaceDetail, placeSearchItems)
 *   data/   backend + mock (listPlaces, getPlace, favourites)
 * Delete this folder once real features exist. New feature: copy src/features/_template.
 */
import { MapPinned } from 'lucide-vue-next'
import { defineFeature } from '@/framework'
import { placeSearchItems } from './logic'

export default defineFeature({
  id: 'example',
  code: 'EX',
  title: '範例：找設施',
  description: '列表 → 詳細頁 → 注意事項 → 地圖 → 收藏的完整範例',
  icon: MapPinned,
  order: 999,
  keywords: ['設施', '地點', '附近', '公園', '運動', '圖書館'],

  routes: [
    { path: '', name: 'list', component: () => import('./ui/PlaceListPage.vue') },
    {
      path: ':id',
      name: 'detail',
      component: () => import('./ui/PlaceDetailPage.vue'),
      meta: { recentTitle: () => '範例設施' },
    },
  ],

  quickActions: [
    { label: '找公園', to: { name: 'example.list', query: { category: '公園' } } },
    { label: '找圖書館', to: { name: 'example.list', query: { category: '圖書館' } } },
  ],

  searchItems: placeSearchItems,

  sources: [
    {
      name: '（範例）臺北市公園基本資料',
      provider: '臺北市政府工務局公園路燈工程管理處',
      url: 'https://data.taipei/',
      licence: '政府資料開放授權條款 1.0',
    },
  ],
})
