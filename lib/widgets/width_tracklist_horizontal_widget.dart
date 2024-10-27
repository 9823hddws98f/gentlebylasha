import 'package:flutter/material.dart';

import '/domain/models/audiofile_model.dart';
import '/domain/services/audio_panel_manager.dart';
import '/page_manager.dart';
import '/utils/app_theme.dart';
import '/utils/get.dart';
import '/utils/global_functions.dart';
import 'mp3_card_list_item_width.dart';

class WidthTrackListHorizontal extends StatelessWidget {
  final List<AudioTrack> trackList;
  final VoidCallback onTap;
  final bool musicList;

  WidthTrackListHorizontal({
    super.key,
    required this.trackList,
    required this.onTap,
    required this.musicList,
  });

  final _audioPanelManager = Get.the<AudioPanelManager>();
  final _pageManager = Get.the<PageManager>();

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 231,
        child: ListView.separated(
          padding: EdgeInsets.only(left: AppTheme.sidePadding),
          scrollDirection: Axis.horizontal,
          itemCount: trackList.length,
          separatorBuilder: (context, index) => SizedBox(width: 16),
          itemBuilder: (context, index) => Mp3ListItem(
            imageUrl: trackList[index].thumbnail,
            mp3Name: trackList[index].title,
            mp3Category: trackList[index].categories.isEmpty
                ? ''
                : trackList[index].categories[0].categoryName,
            mp3Duration: trackList[index].length,
            onPress: () {
              if (musicList) {
                _pageManager.loadPlaylist(trackList, index);
                _audioPanelManager.showPanel(false);
              } else {
                playTrack(trackList[index]);
                _audioPanelManager.showPanel(false);
              }
            },
          ),
        ),
      );
}
