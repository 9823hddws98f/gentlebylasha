import 'package:flutter/material.dart';
import 'package:supa_carbon_icons/supa_carbon_icons.dart';

import '/domain/services/audio_manager.dart';
import '/screens/music_player/music_player_screen.dart';
import '/utils/get.dart';
import '/utils/modals.dart';

class DesktopMusicPreview extends StatelessWidget {
  final _pageManager = Get.the<AudioManager>();

  DesktopMusicPreview({super.key});

  @override
  Widget build(BuildContext context) => IconButton(
        onPressed: () => Modals.show(
          context,
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
