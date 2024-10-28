import 'package:carbon_icons/carbon_icons.dart';
import 'package:flutter/material.dart';

import '/notifiers/play_button_notifier.dart';
import '/page_manager.dart';
import '/utils/get.dart';

class AudioPlayButton extends StatelessWidget {
  AudioPlayButton({super.key, this.large = false});

  final bool large;

  final _pageManager = Get.the<PageManager>();

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<ButtonState>(
        valueListenable: _pageManager.playButtonNotifier,
        builder: (_, value, __) => switch (value) {
          ButtonState.loading => IconButton(
              icon: const CircularProgressIndicator(),
              padding: large ? EdgeInsets.all(24) : null,
              iconSize: large ? 32 : null,
              onPressed: null,
            ),
          ButtonState.paused => IconButton(
              icon: const Icon(CarbonIcons.play_filled_alt),
              padding: large ? EdgeInsets.all(24) : null,
              iconSize: large ? 32 : null,
              onPressed: _pageManager.play,
            ),
          ButtonState.playing => IconButton(
              icon: const Icon(CarbonIcons.pause_filled),
              padding: large ? EdgeInsets.all(24) : null,
              iconSize: large ? 32 : null,
              onPressed: _pageManager.pause,
            )
        },
      );
}
