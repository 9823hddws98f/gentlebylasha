import 'package:flutter/material.dart';

import '/domain/services/service_locator.dart';
import '/notifiers/progress_notifier.dart';
import '/page_manager.dart';
import '/utils/colors.dart';

class AudioProgressBarHome extends StatelessWidget {
  const AudioProgressBarHome({super.key});
  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return ValueListenableBuilder<ProgressBarState>(
      valueListenable: pageManager.progressNotifier,
      builder: (_, value, __) {
        return SliderTheme(
            data: SliderTheme.of(context).copyWith(
              thumbColor: Colors.white,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 0),
              overlayColor: Colors.white.withAlpha(32),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 0),
              activeTrackColor: Colors.white,
              inactiveTrackColor: transparentWhite,
            ),
            child: Padding(
                padding: EdgeInsets.zero,
                child: Slider(
                  value: value.current.inSeconds.toDouble(),
                  min: 0.0,
                  max: value.total.inSeconds.toDouble(),
                  onChanged: (double value) {
                    //_audioPlayer.seek(Duration(seconds: value.toInt()));
                  },
                )));
      },
    );
  }
}
