import 'package:flutter/material.dart';

class RouteName {
  RouteName._();

  // home page
  static const String homePage = "/";

  // chat dialog
  static const String chatDialogPage = "/chat_dialog";

  // setting
  static const String settingPage = "/setting";

  // user chat setting
  static const String userChatSettingPage = "/user_chat_setting";

  // init setting page
  static const String initSettingPage = "/init_setting_page";

  // init permission page
  static const String initPermissionPage = "/init_permission_page";

  // manage local cache page
  static const String manageLocalCachePage = "/manage_local_cache_page";

  // manage local cache page
  static const String imagePreviewPage = "/image_preview_page";

  // manage local cache page
  static const String shareUsersPage = "/share_users_page";

  // picker user avatar
  static const String pickerAvatarPage = "/picker_avatar_page";

  //
  static const String notFoundPage = "/not_found_page";
}

class SlideRightRoute extends PageRouteBuilder {
  final Widget page;

  SlideRightRoute({
    required this.page,
  }) : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
}
