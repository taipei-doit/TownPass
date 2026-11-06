/**
 * DATA LAYER - search index storage (MiniSearch, in memory, on device).
 * Chinese has no spaces, so text is split into single characters + 2-character pairs
 * (bigrams); "公園廁所" matches documents containing "公園" or "廁所". Latin words stay whole.
 */
import MiniSearch from 'minisearch'
import type { RouteLocationRaw } from 'vue-router'
import type { GeoPoint, ItemImage } from '@/framework'

export interface SearchDoc {
  key: string
  kind: 'feature' | 'item'
  featureId: string
  title: string
  subtitle?: string
  tags?: string[]
  text: string
  geo?: GeoPoint
  images?: ItemImage[]
  validFrom?: string
  validTo?: string
  source?: string
  to: RouteLocationRaw
  /** relevance, set on search results */
  score?: number
}

const __CJK = /[㐀-鿿豈-﫿]/

export function tokenize(text: string): string[] {
  const tokens: string[] = []
  for (const chunk of text.toLowerCase().split(/[\s\p{P}\p{S}]+/u)) {
    if (!chunk) continue
    let latin = ''
    for (let i = 0; i < chunk.length; i++) {
      const ch = chunk[i]!
      if (__CJK.test(ch)) {
        if (latin) tokens.push(latin)
        latin = ''
        tokens.push(ch)
        const next = chunk[i + 1]
        if (next && __CJK.test(next)) tokens.push(ch + next)
      } else {
        latin += ch
      }
    }
    if (latin) tokens.push(latin)
  }
  return tokens
}

const __index = new MiniSearch<SearchDoc>({
  idField: 'key',
  fields: ['title', 'text'],
  storeFields: ['kind', 'featureId', 'title', 'subtitle', 'tags', 'geo', 'images', 'validFrom', 'validTo', 'source', 'to'],
  tokenize,
  searchOptions: { boost: { title: 3 }, combineWith: 'OR', fuzzy: (t) => (__CJK.test(t) ? false : 0.2) },
})

const __docs = new Map<string, SearchDoc>()

export function resetDocs(docs: SearchDoc[]): void {
  __index.removeAll()
  __docs.clear()
  addDocs(docs)
}

export function addDocs(docs: SearchDoc[]): void {
  const fresh = docs.filter((d) => !__index.has(d.key))
  __index.addAll(fresh)
  for (const d of fresh) __docs.set(d.key, d)
}

export const allDocs = (): SearchDoc[] => [...__docs.values()]

export function queryDocs(query: string, limit: number): SearchDoc[] {
  if (!query.trim()) return []
  return __index.search(query).slice(0, limit) as unknown as SearchDoc[]
}
