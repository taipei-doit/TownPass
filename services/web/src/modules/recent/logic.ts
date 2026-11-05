/** LOGIC LAYER - recent history: newest first, no duplicates, max 8. */
import { ref } from 'vue'
import { loadRecent, saveRecent, type RecentEntry } from './data'

export type { RecentEntry }

const __MAX = 8

export const recent = ref<RecentEntry[]>(loadRecent())

export function addRecent(title: string, path: string): void {
  recent.value = __dedupeNewestFirst({ title, path, at: Date.now() }, recent.value)
  saveRecent(recent.value)
}

export function clearRecent(): void {
  recent.value = []
  saveRecent([])
}

function __dedupeNewestFirst(entry: RecentEntry, list: RecentEntry[]): RecentEntry[] {
  return [entry, ...list.filter((r) => r.path !== entry.path)].slice(0, __MAX)
}
