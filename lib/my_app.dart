import 'dart:ffi';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/providers/chat_provider.dart';
import 'package:flutter_chat_app/providers/home_state_management.dart';
import 'package:flutter_chat_app/utils/app_lifecycle.dart';
import 'package:flutter_chat_app/utils/index.dart';
import 'package:flutter_chat_app/utils/initialization.dart';
import 'package:flutter_chat_app/utils/route.dart';
import 'package:flutter_chat_app/views/chat_dialog/chat_dialog_view.dart';
import 'package:flutter_chat_app/views/chat_dialog/user_chat_setting_view.dart';
import 'package:flutter_chat_app/views/client_list/my_home_page.dart';
import 'package:flutter_chat_app/views/client_list/shared_clients_view.dart';
import 'package:flutter_chat_app/views/image_view.dart';
import 'package:flutter_chat_app/views/settings/init_client_info_view.dart';
import 'package:flutter_chat_app/views/settings/manage_local_cache_view.dart';
import 'package:flutter_chat_app/views/settings/permission_list_view.dart';
import 'package:flutter_chat_app/views/settings/setting_view.dart';
import 'package:provider/provider.dart';

import 'color_schemes.dart';
import 'models/ws_client_model.dart';
import 'models/ws_message_model.dart';

ValueNotifier<bool> responsive = ValueNotifier(false);

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
      title: 'Flutter Demo',
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
      onGenerateRoute: (RouteSettings settings) {
        if (!Initialization.isValidConfig()) {
          return CupertinoPageRoute(builder: (_) => const InitClientInfoView());
        }
        return CupertinoPageRoute(
          builder: (_) => LayoutBuilder(
            builder: (context, constraints) {
              responsive.value = constraints.maxWidth > 460;
              return MyHome(width: constraints.maxWidth);
            },
          ),
        );
      },
    );
  }
}

class MyHome extends StatelessWidget {
  const MyHome({super.key, required this.width});

  final double width;

  Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    String routeName = settings.name!;
    if (!Initialization.isValidConfig() &&
        routeName != RouteName.pickerAvatarPage) {
      routeName = RouteName.initSettingPage;
    }

    late Widget page;

    MyRouteObserver.instance.currRoute(settings);

    switch (routeName) {
      case RouteName.homePage:
        page = !responsive.value
            ? ChangeNotifierProvider(
                create: (context) => HomeStateManagement.instance,
                child: const MyHomeView(),
              )
            : Container(
                alignment: Alignment.center,
                color: const Color(0xFFF5F7FA),
                child: Center(
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: Image.asset("assets/icons/chat.png"),
                  ),
                ),
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
  Widget build(BuildContext context) {
    return responsive.value
        ? Row(
            children: [
              SizedBox(
                width: 360.0,
                child: ChangeNotifierProvider(
                  create: (_) => HomeStateManagement.instance,
                  child: const MyHomeView(),
                ),
              ),
              Expanded(
                child: ClipRect(
                  child: Navigator(
                    key: MyApp.navigatorKey,
                    onGenerateRoute: onGenerateRoute,
                    initialRoute: RouteName.homePage,
                    observers: [MyRouteObserver.instance],
                  ),
                ),
              ),
            ],
          )
        : Navigator(
            key: MyApp.navigatorKey,
            onGenerateRoute: onGenerateRoute,
            initialRoute: RouteName.homePage,
          );
  }
}

class MyRouteObserver extends NavigatorObserver {
  static MyRouteObserver? _instance;

  static MyRouteObserver get instance => MyRouteObserver();

  MyRouteObserver._();

  factory MyRouteObserver() {
    _instance ??= MyRouteObserver._();
    return _instance!;
  }

  String? _name;

  RouteSettings? _settings;

  RouteSettings? get currSetting => _settings;

  void currRoute(RouteSettings settings) {
    _settings = settings;
  }

  bool isCurrent(String value) {
    return _name == value;
  }
}
