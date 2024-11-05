import 'package:flutter/material.dart';
import '/widgets/app_image.dart';

import '/constants/assets.dart';
import '/domain/services/audio_panel_manager.dart';
import '/page_manager.dart';
import '/utils/app_theme.dart';
import '/utils/get.dart';
import 'audio_play_button.dart';
import 'audio_progress_bar_home.dart';
import 'current_song_title_small.dart';

class MobileMusicPreview extends StatelessWidget {
  MobileMusicPreview({super.key});

  static const height = 72.0;

  final _pageManager = Get.the<PageManager>();
  final _audioPanelManager = Get.the<AudioPanelManager>();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.only(
          topLeft: AppTheme.smallBorderRadius.topLeft,
          topRight: AppTheme.smallBorderRadius.topRight,
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _audioPanelManager.panelController.open(),
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
                        builder: (context, mediaItem, child) => ClipRRect(
                          borderRadius: AppTheme.smallBorderRadius,
                          child: AppImage(
                            imageUrl: mediaItem.artUri.toString(),
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.asset(
                                Assets.placeholderImage,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(child: CurrentSongTitleSmall()),
                    SizedBox(width: 16),
                    AudioPlayButton(),
                  ],
                ),
              ),
            ),
          ),
          if (_pageManager.currentMediaItemNotifier.value.extras?["categories"] !=
              "Soundscape")
            AudioProgressBarHome()
        ],
      ),
    );
  }
}
