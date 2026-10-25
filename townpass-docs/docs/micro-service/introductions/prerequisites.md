---
title: "核心技術"
source_url: "https://townpass.taipei/docs/micro-service/introductions/prerequisites.html"
source_path: "docs/micro-service/introductions/prerequisites.md"
retrieved_at: "2026-10-04"
---

# 核心技術

## 開發環境

為了最佳的開發體驗，我們建議使用作業系統為 Windows 或 macOS 的電腦。我們也建議進行以下開發環境設定。

### 開發工具

請確保您的電腦上有安裝了以下開發工具：[Node.js](https://nodejs.org/en)、[Git](https://git-scm.com/)。

> node 版本請安裝 v18 以上

如果您需要測試後端 API，亦請安裝 [Postman](https://www.postman.com/)。

### 程式編輯器

[VScode](https://code.visualstudio.com/) 是我們首選的程式編輯器。我們建議安裝以下擴充工具：Prettier、ESLint、Vue Language Features (Volar)。

## 前端核心庫與套件

### Vue

本專案選用 Vue 作為前端框架，並完全使用 Vue 3 發布的 Composition API 方法編寫。Vue 的文件可以[參考](https://vuejs.org/guide)。

### Vue-router

Vue-router 的文件可以[參考](https://router.vuejs.org/guide/)。

### Pinia

根據 Vue 官方建議，我們使用 Pinia 來實現全域狀態管理(Global State Management)，而不是使用 Vuex。 Pinia 的文件可以[參考](https://pinia.vuejs.org/introduction.html)。

### TailwindCSS

本專案中 css style 開發都是透過 TailwindCSS。 相關全域設計，如:色票 等，都可以在 `tailwind.config.js` 找到。TailwindCSS 的文件可以[參考](https://tailwindcss.com/)。

### v-calendar

v-calendar 作為表單組件之一 DatePicker 的日期選擇來源。 v-calendar 的文件可以[參考](https://vcalendar.io/)。

### headlessui

headlessui 是沒有 UI 設計的元件，主要是搭配 TailwindCSS 做使用，專案中使用它提供的 Dialog 作為彈窗使用。 headlessui 的文件可以[參考](https://headlessui.com/)。

### 找地點使用套件

### googlemaps/js-api-loader

`googlemaps/js-api-loader` 是一個用於加載 Google Maps JavaScript API 的庫，提供了一個簡單且高效的方式來初始化和配置 Google 地圖應用。這個工具能夠確保地圖 API 的加載過程更加順暢和穩定，減少了手動處理加載的複雜性。

更多關於 `googlemaps/js-api-loader` 的訊息，可以參考 [官方文件](https://developers.google.com/maps/documentation/javascript/overview)。

### googlemaps/markerclusterer

`googlemaps/markerclusterer` 是一個用於管理和顯示地圖標記群集的庫。當地圖上有大量標記時，這個工具能夠將其自動聚合成群集，從而提高地圖的可視性和性能，避免過多標記導致地圖介面混亂。

更多關於 `googlemaps/markerclusterer` 的訊息，可以參考 [官方文件](https://developers.google.com/maps/documentation/javascript/marker-clustering)。
