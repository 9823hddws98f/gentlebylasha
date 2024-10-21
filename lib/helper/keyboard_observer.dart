import 'package:flutter/material.dart';

class KeyboardObserver extends WidgetsBindingObserver {
  final VoidCallback onKeyboardMinimized;

  KeyboardObserver({required this.onKeyboardMinimized});

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final keyboardVisible = WidgetsBinding.instance.window.viewInsets.bottom != 0;
      if (!keyboardVisible) {
        onKeyboardMinimized();
      }
    });
  }
}
