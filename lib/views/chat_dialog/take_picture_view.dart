// A screen that allows users to take a picture using a given camera.
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:desktop_app/views/chat_dialog/chat_dialog_view.dart';
import 'package:desktop_app/views/image_view.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

typedef ValueCallback<T> = void Function(T value);

class TakePictureView extends StatefulWidget {
  const TakePictureView({
    super.key,
    required this.camera,
    required this.onDone,
  });

  final ValueCallback onDone;
  final CameraDescription camera;

  @override
  State<StatefulWidget> createState() => _TakePictureViewState();
}

class _TakePictureViewState extends State<TakePictureView> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _showImage = false;
  String? _filepath;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.veryHigh,
    );
    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  void _handleTakePicture() async {
    // Take the Picture in a try / catch block. If anything goes wrong,
    // catch the error.
    try {
      // Ensure that the camera is initialized.
      await _initializeControllerFuture;
      // Attempt to take a picture and get the file `image`
      // where it was saved.
      final image = await _controller.takePicture();
      if (!mounted) return;
      _controller.pausePreview();
      setState(() => {_filepath = image.path, _showImage = true});
      // If the picture was taken, display it on a new screen.
      // widget.onDone(image.path);
    } catch (e) {
      // If an error occurs, log the error to the console.
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        title: const Text('Take a picture'),
        backgroundColor: Colors.transparent,
      ),
      // You must wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner until the
      // controller has finished initializing.

      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return Stack(
              alignment: Alignment.bottomCenter,
              children: [
                SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: Center(
                    child: SizedBox(
                      height: size.height,
                      child: CameraPreview(_controller),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 60,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(40),
                      ),
                      border: Border.all(
                        color: const Color(0xFFF5F7FA),
                        width: 3,
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.camera_alt,
                        color: Color(0xFFF5F7FA),
                      ),
                      onPressed: () => _handleTakePicture(),
                    ),
                  ),
                ),
                _showImage
                    ? Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          PhotoView(
                            onTapUp: (context, details, controllerValue) {
                              setState(() => _showImage = false);
                              _controller.resumePreview();
                            },
                            imageProvider: FileImage(
                              File(_filepath!),
                            ),
                          ),
                          Positioned(
                            right: 10,
                            bottom: 10,
                            child: InkWell(
                              onTap: () {
                                widget.onDone(_filepath);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(40),
                                  ),
                                  border: Border.all(
                                    color: const Color(0xFFF5F7FA),
                                    width: 2,
                                  ),
                                ),
                                child: const Text(
                                  "Send",
                                  style: TextStyle(
                                    color: Color(0xFFF5F7FA),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Container()
              ],
            );
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
