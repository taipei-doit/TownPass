/**
 * The tool contract: what the chat box can DO, beyond answering with text.
 * A tool returns text plus structured blocks; ChatThread draws the blocks inside the conversation.
 *
 * Add a tool: put `tools: [defineTool({...})]` in your feature's index.ts. Nothing else to change.
 * Items with `geo` or `images` work with the built-in show_map / show_image without writing a tool.
 * Guide: docs/system/09-addons.md
 *
 * Safety rule: arguments may come from a language model, so a tool takes ids or search text and
 * looks up coordinates and image addresses in its own data. Never accept them as arguments.
 */
import type { RouteLocationRaw } from 'vue-router'

/** The JSON Schema subset the arguments validator understands. */
export interface ToolParameter {
  type: 'string' | 'number' | 'integer' | 'boolean'
  description?: string
  enum?: (string | number)[]
}
export interface ToolParameters {
  type: 'object'
  properties: Record<string, ToolParameter>
  required?: string[]
}

export interface GeoPoint {
  lat: number
  lng: number
}
export interface ItemImage {
  /** same-site path, https:// or data:image/... (anything else is dropped) */
  src: string
  /** required: read by screen readers, and shown when the image fails to load */
  alt: string
  caption?: string
}

export interface MapBlockMarker extends GeoPoint {
  label?: string
  detail?: string
  tone?: 'default' | 'warning'
}
export interface MapBlock {
  type: 'map'
  title?: string
  markers: MapBlockMarker[]
}
export interface ImageBlock extends ItemImage {
  type: 'image'
  /** data source shown under the image */
  source?: string
}
/** Original text shown word for word, so an official document is never paraphrased by a model. */
export interface QuoteBlock {
  type: 'quote'
  title?: string
  text: string
  source?: string
}
export type ToolBlock = MapBlock | ImageBlock | QuoteBlock

export interface ToolCard {
  key: string
  title: string
  subtitle?: string
  tags?: string[]
  featureId?: string
  to: RouteLocationRaw
}
export interface ToolResult {
  /** what the assistant says */
  text: string
  blocks?: ToolBlock[]
  /** result cards linking to detail pages */
  cards?: ToolCard[]
}

export type ToolArgs = Record<string, unknown>

export interface ToolDefinition<A = ToolArgs> {
  /** unique snake_case name, e.g. show_map */
  name: string
  /** one sentence: a language model reads this to decide when to call the tool */
  description: string
  parameters: ToolParameters
  /** phrases that call the tool without any model; this path works on every phone */
  triggers?: RegExp[]
  /** a few example questions: with the agent add-on, questions close in meaning also call the tool */
  examples?: string[]
  /** arguments for a trigger match; defaults to { query: question } */
  toArgs?: (question: string) => A
  run: (args: A) => ToolResult | Promise<ToolResult>
}

export const defineTool = <A = ToolArgs>(tool: ToolDefinition<A>): ToolDefinition =>
  tool as unknown as ToolDefinition

export interface ToolRoute {
  tool: ToolDefinition
  args: ToolArgs
}

/** What the chat box hands to an assistant provider. */
export interface AssistantContext {
  question: string
  tools: ToolDefinition[]
  /** validates the arguments, runs the tool and cleans its blocks */
  runTool: (name: string, args: ToolArgs) => Promise<ToolResult>
  routeByRules: (question: string) => ToolRoute | null
  /** stream partial text into the conversation */
  onText?: (text: string) => void
}

/**
 * Optional smarter answers for the chat box. A feature provides one through `assistant`
 * (core never imports add-ons). Return null to let the built-in rules and search answer.
 */
export interface AssistantProvider {
  id: string
  answer: (context: AssistantContext) => Promise<ToolResult | null>
}
