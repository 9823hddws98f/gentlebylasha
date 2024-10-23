import 'package:flutter/material.dart';

import '../models/audiofile_model.dart';
import '../page_manager.dart';
import '../services/service_locator.dart';
import '../utils/global_functions.dart';
import 'mp3_card_list_item_width.dart';

class WidthTrackListHorizontal extends StatelessWidget {
  final List<AudioTrack> audiList;
  final Function() tap;
  bool musicList;
  Function panelFunction;

  WidthTrackListHorizontal(
      {super.key,
      required this.audiList,
      required this.tap,
      required this.musicList,
      required this.panelFunction});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 231,
      child: ListView.separated(
        padding: EdgeInsets.only(left: 16),
        scrollDirection: Axis.horizontal,
        itemCount: audiList.length,
        separatorBuilder: (BuildContext context, int index) {
          return SizedBox(width: 16);
        },
        itemBuilder: (BuildContext context, int index) {
          return Mp3ListItem(
              imageUrl: audiList[index].thumbnail,
              mp3Name: audiList[index].title,
              mp3Category: audiList[index].categories.isEmpty
                  ? ""
                  : audiList[index].categories[0].categoryName,
              mp3Duration: audiList[index].length,
              onPress: () {
                if (musicList) {
                  //getIt<PageManager>().init();
                  getIt<PageManager>().loadPlaylist(audiList, index);
                  panelFunction(false);
                  //Navigator.of(context).push( SlideFromBottomPageRoute(page: MusicPlayerScreen( audioFile: audiList[index],playList: true,)));
                } else {
                  playTrack(audiList[index]);
                  panelFunction(false);
                  //Navigator.of(context).push( SlideFromBottomPageRoute(page: MusicPlayerScreen( audioFile: audiList[index],playList: false,)));
                }
              });
        },
      ),
    );
  }
}
