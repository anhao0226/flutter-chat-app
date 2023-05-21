import 'package:camera/camera.dart';
import 'package:flutter_chat_app/utils/index.dart';
import 'package:flutter_chat_app/views/chat_dialog/take_picture_view.dart';
import 'package:flutter_chat_app/views/image_view.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

typedef ValueCallback<T> = void Function(T value, Map<String, dynamic> extend);

class ChatActionsComponent extends StatefulWidget {
  const ChatActionsComponent({
    super.key,
    required this.onSend,
  });

  final ValueCallback onSend;

  static const double width = 80;

  @override
  State<StatefulWidget> createState() => _ChatActionsComponentState();
}

class _ChatActionsComponentState extends State<ChatActionsComponent> {
  final ImagePicker picker = ImagePicker();

  void _handlePickImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 40);
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

  void _handleSendImage(String filepath) async {
    var imgSize = await imageSize(filepath);
    var extend = <String, dynamic>{};
    extend["width"] = imgSize.width;
    extend["height"] = imgSize.height;
    extend["ratio"] = imgSize.width / imgSize.height;
    widget.onSend(filepath, extend);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ChatActionsComponent.width,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
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
        ],
      ),
    );
  }
}
