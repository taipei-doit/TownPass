/**
 * The contract every feature implements. A feature is one folder under src/features/<id>/
 * whose index.ts does `export default defineFeature({...})`. The registry picks it up
 * automatically: its routes are mounted at /f/<id>/..., it appears on the home screen,
 * its quick actions become chips, and its searchItems become answers in the chat box.
 *
 * Nothing outside the feature folder needs to change -> teammates never edit the same files.
 */
import type { Component } from 'vue'
import type { RouteLocationRaw, RouteRecordRaw } from 'vue-router'
import type { AssistantProvider, GeoPoint, ItemImage, ToolDefinition } from './tool'

/** Something the chat box can answer with: a card that links to a detail page. */
export interface FeatureItem {
  /** unique within the feature */
  id: string
  title: string
  subtitle?: string
  tags?: string[]
  /** extra words people might type (synonyms, district names, ...) */
  keywords?: string[]
  /** longer plain text (address, hours, notices...) - searchable, and usable as context by add-ons such as RAG */
  text?: string
  /** where it is -> the chat box can mark it on a map (show_map) */
  geo?: GeoPoint
  /** pictures that belong to it, e.g. a document's figures -> shown in the chat box (show_image) */
  images?: ItemImage[]
  /** for roadworks, events...: ISO dates (YYYY-MM-DD); finished items are left off the map */
  validFrom?: string
  validTo?: string
  /** where the content comes from, shown next to original text and images */
  source?: string
  to: RouteLocationRaw
}

export interface DataSource {
  name: string
  provider: string
  url: string
  licence?: string
}

export interface Feature {
  /** url-safe id, must equal the folder name */
  id: string
  /** 2-4 capital letters, prefix of this feature's component IDs (e.g. 'EX' -> EX-P01, EX-C01) */
  code: string
  title: string
  description: string
  icon: Component
  /**
   * Routes relative to /f/<id>. The first route is the feature's entry page.
   * Route names are prefixed automatically: name 'detail' -> '<id>.detail'.
   */
  routes: RouteRecordRaw[]
  /** words that should lead to this feature in the chat box */
  keywords?: string[]
  /** shown as chips on the home screen */
  quickActions?: { label: string; to: RouteLocationRaw }[]
  /** searchable content; may fetch from the backend (called once at startup) */
  searchItems?: () => FeatureItem[] | Promise<FeatureItem[]>
  /** things the chat box can do for this feature; see framework/tool.ts */
  tools?: ToolDefinition[]
  /** optional smarter chat answers, e.g. from the agent add-on; see docs/system/09-addons.md */
  assistant?: AssistantProvider
  /** open data used by this feature -> listed on the 資料來源 page */
  sources?: DataSource[]
  /** lower = earlier on the home screen */
  order?: number
  /** hide from home/search but keep routes (e.g. work in progress) */
  hidden?: boolean
}

export const defineFeature = (f: Feature): Feature => f

/** Helper for links inside a feature: featureRoute('parks', 'detail', { id: 1 }) */
export const featureRoute = (featureId: string, name: string, params?: Record<string, string | number>): RouteLocationRaw => ({
  name: `${featureId}.${name}`,
  params,
})
