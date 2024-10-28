import 'package:flutter/material.dart';

import '/domain/models/audiofile_model.dart';
import '/domain/services/audio_panel_manager.dart';
import '/page_manager.dart';
import '/utils/app_theme.dart';
import '/utils/get.dart';
import '/utils/global_functions.dart';
import 'mp3_list_item.dart';

class TrackListHorizontal extends StatelessWidget {
  final List<AudioTrack> trackList;
  final bool isWide;
  final bool musicList;

  TrackListHorizontal({
    super.key,
    required this.trackList,
    this.isWide = false,
    this.musicList = false,
  });

  static const height = 208.0;

  final _audioPanelManager = Get.the<AudioPanelManager>();
  final _pageManager = Get.the<PageManager>();

  @override
  Widget build(BuildContext context) => SizedBox(
        height: height,
        child: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: AppTheme.sidePadding),
          separatorBuilder: (context, index) => SizedBox(width: 16),
          scrollDirection: Axis.horizontal,
          itemCount: trackList.length,
          itemBuilder: (context, index) {
            final track = trackList[index];
            return Mp3ListItem(
              imageUrl: track.thumbnail,
              name: track.title,
              isWide: isWide,
              category: track.categories.firstOrNull?.categoryName ?? '',
              duration: track.length,
              onTap: () async {
                if (musicList) {
                  _pageManager.loadPlaylist(trackList, index);
                } else {
                  playTrack(track);
                }
                _audioPanelManager.maximize(false);
              },
            );
          },
        ),
      );
}
