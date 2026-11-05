// Presentation layer: shared UI kit, styled with the official TownPass tokens (src/style.css).
// Every component has an ID (@component header) - Atoms Axx, Molecules Mxx, Organisms Oxx, Templates Txx.
// Build screens by COMPOSING these; don't write raw styled HTML in features. Gallery: /#/dev/ui
// Catalog with descriptions: docs/system/04-presentation-layer.md

// Atoms
export { default as BaseButton } from './atoms/BaseButton.vue' // A01
export { default as BaseTag } from './atoms/BaseTag.vue' // A02
export { default as BaseChip } from './atoms/BaseChip.vue' // A03
export { default as BaseInput } from './atoms/BaseInput.vue' // A04
export { default as SkeletonBlock } from './atoms/SkeletonBlock.vue' // A05
export { default as IconBadge } from './atoms/IconBadge.vue' // A06
export { default as SourceNote } from './atoms/SourceNote.vue' // A07

// Molecules
export { default as BaseCard } from './molecules/BaseCard.vue' // M01
export { default as ListItem } from './molecules/ListItem.vue' // M02
export { default as SectionTitle } from './molecules/SectionTitle.vue' // M03
export { default as CollapseItem } from './molecules/CollapseItem.vue' // M04
export { default as EmptyState } from './molecules/EmptyState.vue' // M05
export { default as InfoTable } from './molecules/InfoTable.vue' // M06
export { default as ResultCard } from './molecules/ResultCard.vue' // M07
export { default as ChatBubble } from './molecules/ChatBubble.vue' // M08
export { default as ChipRail } from './molecules/ChipRail.vue' // M09

// Organisms
export { default as BaseSheet } from './organisms/BaseSheet.vue' // O01
export { default as OsmMap } from './organisms/OsmMap.vue' // O02
export { default as NoticeList } from './organisms/NoticeList.vue' // O03
export { default as ChatComposer } from './organisms/ChatComposer.vue' // O04
export { default as ChatThread } from './organisms/ChatThread.vue' // O05
export { default as FeatureGrid } from './organisms/FeatureGrid.vue' // O06
export { default as RecentStrip } from './organisms/RecentStrip.vue' // O07

// Templates
export { default as PageContainer } from './templates/PageContainer.vue' // T01
export { default as DetailPage } from './templates/DetailPage.vue' // T02

export type { InfoRow } from './molecules/InfoTable.vue'
export type { Notice } from './organisms/NoticeList.vue'
export type { ThreadMessage, ThreadResult, ThreadSuggestion } from './organisms/ChatThread.vue'
export type { GridItem } from './organisms/FeatureGrid.vue'
export type { RecentItem } from './organisms/RecentStrip.vue'
export type { QuickAction } from './organisms/ChatComposer.vue'
