<script setup lang="ts">
/** @component O02 OsmMap — OpenStreetMap 地圖（斷網時改用隨附的臺北底圖） */
/**
 * OpenStreetMap via Leaflet. Competition rules forbid commercial map SDKs (e.g. Google Maps),
 * so use this component for every map. Attribution must stay visible (OSM licence).
 *
 * Basemap: OSM tiles while online. Offline, or when tiles fail, it switches to maps/taipei.pmtiles,
 * a vector extract shipped with the site. The OSM tile policy forbids downloading their tiles in
 * advance, so the offline map can't be a tile cache.
 */
import { onBeforeUnmount, onMounted, ref, watch } from 'vue'
import L from 'leaflet'
import 'leaflet/dist/leaflet.css'

export type MapMarker = { lat: number; lng: number; label?: string; detail?: string; tone?: 'default' | 'warning' }

const __TONES = {
  default: { color: '#356c77', fillColor: '#2eb6c7' },
  warning: { color: '#a8481c', fillColor: '#f5a623' },
}
const __ATTRIBUTION = '&copy; OpenStreetMap contributors'

const props = withDefaults(
  defineProps<{
    center?: [number, number]
    zoom?: number
    markers?: MapMarker[]
    /** zoom to show every marker */
    fit?: boolean
    /** 'offline' always uses the shipped basemap */
    basemap?: 'auto' | 'offline'
  }>(),
  { center: () => [25.0375, 121.5637], zoom: 14, markers: () => [], basemap: 'auto' },
)
const emit = defineEmits<{ markerClick: [marker: MapMarker] }>()

const el = ref<HTMLDivElement>()
let map: L.Map | undefined
let layer: L.LayerGroup | undefined

function drawMarkers() {
  if (!map) return
  layer?.remove()
  layer = L.layerGroup(
    props.markers.map((m) =>
      L.circleMarker([m.lat, m.lng], { radius: 8, fillOpacity: 0.9, ...__TONES[m.tone ?? 'default'] })
        .bindPopup(__popupOf(m))
        .on('click', () => emit('markerClick', m)),
    ),
  ).addTo(map)
  if (props.fit && props.markers.length) {
    map.fitBounds(L.latLngBounds(props.markers.map((m) => [m.lat, m.lng])), { padding: [28, 28], maxZoom: 16 })
  }
}

/** Built with textContent: labels come from outside data and must never be read as HTML. */
function __popupOf(m: MapMarker): HTMLElement {
  const box = document.createElement('div')
  box.appendChild(document.createElement('strong')).textContent = m.label ?? ''
  if (m.detail) box.appendChild(document.createElement('div')).textContent = m.detail
  return box
}

let onlineLayer: L.TileLayer | undefined
let usingOffline = false

async function useOfflineBasemap() {
  if (usingOffline || !map) return
  usingOffline = true
  onlineLayer?.remove()
  // protomaps-leaflet extends the global L, so it has to exist before the library loads
  ;(window as unknown as { L: typeof L }).L = L
  const { leafletLayer } = await import('protomaps-leaflet')
  if (!map) return
  const layer = leafletLayer({
    url: `${import.meta.env.BASE_URL}maps/taipei.pmtiles`,
    flavor: 'light',
    lang: 'zh',
    maxDataZoom: 14,
    attribution: `${__ATTRIBUTION} &middot; Protomaps`,
  }) as unknown as L.Layer
  layer.addTo(map)
}

function useOnlineBasemap() {
  onlineLayer = L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', { maxZoom: 19, attribution: __ATTRIBUTION })
  onlineLayer.on('tileerror', () => void useOfflineBasemap())
  onlineLayer.addTo(map!)
}

onMounted(() => {
  map = L.map(el.value!, {
    // On phones a one-finger drag should scroll the page, not trap the user in the map.
    // Pinch-zoom and the +/- buttons still work.
    dragging: !L.Browser.mobile,
    scrollWheelZoom: false,
  }).setView(props.center, props.zoom)
  if (props.basemap === 'offline' || !navigator.onLine) void useOfflineBasemap()
  else useOnlineBasemap()
  drawMarkers()
})
watch(() => props.markers, drawMarkers, { deep: true })
watch(() => props.center, (c) => map?.setView(c))
onBeforeUnmount(() => {
  map?.remove()
  map = undefined
})
</script>

<template>
  <!-- isolate: Leaflet panes use z-index 400+, keep them below sticky headers/bars -->
  <div ref="el" class="isolate h-64 w-full rounded-xl" />
</template>
