import 'package:flutter/cupertino.dart';
import 'package:flutter_chat_app/router/router.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/ws_client_model.dart';
import '../models/ws_message_model.dart';
import '../providers/chat_provider.dart';
import '../providers/home_state_management.dart';
import '../views/chat_dialog/chat_dialog_view.dart';
import '../views/chat_dialog/user_chat_setting_view.dart';
import '../views/client_list/client_details_view.dart';
import '../views/client_list/my_home_page.dart';
import '../views/client_list/shared_clients_view.dart';
import '../views/image_view.dart';
import '../views/settings/init_client_info_view.dart';
import '../views/settings/manage_local_cache_view.dart';
import '../views/settings/permission_list_view.dart';
import '../views/settings/setting_view.dart';

typedef GoRouteWidgetBuilder = Widget Function(BuildContext, GoRouterState);

class GoRouteWrap extends GoRoute {
  GoRouteWrap({
    required String path,
    required GoRouteWidgetBuilder builder,
    super.name,
    super.parentNavigatorKey,
    super.redirect,
    super.routes = const <RouteBase>[],
  }) : super(
          path: path,
          pageBuilder: (context, state) {
            return CupertinoPage(child: builder(context, state));
          },
        );
}

final routes = <GoRoute>[
  GoRouteWrap(
    path: RoutePaths.home,
    builder: (context, state) {
      return ChangeNotifierProvider(
        create: (context) => HomeStateManagement.instance,
        child: const MyHomeView(),
      );
    },
  ),
  GoRouteWrap(
    path: RoutePaths.settings,
    builder: (context, state) => const SettingView(),
  ),
  GoRouteWrap(
    path: RoutePaths.permissionSettings,
    builder: (context, state) => const PermissionListView(),
  ),
  GoRouteWrap(
    path: RoutePaths.cacheManagement,
    builder: (context, state) => const ManageLocalCacheView(),
  ),
  GoRouteWrap(
    path: RoutePaths.clientDetails,
    builder: (context, state) {
      var client = state.extra as WSClient;
      return ClientDetailsView(client: client);
    },
  ),
  GoRouteWrap(
    path: RoutePaths.clientChatting,
    builder: (context, state) {
      var client = state.extra as WSClient;
      return ChangeNotifierProvider(
        create: (context) => ChatProvider(client),
        child: ChatDialogView(client: client),
      );
    },
  ),
  GoRouteWrap(
    path: RoutePaths.clientChatSettings,
    builder: (context, state) {
      var client = state.extra as WSClient;
      return UserChatSettingView(client: client);
    },
  ),
  GoRouteWrap(
    path: RoutePaths.clientShared,
    builder: (context, state) {
      var message = state.extra as WSMessage;
      return SharedClientListView(message: message);
    },
  ),
  GoRouteWrap(
    path: RoutePaths.imagePreview,
    builder: (context, state) {
      var filepath = state.extra as String;
      return ImageView(filepath: filepath);
    },
  ),
  GoRouteWrap(
    path: RoutePaths.init,
    builder: (context, state) => const InitClientInfoView(),
  ),
];
