import 'package:flutter/material.dart';

import '/domain/services/audio_timer_service.dart';
import '/helper/global_functions.dart';
import '/screens/reminder/widgets/timer_picker_screen.dart';
import '/utils/get.dart';

/// Opens the sleep timer; shows the minutes left while it runs.
class TimerButton extends StatelessWidget {
  const TimerButton({super.key});

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
        valueListenable: Get.the<AudioTimerService>().timerState,
        builder: (context, state, _) => IconButton(
          icon: state.isActive
              ? _minutesLeft(state.remainingTime)
              : const Icon(Icons.timer_outlined),
          onPressed: () => pushName(context, const SleepTimerScreen()),
        ),
      );

  Widget _minutesLeft(Duration remaining) {
    final minutes = (remaining.inSeconds / 60).ceil();
    return AnimatedSwitcher(
      duration: Durations.medium2,
      child: Text(
        '$minutes',
        key: ValueKey(minutes),
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
      ),
    );
  }
}
