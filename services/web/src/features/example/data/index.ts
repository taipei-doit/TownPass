/**
 * DATA LAYER - example feature. The ONLY place this feature talks to the backend.
 * Pattern: try the backend, fall back to local mock data, so the feature works in a plain
 * browser, offline, and on GitHub Pages without a backend.
 */
import type { ItemImage } from '@/framework'
import { api } from '@/platform/http'

export interface Place {
  id: number
  name: string
  district: string
  category: string
  address: string
  hours: string
  lat: number
  lng: number
  tags: string[]
  notices: { title: string; body: string }[]
}

export async function listPlaces(): Promise<Place[]> {
  try {
    return await api<Place[]>('/examples/places')
  } catch {
    return __MOCK_PLACES
  }
}

export async function getPlace(id: number): Promise<Place | undefined> {
  return (await listPlaces()).find((p) => p.id === id)
}

/** Pictures that belong to a place. Files in public/ are stored for offline use by the service worker. */
export function imagesOfPlace(id: number): ItemImage[] {
  if (id !== 1) return []
  return [{ src: `${import.meta.env.BASE_URL}examples/park-rules.svg`, alt: '範例公園園區須知：寵物繫牽繩、清理排泄物', caption: '範例公園園區須知（範例圖）' }]
}

// Mock data - clearly fake, replace with real open data on the day.
const __MOCK_PLACES: Place[] = [
  {
    id: 1,
    name: '範例公園',
    district: '信義區',
    category: '公園',
    address: '臺北市信義區市府路 1 號（範例）',
    hours: '全天開放',
    lat: 25.0375,
    lng: 121.5637,
    tags: ['免費', '無障礙'],
    notices: [
      { title: '開放時間', body: '全天開放，夜間照明至 23:00。' },
      { title: '寵物', body: '寵物須繫牽繩，並清理排泄物。' },
    ],
  },
  {
    id: 2,
    name: '範例運動中心',
    district: '大安區',
    category: '運動中心',
    address: '臺北市大安區（範例）',
    hours: '06:00–22:00',
    lat: 25.0263,
    lng: 121.5434,
    tags: ['需付費', '室內'],
    notices: [{ title: '入場規定', body: '泳池須著泳帽，請自備。' }],
  },
  {
    id: 3,
    name: '範例圖書館分館',
    district: '中正區',
    category: '圖書館',
    address: '臺北市中正區（範例）',
    hours: '08:30–21:00，週一休館',
    lat: 25.0322,
    lng: 121.5185,
    tags: ['免費', '自習室'],
    notices: [{ title: '自習座位', body: '採線上預約，保留 15 分鐘。' }],
  },
]
