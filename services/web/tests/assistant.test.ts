import { beforeAll, describe, expect, it, vi } from 'vitest'
import { useAssistant } from '@/modules/assistant'
import { buildSearchIndex } from '@/modules/search'

describe('assistant (logic layer, on-device search)', () => {
  beforeAll(async () => {
    vi.stubGlobal('fetch', vi.fn().mockRejectedValue(new TypeError('offline'))) // no backend -> mock data
    await buildSearchIndex()
  })

  it('answers with result cards, best match first', async () => {
    const { messages, ask } = useAssistant()
    await ask('信義區的公園')
    const reply = messages.value[1]!
    expect(reply.role).toBe('bot')
    expect(reply.results?.[0]?.title).toBe('範例公園')
  })

  it('suggests features when nothing matches', async () => {
    const { messages, ask } = useAssistant()
    await ask('qqqqzzzz')
    expect(messages.value[1]!.results ?? []).toHaveLength(0)
    expect(messages.value[1]!.suggestions?.length).toBeGreaterThan(0)
  })

  it('ignores blank questions', async () => {
    const { messages, ask } = useAssistant()
    await ask('   ')
    expect(messages.value).toHaveLength(0)
  })
})
