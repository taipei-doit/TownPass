// Framework (wiring, not a layer): the feature contract and the registry that discovers features.
export { defineFeature, featureRoute } from './feature'
export type { DataSource, Feature, FeatureItem } from './feature'
export { allFeatures, features, featureEntry, featureRoutes, getFeature } from './registry'
export { defineTool } from './tool'
export type {
  AssistantContext,
  AssistantProvider,
  GeoPoint,
  ImageBlock,
  ItemImage,
  MapBlock,
  MapBlockMarker,
  QuoteBlock,
  ToolArgs,
  ToolBlock,
  ToolCard,
  ToolDefinition,
  ToolParameters,
  ToolResult,
  ToolRoute,
} from './tool'
