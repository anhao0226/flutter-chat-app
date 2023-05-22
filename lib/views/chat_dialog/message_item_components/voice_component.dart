// VoiceMessage

// import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_chat_app/models/ws_message_model.dart';
import 'package:flutter_chat_app/utils/index.dart';
import 'package:flutter_chat_app/views/chat_dialog/theme.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
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
      double boxWidth = _duration.inMilliseconds / 100;
      _boxWidth = boxWidth > _boxMinWidth ? boxWidth : _boxMinWidth;
    }
    _player.playerStateStream.listen((state) {
      switch(state.processingState) {
        case ProcessingState.idle:
          logger.i("idle");
          break;
        case ProcessingState.loading:
          logger.i("loading");
          break;
        case ProcessingState.buffering:
          logger.i("buffering");
          break;
        case ProcessingState.ready:
          logger.i("ready");
          break;
        case ProcessingState.completed:
          setState(() => {_isPlaying = false});
          break;
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _handlePlayAudio() async {
    _boxWidth = _key.currentContext!.size!.width;
    if (_isPlaying) {
      await _player.stop();
    } else {
      await _player.setFilePath(widget.message.filepath!);
      setState(() {
        _isPlaying = true;
        _duration = _player.duration!;
      });
      await _player.play();
    }
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
    return AnimatedSize(
      duration: _duration,
      reverseDuration: Duration.zero,
      child: Container(
        height: 36,
        width: _isPlaying ? _boxWidth : 0,
        color: widget.theme.processBarColor,
      ),
    );

    //   AnimatedOpacity(
    //   opacity: _isPlaying ? 1 : 0,
    //   duration: const Duration(milliseconds: 300),
    //   child:
    // );
  }
}
