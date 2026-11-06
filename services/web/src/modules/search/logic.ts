/**
 * LOGIC LAYER - on-device search over every registered feature. No LLM, no network
 * (satisfies the competition's on-device AI rule and works offline).
 */
import { ref } from 'vue'
import { featureEntry, features, type Feature, type FeatureItem } from '@/framework'
import { addDocs, allDocs, queryDocs, resetDocs, type SearchDoc } from './data'

export type { SearchDoc }

export const searchReady = ref(false)

/** Build the index once at startup. A failing feature doesn't break the others. */
export async function buildSearchIndex(): Promise<void> {
  resetDocs(features.map(__featureDoc))
  await Promise.all(
    features.map(async (f) => {
      if (!f.searchItems) return
      try {
        addDocs((await f.searchItems()).map((it) => __itemDoc(f, it)))
      } catch (err) {
        console.warn(`[search] ${f.id}.searchItems failed`, err)
      }
    }),
  )
  searchReady.value = true
}

export function search(query: string, limit = 8): SearchDoc[] {
  return queryDocs(query, limit)
}

/** Every indexed document; used to put all located items on a map. */
export const searchDocuments = (): SearchDoc[] => allDocs()

function __featureDoc(f: Feature): SearchDoc {
  return {
    key: `f:${f.id}`,
    kind: 'feature',
    featureId: f.id,
    title: f.title,
    subtitle: f.description,
    text: [f.description, ...(f.keywords ?? [])].join(' '),
    to: featureEntry(f),
  }
}

function __itemDoc(f: Feature, it: FeatureItem): SearchDoc {
  return {
    key: `i:${f.id}:${it.id}`,
    kind: 'item',
    featureId: f.id,
    title: it.title,
    subtitle: it.subtitle,
    tags: it.tags,
    geo: it.geo,
    images: it.images,
    validFrom: it.validFrom,
    validTo: it.validTo,
    source: it.source,
    text: [it.subtitle, ...(it.tags ?? []), ...(it.keywords ?? []), it.text, f.title].filter(Boolean).join(' '),
    to: it.to,
  }
}
