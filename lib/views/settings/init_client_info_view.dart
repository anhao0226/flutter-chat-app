import 'package:animations/animations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_chat_app/models/ws_client_model.dart';
import 'package:flutter_chat_app/utils/dio_instance.dart';
import 'package:flutter_chat_app/utils/index.dart';
import 'package:flutter_chat_app/utils/initialization.dart';
import 'package:flutter_chat_app/router/router.dart';
import 'package:flutter_chat_app/utils/websocket.dart';
import 'package:flutter_chat_app/views/common_components/wrapper.dart';
import 'package:flutter_chat_app/views/settings/picker_avator_view.dart';
import 'package:flutter_chat_app/views/settings/connection_setting_view.dart';

class InitClientInfoView extends StatefulWidget {
  const InitClientInfoView({super.key});

  @override
  State<InitClientInfoView> createState() {
    return _InitClientInfoViewState();
  }
}

class _InitClientInfoViewState extends State<InitClientInfoView> {
  bool _isLoggedIn = false;
  late String _host;
  late String _nickname;
  late int _port;
  bool _isLoading = false;

  List<ServerIconData> _icons = [];

  void _handleSubmit(String avatarUrl) {
    logger.i(avatarUrl);
    var clientId = uuid.v4();
    var wsClient =
        WSClient(uid: clientId, nickname: _nickname, avatarUrl: avatarUrl);
    setState(() => _isLoading = true);
    WSUtil.instance
        .initWebSocket(port: _port, host: _host, client: wsClient)
        .then((value) {
      setState(() => _isLoading = false);
      Initialization.writeServerConfig(_host, _port);
      Initialization.writeClientCache(wsClient);
      dioInstance = Dio(BaseOptions(baseUrl: "http://$_host:$_port"));
      context.pushReplacement(RoutePaths.home);
    }).catchError((err) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          showCloseIcon: true,
          duration: const Duration(seconds: 10),
          content: Text(err.toString()),
        ),
      );
    });
  }

  void _handleNext(String nickname, String host, int port) {
    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();
    var uri = Uri(scheme: "http", host: host, port: port);
    var instance = Dio(BaseOptions(baseUrl: uri.toString()));
    fetchIcons(instance: instance).then((value) {
      setState(() => _isLoading = false);
      logger.i(value);
      _host = host;
      _port = port;
      _nickname = nickname;
      dioInstance = instance;
      _icons = value;
      setState(() => _isLoggedIn = !_isLoggedIn);
    }).catchError((err) {
      logger.e(err is DioError);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          showCloseIcon: true,
          duration: const Duration(seconds: 10),
          content: Text(err.toString()),
        ),
      );
      setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
      body: Wrapper(
        bdColor: const Color.fromRGBO(0, 0, 0, 0.2),
        isLoading: _isLoading,
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                child: PageTransitionSwitcher(
                  reverse: !_isLoggedIn,
                  transitionBuilder: (
                    Widget child,
                    Animation<double> animation,
                    Animation<double> secondaryAnimation,
                  ) {
                    return SharedAxisTransition(
                      animation: animation,
                      secondaryAnimation: secondaryAnimation,
                      transitionType: SharedAxisTransitionType.horizontal,
                      child: child,
                    );
                  },
                  child: _isLoggedIn
                      ? PickerAvatarView(
                          icons: _icons,
                          onNext: _handleSubmit,
                          onBack: () {
                            setState(() => _isLoggedIn = !_isLoggedIn);
                          },
                        )
                      : ConnectionSettingsView(
                          onNext: _handleNext,
                          initStep: true,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
