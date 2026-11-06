# App ↔ 微服務訊息（bridge）

微服務是網頁，在 App 的 WebView 裡執行，透過 `window.flutterObject` 跟 App 溝通。
網頁端一律用 [`services/web/src/platform/bridge.ts`](../services/web/src/platform/bridge.ts)（資料層），邏輯層透過 `modules/env` 使用：

```ts
import { request, send, isInApp } from '@/platform/bridge'
const user = await request('userinfo')          // 等 App 回覆
send('open_link', 'https://data.taipei/')        // 不需回覆
```

在一般瀏覽器開發時沒有 `flutterObject`，`request` 會回傳 `bridge.ts` 裡的 mock。

## 目前 App 支援的訊息

App 端實作在 `lib/util/web_message_handler/tp_web_message_handler.dart`。

| name | 送出的 data | App 回覆 | 用途 |
|---|---|---|---|
| `userinfo` | — | 帳號物件 | 取得登入者資訊 |
| `location` | — | `{latitude, longitude}` | 取得 GPS 位置（會要求權限） |
| `deviceinfo` | — | 裝置資訊 | |
| `launch_map` | 地圖 URL 字串 | `bool` | 開外部地圖 App |
| `phone_call` | 電話號碼 | `bool` | 撥電話 |
| `1999agree` | 任意 | `bool` | 1999 語音通報 |
| `open_link` | URL | — | 用外部瀏覽器開連結 |
| `notify` | 通知內容 | — | 本機推播通知 |
| `qr_code_scan` | — | 掃描結果 | 開相機掃 QR code |
| `tts_speak` | `{text, lang}` | — | 用手機內建語音念出文字（WebView 沒有 `speechSynthesis`） |
| `tts_stop` | — | — | 停止朗讀 |

> 確切的 data 格式以 Dart 原始碼為準，用到前先看一下對應的 handler。

## 新增訊息（需要 App 端配合時）

1. Flutter 負責人在 `tp_web_message_handler.dart` 新增 `class XxxMessageHandler extends TPWebMessageHandler`
2. 加進 `tp_web_message_listener.dart` 的 `_cachedMessageHandlers`
3. **在上表加一列**（name、data 格式、回覆格式）— 這張表就是前端和 App 的合約
4. 如果需要瀏覽器 mock，加到 `bridge.ts` 的 `mocks`
