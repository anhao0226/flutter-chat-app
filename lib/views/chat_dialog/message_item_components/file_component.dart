// TextMessage
import 'package:flutter_chat_app/models/ws_message_model.dart';
import 'package:flutter_chat_app/views/chat_dialog/message_item_components/shap_component.dart';
import 'package:flutter_chat_app/views/chat_dialog/theme.dart';
import 'package:flutter/material.dart';

class FileMessageComponent extends StatefulWidget {
  const FileMessageComponent({
    super.key,
    required this.message,
    required this.theme,
    required this.onLongPress,
  });

  final WSMessage message;
  final MessageTheme theme;
  final VoidCallback onLongPress;

  @override
  State<StatefulWidget> createState() => _FileMessageComponentState();
}

class _FileMessageComponentState extends State<FileMessageComponent> {
  String _getFilename(String filepath) {
    return filepath.substring(filepath.lastIndexOf('/') + 1);
  }

  @override
  Widget build(BuildContext context) {
    return ShapeWrapComponent(
      onTap: () {},
      onLongPress: widget.onLongPress,
      theme: widget.theme,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  _getFilename(widget.message.text),
                  style: TextStyle(
                    fontSize: 14,
                    color: widget.theme.fontColor,
                  ),
                ),
              ),
            ),
            Icon(
              Icons.file_open_outlined,
              size: 40,
              color: widget.theme.fontColor,
            )
          ],
        ),
      ),
    );
  }
}
