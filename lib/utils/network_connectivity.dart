import 'package:connectivity_plus/connectivity_plus.dart';
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
          var wsUrl = Initialization.websocketConnUrl();
          WSUtil.instance.initWebSocket(wsUrl.toString()).then((value) {});
        }
        break;
      case ConnectivityResult.none:
        break;
    }
  });
}
