import 'package:flutter/material.dart';

import '/page_manager.dart';
import '/utils/colors.dart';
import '/utils/get.dart';

class AudioProgressBarHome extends StatelessWidget {
  AudioProgressBarHome({super.key});

  final _progressNotifier = Get.the<PageManager>().progressNotifier;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
        valueListenable: _progressNotifier,
        builder: (context, value, child) {
          final colors = Theme.of(context).colorScheme;
          return SliderTheme(
            data: SliderThemeData(
              thumbColor: colors.onSurface,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 0),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 0),
              activeTrackColor: colors.onSurface,
              inactiveTrackColor: transparentWhite,
              trackHeight: 1,
            ),
            child: Slider(
              value: value.current.inSeconds.toDouble(),
              max: value.total.inSeconds.toDouble(),
              onChanged: (_) {},
            ),
          );
        },
      );
}
