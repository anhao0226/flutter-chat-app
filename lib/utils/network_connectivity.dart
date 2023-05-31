import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/utils/index.dart';
import 'package:flutter_chat_app/utils/websocket.dart';

import 'initialization.dart';

void watchNetworkConnectivity() {
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
          WSUtil.instance
              .initWebSocket(
            host: Initialization.host!,
            port: Initialization.port!,
            client: Initialization.client!,
          )
              .then((value) {
            logger.i(value);
          }).catchError((err) {
            logger.i(err);
          });
        }
        break;
      case ConnectivityResult.none:
        break;
    }
  });
}
