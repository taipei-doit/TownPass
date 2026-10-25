---
title: "核心技術"
source_url: "https://townpass.taipei/docs/micro-service/find-places/prerequisites.html"
source_path: "docs/micro-service/find-places/prerequisites.md"
retrieved_at: "2026-10-04"
---

# 核心技術

## 前端核心庫與套件

### Vue

本專案選用 Vue 作為前端框架，並完全使用 Vue 3 發布的 Composition API 方法編寫。Vue 的文件可以[參考](https://vuejs.org/guide)。

### Vue-router

Vue-router 的文件可以[參考](https://router.vuejs.org/guide/)。

### Pinia

根據 Vue 官方建議，我們使用 Pinia 來實現全域狀態管理(Global State Management)，而不是使用 Vuex。 Pinia 的文件可以[參考](https://pinia.vuejs.org/introduction.html)。

### TailwindCSS

本專案中 css style 開發都是透過 TailwindCSS。 相關全域設計，如:色票 等，都可以在 `tailwind.config.js` 找到。TailwindCSS 的文件可以[參考](https://tailwindcss.com/)。

### googlemaps/js-api-loader

`googlemaps/js-api-loader` 是一個用於加載 Google Maps JavaScript API 的庫，提供了一個簡單且高效的方式來初始化和配置 Google 地圖應用。這個工具能夠確保地圖 API 的加載過程更加順暢和穩定，減少了手動處理加載的複雜性。

更多關於 `googlemaps/js-api-loader` 的訊息，可以參考 [官方文件](https://developers.google.com/maps/documentation/javascript/overview)。

### googlemaps/markerclusterer

`googlemaps/markerclusterer` 是一個用於管理和顯示地圖標記群集的庫。當地圖上有大量標記時，這個工具能夠將其自動聚合成群集，從而提高地圖的可視性和性能，避免過多標記導致地圖介面混亂。

更多關於 `googlemaps/markerclusterer` 的訊息，可以參考 [官方文件](https://developers.google.com/maps/documentation/javascript/marker-clustering)。
