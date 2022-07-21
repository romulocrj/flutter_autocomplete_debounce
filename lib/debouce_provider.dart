import 'dart:async';

typedef DebounceFunction<T> = Future<T> Function();

class DebounceProvider {
  Timer? _debounceTimer;
  Completer? _f;
  final Duration duration;

  DebounceProvider([this.duration = const Duration(milliseconds: 500)]);

  Future<T> debounce<T>(DebounceFunction<T> func) {
    _f ??= Completer<T>();
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer?.cancel();
    }
    _debounceTimer = Timer(duration, () {
      var result = func();
      _f?.complete(result);
      _f = null;
    });
    return _f!.future as Future<T>;
  }

  /// Cancels the timer.
  void dispose() {
    _debounceTimer?.cancel();
  }
}
