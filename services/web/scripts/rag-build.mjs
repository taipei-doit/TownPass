#!/usr/bin/env node
/**
 * Builds a RAG collection: Markdown documents -> one JSON file with text and pre-computed vectors.
 * Phones then skip the slow embedding step, and the documents work before any model is loaded.
 *
 *   pnpm rag:build <folder of .md files> <collection name>
 *   pnpm rag:build ../../data/rag/notices notices        ->  public/rag/notices.json
 *   pnpm rag:build ../../data/rag/notices notices --no-vectors
 *
 * Document format (PDFs: scripts/rag-pdf.py writes this for you; `images` is JSON on one line):
 *   ---
 *   title: 信義路封路公告
 *   subtitle: 臺北市政府工務局
 *   source: 臺北市政府公文
 *   sourceUrl: https://...
 *   validFrom: 2026-11-01
 *   validTo: 2026-12-31
 *   lat: 25.033
 *   lng: 121.564
 *   images: [{"src":"rag/img/road-1.png","alt":"封路範圍圖","caption":"附圖一"}]
 *   ---
 *   正文，一行一件事。太長的段落會在句號斷開。
 *
 * Guide: src/addons/rag/README.md
 */
import { mkdirSync, readdirSync, readFileSync, writeFileSync } from 'node:fs'
import { basename, dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'

// same as EMBEDDING_MODEL in src/addons/model/logic.ts
const EMBEDDING_MODEL = 'onnx-community/embeddinggemma-300m-ONNX'
const EMBEDDING_DTYPE = 'q8'
const PASSAGE_PREFIX = 'title: none | text: '
const MAX_LINE_CHARS = 120

const args = process.argv.slice(2).filter((a) => a !== '--')
const noVectors = args.includes('--no-vectors')
const [folder, name] = args.filter((a) => !a.startsWith('--'))
if (!folder || !name) {
  console.error('usage: pnpm rag:build <folder of .md files> <collection name> [--no-vectors]')
  process.exit(1)
}

/** Reads `---` front matter; numbers and JSON stay typed. */
function parse(path) {
  const raw = readFileSync(path, 'utf8').replace(/^﻿/, '').replace(/\r\n/g, '\n')
  const match = raw.match(/^---\n([\s\S]*?)\n---\n?([\s\S]*)$/)
  if (!match) throw new Error(`${path}: missing --- front matter`)
  const meta = {}
  for (const line of match[1].split('\n')) {
    const at = line.indexOf(':')
    if (at > 0) meta[line.slice(0, at).trim()] = line.slice(at + 1).trim()
  }
  if (!meta.title) throw new Error(`${path}: title is required`)
  const lat = Number(meta.lat)
  const lng = Number(meta.lng)
  return {
    id: meta.id || basename(path, '.md'),
    title: meta.title,
    subtitle: meta.subtitle || undefined,
    text: splitLines(match[2]).join('\n'),
    geo: meta.lat && meta.lng && Number.isFinite(lat) && Number.isFinite(lng) ? { lat, lng } : undefined,
    images: meta.images ? JSON.parse(meta.images) : undefined,
    validFrom: meta.validFrom || undefined,
    validTo: meta.validTo || undefined,
    source: meta.source || undefined,
    sourceUrl: meta.sourceUrl || undefined,
  }
}

/** One fact per line, because retrieval works on lines. Long paragraphs break after a sentence. */
function splitLines(body) {
  const lines = []
  for (const paragraph of body.split('\n').map((l) => l.trim()).filter(Boolean)) {
    let line = ''
    for (const sentence of paragraph.match(/[^。！？；]+[。！？；]?/g) ?? []) {
      if (line && line.length + sentence.length > MAX_LINE_CHARS) {
        lines.push(line)
        line = ''
      }
      line += sentence
    }
    if (line) lines.push(line)
  }
  return lines
}

// Must match __chunksOf and __hash in src/addons/rag/logic.ts. If they ever differ, phones simply
// calculate the missing vectors themselves.
function chunksOf(d) {
  const lines = d.text.split('\n').filter(Boolean)
  const header = [d.subtitle, ...lines.slice(0, 1)].filter(Boolean).join('；')
  return [header, ...lines].map((text) => ({ title: d.title, text }))
}
function hash(s) {
  let h = 2166136261
  for (let i = 0; i < s.length; i++) h = Math.imul(h ^ s.charCodeAt(i), 16777619)
  return (h >>> 0).toString(36) + s.length.toString(36)
}

const files = readdirSync(folder).filter((f) => f.endsWith('.md'))
const documents = files.map((f) => parse(join(folder, f)))
const ids = new Set(documents.map((d) => d.id))
if (ids.size !== documents.length) throw new Error('two documents have the same id')

const vectors = {}
if (!noVectors) {
  const { pipeline } = await import('@huggingface/transformers')
  const embedder = await pipeline('feature-extraction', EMBEDDING_MODEL, { dtype: EMBEDDING_DTYPE })
  const chunks = documents.flatMap(chunksOf)
  for (let i = 0; i < chunks.length; i += 16) {
    const batch = chunks.slice(i, i + 16)
    const output = await embedder(batch.map((c) => `${PASSAGE_PREFIX}${c.title}：${c.text}`), { pooling: 'mean', normalize: true })
    output.tolist().forEach((v, j) => {
      const c = batch[j]
      vectors[hash(`${c.title}\n${c.text}`)] = v.map((x) => Math.round(x * 1e4) / 1e4)
    })
    console.log(`  ${Math.min(i + 16, chunks.length)}/${chunks.length} chunks`)
  }
}

const output = join(dirname(fileURLToPath(import.meta.url)), `../public/rag/${name}.json`)
mkdirSync(dirname(output), { recursive: true })
writeFileSync(output, JSON.stringify({ model: EMBEDDING_MODEL, documents, vectors }))
console.log(`${output}: ${documents.length} documents, ${Object.keys(vectors).length} vectors`)
