import 'package:flutter/material.dart';

import '/domain/models/block_item/audio_track.dart';
import '/domain/services/audio_manager.dart';
import '/domain/services/audio_panel_manager.dart';
import '/utils/app_theme.dart';
import '/utils/get.dart';
import '/widgets/app_image.dart';
import 'audio_play_button.dart';
import 'audio_progress_bar_home.dart';
import 'current_song_info_small.dart';

class MobileMusicPreview extends StatelessWidget {
  MobileMusicPreview({super.key});

  static const height = 64.0;

  final _pageManager = Get.the<AudioManager>();
  final _audioPanelManager = Get.the<AudioPanelManager>();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => _audioPanelManager.panelController.open(),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: colors.secondaryContainer,
          borderRadius: BorderRadius.only(
            topLeft: AppTheme.smallBorderRadius.topLeft,
            topRight: AppTheme.smallBorderRadius.topRight,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.sidePadding,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: ValueListenableBuilder(
                        valueListenable: _pageManager.currentMediaItemNotifier,
                        builder: (context, mediaItem, child) {
                          if (mediaItem.extras == null) {
                            return const SizedBox.shrink();
                          }
                          return AppImage(
                            image: (mediaItem.extras?['track'] as AudioTrack).thumbnail,
                            fit: BoxFit.cover,
                            borderRadius: AppTheme.smallImageBorderRadius,
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(child: CurrentSongInfoSmall()),
                    SizedBox(width: 16),
                    AudioPlayButton(),
                  ],
                ),
              ),
            ),
            AudioProgressBarHome()
          ],
        ),
      ),
    );
  }
}
