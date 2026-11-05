// Framework (wiring, not a layer): the feature contract and the registry that discovers features.
export { defineFeature, featureRoute } from './feature'
export type { DataSource, Feature, FeatureItem } from './feature'
export { allFeatures, features, featureEntry, featureRoutes, getFeature } from './registry'
