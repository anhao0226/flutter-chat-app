// VoiceMessage
import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:desktop_app/models/ws_message_model.dart';
import 'package:desktop_app/utils/database.dart';
import 'package:desktop_app/utils/dio_instance.dart';
import 'package:desktop_app/utils/index.dart';
import 'package:desktop_app/views/chat_dialog/message_item_components/chat_message_item.dart';
import 'package:desktop_app/views/chat_dialog/message_item_components/show_status_component.dart';
import 'package:desktop_app/views/chat_dialog/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'shap_component.dart';

class VoiceMessageComponent extends StatefulWidget {
  const VoiceMessageComponent({
    super.key,
    required this.message,
    required this.isSelf,
    required this.onLongPress,
    required this.onPress,
    required this.theme,
  });

  final bool isSelf;
  final WSMessage message;
  final VoidCallback onPress;
  final VoidCallback onLongPress;
  final MessageTheme theme;

  @override
  State<StatefulWidget> createState() => _VoiceMessageComponentState();
}

class _VoiceMessageComponentState extends State<VoiceMessageComponent> {
  final AudioPlayer _player = AudioPlayer();
  final double _boxMinWidth = 80;
  final GlobalKey _key = GlobalKey();

  bool _isPlaying = false;
  double _boxWidth = 80;
  Duration _duration = const Duration(seconds: 0);

  @override
  void initState() {
    if (widget.message.extend != null &&
        widget.message.extend!.containsKey("duration")) {
      double duration = widget.message.extend!['duration'] * 1000;
      _duration = Duration(milliseconds: duration.toInt());
      double boxWidth = _duration.inSeconds * 10;
      _boxWidth = boxWidth > _boxMinWidth ? boxWidth : _boxMinWidth;
    }
    _player.onPlayerStateChanged.listen((event) {
      if (event == PlayerState.completed) {
        setState(() => {_isPlaying = false});
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _player.release();
    super.dispose();
  }

  void _handlePlayAudio() async {
    _boxWidth = _key.currentContext!.size!.width;
    if (_isPlaying) {
      await _player.stop();
    } else {
      await _player.play(DeviceFileSource(widget.message.filepath!));
    }
    setState(() => _isPlaying = !_isPlaying);
    widget.onPress();
  }

  @override
  Widget build(BuildContext context) {
    return ShapeWrapComponent(
      onLongPress: widget.onLongPress,
      theme: widget.theme,
      onTap: () => _handlePlayAudio(),
      child: AnimatedSize(
        curve: Curves.ease,
        alignment: Alignment.centerRight,
        duration: const Duration(milliseconds: 300),
        child: Stack(
          alignment: Alignment.center,
          children: [
            _buildContent(),
            widget.isSelf
                ? Positioned(top: 0, right: 0, child: _buildProcessBar())
                : Positioned(top: 0, left: 0, child: _buildProcessBar()),
          ],
        ),
      ),
    );
  }

  List<Widget> _neededReversed(bool value, List<Widget> widgets) {
    return value ? widgets : widgets.reversed.toList();
  }

  Widget _buildContent() {
    var components = [
      const SizedBox(width: 10),
      Text(
        "${_duration.inSeconds.toString()}''",
        style: TextStyle(color: widget.theme.fontColor),
      ),
      const SizedBox(width: 10),
      Icon(Icons.multitrack_audio, color: widget.theme.fontColor, size: 18),
      const SizedBox(width: 10),
    ];
    return SizedBox(
      width: _boxWidth,
      child: Row(
        key: _key,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: widget.theme.mainAxisAlignment,
        children: _neededReversed(widget.isSelf, components),
      ),
    );
  }

  Widget _buildProcessBar() {
    return AnimatedOpacity(
      opacity: _isPlaying ? 1 : 0,
      duration: const Duration(milliseconds: 300),
      child: AnimatedSize(
        duration: _duration,
        child: Container(
          height: 36,
          width: _isPlaying ? _boxWidth : 0,
          color: widget.theme.processBarColor,
        ),
      ),
    );
  }
}
