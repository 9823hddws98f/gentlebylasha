import 'dart:async';

import 'package:flutter/foundation.dart';

import '/utils/get.dart';
import 'audio_manager.dart';

class AudioTimerState {
  final bool isActive;
  final Duration remainingTime;
  final Duration totalDuration;

  const AudioTimerState({
    this.isActive = false,
    this.remainingTime = Duration.zero,
    this.totalDuration = Duration.zero,
  });

  AudioTimerState copyWith({
    bool? isActive,
    Duration? remainingTime,
    Duration? totalDuration,
  }) =>
      AudioTimerState(
        isActive: isActive ?? this.isActive,
        remainingTime: remainingTime ?? this.remainingTime,
        totalDuration: totalDuration ?? this.totalDuration,
      );

  double get progress => totalDuration.inSeconds == 0
      ? 0
      : remainingTime.inSeconds / totalDuration.inSeconds;
}

class AudioTimerService {
  AudioTimerService._();

  static final instance = AudioTimerService._();

  final _pageManager = Get.the<AudioManager>();
  final timerState = ValueNotifier<AudioTimerState>(AudioTimerState());

  Timer? _stopTimer;
  Timer? _countdownTimer;

  void startTimer(Duration duration) {
    cancelTimer();

    timerState.value = AudioTimerState(
      isActive: true,
      remainingTime: duration,
      totalDuration: duration,
    );

    _stopTimer = Timer(duration, () {
      _pageManager.pause();
      _resetState();
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final remaining = timerState.value.remainingTime;
      if (remaining.inSeconds <= 0) {
        cancelTimer();
        return;
      }

      timerState.value = timerState.value.copyWith(
        remainingTime: remaining - const Duration(seconds: 1),
      );
    });
  }

  void cancelTimer() {
    _stopTimer?.cancel();
    _countdownTimer?.cancel();
    _stopTimer = null;
    _countdownTimer = null;
    _resetState();
  }

  void _resetState() {
    timerState.value = AudioTimerState();
  }

  void dispose() {
    cancelTimer();
    timerState.dispose();
  }
}
