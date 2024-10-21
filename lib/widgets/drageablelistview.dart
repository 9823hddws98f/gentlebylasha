import 'package:flutter/material.dart';

import '../models/audiofile_model.dart';
import '../page_manager.dart';
import '../services/service_locator.dart';
import '../utils/global_functions.dart';
import 'mp3_card_list_item_width.dart';

class WidthTrackListHorizontalNew extends StatelessWidget {
  final List<AudioTrack> audiList;
  final Function() tap;
  final bool musicList;
  final Function panelFunction;

  const WidthTrackListHorizontalNew({
    super.key,
    required this.audiList,
    required this.tap,
    required this.musicList,
    required this.panelFunction,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 231,
      child: ReorderableListView(
        padding: EdgeInsets.only(left: 16),
        scrollDirection: Axis.horizontal,
        onReorder: (int oldIndex, int newIndex) {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final item = audiList.removeAt(oldIndex);
          audiList.insert(newIndex, item);
        },
        children: List.generate(
          audiList.length,
          (index) => Mp3ListItem(
            key: Key('$index'),
            imageUrl: audiList[index].thumbnail,
            mp3Name: audiList[index].title,
            mp3Category: audiList[index].categories.isEmpty
                ? ""
                : audiList[index].categories[0].categoryName,
            mp3Duration: audiList[index].length,
            onPress: () {
              if (musicList) {
                getIt<PageManager>().loadPlaylist(audiList, index);
                panelFunction();
              } else {
                playTrack(audiList[index]);
                panelFunction();
              }
            },
          ),
        ),
      ),
    );
  }
}
