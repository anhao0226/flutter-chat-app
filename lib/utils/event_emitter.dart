typedef WhereCallback<T> = bool Function(T value);

typedef ListenerCallback<T> = void Function(T value);

typedef ValueCallback<T> = void Function(T value);


class Listener {

}


class EventEmitter<T> {
  EventEmitter<T>? _instance;

  Map<String, List<ValueCallback<T>>>? _events;

  EventEmitter() {
    _instance ??= this;
    _events ??= <String, List<ValueCallback<T>>>{};
  }

  EventEmitter<T> instance() => _instance!;

  void _addListener(String key, ValueCallback<T> listener) {
    if (_checkExisting(key)) {
      _events![key] = <ValueCallback<T>>[listener];
    } else {
      _events![key]!.add(listener);
    }
  }

  bool _checkExisting(String key) {
    return _events != null && _events!.containsKey(key);
  }

  void doEvents(String key, T value) {
    if (_events!.containsKey(key) && _events![key]!.isNotEmpty) {
      var events = _events![key] ?? [];
      for (var event in events) {
        event(value);
      }
    }
  }

  void on({
    required String name,
    required ListenerCallback<T> listener,
    WhereCallback<T>? execCond,
  }) {
    _addListener(name, (value) {
      if (execCond != null && execCond(value)) return;
      listener(value);
    });
  }
}
