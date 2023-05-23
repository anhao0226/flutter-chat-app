import 'dart:io';

import 'package:flutter_chat_app/providers/multiple_select_notifier.dart';
import 'package:flutter_chat_app/providers/ws_client_management.dart';
import 'package:flutter_chat_app/utils/initialization.dart';
import 'package:flutter_chat_app/utils/network_connectivity.dart';
import 'package:flutter_chat_app/utils/notification.dart';
import 'package:flutter_chat_app/utils/websocket.dart';
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
      watchNetworkConnectivity();
      //
      WSUtil.instance.onData.listen(WSClientManagement.instance.handleMessage);
      // 初始化通知服务
      if (!Platform.isLinux) {
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
