import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_chat_app/models/ws_client_model.dart';
import 'package:flutter_chat_app/models/ws_message_model.dart';
import 'package:flutter_chat_app/providers/home_state_management.dart';
import 'package:flutter_chat_app/providers/multiple_select_notifier.dart';
import 'package:flutter_chat_app/providers/ws_client_management.dart';
import 'package:flutter_chat_app/utils/app_lifecycle.dart';
import 'package:flutter_chat_app/utils/initialization.dart';
import 'package:flutter_chat_app/providers/chat_provider.dart';
import 'package:flutter_chat_app/utils/notification.dart';
import 'package:flutter_chat_app/utils/route.dart';
import 'package:flutter_chat_app/utils/websocket.dart';
import 'package:flutter_chat_app/views/client_list/shared_clients_view.dart';
import 'package:flutter_chat_app/views/chat_dialog/user_chat_setting_view.dart';
import 'package:flutter_chat_app/views/image_view.dart';
import 'package:flutter_chat_app/views/settings/init_client_info_view.dart';
import 'package:flutter_chat_app/views/settings/permission_list_view.dart';
import 'package:flutter_chat_app/views/settings/manage_local_cache_view.dart';
import 'package:flutter_chat_app/views/client_list/my_home_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'color_schemes.dart';
import 'views/chat_dialog/chat_dialog_view.dart';
import 'views/settings/setting_view.dart';

void main() {
  Initialization.init().then((value) async {
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
    // 初始化通知服务
    await NotificationService.initNotification();
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
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final GlobalKey appKey = GlobalKey();

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    String routeName = settings.name!;
    if (!Initialization.isValidConfig() &&
        routeName != RouteName.pickerAvatarPage) {
      routeName = RouteName.initSettingPage;
    }

    late Widget page;
    switch (routeName) {
      case RouteName.homePage:
        page = ChangeNotifierProvider(
          create: (context) => HomeStateManagement.instance,
          child: const MyHomeView(),
        );
        break;
      case RouteName.chatDialogPage:
        var client = settings.arguments as WSClient;
        page = ChangeNotifierProvider(
          create: (context) => ChatProvider(client),
          child: ChatDialogView(client: client),
        );
        break;
      case RouteName.settingPage:
        page = const SettingView();
        break;
      case RouteName.initSettingPage:
        page = const InitClientInfoView();
        break;
      case RouteName.userChatSettingPage:
        var client = settings.arguments as WSClient;
        page = UserChatSettingView(client: client);
        break;
      case RouteName.initPermissionPage:
        page = const PermissionListView();
        break;
      case RouteName.manageLocalCachePage:
        page = const ManageLocalCacheView();
        break;
      case RouteName.imagePreviewPage:
        var filepath = settings.arguments as String;
        page = ImageView(filepath: filepath);
        break;
      case RouteName.shareUsersPage:
        var message = settings.arguments as WSMessage;
        page = SharedClientListView(message: message);
        break;
    }
    return CupertinoPageRoute(builder: (BuildContext context) => page);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    AppLifeCycleUtil.init(state);
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      key: MyApp.appKey,
      title: 'Flutter Demo',
      navigatorKey: MyApp.navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData.from(
        useMaterial3: true,
        colorScheme: lightColorScheme,
      ).copyWith(
        // iconButtonTheme: const IconButtonThemeData(),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          foregroundColor: Color(0xFF303133),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.white,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: <TargetPlatform, PageTransitionsBuilder>{
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
          },
        ),
      ),
      initialRoute: RouteName.homePage,
      onGenerateRoute: onGenerateRoute,
    );
  }
}
