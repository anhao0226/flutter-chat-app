import 'package:animations/animations.dart';
import 'package:flutter_chat_app/models/ws_client_model.dart';
import 'package:flutter_chat_app/utils/dio_instance.dart';
import 'package:flutter_chat_app/utils/index.dart';
import 'package:flutter_chat_app/utils/initialization.dart';
import 'package:flutter_chat_app/router/router.dart';
import 'package:flutter_chat_app/utils/websocket.dart';
import 'package:flutter_chat_app/views/common_components/wrapper.dart';
import 'package:flutter_chat_app/views/settings/select_avator_view.dart';
import 'package:flutter_chat_app/views/settings/set_connection_info_view.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class InitClientInfoView extends StatefulWidget {
  const InitClientInfoView({super.key});

  @override
  State<InitClientInfoView> createState() {
    return _InitClientInfoViewState();
  }
}

class _InitClientInfoViewState extends State<InitClientInfoView> {
  bool _isLoggedIn = false;
  String? _host;
  String? _port;
  String? _nickname;
  bool _isLoading = false;

  List<ServerIconData> _icons = [];

  void _toggleLoginStatus() {
    setState(() {
      _isLoggedIn = !_isLoggedIn;
    });
  }

  void _handleSubmit(String avatarUrl) {
    var clientId = uuid.v4();

    var queryParameters = <String, dynamic>{};
    queryParameters['uid'] = clientId;
    queryParameters['nickname'] = _nickname;
    queryParameters['avatarUrl'] = avatarUrl;
    //
    var uri = Uri(
      path: "/ws",
      host: _host,
      port: int.parse(_port!),
      scheme: "ws",
      queryParameters: queryParameters,
    );
    //
    setState(() => _isLoading = true);
    WSUtil.instance.initWebSocket(uri.toString()).then((value) {
      setState(() => _isLoading = false);

      var client =
          WSClient(uid: clientId, nickname: _nickname!, avatarUrl: avatarUrl);
      //
      Initialization.writeHost(_host!);
      Initialization.writePort(_port!);
      Initialization.writeClientCache(client);
      dioInstance = Dio(BaseOptions(baseUrl: "http://$_host:$_port"));
      context.pushReplacement(RoutePaths.home);
    }).catchError((err) {
      setState(() => _isLoading = false);
      // _showErrorDialog(err);
    });
  }

  void _handleNext(String nickname, String host, String port) {
    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();
    var uri = Uri(scheme: "http", host: host, port: int.parse(port));
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
          duration: const Duration(seconds: 3),
          content: Text(err.toString()),
          action: SnackBarAction(
            label: "Close",
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).clearSnackBars();
            },
          ),
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
      // appBar: AppBar(title: const Text('Shared axis')),
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
                          onNext: (String avatarUrl) {
                            _handleSubmit(avatarUrl);
                          },
                          onBack: () {
                            setState(() => _isLoggedIn = !_isLoggedIn);
                          },
                        )
                      : SetConnectionInfoView(onNext: _handleNext),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
