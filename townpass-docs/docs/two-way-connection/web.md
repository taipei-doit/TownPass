---
title: "雙向溝通網頁"
source_url: "https://townpass.taipei/docs/two-way-connection/web.html"
source_path: "docs/two-way-connection/web.md"
retrieved_at: "2026-10-04"
---

# 雙向溝通網頁

此頁面將會介紹城市通開源專案中的微服務網頁是如何與城市通做雙向溝通溝通。

## 連結機制

在 [簡介](index.md) 頁我們有提到，城市通透過 flutter_inappwebview 的 [web-message-listeners](https://inappwebview.dev/docs/webview/javascript/communication#web-message-listeners) 與 App 溝通。

web-message-listeners 會在網頁中全域註冊一個 object 供網頁使用，object 的名稱可以透過 Flutter 部分做定義。

- 網頁呼叫 App：透過 object 的 `postMessage` 傳送字串資訊給 App，作為呼叫手段。
- 網頁接收 App 訊息：object 透過 `onmessage` 或 `addEventListener` 監聽 App 的呼叫，同時處理來自 App 的資訊。

ℹ️ 方法資訊

- `postMessage` 只能接受一個字串類型的參數，當要傳送給 App 的資料不是字串時，必須先轉換成字串，再做為參數傳入。
- `onmessage` 可以被賦予一個 function，該 function 會被傳入一個 event 參數，來自 App 的資訊一樣以字串形式存在 `event.data` 中，在 function 中可以針對 `event.data` 做後續處理。
- `addEventListener` 就跟 js 的 `addEventListener` 一樣，第一個參數接收所謂的事件，在這邊的事件一律都叫做 `message`，當 App 傳送資訊時，object 就會接收到 message 事件。
  第二個參數傳入一個 callback function，該 function 一樣會被傳入 event 參數，可以在 fucntion 中針對 `event.data` 去做處理。

⚠️ 注意

因為 web-message-listeners 提供給網頁的 object 存在全域中

若要使用 `addEventListener` 這方法，請注意 Vue 元件的生命週期與 listener 之間的關係，並適時使用 `removeEventListener` 來移除 listener，避免創造非預期的 listener。

## 專案內使用設計

我們目前已經在城市通 App 與微服務定義好資料的溝通格式，統一用 object 轉成字串的形式作傳遞，object 中填入兩個 key 分別是 name 與 data。

| name | data |
| --- | --- |
| 要溝通的資料分類，像是 userinfo | 傳送與接收的資料都會是字串形式，但 parse 後資料格式不限，也可以是 null |

ℹ️ 參考資訊

我們已在微服務專案中實作了從 App 取得 user 資料與開啟 map 的溝通功能。

可以參考以下路徑檔案更了解使用方法。

`/src/views/HomeView.vue`

`/src/views/HotSpotView.vue`

`/src/views/TicketDetail.vue`

`/src/views/CouponDetail.vue`

`/src/composables/useConnectionMessage.ts`

`/src/composables/useHandleConnectionData.ts`
