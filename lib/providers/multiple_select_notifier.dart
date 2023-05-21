import 'package:flutter_chat_app/models/ws_message_model.dart';
import 'package:flutter/cupertino.dart';

class MultipleSelectNotifier extends ValueNotifier<bool> {
  static MultipleSelectNotifier? _instance;

  static MultipleSelectNotifier get instance => MultipleSelectNotifier();

  MultipleSelectNotifier._(super._value);

  factory MultipleSelectNotifier() {
    _instance ??= MultipleSelectNotifier._(false);
    return _instance!;
  }

  static final _selectedItems = <WSMessage>[];

  List<WSMessage> get selectedItems => _selectedItems.toList();

  static final _listeners = <WSMessage, Function>{};

  static int _count = 0;

  int get count => _count;

  void exits() {
    _doListeners(false);
    _listeners.clear();
    _selectedItems.clear();
    _count = 0;
    value = false;
  }

  void _doListeners(bool value) {
    if (_listeners.isNotEmpty) {
      _listeners.forEach((key, listener) {
        listener(value);
      });
    }
  }

  void enter() => value = true;

  void add(WSMessage message, {Function? listener}) {
    _count++;
    _selectedItems.add(message);
    notifyListeners();
    if (listener != null && !_listeners.containsKey(message)) {
      _listeners[message] = listener;
    }
  }

  void remove(WSMessage message) {
    _count--;
    _selectedItems.remove(message);
    notifyListeners();
    if (_listeners.containsKey(message)) {
      _listeners.remove(message);
    }
    if (_selectedItems.isEmpty) exits();
  }
}
