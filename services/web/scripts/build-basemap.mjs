#!/usr/bin/env node
/**
 * Builds the offline basemap: copies one area out of a Protomaps world build into a small
 * PMTiles v3 file. Run again only to change the area or refresh the map.
 *
 *   pnpm basemap:build                               # Greater Taipei, zoom 0-14
 *   pnpm basemap:build -- --bbox=121.4,24.95,121.68,25.22 --maxzoom=14 --date=20261105
 *
 * The data is OpenStreetMap (ODbL), so attribution must stay visible on the map; OsmMap adds it.
 * Output: public/maps/taipei.pmtiles
 * Format: https://github.com/protomaps/PMTiles/blob/main/spec/v3/spec.md
 */
import { mkdirSync, writeFileSync } from 'node:fs'
import { dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'
import { gzipSync } from 'node:zlib'
import { PMTiles, zxyToTileId } from 'pmtiles'

const option = (name, fallback) => process.argv.find((a) => a.startsWith(`--${name}=`))?.split('=')[1] ?? fallback
const [west, south, east, north] = option('bbox', '121.4,24.95,121.68,25.22').split(',').map(Number)
const maxZoom = Number(option('maxzoom', '14'))
const date = option('date', new Date(Date.now() - 2 * 864e5).toISOString().slice(0, 10).replaceAll('-', ''))
const output = join(dirname(fileURLToPath(import.meta.url)), '../public/maps/taipei.pmtiles')
const CONCURRENCY = 6

const source = new PMTiles(`https://build.protomaps.com/${date}.pmtiles`)
const sourceHeader = await source.getHeader()
const metadata = await source.getMetadata()

const lngToX = (lng, z) => Math.floor(((lng + 180) / 360) * 2 ** z)
const latToY = (lat, z) => {
  const r = (lat * Math.PI) / 180
  return Math.floor(((1 - Math.log(Math.tan(r) + 1 / Math.cos(r)) / Math.PI) / 2) * 2 ** z)
}

const wanted = []
for (let z = 0; z <= maxZoom; z++) {
  for (let x = lngToX(west, z); x <= lngToX(east, z); x++) {
    for (let y = latToY(north, z); y <= latToY(south, z); y++) wanted.push({ z, x, y, id: zxyToTileId(z, x, y) })
  }
}
wanted.sort((a, b) => a.id - b.id)
console.log(`${date}: ${wanted.length} tiles, zoom 0-${maxZoom}`)

const tiles = new Array(wanted.length)
let next = 0
let fetched = 0
await Promise.all(
  Array.from({ length: CONCURRENCY }, async () => {
    while (next < wanted.length) {
      const i = next++
      const { z, x, y } = wanted[i]
      const tile = await source.getZxy(z, x, y)
      if (tile) tiles[i] = gzipSync(new Uint8Array(tile.data))
      if (++fetched % 50 === 0) console.log(`  ${fetched}/${wanted.length}`)
    }
  }),
)

const entries = []
const chunks = []
let offset = 0
wanted.forEach((t, i) => {
  if (!tiles[i]) return // empty sea tile
  entries.push({ id: t.id, offset, length: tiles[i].length })
  chunks.push(tiles[i])
  offset += tiles[i].length
})

function directory() {
  const bytes = []
  const varint = (value) => {
    let v = value
    while (v >= 128) {
      bytes.push((v % 128) | 128)
      v = Math.floor(v / 128)
    }
    bytes.push(v)
  }
  varint(entries.length)
  let last = 0
  for (const e of entries) {
    varint(e.id - last)
    last = e.id
  }
  for (const _ of entries) varint(1) // run length
  for (const e of entries) varint(e.length)
  entries.forEach((e, i) => {
    const previous = entries[i - 1]
    varint(previous && e.offset === previous.offset + previous.length ? 0 : e.offset + 1)
  })
  return gzipSync(Uint8Array.from(bytes))
}

const root = directory()
const meta = gzipSync(Buffer.from(JSON.stringify(metadata)))
const HEADER_BYTES = 127
if (HEADER_BYTES + root.length > 16384) throw new Error('area too large for one directory: use a smaller --bbox or --maxzoom')

const header = Buffer.alloc(HEADER_BYTES)
const u64 = (at, value) => header.writeBigUInt64LE(BigInt(value), at)
const e7 = (at, value) => header.writeInt32LE(Math.round(value * 1e7), at)
header.write('PMTiles', 0, 'ascii')
header[7] = 3 // spec version
u64(8, HEADER_BYTES)
u64(16, root.length)
u64(24, HEADER_BYTES + root.length)
u64(32, meta.length)
u64(40, 0) // no leaf directories
u64(48, 0)
u64(56, HEADER_BYTES + root.length + meta.length)
u64(64, offset)
u64(72, entries.length)
u64(80, entries.length)
u64(88, entries.length)
header[96] = 1 // clustered
header[97] = 2 // directory compression: gzip
header[98] = 2 // tile compression: gzip
header[99] = sourceHeader.tileType
header[100] = 0
header[101] = maxZoom
e7(102, west)
e7(106, south)
e7(110, east)
e7(114, north)
header[118] = Math.min(12, maxZoom)
e7(119, (west + east) / 2)
e7(123, (south + north) / 2)

mkdirSync(dirname(output), { recursive: true })
writeFileSync(output, Buffer.concat([header, root, meta, ...chunks]))
console.log(`${output}: ${entries.length} tiles, ${(HEADER_BYTES + root.length + meta.length + offset) / 2 ** 20 | 0} MB`)
