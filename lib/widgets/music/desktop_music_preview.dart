import 'package:carbon_icons/carbon_icons.dart';
import 'package:flutter/material.dart';
import 'package:sleeptales/screens/music_player/music_player_screen.dart';

import '/page_manager.dart';
import '/utils/get.dart';

class DesktopMusicPreview extends StatelessWidget {
  DesktopMusicPreview({super.key});

  final _pageManager = Get.the<PageManager>();

  @override
  Widget build(BuildContext context) => IconButton(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => AlertDialog(
            contentPadding: EdgeInsets.all(32),
            content: SizedBox(
              height: 500,
              width: 900,
              child: MusicPlayerScreen(),
            ),
          ),
        ),
        icon: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(CarbonIcons.music),
            AnimatedSize(
              duration: Durations.medium2,
              curve: Easing.standard,
              alignment: Alignment.centerLeft,
              child: ValueListenableBuilder(
                valueListenable: _pageManager.currentMediaItemNotifier,
                builder: (_, mediaItem, __) => mediaItem.id.isEmpty
                    ? SizedBox()
                    : Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          mediaItem.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      );
}
