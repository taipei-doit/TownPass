/**
 * LOGIC LAYER - example feature. Public interface used by this feature's pages and index.ts.
 * Helpers prefixed `__` are internal: never export them, never import them elsewhere.
 */
import { computed, onMounted, ref } from 'vue'
import { useRoute, useRouter, type RouteLocationRaw } from 'vue-router'
import { featureRoute, type FeatureItem } from '@/framework'
import { openMap, shareLink } from '@/modules/env'
import { requireUser } from '@/modules/session'
import { getPlace, listFavoriteIds, listPlaces, setFavorite, type Place } from '../data'

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
  const favorite = ref(false)
  const favoriteBusy = ref(false)
  const message = ref('')

  onMounted(async () => {
    place.value = (await getPlace(id)) ?? null
    favorite.value = await __isFavorite(id)
  })

  async function toggleFavorite() {
    favoriteBusy.value = true
    message.value = ''
    try {
      await requireUser() // protected action
      await setFavorite(id, !favorite.value)
      favorite.value = !favorite.value
    } catch (err) {
      message.value = err instanceof Error ? err.message : '收藏失敗'
    } finally {
      favoriteBusy.value = false
    }
  }

  const navigate = () => place.value && openMap(place.value.lat, place.value.lng, place.value.name)
  const share = async () => {
    if (!place.value) return
    const r = await shareLink(place.value.name, `${place.value.name}｜${place.value.address}`)
    if (r === 'copied') message.value = '已複製連結'
  }

  return { place, favorite, favoriteBusy, message, toggleFavorite, navigate, share }
}

export const placeDetailRoute = (id: number): RouteLocationRaw => featureRoute('example', 'detail', { id })

/** Feeds the home chat box. */
export async function placeSearchItems(): Promise<FeatureItem[]> {
  return (await listPlaces()).map(__toSearchItem)
}

function __categoriesOf(places: Place[]): string[] {
  return [...new Set(places.map((p) => p.category))]
}

function __matches(p: Place, category: string): boolean {
  return category === ALL || p.category === category
}

async function __isFavorite(id: number): Promise<boolean> {
  try {
    return (await listFavoriteIds()).includes(id)
  } catch {
    return false // not logged in -> nothing is a favourite yet
  }
}

function __toSearchItem(p: Place): FeatureItem {
  return {
    id: String(p.id),
    title: p.name,
    subtitle: `${p.district}・${p.category}`,
    tags: p.tags,
    keywords: [p.district, p.category, p.address],
    to: placeDetailRoute(p.id),
  }
}
