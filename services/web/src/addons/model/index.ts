/**
 * ADD-ON: model (optional, OFF by default). Public interface - import only from '@/addons/model'.
 * On-device models: hardware probe, model choice, download + offline cache, embeddings, text
 * generation and the disclosure table the competition requires.
 * How to use it: README.md in this folder. Catalog of add-ons: docs/system/09-addons.md
 */
export const ADDON_CODE = 'ML'

export {
  chooseGenerator,
  complete,
  embedPassages,
  embedQuery,
  activeEmbedding,
  chooseEmbedding,
  EMBEDDING_MODELS,
  EMBEDDING_NEEDS,
  GENERATORS,
  inspectDevice,
  isOfflineReady,
  LARGE_MODEL_NEEDS,
  languageModelId,
  languageModelReady,
  modelDisclosure,
  ONLY_OPEN_SOURCE_MODELS,
  prepareEmbedding,
  prepareLanguageModel,
  useModel,
} from './logic'
export type { ChatMessage, CompleteOptions, EmbeddingModel, GeneratorKey, HardwareProfile, ModelChoice, ModelKey, ModelTool } from './logic'

/** Hardware, chosen model and disclosure table, for any screen that manages the models. */
export const DeviceModelCard = () => import('./ui/DeviceModelCard.vue')
