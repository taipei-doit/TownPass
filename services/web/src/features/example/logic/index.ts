/**
 * LOGIC LAYER - example feature. Public interface used by this feature's pages and index.ts.
 * Helpers prefixed `__` are internal: never export them, never import them elsewhere.
 */
import { computed, onMounted, ref } from 'vue'
import { useRoute, useRouter, type RouteLocationRaw } from 'vue-router'
import { featureRoute, type FeatureItem } from '@/framework'
import { openMap, shareLink } from '@/modules/env'
import { getPlace, imagesOfPlace, listPlaces, type Place } from '../data'

export type { Place }

const ALL = '全部'

/** List page: places + category filter kept in the URL (?category=公園) so it can be deep-linked. */
export function usePlaceList() {
  const route = useRoute()
  const router = useRouter()
  const places = ref<Place[]>()

  const categories = computed(() => [ALL, ...__categoriesOf(places.value ?? [])])
  const active = computed(() => (route.query.category as string) || ALL)
  const shown = computed(() => (places.value ?? []).filter((p) => __matches(p, active.value)))
  const setCategory = (c: string) => router.replace({ query: c === ALL ? {} : { category: c } })

  onMounted(async () => (places.value = await listPlaces()))
  return { places, categories, active, shown, setCategory }
}

/** Detail page. place: undefined = loading, null = not found. */
export function usePlaceDetail(id: number) {
  const place = ref<Place | null>()
  const message = ref('')

  onMounted(async () => (place.value = (await getPlace(id)) ?? null))

  const navigate = () => place.value && openMap(place.value.lat, place.value.lng, place.value.name)
  const share = async () => {
    if (!place.value) return
    const r = await shareLink(place.value.name, `${place.value.name}｜${place.value.address}`)
    if (r === 'copied') message.value = '已複製連結'
  }

  return { place, message, navigate, share }
}

export const placeDetailRoute = (id: number): RouteLocationRaw => featureRoute('example', 'detail', { id })

/** Feeds the home chat box (and any add-on that reads search items, e.g. RAG). */
export async function placeSearchItems(): Promise<FeatureItem[]> {
  return (await listPlaces()).map(__toSearchItem)
}

function __categoriesOf(places: Place[]): string[] {
  return [...new Set(places.map((p) => p.category))]
}

function __matches(p: Place, category: string): boolean {
  return category === ALL || p.category === category
}

function __toSearchItem(p: Place): FeatureItem {
  return {
    id: String(p.id),
    title: p.name,
    subtitle: `${p.district}・${p.category}`,
    tags: p.tags,
    keywords: [p.district, p.category],
    text: [`地址：${p.address}`, `開放時間：${p.hours}`, ...p.notices.map((n) => `${n.title}：${n.body}`)].join('\n'),
    geo: { lat: p.lat, lng: p.lng },
    images: imagesOfPlace(p.id),
    source: '（範例）臺北市公園基本資料',
    to: placeDetailRoute(p.id),
  }
}
