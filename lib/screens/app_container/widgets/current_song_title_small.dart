import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';

import '/page_manager.dart';
import '/utils/get.dart';

class CurrentSongTitleSmall extends StatelessWidget {
  CurrentSongTitleSmall({super.key});

  final _pageManager = Get.the<PageManager>();

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<MediaItem>(
        valueListenable: _pageManager.currentMediaItemNotifier,
        builder: (_, mediaItem, __) => Padding(
          padding: const EdgeInsets.only(top: 8.0),
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
      );
}
