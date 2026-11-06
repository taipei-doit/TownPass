/**
 * ADD-ON: rag (optional, OFF by default). Public interface - import only from '@/addons/rag'.
 * On-device retrieval over what features provide, plus collections built by `pnpm rag:build`.
 * Needs the model add-on. How to use it: README.md in this folder.
 * Catalog of add-ons: docs/system/09-addons.md
 */
export const ADDON_CODE = 'RG'

export { bestScore, collectionItems, isGrounded, useRag } from './logic'
export type { RagAnswer, RagCollectionDocument, RagDocument, RagSource } from './logic'

/** Lazy route component: the model runtime is only downloaded when this page opens. */
export const RagLabPage = () => import('./ui/RagLabPage.vue')
