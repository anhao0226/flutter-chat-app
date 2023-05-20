import 'package:desktop_app/providers/chat_provider.dart';
import 'package:desktop_app/utils/index.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StatusBarComponent extends StatefulWidget {
  const StatusBarComponent({
    super.key,
    this.actions = const [],
    this.onClose,
    required this.isOpen,
  });

  final bool isOpen;
  final VoidCallback? onClose;
  final List<Widget> actions;

  @override
  State<StatefulWidget> createState() => _StatusBarComponentState();
}

class _StatusBarComponentState extends State<StatusBarComponent> {
  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(seconds: 1),
      child: Container(
        height: widget.isOpen ? 60 : 0,
        clipBehavior: Clip.hardEdge,
        padding: const EdgeInsets.only(left: 10),
        decoration: const BoxDecoration(
          color: Color(0xFFF2F6FC),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
                child: Row(
              children: const [
                Icon(
                  Icons.link_off_outlined,
                  color: Color(0xFFF56C6C),
                ),
                SizedBox(width: 10),
                Text(
                  "Websocket Service connection failed",
                  style: TextStyle(
                    color: Color(0xFF606266),
                  ),
                ),
              ],
            )),
            IconButton(
              onPressed: () {
                context.read<ChatProvider>().hiddenStatusBar();
              },
              icon: const Icon(Icons.close),
            ),
          ],
        ),
      ),
    );
  }
}
