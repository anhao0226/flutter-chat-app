import 'dart:io';

import 'package:flutter_chat_app/models/ws_client_model.dart';
import 'package:flutter_chat_app/utils/iconfont.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter_chat_app/utils/index.dart';
import 'package:flutter_chat_app/utils/network_image.dart';
import 'package:flutter/material.dart';

class AvatarComponent extends StatelessWidget {
  const AvatarComponent({
    super.key,
    required this.client,
    this.width = 46.0,
    this.height = 46.0,
    this.showBadge = true,
    this.online = false,
    this.selected = false,
  });

  final double width;
  final double height;
  final WSClient client;
  final bool showBadge;
  final bool selected;
  final bool online;

  @override
  Widget build(BuildContext context) {
    var child = _getAvatarUI();
    if (showBadge == true) {
      child = badges.Badge(
        position: badges.BadgePosition.bottomEnd(bottom: 0, end: 0),
        badgeAnimation: const badges.BadgeAnimation.slide(),
        badgeStyle: badges.BadgeStyle(
          badgeColor: online ? Colors.green : Colors.redAccent,
          padding: const EdgeInsets.all(6),
          borderSide: const BorderSide(width: 2, color: Colors.white),
        ),
        child: child,
      );
    }
    return child;
  }

  Widget _getAvatarUI() {
    return AnimatedCrossFade(
      firstChild: ClipOval(
        child: SizedBox(
          width: width,
          height: height,
          child: client.avatarUrl.isEmpty
              ? Image.asset("assets/icons/chat.png")
              : Image(
                  fit: BoxFit.fitWidth,
                  image: CustomNetworkImage(
                    client.avatarUrl,
                    File(client.avatarPath),
                  ),
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset("assets/icons/chat.png");
                  },
                ),
        ),
      ),
      secondChild: Container(
        width: width,
        height: height,
        decoration: const BoxDecoration(
          color: Color(0xFF6750A4),
          borderRadius: BorderRadius.all(Radius.circular(23)),
        ),
        child: const Icon(Iconfonts.check, color: Colors.white),
      ),
      crossFadeState:
          selected ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 300),
    );
  }
}
