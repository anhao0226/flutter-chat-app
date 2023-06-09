import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter_chat_app/router/router.dart';
import 'package:flutter_chat_app/utils/index.dart';
import 'package:flutter_chat_app/views/chat_dialog/input_bar_components/actions/location/location_select_view.dart';
import 'package:flutter_chat_app/views/chat_dialog/take_picture_view.dart';
import 'package:flutter_chat_app/views/image_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

typedef ValueCallback<T> = void Function(T value, Map<String, dynamic> extend);

class ChatActionsComponent extends StatefulWidget {
  const ChatActionsComponent({
    super.key,
    required this.onSendImage,
    required this.onSendFile,
    required this.onSendLocation,
  });

  final ValueCallback onSendFile;
  final ValueCallback onSendImage;
  final ValueCallback onSendLocation;

  static const double width = 80;

  @override
  State<StatefulWidget> createState() => _ChatActionsComponentState();
}

class _ChatActionsComponentState extends State<ChatActionsComponent> {
  final ImagePicker picker = ImagePicker();

  void _handlePickImage() async {
    final XFile? image =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 40);
    if (!mounted) return;
    if (image == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ImageView(
          filepath: image.path,
          onSend: (_) => _handleSendImage(image.path),
        );
      },
    );
  }

  void _handlePickerFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      PlatformFile file = result.files.first;
      var extend = <String, dynamic>{};
      widget.onSendFile(file.path, extend);
    } else {
      // User canceled the picker
    }
  }

  void _handleSendImage(String filepath) async {
    var imgSize = await imageSize(filepath);
    var extend = <String, dynamic>{};
    extend["width"] = imgSize.width;
    extend["height"] = imgSize.height;
    extend["ratio"] = imgSize.width / imgSize.height;
    widget.onSendImage(filepath, extend);
  }

  void _handleSendLocation() {
    context.push(
      RoutePaths.selectLocation,
      extra: <String, dynamic>{"mapState": MapState.select},
    ).then((value) {
      if (value != null) {
        widget.onSendLocation("", value as Map<String, dynamic>);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ChatActionsComponent.width,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF967ADC),
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
            child: IconButton(
              onPressed: () => _handlePickImage(),
              icon: const Icon(
                Icons.picture_in_picture,
                color: Color(0xFFF5F7FA),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF967ADC),
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
            child: IconButton(
              onPressed: () async {
                final cameras = await availableCameras();
                final firstCamera = cameras.first;
                if (mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TakePictureView(
                        camera: firstCamera,
                        onDone: (filepath) {
                          _handleSendImage(filepath);
                        },
                      ),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.camera_alt, color: Color(0xFFF5F7FA)),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF967ADC),
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
            child: IconButton(
              onPressed: () => _handlePickerFile(),
              icon: const Icon(
                Icons.file_open,
                color: Color(0xFFF5F7FA),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF967ADC),
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
            child: IconButton(
              onPressed: _handleSendLocation,
              icon: const Icon(
                Icons.map,
                color: Color(0xFFF5F7FA),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
