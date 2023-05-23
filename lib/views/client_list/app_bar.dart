import 'dart:io';

import 'package:flutter_chat_app/utils/iconfont.dart';
import 'package:flutter_chat_app/utils/initialization.dart';
import 'package:flutter_chat_app/utils/network_image.dart';
import 'package:flutter_chat_app/router/router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ClientListAppBar extends StatefulWidget {
  const ClientListAppBar({
    super.key,
    required this.onClose,
    required this.crossFadeState,
    required this.selectedCount,
    required this.onDelete,
  });

  final int selectedCount;
  final CrossFadeState crossFadeState;
  final VoidCallback onClose;
  final VoidCallback onDelete;

  @override
  State<StatefulWidget> createState() => _ClientListAppBarState();
}

class _ClientListAppBarState extends State<ClientListAppBar> {
  void _showDeleteDialog(BuildContext context) async {
    var isDeleted = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete ?"),
          content: const Text("Are you sure to delete the selected users ?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Done"),
            )
          ],
        );
      },
    );
    if (!mounted) return;
    if (isDeleted) {
      widget.onDelete();
    } else {
      widget.onClose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar.medium(
      pinned: true,
      stretch: true,
      expandedHeight: 122,
      centerTitle: true,
      leading: AnimatedCrossFade(
        alignment: Alignment.centerLeft,
        firstChild: Center(
          child: IconButton(
            onPressed: () => widget.onClose(),
            icon: const Icon(Iconfonts.bell, size: 24),
          ),
        ),
        secondChild: Center(
          child: IconButton(
            onPressed: () => widget.onClose(),
            icon: const Icon(Iconfonts.close, size: 24),
          ),
        ),
        crossFadeState: widget.crossFadeState,
        duration: const Duration(milliseconds: 400),
      ),
      title: AnimatedCrossFade(
        alignment: Alignment.center,
        firstChild: const Text(
          "Chat messages",
          style: TextStyle(
            // fontSize: 30,
            color: Color(0xFF606266),
            // fontWeight: FontWeight.w400,
          ),
        ),
        secondChild: Text(
          "Selected ${widget.selectedCount} items",
          style: const TextStyle(
            // fontSize: 30,
            color: Color(0xFF606266),
            // fontWeight: FontWeight.w400,
          ),
        ),
        crossFadeState: widget.crossFadeState,
        duration: const Duration(milliseconds: 400),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Iconfonts.search),
        ),
        AnimatedCrossFade(
          firstChild: IconButton(
            onPressed: () {
              context.go(RoutePaths.settings);
            },
            icon: const Icon(Iconfonts.setting, size: 24),
          ),
          secondChild: IconButton(
            onPressed: () => _showDeleteDialog(context),
            icon: const Icon(Iconfonts.clear, size: 24),
          ),
          crossFadeState: widget.crossFadeState,
          duration: const Duration(milliseconds: 400),
        ),
      ],
      // backgroundColor: Colors.white,
    );
  }

  final FocusNode _focusNode = FocusNode();
  final TextEditingController _textEditingController = TextEditingController();

  Widget _buildInput() {
    return Container(
      height: 36,
      alignment: Alignment.center,
      color: Colors.redAccent,
      child: TextField(
        maxLines: null,
        cursorColor: Colors.black,
        controller: _textEditingController,
        keyboardType: TextInputType.multiline,
        focusNode: _focusNode,
        onChanged: (text) {
          // if (text.isNotEmpty && !_showSendBtn) {
          //   setState(() => _showSendBtn = true);
          // } else if (text.isEmpty && _showSendBtn) {
          //   setState(() => _showSendBtn = false);
          // }
        },
        decoration: const InputDecoration(
          isDense: true,
          hintStyle: TextStyle(fontSize: 14.0),
          hintText: "Write a text message",
          contentPadding: EdgeInsets.all(5.0),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
          ),
          prefixIconColor: Colors.black,
        ),
      ),
    );
  }
}
