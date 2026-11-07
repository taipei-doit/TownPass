import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:town_pass/gen/assets.gen.dart';
import 'package:town_pass/service/account_service.dart';
import 'package:town_pass/service/device_service.dart';
import 'package:town_pass/service/geo_locator_service.dart';
import 'package:town_pass/service/notification_service.dart';
import 'package:town_pass/service/shared_preferences_service.dart';
import 'package:town_pass/service/subscription_service.dart';
import 'package:town_pass/util/tp_button.dart';
import 'package:town_pass/util/tp_dialog.dart';
import 'package:town_pass/util/tp_route.dart';
import 'package:town_pass/util/tp_text.dart';
import 'package:town_pass/util/web_message_handler/tp_web_message_reply.dart';
import 'package:url_launcher/url_launcher.dart';

abstract class TPWebMessageHandler {
  String get name;

  Future<void> handle({
    required Object? message,
    required WebUri? sourceOrigin,
    required bool isMainFrame,
    required Function(WebMessage replyWebMessage)? onReply,
  });

  WebMessage replyWebMessage({required Object? data}) {
    return TPWebStringMessageReply(
      name: name,
      data: data,
    ).message;
  }
}

/// 持續推送資料給網頁的處理器（例如感測器串流）。
///
/// 網頁傳入 `{action: 'start', ...}` 開始、`{action: 'stop'}` 停止，開始後會透過同一個
/// reply proxy 重複回傳 `{name, data}`。每個 WebView 以 `owner` 區分各自的串流，
/// WebView 關閉或換頁時由 `TPWebMessageListener.cancelStreams` 統一停止。
abstract class TPWebMessageStreamHandler extends TPWebMessageHandler {
  final Map<Object, Future<void> Function()> _cancellers = {};

  /// 開始串流，回傳停止串流用的 callback。
  Future<Future<void> Function()> start({
    required Map config,
    required void Function(Object? data) onData,
  });

  @override
  Future<void> handle({
    required Object? message,
    required WebUri? sourceOrigin,
    required bool isMainFrame,
    required Function(WebMessage replyWebMessage)? onReply,
  }) {
    return handleStream(
      owner: this,
      message: message,
      sourceOrigin: sourceOrigin,
      isMainFrame: isMainFrame,
      onReply: onReply,
    );
  }

  Future<void> handleStream({
    required Object owner,
    required Object? message,
    required WebUri? sourceOrigin,
    required bool isMainFrame,
    required Function(WebMessage replyWebMessage)? onReply,
  }) async {
    await cancel(owner: owner);

    final Map config = message is Map ? message : const {};
    if (config['action'] != 'start' || onReply == null) {
      onReply?.call(replyWebMessage(data: true));
      return;
    }

    final Future<void> Function() canceller = await start(
      config: config,
      onData: (data) {
        try {
          onReply(replyWebMessage(data: data));
        } catch (error) {
          // reply proxy 已失效（WebView 已關閉）
          printError(info: error.toString());
          cancel(owner: owner);
        }
      },
    );

    // start 等待期間若又收到新的 start，先停掉前一個避免殘留
    final Future<void> Function()? previous = _cancellers[owner];
    _cancellers[owner] = canceller;
    await previous?.call();
  }

  Future<void> cancel({required Object owner}) async {
    await _cancellers.remove(owner)?.call();
  }
}

class UserinfoWebMessageHandler extends TPWebMessageHandler {
  @override
  String get name => 'userinfo';

  @override
  Future<void> handle({
    required Object? message,
    required WebUri? sourceOrigin,
    required bool isMainFrame,
    required onReply,
  }) async {
    onReply?.call(replyWebMessage(
      data: Get.find<AccountService>().account ?? [],
    ));
  }
}

/// 性別（好行「找廁所」導向對應性別廁所用）：由身分證／居留證號第 2 碼推得，只回傳性別、不回傳證號。
/// 回覆 `{ gender: 'male' | 'female' | null }`；未登入或證號無法判斷時為 null。
class UserGenderMessageHandler extends TPWebMessageHandler {
  @override
  String get name => 'user_gender';

  @override
  Future<void> handle({
    required Object? message,
    required WebUri? sourceOrigin,
    required bool isMainFrame,
    required onReply,
  }) async {
    onReply?.call(replyWebMessage(
      data: {'gender': genderFromIdNumber(Get.find<AccountService>().account?.idNumber)},
    ));
  }
}

/// 身分證號第 2 碼 1／2、新式居留證號 8／9 分別為男／女；其他格式回傳 null。
String? genderFromIdNumber(String? idNumber) {
  final String? id = idNumber?.trim().toUpperCase();
  if (id == null || !RegExp(r'^[A-Z][1289][0-9]{8}$').hasMatch(id)) return null;
  return switch (id[1]) { '1' || '8' => 'male', _ => 'female' };
}

class LaunchMapWebMessageHandler extends TPWebMessageHandler {
  @override
  String get name => 'launch_map';

  @override
  handle({
    required Object? message,
    required WebUri? sourceOrigin,
    required bool isMainFrame,
    required Function(WebMessage reply)? onReply,
  }) async {
    if (message == null || message is! String) {
      onReply?.call(
        replyWebMessage(data: false),
      );
    }
    final Uri uri = Uri.parse(message as String);
    final bool canLaunch = await canLaunchUrl(uri);

    onReply?.call(
      replyWebMessage(data: canLaunch),
    );

    if (canLaunch) {
      await launchUrl(uri);
    }
  }
}

