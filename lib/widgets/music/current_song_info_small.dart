import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';

import '/domain/models/block_item/audio_track.dart';
import '/domain/services/audio_manager.dart';
import '/utils/get.dart';

class CurrentSongInfoSmall extends StatelessWidget {
  CurrentSongInfoSmall({super.key});

  final _pageManager = Get.the<AudioManager>();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ValueListenableBuilder<MediaItem>(
      valueListenable: _pageManager.currentMediaItemNotifier,
      builder: (_, mediaItem, __) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            mediaItem.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          if (mediaItem.extras != null)
            Text(
              (mediaItem.extras!['track'] as AudioTrack).durationString,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }
}
