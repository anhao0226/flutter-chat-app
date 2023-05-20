import 'dart:io';

import 'package:desktop_app/utils/iconfont.dart';
import 'package:desktop_app/utils/index.dart';
import 'package:desktop_app/utils/initialization.dart';
import 'package:desktop_app/utils/route.dart';
import 'package:desktop_app/utils/websocket.dart';
import 'package:flutter/material.dart';

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
    var url = Initialization.websocketConnUrl().toString();
    WSUtil.instance.initWebSocket(url).catchError((err) {
      setState(() => _isReconnecting = false);
      _showErrorDialog(err);
    });
  }

  void _showErrorDialog(Object err) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(err.toString()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, RouteName.initSettingPage);
              },
              child: const Text("Setting"),
            )
          ],
        );
      },
    );
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
