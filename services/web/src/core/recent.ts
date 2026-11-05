/**
 * "近期使用" history, stored on the device. Storage can be unavailable (private mode,
 * locked-down WebView), so every access is guarded and the app works without it.
 */
import { ref } from 'vue'

export interface RecentEntry {
  title: string
  path: string
  at: number
}

const KEY = 'townpass.recent.v1'
const MAX = 8

function load(): RecentEntry[] {
  try {
    return JSON.parse(localStorage.getItem(KEY) ?? '[]') as RecentEntry[]
  } catch {
    return []
  }
}

export const recent = ref<RecentEntry[]>(load())

export function addRecent(title: string, path: string): void {
  recent.value = [{ title, path, at: Date.now() }, ...recent.value.filter((r) => r.path !== path)].slice(0, MAX)
  try {
    localStorage.setItem(KEY, JSON.stringify(recent.value))
  } catch {
    /* storage unavailable - keep in memory only */
  }
}

export function clearRecent(): void {
  recent.value = []
  try {
    localStorage.removeItem(KEY)
  } catch {
    /* ignore */
  }
}