class Agree1999MessageHandler extends TPWebMessageHandler {
  @override
  String get name => '1999agree';

  @override
  handle({
    required Object? message,
    required WebUri? sourceOrigin,
    required bool isMainFrame,
    required Function(WebMessage reply)? onReply,
  }) async {
    if (message == null) {
      onReply?.call(
        replyWebMessage(data: false),
      );
    }
    final Uri uri = Uri.parse('tel://1999');

    final bool canLaunch = await canLaunchUrl(uri);
    if (!canLaunch) {
      onReply?.call(replyWebMessage(data: false));
      return;
    }

    final bool userAgreement = SharedPreferencesService().instance.getBool(SharedPreferencesService.keyPhoneCallUserAgreement) ?? false;
    if (!userAgreement) {
      await Get.toNamed(TPRoute.phoneCallUserAgreement);

      final bool userAgreement = SharedPreferencesService().instance.getBool(SharedPreferencesService.keyPhoneCallUserAgreement) ?? false;
      if (!userAgreement) {
        onReply?.call(replyWebMessage(data: false));
        return;
      }
    }

    await TPDialog.show(
      padding: const EdgeInsets.symmetric(horizontal: 68, vertical: 40),
      showCloseCross: true,
      barrierDismissible: false,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Assets.svg.phoneCallService.svg(),
          const TPText('語音通報', style: TPTextStyles.titleSemiBold),
          const SizedBox(height: 8),
          const TPText('電話撥號'),
          const SizedBox(height: 24),
          TPButton.primary(
            text: '立即撥號',
            onPressed: () async => await launchUrl(uri),
          ),
        ],
      ),
    );
  }
}

class PhoneCallMessageHandler extends TPWebMessageHandler {
  @override
  String get name => 'phone_call';

  @override
  handle({
    required Object? message,
    required WebUri? sourceOrigin,
    required bool isMainFrame,
    required Function(WebMessage reply)? onReply,
  }) async {
    if (message == null) {
      onReply?.call(
        replyWebMessage(data: false),
      );
    }
    final Uri uri = Uri.parse('tel://${message!}');
    final bool canLaunch = await canLaunchUrl(uri);

    onReply?.call(
      replyWebMessage(data: canLaunch),
    );

    if (canLaunch) {
      await launchUrl(uri);
    }
  }
}

class LocationMessageHandler extends TPWebMessageHandler {
  @override
  String get name => 'location';

  @override
  handle({
    required Object? message,
    required WebUri? sourceOrigin,
    required bool isMainFrame,
    required Function(WebMessage reply)? onReply,
  }) async {
    Position? position;

    // might have permission issue
    try {
      position = await Get.find<GeoLocatorService>().position();
    } catch (error) {
      printError(info: error.toString());
    }

    onReply?.call(replyWebMessage(
      data: position?.toJson() ?? [],
    ));
  }
}

class DeviceInfoMessageHandler extends TPWebMessageHandler {
  @override
  String get name => 'deviceinfo';

  @override
  handle({
    required Object? message,
    required WebUri? sourceOrigin,
    required bool isMainFrame,
    required Function(WebMessage reply)? onReply,
  }) async {
    onReply?.call(replyWebMessage(
      data: Get.find<DeviceService>().baseDeviceInfo?.data ?? [],
    ));
  }
}

class OpenLinkMessageHandler extends TPWebMessageHandler {
  @override
  String get name => 'open_link';

  @override
  handle({
    required Object? message,
    required WebUri? sourceOrigin,
    required bool isMainFrame,
    required Function(WebMessage reply)? onReply,
  }) async {
    switch (message as String?) {
      case String uri:
        await TPRoute.openUri(uri: uri);
      case null:
        onReply?.call(replyWebMessage(data: false));
    }
  }
}

class NotifyMessageHandler extends TPWebMessageHandler {
  @override
  String get name => 'notify';

  @override
  Future<void> handle(
      {required Object? message,
      required WebUri? sourceOrigin,
      required bool isMainFrame,
      required Function(
        WebMessage replyWebMessage,
      )? onReply}) async {
    switch (message) {
      case Object json when json is Map<String, dynamic>:
        NotificationService.showNotification(
          title: json['title'],
          content: json['content'],
        );
        final String content = json['content'];
        if (RegExp(r'已訂閱(.+)').hasMatch(content)) {
          final String target = RegExp(r'已訂閱(.+)').firstMatch(content)!.group(1)!;
          Get.find<SubscriptionService>().addSubscription(title: target);
        } else if (RegExp(r'已取消訂閱(.+)').hasMatch(content)) {
          final String target = RegExp(r'已取消訂閱(.+)').firstMatch(content)!.group(1)!;
          Get.find<SubscriptionService>().removeSubscription(title: target);
        }
      default:
        onReply?.call(replyWebMessage(data: false));
        return;
    }
  }
}

class QRCodeScanMessageHandler extends TPWebMessageHandler {
  @override
  String get name => 'qr_code_scan';

  @override
  Future<void> handle({
    required Object? message,
    required WebUri? sourceOrigin,
    required bool isMainFrame,
    required onReply,
  }) async {
    final result = await Get.toNamed(TPRoute.qrCodeScan);
    onReply?.call(
      replyWebMessage(data: result),
    );
  }
}
