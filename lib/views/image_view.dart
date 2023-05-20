import 'dart:io';

import 'package:desktop_app/utils/initialization.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

typedef ValueCallback<T> = void Function(T value);

class ImageView extends StatefulWidget {
  const ImageView({
    super.key,
    required this.filepath,
    this.onSend,
    this.onDelete,
    this.onShare,
  });

  final String filepath;
  final ValueCallback? onSend;
  final ValueCallback? onDelete;
  final ValueCallback? onShare;

  @override
  State<StatefulWidget> createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  final List<Widget> _actions = [];

  @override
  void initState() {
    if (widget.onDelete != null) {
      _actions.add(IconButton(
        onPressed: () => widget.onDelete!(""),
        icon: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ));
    }
    if (widget.onShare != null) {
      _actions.add(IconButton(
        onPressed: () => widget.onShare!(""),
        icon: const Icon(
          Icons.share,
          color: Colors.white,
        ),
      ));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        actions: _actions,
      ),
      body: Stack(
        alignment: Alignment.bottomRight,
        children: [
          PhotoView(
            minScale: PhotoViewComputedScale.contained,
            onTapUp: (context, details, controllerValue) {
              Navigator.pop(context);
            },
            loadingBuilder: (context, event) {
              return Container(
                color: Colors.black,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white60,
                    strokeWidth: 2.0,
                  ),
                ),
              );
            },
            imageProvider: FileImage(File(widget.filepath)),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSendButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSendButton() {
    if (widget.onSend == null) return Container();
    return InkWell(
      onTap: () {
        widget.onSend!("");
      },
      child: Container(
        width: 60.0,
        height: 34.0,
        margin: const EdgeInsets.only(left: 10),
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Color.fromRGBO(0, 0, 0, 0.2),
          borderRadius: BorderRadius.all(Radius.circular(17.0)),
        ),
        child: const Text(
          "Send",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
