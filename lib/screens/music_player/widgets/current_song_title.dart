import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';

import '/domain/services/service_locator.dart';
import '/page_manager.dart';

class CurrentSongTitle extends StatelessWidget {
  CurrentSongTitle({super.key});

  final _pageManager = getIt<PageManager>();

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<MediaItem>(
        valueListenable: _pageManager.currentMediaItemNotifier,
        builder: (_, mediaItem, __) => Center(
          child: Text(
            mediaItem.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 24,
            ),
          ),
        ),
      );
}
