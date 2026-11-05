<script setup lang="ts">
/** @component O02 OsmMap — OpenStreetMap 地圖 */
/**
 * OpenStreetMap via Leaflet. Competition rules forbid commercial map SDKs (e.g. Google Maps),
 * so use this component for every map. Attribution must stay visible (OSM licence).
 */
import { onBeforeUnmount, onMounted, ref, watch } from 'vue'
import L from 'leaflet'
import 'leaflet/dist/leaflet.css'

export type MapMarker = { lat: number; lng: number; label?: string }

const props = withDefaults(
  defineProps<{ center?: [number, number]; zoom?: number; markers?: MapMarker[] }>(),
  { center: () => [25.0375, 121.5637], zoom: 14, markers: () => [] },
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
      L.circleMarker([m.lat, m.lng], { radius: 8, color: '#356c77', fillColor: '#2eb6c7', fillOpacity: 0.9 })
        .bindTooltip(m.label ?? '')
        .on('click', () => emit('markerClick', m)),
    ),
  ).addTo(map)
}

onMounted(() => {
  map = L.map(el.value!, {
    // On phones a one-finger drag should scroll the page, not trap the user in the map.
    // Pinch-zoom and the +/- buttons still work.
    dragging: !L.Browser.mobile,
    scrollWheelZoom: false,
  }).setView(props.center, props.zoom)
  L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
    maxZoom: 19,
    attribution: '&copy; OpenStreetMap contributors',
  }).addTo(map)
  drawMarkers()
})
watch(() => props.markers, drawMarkers, { deep: true })
watch(() => props.center, (c) => map?.setView(c))
onBeforeUnmount(() => map?.remove())
</script>

<template>
  <!-- isolate: Leaflet panes use z-index 400+, keep them below sticky headers/bars -->
  <div ref="el" class="isolate h-64 w-full rounded-xl" />
</template>
