import 'dart:ui';

import 'package:flutter_chat_app/models/ws_message_model.dart';
import 'package:flutter_chat_app/providers/chat_provider.dart';
import 'package:flutter_chat_app/providers/multiple_select_notifier.dart';
import 'package:flutter_chat_app/utils/index.dart';
import 'package:flutter_chat_app/views/chat_dialog/input_bar_components/chat_actions_component.dart';
import 'package:flutter_chat_app/views/chat_dialog/input_bar_components/chat_record_component.dart';
import 'package:flutter_chat_app/views/animations/size_animation_wrap.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

typedef ChangedCallback = void Function(InputBarState type);

enum InputBarState {
  init(56),
  voice(196),
  action(136),
  multiple(56);

  const InputBarState(this.value);

  final double value;
}

typedef SendCallback = void Function(
    String text, MessageType msg, Map<String, dynamic>? extend);

class InputBarController extends ValueNotifier<InputBarState> {
  InputBarController() : super(InputBarState.init);

  double get height => value.value;

  void close() {
    value = InputBarState.init;
    notifyListeners();
  }
}

// ChatInputBarComponent
class InputBarComponent extends StatefulWidget {
  const InputBarComponent({
    super.key,
    required this.onSend,
    required this.controller,
  });

  final SendCallback onSend;
  final InputBarController controller;

  @override
  State<StatefulWidget> createState() => _InputBarComponentState();
}

class _InputBarComponentState extends State<InputBarComponent> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _textEditingController = TextEditingController();

  bool _showSendBtn = false;
  bool _isVoiceStatus = false;
  late InputBarState _state;

  @override
  void initState() {
    _state = widget.controller.value;
    widget.controller.addListener(() {
      setState(() => _state = widget.controller.value);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      left: 0,
      right: 0,
      bottom: -200 + _state.value,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Container(
        height: 200.0,
        color: Colors.white,
        child: _buildInputBox(),
      ),
    );
  }

  Widget _buildInputBox() {
    var multipleSelectState = context.watch<MultipleSelectNotifier>().value;
    if (multipleSelectState) _state = InputBarState.init;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        AnimatedCrossFade(
          firstChild: Container(
            height: 42,
            alignment: Alignment.center,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: const BoxDecoration(
              color: Color(0xFFF2F6FC),
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
            child: Row(
              children: [
                _buildPrefixButton(),
                _buildContent(),
                _buildSuffixButton(),
                _buildSendButton(),
              ],
            ),
          ),
          secondChild: _buildMultipleSelectUI(),
          crossFadeState: multipleSelectState
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
        _buildExpandUI(),
      ],
    );
  }

  Widget _buildContent() {
    return Expanded(
      child: AnimatedCrossFade(
        alignment: Alignment.center,
        firstCurve: Curves.ease,
        secondCurve: Curves.ease,
        firstChild: _buildInput(),
        secondChild: RecordComponentView(
          onDone: (filepath, extend) {
            widget.onSend(filepath, MessageType.voice, extend);
          },
        ),
        crossFadeState: _isVoiceStatus
            ? CrossFadeState.showSecond
            : CrossFadeState.showFirst,
        duration: const Duration(milliseconds: 200),
        reverseDuration: const Duration(milliseconds: 200),
      ),
    );
  }

  Widget _buildSuffixButton() {
    return InkWell(
      onTap: () {
        _focusNode.unfocus();
        widget.controller.value = InputBarState.action;
      },
      child: Container(
        height: 36.0,
        padding: const EdgeInsets.symmetric(horizontal: 14.0),
        child: const Icon(Icons.add_circle_outline,
            size: 20.0, color: Color(0xFF967ADC)),
      ),
    );
  }

  Widget _buildPrefixButton() {
    return InkWell(
      onTap: () {
        setState(() => _isVoiceStatus = !_isVoiceStatus);
        if (_state != InputBarState.init) widget.controller.close();
      },
      child: Container(
        height: 36.0,
        padding: const EdgeInsets.symmetric(horizontal: 14.0),
        child: Icon(
          _isVoiceStatus ? Icons.keyboard : Icons.keyboard_voice,
          size: 20.0,
          color: const Color(0xFF967ADC),
        ),
      ),
    );
  }

  Widget _buildExpandUI() {
    Widget component = Container();
    component = ChatActionsComponent(
      onSendImage: (filepath, extend) =>
          widget.onSend(filepath, MessageType.picture, extend),
      onSendFile: (filepath, extend) =>
          widget.onSend(filepath, MessageType.file, extend),
    );
    return component;
  }

  Widget _buildMultipleSelectUI() {
    var count = context.select((MultipleSelectNotifier value) => value.count);
    return Container(
      height: 56,
      color: Colors.white,
      alignment: Alignment.center,
      child: Text('Selected $count items'),
    );
  }

  Widget _buildInput() {
    return Container(
      height: 36,
      alignment: Alignment.center,
      child: TextField(
        maxLines: null,
        cursorColor: Colors.black,
        controller: _textEditingController,
        keyboardType: TextInputType.multiline,
        focusNode: _focusNode,
        onChanged: (text) {
          if (text.isNotEmpty && !_showSendBtn) {
            setState(() => _showSendBtn = true);
          } else if (text.isEmpty && _showSendBtn) {
            setState(() => _showSendBtn = false);
          }
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

  Widget _buildSendButton() {
    return AnimatedSize(
      curve: Curves.ease,
      duration: const Duration(milliseconds: 500),
      child: InkWell(
        onTap: () {
          widget.onSend(_textEditingController.text, MessageType.text, null);
          _textEditingController.clear();
          setState(() => _showSendBtn = false);
        },
        child: Container(
          width: _showSendBtn ? 50 : 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: const Icon(Icons.send, size: 24, color: Color(0xFF967ADC)),
        ),
      ),
    );
  }
}
