import 'dart:io';

import 'package:flutter_chat_app/utils/iconfont.dart';
import 'package:flutter_chat_app/utils/index.dart';
import 'package:flutter_chat_app/utils/initialization.dart';
import 'package:flutter_chat_app/router/router.dart';
import 'package:flutter_chat_app/utils/websocket.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StatusBarComponent extends StatefulWidget {
  const StatusBarComponent({
    super.key,
    this.actions = const [],
    this.onClose,
    this.isOpen = false,
  });

  final VoidCallback? onClose;
  final List<Widget> actions;
  final bool isOpen;

  @override
  State<StatefulWidget> createState() => _StatusBarComponentState();
}

class _StatusBarComponentState extends State<StatusBarComponent> {
  bool _isReconnecting = false;

  @override
  void initState() {
    super.initState();
  }

  void _handleWsReconnect() {
    setState(() => _isReconnecting = true);
    WSUtil.instance
        .initWebSocket(
      port: Initialization.port!,
      host: Initialization.host!,
      client: Initialization.client!,
    )
        .then((value) {
      logger.i(value);
    }).catchError((err) {
      setState(() => _isReconnecting = false);
      _showErrorDialog(err);
    });
  }

  void _showErrorDialog(Object err) async {
    var result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(err.toString()),
          actions: [
            TextButton(
              onPressed: () => context.pop(false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => context.pop(true),
              child: const Text("Setting"),
            )
          ],
        );
      },
    );
    if (mounted && result!) {
      context.push(RoutePaths.connectionSettings);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(seconds: 1),
      child: Container(
        height: widget.isOpen ? 0 : 60,
        clipBehavior: Clip.hardEdge,
        padding: const EdgeInsets.only(left: 10),
        decoration: const BoxDecoration(
          color: Color(0xFFF2F6FC),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(
              child: Text(
                "Websocket Service connection failed",
                style: TextStyle(color: Color(0xFF606266)),
              ),
            ),
            IconButton(
              onPressed: () => _handleWsReconnect(),
              icon: AnimatedCrossFade(
                alignment: Alignment.center,
                firstChild: const Icon(
                  Iconfonts.disconnect,
                  color: Color(0xFF967ADC),
                ),
                secondChild: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                ),
                crossFadeState: _isReconnecting
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
