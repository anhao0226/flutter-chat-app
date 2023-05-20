import 'package:animations/animations.dart';
import 'package:desktop_app/models/ws_client_model.dart';
import 'package:desktop_app/utils/dio_instance.dart';
import 'package:desktop_app/utils/index.dart';
import 'package:desktop_app/utils/initialization.dart';
import 'package:desktop_app/utils/route.dart';
import 'package:desktop_app/utils/websocket.dart';
import 'package:desktop_app/views/common_components/wrapper.dart';
import 'package:desktop_app/views/settings/select_avator_view.dart';
import 'package:desktop_app/views/settings/set_connection_info_view.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

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
      Navigator.pushReplacementNamed(context, RouteName.homePage);
    }).catchError((err) {
      setState(() => _isLoading = false);
      // _showErrorDialog(err);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
      // appBar: AppBar(title: const Text('Shared axis')),
      body: Wrapper(
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
                          onNext: (String avatarUrl) {
                            _handleSubmit(avatarUrl);
                          },
                          onBack: () {
                            setState(() => _isLoggedIn = !_isLoggedIn);
                          },
                        )
                      : SetConnectionInfoView(
                          onNext: (nickname, host, port) {
                            _host = host;
                            _port = port;
                            _nickname = nickname;
                            dioInstance = Dio(
                                BaseOptions(baseUrl: "http://$_host:$_port"));
                            setState(() => _isLoggedIn = !_isLoggedIn);
                          },
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
