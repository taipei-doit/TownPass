---
title: "專案結構"
source_url: "https://townpass.taipei/docs/micro-service/introductions/project-structure.html"
source_path: "docs/micro-service/introductions/project-structure.md"
retrieved_at: "2026-10-04"
---

# 專案結構

## /src

### /assets

`/assets` 資料夾儲存靜態項目，例如圖片。

### /views

`/views` 資料夾儲存申辦服務各頁面 Vue 元件，每一個元件都對應一個 vue-router 路徑。

### /components

`/components` 資料夾儲存較小的 Vue 元件，用於組成使用者介面。

參考原子設計規劃此資料夾結構。

相關原子設計可以參考此篇[文章](https://bradfrost.com/blog/post/atomic-web-design/)

### /composables

`/composables` 儲存了 vue composition api 邏輯抽出的各方法，以達到共用目的。

可以參考[composables 概念](https://vuejs.org/guide/reusability/composables.html#composables)

### /css

儲存全域 css 設定，如：字體等。

### /stores

`/stores` 資料夾是所有 Pinia Store 的所在地。本專案透過使用 Pinia Stores 中的函式與資料，實現全域狀態管理。

### /router

`/router` 資料夾主要是 vue-router 的配置。

### /utils

`/utils` 主要儲存一些工具型的方法，例如：formatter。

## /public

`/public` 資料夾儲存較大檔案與靜態資料。像是 mockData。
