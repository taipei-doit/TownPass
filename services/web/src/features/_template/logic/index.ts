/** LOGIC LAYER - public interface of this feature. `__` helpers are private. */
import { onMounted, ref } from 'vue'
import type { FeatureItem } from '@/framework'
import { listItems, type Item } from '../data'

export type { Item }

export function useTemplateItems() {
  const items = ref<Item[]>()
  onMounted(async () => (items.value = await listItems()))
  return { items }
}

export async function templateSearchItems(): Promise<FeatureItem[]> {
  return (await listItems()).map(__toSearchItem)
}

function __toSearchItem(it: Item): FeatureItem {
  return { id: String(it.id), title: it.name, to: { name: '_template.home' } }
}
