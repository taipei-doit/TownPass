---
title: "雙向溝通 App"
source_url: "https://townpass.taipei/docs/two-way-connection/app.html"
source_path: "docs/two-way-connection/app.md"
retrieved_at: "2026-10-04"
---

# 雙向溝通 App

此頁面將會介紹城市通開源專案中的 App 是如何與城市通做雙向溝通溝通。

## 連結機制

在 [簡介](index.md) 頁我們有提到，城市通透過 flutter_inappwebview 的 [web-message-listeners](https://inappwebview.dev/docs/webview/javascript/communication#web-message-listeners) 與 Web 溝通。

透過 flutter_inappwebview 所提供的方式，使用 `WebMessageListener` 物件於 WebView 註冊一個名為 `flutterObject` 的 object：

dart

```
// lib/util/web_message_handler/cp_web_message_listener.dart

WebMessageListener(
  jsObjectName: 'flutterObject',
  onPostMessage: (webMessage, sourceOrigin, isMainFrame, replyProxy) {
    ...
  },
)
```

- `jsObjectName` 定義了在 WebView 端該使用何名稱取得該物件。
- `onPostMessage` 定義了收到網頁端訊息後的邏輯處理。

## 撰寫自定義的 MessageHandler

城市通專案已簡化了多數的訊息傳遞工作。

1. 至 `lib/util/web_message_handler/cp_web_message_handler.dart` 新增一個繼承自 `CPWebMessageHandler` 的 handler；實作：

dart

```
// lib/util/web_message_handler/cp_web_message_handler.dart

abstract class CPWebMessageHandler {
  String get name;

  Future<void> handle({
    required String? message,
    required WebUri? sourceOrigin,
    required bool isMainFrame,
    required Function(WebMessage replyWebMessage)? onReply,
  });

  WebMessage replyWebMessage({required Object data}) {
    return CPWebStringMessageReply(
      name: name,
      data: data,
    ).message;
  }
}
```

- `name` ：定義 handler 名稱，與 [雙向溝通網頁 - 專案內使用設計](web.md#專案內使用設計) 中提及的 name 相對應。
- `handle` ：定義收到資訊該作何處置，其中：
  ⚠️ 注意

  `replyWebMessage()` 參數的 `data` 為需要能夠產出 JSON string 的類別或物件(number, boolean, string, null, list, map 或有實作 toJson() 之物件)。
  - `message` 對應 [雙向溝通網頁 - 專案內使用設計](web.md#專案內使用設計) 結構內的 `data`，也是 WebView 實際要傳給 App 端的資訊。
  - `onReply` 為回覆網頁端的方法，可使用 `replyWebMessage()` 來構建回覆的訊息。

2. 至 `lib/util/web_message_handler/cp_web_message_listener.dart` 的 `messageHandler` list 內新增你新建的 handler：

dart

```
// lib/util/web_message_handler/cp_web_message_listener.dart

static List<CPWebMessageHandler> get messageHandler => [
  UserinfoWebMessageHandler(),
  LaunchMapWebMessageHandler(),
  LaunchPhoneCallMessageHandler(),
  // add it here
];
```

可參考以下檔案內已有的 Handler 以及其實作：

- `lib/util/web_message_handler/cp_web_message_handler.dart`
