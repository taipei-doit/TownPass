---
title: "雙向溝通簡介"
source_url: "https://townpass.taipei/docs/two-way-connection/"
source_path: "docs/two-way-connection/index.md"
retrieved_at: "2026-10-04"
---

# 雙向溝通簡介

App 與 WebView 的雙向溝通（Two-Way Connection）指的是在一個行動應用程式（App）與其嵌入的 WebView 之間建立的一種互動機制，使得它們能夠相互傳遞數據和指令。

ℹ️ 資訊

城市通 flutter 專案中我們使用 [flutter_inappwebview](https://pub.dev/packages/flutter_inappwebview) 作為 WebView 工具。

我們透過 flutter_inappwebview 提供的 [web-message-listeners](https://inappwebview.dev/docs/webview/javascript/communication#web-message-listeners) 作為 WebView 與 App 的溝通手段。

## 何謂 App 與 WebView 的雙向溝通？

雙向溝通意味著：

- 從 App 到 WebView 的通訊： 原生 App 可以向 WebView 中網頁傳遞資料或事件。
  例如：當用戶在 App 中觸發某個事件時，App 可以向 WebView 發送消息，控制網頁內容的變更或執行特定操作。
- 從 WebView 到 App 的通訊： 相反，WebView 中的網頁也可以向原生 App 傳遞資料或請求原生 App 功能。
  例如：網頁上的一個按鈕被點擊後，WebView 可以通過 JavaScript 發送一個訊息給 App，讓 App 執行某些原生功能（如啟動相機或查詢地理位置）。

**雙向溝通機制讓開發者可以靈活地結合原生 App 的強大功能與 Web 技術的靈活性，提供更豐富的應用體驗。**
