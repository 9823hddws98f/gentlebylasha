import 'package:flutter/cupertino.dart';
import 'package:sleeptales/utils/app_theme.dart';
import 'package:sleeptales/utils/get.dart';
import 'package:sleeptales/utils/tx_button.dart';
import 'package:sleeptales/widgets/app_scaffold/app_scaffold.dart';

import '/domain/services/audio_timer_service.dart';
import '/widgets/app_scaffold/adaptive_app_bar.dart';

class SleepTimerScreen extends StatefulWidget {
  const SleepTimerScreen({super.key});

  @override
  State<SleepTimerScreen> createState() => _SleepTimerScreenState();
}

class _SleepTimerScreenState extends State<SleepTimerScreen> {
  final _timerService = Get.the<AudioTimerService>();

  Duration _duration = Duration(hours: 1);

  @override
  Widget build(BuildContext context) => AppScaffold(
        appBar: (context, isMobile) => AdaptiveAppBar(
          title: 'Sleep Timer',
        ),
        body: (context, isMobile) => ValueListenableBuilder<AudioTimerState>(
            valueListenable: _timerService.timerState,
            builder: (context, state, _) => SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppTheme.sidePadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (state.isActive && state.remainingTime != Duration.zero)
                          Column(
                            children: [
                              Text(
                                'Time Remaining',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 12),
                              Text(
                                _formatTime(state),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 48,
                                ),
                              ),
                            ],
                          ),
                        SizedBox(height: 12),
                        Text(
                          'Playback will stop after this time',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20),
                        ),
                        Expanded(
                          child: CupertinoTimerPicker(
                            mode: CupertinoTimerPickerMode.hm,
                            initialTimerDuration: _duration,
                            onTimerDurationChanged: (d) => setState(() => _duration = d),
                          ),
                        ),
                        SizedBox(height: 12),
                        TxButton.filled(
                          label: Text(state.isActive ? 'Update Timer' : 'Set Timer'),
                          showSuccess: false,
                          onPressVoid: _setSleepTimer,
                        ),
                        if (state.isActive) ...[
                          SizedBox(height: 12),
                          TxButton.outlined(
                            label: Text('Cancel Timer'),
                            showSuccess: false,
                            onPressVoid: _cancelSleepTimer,
                          ),
                        ],
                      ],
                    ),
                  ),
                )),
      );

  String _formatTime(AudioTimerState state) =>
      '${state.remainingTime.inHours > 0 ? '${state.remainingTime.inHours}:' : ''}${state.remainingTime.inMinutes > 0 ? '${state.remainingTime.inMinutes.remainder(60).toString().padLeft(2, '0')}:' : ''}${state.remainingTime.inSeconds.remainder(60).toString().padLeft(2, '0')}';

  void _setSleepTimer() => _timerService.startTimer(_duration);

  void _cancelSleepTimer() => _timerService.cancelTimer();
}
