import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';

import '/domain/services/audio_manager.dart';
import '/notifiers/progress_notifier.dart';
import '/utils/get.dart';

class AudioProgressBar extends StatelessWidget {
  AudioProgressBar({super.key});

  final _pageManager = Get.the<AudioManager>();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ValueListenableBuilder<ProgressBarState>(
      valueListenable: _pageManager.progressNotifier,
      builder: (context, value, _) => ProgressBar(
        progress: value.current,
        buffered: value.buffered,
        total: value.total,
        onSeek: _pageManager.seek,
        baseBarColor: colors.primary.withAlpha(70),
        progressBarColor: colors.primary,
        thumbColor: colors.primary,
      ),
    );
  }
}
