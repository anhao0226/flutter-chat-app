import 'dart:io';

import 'package:desktop_app/models/ws_message_model.dart';
import 'package:desktop_app/utils/network_image.dart';
import 'package:flutter/material.dart';

class SharedDialog extends StatefulWidget {
  const SharedDialog({super.key, required this.message});

  final WSMessage message;

  @override
  State<StatefulWidget> createState() => _SharedDialogState();
}

enum ShowType { text, picture, loading, tips, error }

class _SharedDialogState extends State<SharedDialog> {
  ShowType _showType = ShowType.tips;

  @override
  void initState() {
    super.initState();
    if (widget.message.type == MessageType.text) {
      _showType = ShowType.text;
    } else if (widget.message.type == MessageType.picture) {
      _showType = ShowType.picture;
    }
  }

  Widget _matchWidget() {
    switch (_showType) {
      case ShowType.text:
        return Container(
          color: Colors.white,
          child: Text(widget.message.text),
        );
      case ShowType.picture:
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.3,
          ),
          child: Image(
            image: CacheNetworkImage(
              widget.message.text,
              File(widget.message.filepath!),
            ),
          ),
        );
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Send to"),
      content: _matchWidget(),
      actionsAlignment: MainAxisAlignment.spaceAround,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text("Send"),
        )
      ],
    );
  }
}
