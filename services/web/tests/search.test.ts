import { describe, expect, it } from 'vitest'
import { tokenize } from '@/modules/search/data'

describe('tokenize (data layer)', () => {
  it('splits Chinese into characters and bigrams', () => {
    const t = tokenize('公園廁所')
    expect(t).toEqual(expect.arrayContaining(['公', '公園', '園廁', '廁所']))
  })

  it('keeps latin words whole and lower-cased, drops punctuation', () => {
    expect(tokenize('YouBike 2.0，站點！')).toEqual(expect.arrayContaining(['youbike', '2', '0', '站點']))
  })

  it('handles mixed scripts without losing either side', () => {
    expect(tokenize('MRT捷運站')).toEqual(expect.arrayContaining(['mrt', '捷運', '運站']))
  })
})
