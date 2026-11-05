/** DATA LAYER - "近期使用" history persisted on the device. */
import { readJson, writeJson } from '@/platform/storage'

export interface RecentEntry {
  title: string
  path: string
  at: number
}

const __KEY = 'recent.v1'

export const loadRecent = (): RecentEntry[] => readJson<RecentEntry[]>(__KEY, [])
export const saveRecent = (entries: RecentEntry[]): void => writeJson(__KEY, entries.length ? entries : null)
