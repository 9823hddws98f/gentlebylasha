import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sleeptales/constants/assets.dart';
import 'package:sleeptales/utils/app_theme.dart';

import '/page_manager.dart';
import '/utils/get.dart';
import 'home_screen.dart';

class MusicPanelPreview extends StatelessWidget {
  MusicPanelPreview({super.key});

  static const height = 78.0;

  final _pageManager = Get.the<PageManager>();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colors.surface,
      child: SizedBox(
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => panelController.open(),
              child: Row(
                children: [
                  ValueListenableBuilder(
                    valueListenable: _pageManager.currentMediaItemNotifier,
                    builder: (context, mediaItem, child) {
                      return SizedBox(
                        width: 72,
                        height: 72,
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: AppTheme.smallBorderRadius.topLeft,
                          ),
                          child: CachedNetworkImage(
                            imageUrl: mediaItem.artUri.toString(),
                            width: 72,
                            height: 72,
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
                      );
                    },
                  ),
                  SizedBox(width: 5),
                  Expanded(child: CurrentSongTitleSmall()),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: 10),
                      ValueListenableBuilder(
                        valueListenable: _pageManager.progressNotifier,
                        builder: (context, progress, child) => Text(
                          "${progress.current.inMinutes.remainder(60).toString().padLeft(2, '0')}:${progress.current.inSeconds.remainder(60).toString().padLeft(2, '0')}",
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                      PlayButtonNew(),
                    ],
                  ),
                ],
              ),
            ),
            if (_pageManager.currentMediaItemNotifier.value.extras?["categories"] !=
                "Soundscape")
              AudioProgressBarHome()
          ],
        ),
      ),
    );
  }
}
