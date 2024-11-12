import 'package:flutter/material.dart';

import '/domain/models/block_item/audio_track.dart';
import 'blocks/items/audio_block_item.dart';

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
          (index) => AudioBlockItem(
            key: Key('$index'),
            track: audiList[index],
            //   onTap: () {
            //   if (musicList) {
            //     getIt<PageManager>().loadPlaylist(audiList, index);
            //     panelFunction();
            //   } else {
            //     playTrack(audiList[index]);
            //     panelFunction();
            //   }
            // },
          ),
        ),
      ),
    );
  }
}
