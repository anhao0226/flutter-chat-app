import 'package:flutter_chat_app/models/ws_message_model.dart';
import 'package:flutter/cupertino.dart';

class MultipleSelectNotifier extends ValueNotifier<bool> {
  factory MultipleSelectNotifier() {
    _instance ??= MultipleSelectNotifier._(false);
    return _instance!;
  }

  static MultipleSelectNotifier? _instance;

  static MultipleSelectNotifier get instance => MultipleSelectNotifier();

  MultipleSelectNotifier._(super._value);

   final _selectedItems = <Object>[];

  List<Object> get selectedItems => _selectedItems.toList();

  static final _listeners = <Object, Function>{};

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

  void add(Object value, {Function? listener}) {
    _count++;
    _selectedItems.add(value);
    notifyListeners();
    if (listener != null && !_listeners.containsKey(value)) {
      _listeners[value] = listener;
    }
  }

  void remove(Object value) {
    _count--;
    _selectedItems.remove(value);
    notifyListeners();
    if (_listeners.containsKey(value)) {
      _listeners.remove(value);
    }
    if (_selectedItems.isEmpty) exits();
  }
}
