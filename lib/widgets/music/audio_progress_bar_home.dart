import 'dart:math';

import 'package:flutter/material.dart';

import '/page_manager.dart';
import '/utils/get.dart';

class AudioProgressBarHome extends StatelessWidget {
  AudioProgressBarHome({super.key});

  final _progressNotifier = Get.the<PageManager>().progressNotifier;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ValueListenableBuilder(
      valueListenable: _progressNotifier,
      builder: (context, value, child) {
        final current = value.current.inSeconds.toDouble();
        final total = value.total.inSeconds.toDouble();
        return SliderTheme(
          data: SliderThemeData(
            thumbColor: colors.onSurface,
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 0),
            overlayShape: RoundSliderOverlayShape(overlayRadius: 0),
            activeTrackColor: colors.onSecondaryContainer,
            inactiveTrackColor: colors.outline,
            trackHeight: 1,
          ),
          child: Slider(
            value: min(current, total),
            max: total,
            onChanged: (_) {},
          ),
        );
      },
    );
  }
}
