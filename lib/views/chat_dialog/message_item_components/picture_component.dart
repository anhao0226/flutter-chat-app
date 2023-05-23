// PictureMessage
import 'dart:io';

import 'package:animations/animations.dart';
import 'package:flutter_chat_app/models/ws_message_model.dart';
import 'package:flutter_chat_app/utils/network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PictureMessageComponent extends StatefulWidget {
  const PictureMessageComponent({
    super.key,
    required this.message,
    required this.onLongPress,
    required this.status,
  });

  final WSMessage message;
  final VoidCallback onLongPress;
  final MessageStatus status;

  @override
  State<StatefulWidget> createState() => _PictureMessageComponentState();
}

class _PictureMessageComponentState extends State<PictureMessageComponent> {
  double _width = 60.0;
  double _height = 60.0;

  @override
  void initState() {
    super.initState();
    if (widget.message.extend != null) {
      var ratio = widget.message.extend!["ratio"];
      if (ratio > 1) {
        _width = 120;
        _height = _width / ratio;
      } else {
        _width = 60.0;
        _height = _width / ratio;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () => widget.onLongPress(),
      onTap: () {},
      child: Stack(
        children: [
          Container(
            width: _width,
            height: _height,
            clipBehavior: Clip.hardEdge,
            decoration: const BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
            child: OpenContainer(
              transitionType: ContainerTransitionType.fadeThrough,
              closedBuilder: (context, action) {
                return Image(
                  filterQuality: FilterQuality.medium,
                  image: ResizeImage(
                    CustomNetworkImage(
                      widget.message.text,
                      File(widget.message.filepath!),
                    ),
                    width: _width.toInt(),
                    height: _height.toInt(),
                  ),
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.white24,
                      child: const Center(
                        child: Icon(Icons.info, color: Colors.white70),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    return AnimatedCrossFade(
                      alignment: Alignment.center,
                      firstChild: child,
                      secondChild: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 1,
                        ),
                      ),
                      crossFadeState: loadingProgress == null
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      duration: const Duration(seconds: 1),
                    );
                  },
                );
              },
              openBuilder: (context, action) {
                return _PreviewImage(widget.message.filepath!);
              },
            ),
          ),
          _getLoadingUI(),
        ],
      ),
    );
  }

  Widget _getLoadingUI() {
    switch (widget.status) {
      case MessageStatus.normal:
        return Container();
      case MessageStatus.upload:
        return Positioned.fill(
          child: Container(
            color: Colors.white54,
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
          ),
        );
      case MessageStatus.download:
        return Container();
      case MessageStatus.error:
        return Positioned.fill(
          child: Container(
            color: Colors.white54,
            child: const Icon(
              Icons.info_outline,
              color: Color(0xFFF56C6C),
            ),
          ),
        );
      case MessageStatus.unread:
        return Container();

      default:
        return Container();
    }
  }
}

class _PreviewImage extends StatelessWidget {
  const _PreviewImage(this.filepath);

  final String filepath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      extendBodyBehindAppBar: true,
      body: PhotoView(
        filterQuality: FilterQuality.medium,
        loadingBuilder: (context, event) {
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 1,
            ),
          );
        },
        minScale: PhotoViewComputedScale.contained,
        // backgroundDecoration: const BoxDecoration(color: Colors.white),
        imageProvider: FileImage(File(filepath)),
      ),
    );
  }
}
