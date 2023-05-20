import 'dart:io';

import 'package:desktop_app/utils/initialization.dart';
import 'package:desktop_app/utils/index.dart';
import 'package:desktop_app/views/chat_dialog/input_bar_components/record_overlay_component.dart';
import 'package:desktop_app/views/request_permission_view.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';
import 'package:permission_handler/permission_handler.dart';

typedef DoneCallback<T> = void Function(T value, Map<String, dynamic> extend);

class RecordComponentView extends StatefulWidget {
  const RecordComponentView({
    super.key,
    required this.onDone,
  });

  final DoneCallback<String> onDone;

  @override
  State<StatefulWidget> createState() => _RecordComponentViewState();
}

class _RecordComponentViewState extends State<RecordComponentView> {
  final Record _record = Record();
  final Uuid _uuid = const Uuid();
  final List<double> _amplitude = [];
  final ScrollController _scrollController = ScrollController();

  int _endTime = 0;
  int _startTime = 0;
  late String _filepath;
  bool _recording = false;
  int _selectedButton = 0;

  @override
  void dispose() {
    _record.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _record
        .onAmplitudeChanged(const Duration(milliseconds: 200))
        .listen((event) {
      if (event.current <= 0) {
        var height = (100 + event.current) / 2;
        setState(() => _amplitude.add(height));
        overlayEntry!.markNeedsBuild();
        _scrollToEnd();
      }
    });

    _record.onStateChanged().listen(_handleStateChanged);
    super.initState();
  }

  void _scrollToEnd() {
    // _scrollController.animateTo(
    //   _scrollController.position.maxScrollExtent,
    //   duration: const Duration(milliseconds: 300),
    //   curve: Curves.easeIn,
    // );
  }

  void _handleStateChanged(RecordState event) async {
    if (event == RecordState.stop) {
      logger.i('stop');
    }
  }

  String _handleCreateTempFile() {
    return '${Initialization.temporaryDir.path}/${_uuid.v4()}.m4a';
  }

  void _handleLongPressEnd() async {
    logger.i("_handleRecordUp");
    if (!_recording) return;
    await _record.stop();
    overlayEntry!.remove();
    setState(() => {_recording = false, _amplitude.clear()});
    _endTime = DateTime.now().millisecondsSinceEpoch;
    var duration = (_endTime - _startTime) / 1000;
    if (duration > 2 && _selectedButton == 2) {
      _selectedButton = 0;
      widget.onDone(_filepath, {'duration': duration});
    } else {
      // delete temporary file
      File(_filepath).delete();
    }
    //
  }

  void _handleLongPressStart() async {
    var status = await Permission.microphone.status;
    if (status.isGranted) {
      _getOverlayView();
      setState(() => _recording = true);
      _filepath = _handleCreateTempFile();
      await _record.start(
        path: _filepath,
        encoder: AudioEncoder.aacLc, // by default
        bitRate: 128000, // by default
        samplingRate: 44100, // by default
      );
      _startTime = DateTime.now().millisecondsSinceEpoch;
    } else {
      if (!mounted) return;
      var isAllowed = await showDialog(
        context: context,
        builder: (context) => const RequestPermissionView(
          title: "Get microphone permission",
          describe: "Allow app to record audio",
        ),
      );
      if (isAllowed) isAllowed = await _record.hasPermission();
      if (!isAllowed) return;
    }
  }

  OverlayEntry? overlayEntry;

  void _getOverlayView() {
    overlayEntry ??= OverlayEntry(builder: (context) {
      return OverlayComponent(
        amplitude: _amplitude,
        selectStatus: _selectedButton,
      );
    });
    Overlay.of(context).insert(overlayEntry!);
  }

  // rect  [top, bottom, left]
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double width = screenSize.width;
    double height = screenSize.height;
    double bottom = height - 60;
    double top = bottom - 66;
    // logger.i(bottom);
    return GestureDetector(
        onLongPressStart: (detail) => _handleLongPressStart(),
        onLongPressEnd: (detail) => _handleLongPressEnd(),
        child: Listener(
          onPointerMove: (details) {
            if (details.position.dy > top && details.position.dy < bottom) {
              if (details.position.dx > 20 && details.position.dx < 86) {
                if (_selectedButton != 1) {
                  setState(() => _selectedButton = 1);
                  overlayEntry!.markNeedsBuild();
                }
              } else if (details.position.dx > (width - 86) &&
                  details.position.dx < width - 20) {
                if (_selectedButton != 2) {
                  setState(() => _selectedButton = 2);
                  overlayEntry!.markNeedsBuild();
                }
              } else if (_selectedButton != 0) {
                setState(() => _selectedButton = 0);
                overlayEntry!.markNeedsBuild();
              }
            }
          },
          child: Container(
            height: 36,
            alignment: Alignment.center,
            child: const Text("Hold to talk"),
          ),
        ));
  }
}
