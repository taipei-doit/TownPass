/**
 * ADD-ON: agent (optional, OFF by default). Public interface - import only from '@/addons/agent'.
 * Connects on-device models to the chat box: tools + retrieval, with original text, images and
 * maps inside the conversation. Needs the model and rag add-ons.
 * How to use it: README.md in this folder. Catalog of add-ons: docs/system/09-addons.md
 */
export const ADDON_CODE = 'AG'

export { answerToResult, chooseTool, createAgent, parseToolCall, pickBySimilarity, routeByMeaning, SEMANTIC_ROUTING } from './logic'
export type { AgentOptions, ToolCall } from './logic'
