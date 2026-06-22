import 'dart:async';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

class NotificationService extends GetxService {
  static int _id = 0;
  static final FlutterLocalNotificationsPlugin _notificationInstance = FlutterLocalNotificationsPlugin();

  // Android 通知通道的常數，避免使用魔術字串。
  static const String _androidChannelId = 'TownPass_android_notification_id';
  static const String _androidChannelName = 'TownPass android notification channel name';
  static const String _androidChannelDescription = 'TownPass notifications for important updates'; // 可以考慮添加描述，雖然目前未使用

  Future<NotificationService> init() async {
    await _notificationInstance.getNotificationAppLaunchDetails();

    final InitializationSettings initializationSettings = InitializationSettings(
      android: const AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        onDidReceiveLocalNotification: (int id, String? title, String? body, String? payload) async {
          // add action when notification clicked
        },
      ),
    );

    await _notificationInstance.initialize(initializationSettings);

    return this;
  }

  static Future<void> requestPermission() async {
    if (Platform.isAndroid) {
      await _notificationInstance.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    } else if (Platform.isIOS) {
      await _notificationInstance.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
  }

  static Future<void> showNotification({String? title, String? content}) async {
    await _notificationInstance.show(
      _id++,
      title,
      content,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannelId, // 使用常數
          _androidChannelName, // 使用常數
          // 可選：如果需要，可以在這裡添加 channelDescription: _androidChannelDescription,
          importance: Importance.max,
          priority: Priority.max,
        ),
      ),
    );
  }
}