import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_chat_app/providers/multiple_select_notifier.dart';
import 'package:flutter_chat_app/providers/ws_client_management.dart';
import 'package:flutter_chat_app/utils/initialization.dart';
import 'package:flutter_chat_app/utils/notification.dart';
import 'package:flutter_chat_app/utils/websocket.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'my_app.dart';

void main() {
  Initialization.init().then(
    (value) async {
      // 设置沉浸式状态栏
      SystemChrome.setSystemUIOverlayStyle(
          const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
      // 监听网络变化
      Connectivity().onConnectivityChanged.listen((event) {
        WSUtil.instance.connectivity.value = false;
        switch (event) {
          case ConnectivityResult.vpn:
          case ConnectivityResult.wifi:
          case ConnectivityResult.ethernet:
          case ConnectivityResult.bluetooth:
          case ConnectivityResult.mobile:
          case ConnectivityResult.other:
            // 初始化Websocket服务
            if (Initialization.isValidConfig()) {
              var wsUrl = Initialization.websocketConnUrl();
              WSUtil.instance.initWebSocket(wsUrl.toString()).then((value) {});
            }
            break;
          case ConnectivityResult.none:
            break;
        }
      });

      //
      WSUtil.instance.onData.listen(WSClientManagement.instance.handleMessage);

      if (!Platform.isLinux) {
        // 初始化通知服务
        await NotificationService.initNotification();
      }

      //
      runApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => MultipleSelectNotifier.instance,
            ),
            ChangeNotifierProvider(
              create: (_) => WSClientManagement.instance,
            )
          ],
          child: const MyApp(),
        ),
      );
    },
  );
}
