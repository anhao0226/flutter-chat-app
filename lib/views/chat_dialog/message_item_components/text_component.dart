// TextMessage
import 'package:desktop_app/models/ws_message_model.dart';
import 'package:desktop_app/views/chat_dialog/theme.dart';
import 'package:flutter/material.dart';

class TextMessageComponent extends StatefulWidget {
  const TextMessageComponent({
    super.key,
    required this.message,
    required this.theme,
  });

  final WSMessage message;
  final MessageTheme theme;

  @override
  State<StatefulWidget> createState() => _TextMessageComponentState();
}

class _TextMessageComponentState extends State<TextMessageComponent> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.message.text,
            style: TextStyle(
              fontSize: 14,
              color: widget.theme.fontColor,
            ),
          ),
        ],
      ),
    );
  }
}
