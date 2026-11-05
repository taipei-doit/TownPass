/** DATA LAYER - backend calls with a mock fallback. `__` helpers are private. */
import { api } from '@/platform/http'

export interface Item {
  id: number
  name: string
}

export async function listItems(): Promise<Item[]> {
  try {
    return await api<Item[]>('/template/items') // matches backend features/_template
  } catch {
    return __MOCK
  }
}

const __MOCK: Item[] = [{ id: 1, name: '範例項目' }]
