import 'package:flutter/material.dart';
import 'package:number_ticker/number_ticker.dart';
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
  static const _showMinutes = true;
  static const _curve = Easing.standard;
  static const _duration = Durations.long4;

  final _audioTimerService = Get.the<AudioTimerService>();
  final _tickerController = NumberTickerController();
  bool _isActive = false;

  @override
  void initState() {
    super.initState();
    _audioTimerService.timerState.addListener(_updateTicker);
  }

  @override
  void dispose() {
    _audioTimerService.timerState.removeListener(_updateTicker);
    _tickerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IconButton(
        icon: _isActive ? _buildTicker() : const Icon(CarbonIcons.timer),
        onPressed: () => _navigateToTimerPicker(context),
      );

  Widget _buildTicker() => NumberTicker(
        controller: _tickerController,
        initialNumber: _formatTime(
          _audioTimerService.timerState.value.remainingTime.inSeconds,
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 20,
        ),
        curve: _curve,
        duration: _duration,
      );

  void _updateTicker() {
    final state = _audioTimerService.timerState.value;
    if (state.isActive && !_isActive) {
      setState(() => _isActive = true);
    } else if (!state.isActive && _isActive) {
      setState(() => _isActive = false);
    }
    _tickerController.number = _formatTime(
      state.remainingTime.inSeconds,
    );
  }

  void _navigateToTimerPicker(BuildContext context) {
    pushName(context, const SleepTimerScreen());
  }

  double _formatTime(int seconds) =>
      _showMinutes ? (seconds / 60).ceilToDouble() : seconds.toDouble();
}
