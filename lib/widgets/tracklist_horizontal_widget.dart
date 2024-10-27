import 'package:flutter/material.dart';

import '/domain/models/audiofile_model.dart';
import '/domain/services/audio_panel_manager.dart';
import '/domain/services/service_locator.dart';
import '/page_manager.dart';
import '/utils/get.dart';
import '/utils/global_functions.dart';
import 'mp3_card_list_item_height.dart';

class TrackListHorizontal extends StatelessWidget {
  final List<AudioTrack> trackList;
  final VoidCallback onTap;
  final bool musicList;

  TrackListHorizontal({
    super.key,
    required this.trackList,
    required this.onTap,
    required this.musicList,
  });

  final _audioPanelManager = Get.the<AudioPanelManager>();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 231,
      child: ListView.separated(
        padding: EdgeInsets.only(left: 16),
        scrollDirection: Axis.horizontal,
        itemCount: trackList.length,
        separatorBuilder: (BuildContext context, int index) {
          return SizedBox(width: 16);
        },
        itemBuilder: (BuildContext context, int index) {
          return Mp3Item(
              imageUrl: trackList[index].thumbnail,
              mp3Name: trackList[index].title,
              mp3Category: trackList[index].categories.isEmpty
                  ? ""
                  : trackList[index].categories[0].categoryName,
              mp3Duration: trackList[index].length,
              tap: () {
                if (musicList) {
                  //getIt<PageManager>().init();
                  getIt<PageManager>().loadPlaylist(trackList, index);
                  _audioPanelManager.showPanel(false);
                  //Navigator.of(context).push( SlideFromBottomPageRoute(page: MusicPlayerScreen( audioFile: audiList[index],playList: true,)));
                } else {
                  playTrack(trackList[index]);
                  _audioPanelManager.showPanel(false);
                  //Navigator.of(context).push( SlideFromBottomPageRoute(page: MusicPlayerScreen( audioFile: audiList[index],playList: false,)));
                }
              });
        },
      ),
    );
  }

  // Widget _buildShimmerListViewHeight() => SizedBox(
  //       height: 231,
  //       child: ListView.builder(
  //         itemBuilder: (context, index) => _buildShimmerListViewHeightWithTitle(),
  //       ),
  //     );
}
