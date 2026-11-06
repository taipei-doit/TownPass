import { describe, expect, it } from 'vitest'
import { features } from '@/framework'

describe('AI 問答 stays off until switched on', () => {
  it('the live feature list has no assistant and no AI feature', () => {
    expect(features.filter((f) => f.assistant)).toEqual([])
    expect(features.map((f) => f.id)).not.toContain('_ai')
  })

  it('the template is complete: lab page + assistant', async () => {
    const template = (await import('@/features/_ai')).default
    expect(template.assistant?.id).toBe('agent')
    expect(template.routes[0]?.name).toBe('lab')
  })
})

describe('open-source models only, until the organiser confirms the Gemma Terms', async () => {
  const { chooseEmbedding, chooseGenerator, EMBEDDING_MODELS, GENERATORS, ONLY_OPEN_SOURCE_MODELS } = await import('@/addons/model')
  const phone = { webgpu: true, shaderF16: true, maxBufferMB: 2048, memoryGB: 8, cores: 8, freeStorageMB: 8000, gpuName: 'test' }

  it('is the default', () => expect(ONLY_OPEN_SOURCE_MODELS).toBe(true))

  it('embedding: e5-small (MIT) even on a strong phone', () => {
    expect(chooseEmbedding(phone)).toBe(EMBEDDING_MODELS.light)
    expect(chooseEmbedding(phone).licence).toBe('MIT')
  })

  it('asking for Gemma 3 1B gives Granite 350M (Apache-2.0) and says why', () => {
    const c = chooseGenerator(phone, 'large')
    expect(c.id).toBe(GENERATORS.small.id)
    expect(c.reasons.join()).toContain('Gemma')
  })

  it('switching the policy off allows them', () => {
    expect(chooseEmbedding(phone, false)).toBe(EMBEDDING_MODELS.standard)
    expect(chooseGenerator(phone, 'large', false).id).toBe(GENERATORS.large.id)
  })
})
