import 'dart:convert';

import 'package:flutter_chat_app/models/ws_client_model.dart';
import 'package:flutter_chat_app/my_app.dart';
import 'package:flutter_chat_app/utils/app_lifecycle.dart';
import 'package:flutter_chat_app/utils/index.dart';
import 'package:flutter_chat_app/router/router.dart';
import 'package:flutter_chat_app/views/request_permission_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelName = "flutter_chat_app";

  static int _channelId = -1;

  static Future<void> initNotification() async {
    // android
    AndroidInitializationSettings initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');

    // ios
    var initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        onDidReceiveLocalNotification:
            (int id, String? title, String? body, String? payload) async {});

    //
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    //
    await _notificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);
  }

  static Future<NotificationDetails> notificationDetails() async {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        (_channelId++).toString(),
        _channelName,
        importance: Importance.max,
      ),
      iOS: const DarwinNotificationDetails(),
    );
  }

  static void _handleRequestPermission(Function successCallback) async {
    final status = await Permission.notification.status;
    if (status.isGranted) {
      successCallback();
      return;
    }

    var isAllowed = await showDialog(
      context: MyApp.navigatorKey.currentContext!,
      builder: (context) => const RequestPermissionView(
        title: "Get Notified!",
        describe: "Allow to send you beautiful notifications!",
      ),
    );
    //
    if (!isAllowed) return;
    await openAppSettings();
    AppLifeCycleUtil.onResumed((state) async {
      if (await Permission.notification.status.isGranted) {
        successCallback();
      }
      return true;
    });
  }

  static void showNotification(
      {int id = 0, String? title, String? body, String? payLoad}) async {
    _handleRequestPermission(() async {
      _notificationsPlugin.show(id, title, body, await notificationDetails(),
          payload: payLoad);
    });
  }

  static void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) {
    _toChatDialog(notificationResponse);
  }

  static void _toChatDialog(NotificationResponse notificationResponse) {
    var payload = jsonDecode(notificationResponse.payload!);

    logger.i(payload);
    var client = WSClient.formCache(payload);
    MyApp.navigatorKey.currentState
        ?.pushReplacementNamed(RoutePaths.clientChatting, arguments: client);
  }

  @pragma('vm:entry-point')
  void notificationTapBackground(NotificationResponse notificationResponse) {
    // handle action
    logger.i(notificationResponse);
    _toChatDialog(notificationResponse);
  }
}
