import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';

import '/notifiers/progress_notifier.dart';
import '../../../domain/services/audio_manager.dart';
import '/utils/get.dart';

class AudioProgressBar extends StatelessWidget {
  AudioProgressBar({super.key});

  final _pageManager = Get.the<AudioManager>();

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<ProgressBarState>(
        valueListenable: _pageManager.progressNotifier,
        builder: (context, value, _) => ProgressBar(
          progress: value.current,
          buffered: value.buffered,
          total: value.total,
          onSeek: _pageManager.seek,
          baseBarColor: Colors.white.withAlpha(70),
          progressBarColor: Colors.white,
          thumbColor: Colors.white,
        ),
      );
}
