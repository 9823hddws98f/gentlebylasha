import 'package:flutter/foundation.dart';

class PlayButtonNotifier extends ValueNotifier<ButtonState> {
  static const _initialValue = ButtonState.playing;
  PlayButtonNotifier() : super(_initialValue);
}

enum ButtonState {
  paused,
  playing,
  loading,
}
