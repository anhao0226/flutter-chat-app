import 'dart:ui';

import 'package:flutter_chat_app/utils/index.dart';

typedef VoidCallback = Future<bool> Function(AppLifecycleState state);

class AppLifeCycleUtil {
  static final _callbackMap = <AppLifecycleState, List<VoidCallback>>{};

  static AppLifecycleState _state = AppLifecycleState.inactive;

  static get currState => _state;

  static void init(AppLifecycleState state) async {
    _state = state;
    logger.i('APP ${state.toString()}');
    if (!_callbackMap.containsKey(state) || _callbackMap[state]!.isNotEmpty) {
      return;
    }
    List<VoidCallback> callbacks = _callbackMap[state]!;
    for (var i = 0; i < callbacks.length; i++) {
      if (await callbacks[i](state)) {
        _callbackMap[state]!.removeAt(i);
      }
    }
  }

  static void _push(AppLifecycleState state, VoidCallback callback) {
    if (!_callbackMap.containsKey(state)) {
      _callbackMap[state] = [callback];
    } else {
      _callbackMap[state]!.add(callback);
    }
  }

  static void onResumed(VoidCallback callback) =>
      _push(AppLifecycleState.resumed, callback);

  static void onInactive(VoidCallback callback) =>
      _push(AppLifecycleState.inactive, callback);

  static void onDetached(VoidCallback callback) =>
      _push(AppLifecycleState.detached, callback);

  static void onPaused(VoidCallback callback) =>
      _push(AppLifecycleState.paused, callback);
}
