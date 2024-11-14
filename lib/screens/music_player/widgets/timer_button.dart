import 'package:flutter/material.dart';
import 'package:supa_carbon_icons/supa_carbon_icons.dart';

import '/domain/services/audio_timer_service.dart';
import '/helper/global_functions.dart';
import '/screens/reminder/widgets/timer_picker_screen.dart';
import '/utils/get.dart';

class TimerButton extends StatefulWidget {
  const TimerButton({super.key});

  @override
  State<TimerButton> createState() => _TimerButtonState();
}

class _TimerButtonState extends State<TimerButton> {
  final _audioTimerService = Get.the<AudioTimerService>();

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
        valueListenable: _audioTimerService.timerState,
        builder: (context, timerState, child) => IconButton(
          icon: timerState.isActive
              ? Text(
                  _formatTime(timerState.remainingTime.inSeconds),
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                )
              : const Icon(CarbonIcons.timer),
          onPressed: () => pushName(context, SleepTimerScreen()),
        ),
      );

  String _formatTime(int seconds) =>
      '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
}
