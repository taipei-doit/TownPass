import 'dart:convert';

import 'package:town_pass/util/web_message_handler/tp_web_message_handler.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

abstract class TPWebMessageListener {
  // 將訊息處理器列表快取起來，避免每次訪問時都重複建立新的實例。
  // 這樣做可以提升應用程式的啟動效能，因為這些處理器通常是無狀態的。
  static final List<TPWebMessageHandler> _cachedMessageHandlers = [
        UserinfoWebMessageHandler(),
        LaunchMapWebMessageHandler(),
        PhoneCallMessageHandler(),
        Agree1999MessageHandler(),
        LocationMessageHandler(),
        DeviceInfoMessageHandler(),
        OpenLinkMessageHandler(),
        NotifyMessageHandler(),
        QRCodeScanMessageHandler(),
      ];

  static List<TPWebMessageHandler> get messageHandler => _cachedMessageHandlers;

  static WebMessageListener webMessageListener() {
    return WebMessageListener(
      jsObjectName: 'flutterObject',
      onPostMessage: (webMessage, sourceOrigin, isMainFrame, replyProxy) async {
        if (webMessage == null) {
          return;
        }

        final Map dataMap = jsonDecode(webMessage.data);
        for (TPWebMessageHandler handler in messageHandler) {
          if (handler.name == dataMap['name']) {
            await handler.handle(
              message: dataMap['data'],
              sourceOrigin: sourceOrigin,
              isMainFrame: isMainFrame,
              onReply: (reply) => replyProxy.postMessage(reply),
            );
          }
        }
      },
    );
  }
}