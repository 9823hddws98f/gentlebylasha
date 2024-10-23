import 'package:flutter/foundation.dart';

class TxLoader with ChangeNotifier {
  int _operation = 0;
  bool _loading = false;

  bool get loading => _loading;

  /// Load data using the provided `loader` function. Only the results of the
  /// latest call to `load` will trigger the finalizing `on` callbacks.
  Future<void> load<T>(
    Future<T> Function() loader, {
    bool Function()? ensure,
    void Function(T result)? onSuccess,
    void Function(Object error)? onError,
    void Function()? onStart,
    void Function()? onFinish,
    void Function(bool loading)? onStartFinish,
  }) async {
    final op = ++_operation;
    _loading = true;
    onStartFinish?.call(true);
    onStart?.call();
    notifyListeners();
    try {
      final result = await loader();
      if (op == _operation && (ensure == null || ensure())) {
        onSuccess?.call(result);
      }
    } catch (error) {
      if (op == _operation && (ensure == null || ensure())) {
        if (onError == null) rethrow;
        onError(error);
      }
    } finally {
      if (op == _operation && (ensure == null || ensure())) {
        _loading = false;
        onFinish?.call();
        onStartFinish?.call(false);
        notifyListeners();
      }
    }
  }
}
