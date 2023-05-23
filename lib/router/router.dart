import 'package:go_router/go_router.dart';

import '../utils/initialization.dart';
import 'routes.dart';

class RoutePaths {
  RoutePaths._();

  static const String home = "/";

  static const String settings = "/settings";

  static const String permissionSettings = "/settings/permission";

  static const String cacheManagement = "/settings/cache";

  static const String clientDetails = "/client/details";

  static const String clientChatting = "/client/chatting";

  static const String clientChatSettings = "/client/chat/setting";

  static const String clientShared = "/client/shared";

  static const String imagePreview = "/image/preview";

  static const String init = "/init";
}

//
final router = GoRouter(
  routes: routes,
  initialLocation: RoutePaths.home,
  redirect: (context, state) async {
    return Initialization.isValidConfig() ? state.path : RoutePaths.init;
  },
);
