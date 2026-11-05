/**
 * Chat-box search. Runs entirely on the device (no LLM, no network) so it satisfies the
 * competition's on-device AI rule and still works offline.
 *
 * Chinese has no spaces, so text is split into single characters + 2-character pairs
 * (bigrams); "公園廁所" matches documents containing "公園" or "廁所". Latin words are kept whole.
 */
import MiniSearch from 'minisearch'
import { ref } from 'vue'
import type { RouteLocationRaw } from 'vue-router'
import type { Feature, FeatureItem } from './feature'
import { featureEntry, features } from './registry'

export interface SearchDoc {
  key: string
  kind: 'feature' | 'item'
  featureId: string
  title: string
  subtitle?: string
  tags?: string[]
  text: string
  to: RouteLocationRaw
}

const CJK = /[㐀-鿿豈-﫿]/

export function tokenize(text: string): string[] {
  const tokens: string[] = []
  for (const chunk of text.toLowerCase().split(/[\s\p{P}\p{S}]+/u)) {
    if (!chunk) continue
    let latin = ''
    const flushLatin = () => {
      if (latin) tokens.push(latin)
      latin = ''
    }
    for (let i = 0; i < chunk.length; i++) {
      const ch = chunk[i]!
      if (CJK.test(ch)) {
        flushLatin()
        tokens.push(ch)
        const next = chunk[i + 1]
        if (next && CJK.test(next)) tokens.push(ch + next)
      } else {
        latin += ch
      }
    }
    flushLatin()
  }
  return tokens
}

const index = new MiniSearch<SearchDoc>({
  idField: 'key',
  fields: ['title', 'text'],
  storeFields: ['kind', 'featureId', 'title', 'subtitle', 'tags', 'to'],
  tokenize,
  searchOptions: { boost: { title: 3 }, combineWith: 'OR', fuzzy: (t) => (CJK.test(t) ? false : 0.2) },
})

export const searchReady = ref(false)

const featureDoc = (f: Feature): SearchDoc => ({
  key: `f:${f.id}`,
  kind: 'feature',
  featureId: f.id,
  title: f.title,
  subtitle: f.description,
  text: [f.description, ...(f.keywords ?? [])].join(' '),
  to: featureEntry(f),
})

const itemDoc = (f: Feature, it: FeatureItem): SearchDoc => ({
  key: `i:${f.id}:${it.id}`,
  kind: 'item',
  featureId: f.id,
  title: it.title,
  subtitle: it.subtitle,
  tags: it.tags,
  text: [it.subtitle, ...(it.tags ?? []), ...(it.keywords ?? []), f.title].filter(Boolean).join(' '),
  to: it.to,
})

/** Build the index once at startup. A failing feature doesn't break the others. */
export async function buildSearchIndex(): Promise<void> {
  index.removeAll()
  index.addAll(features.map(featureDoc))
  await Promise.all(
    features.map(async (f) => {
      if (!f.searchItems) return
      try {
        index.addAll((await f.searchItems()).map((it) => itemDoc(f, it)))
      } catch (err) {
        console.warn(`[search] ${f.id}.searchItems failed`, err)
      }
    }),
  )
  searchReady.value = true
}

export function search(query: string, limit = 8): SearchDoc[] {
  if (!query.trim()) return []
  return index.search(query).slice(0, limit) as unknown as SearchDoc[]
}
