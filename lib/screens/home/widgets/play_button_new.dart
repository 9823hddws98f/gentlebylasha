import 'package:flutter/material.dart';

import '/domain/services/service_locator.dart';
import '/notifiers/play_button_notifier.dart';
import '/page_manager.dart';

class PlayButtonNew extends StatelessWidget {
  const PlayButtonNew({super.key});
  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return ValueListenableBuilder<ButtonState>(
      valueListenable: pageManager.playButtonNotifier,
      builder: (_, value, __) => switch (value) {
        ButtonState.loading => Container(
            margin: EdgeInsets.all(8),
            height: 24,
            width: 24,
            child: const CircularProgressIndicator(
              color: Colors.white,
            ),
          ),
        ButtonState.paused => IconButton(
            icon: const Icon(Icons.play_arrow),
            iconSize: 24,
            onPressed: pageManager.play,
          ),
        ButtonState.playing => IconButton(
            icon: const Icon(Icons.pause),
            iconSize: 24,
            onPressed: pageManager.pause,
          )
      },
    );
  }
}
