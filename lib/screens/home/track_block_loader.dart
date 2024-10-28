import 'package:flutter/material.dart';

import '/domain/models/audiofile_model.dart';
import '/domain/models/block.dart';
import '/screens/playlist_screen.dart';
import '/screens/track_list.dart';
import '/utils/app_theme.dart';
import '/utils/firestore_helper.dart';
import '/utils/tx_loader.dart';
import '/widgets/mp3_list_item.dart';
import '/widgets/tracklist_horizontal_widget.dart';
import 'block_header.dart';

class TrackBlockLoader extends StatefulWidget {
  const TrackBlockLoader(this.block, {super.key});

  final Block block;

  @override
  State<TrackBlockLoader> createState() => _TrackBlockLoaderState();

  static Widget shimmer() => Column(
        children: [
          BlockHeader.shimmer(),
          SizedBox(
            height: TrackListHorizontal.height,
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: AppTheme.sidePadding),
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              separatorBuilder: (_, __) => SizedBox(width: 16),
              itemBuilder: (_, __) => Mp3ListItem.shimmer(),
            ),
          ),
        ],
      );
}

class _TrackBlockLoaderState extends State<TrackBlockLoader> {
  final _txLoader = TxLoader();

  final _trackList = <AudioTrack>[];

  @override
  void initState() {
    super.initState();
    _txLoader.load(
      () => fetchTracksForBlock(widget.block.id),
      ensure: () => mounted,
      onError: (error) => debugPrint(error.toString()),
      onSuccess: (result) => setState(() => _trackList.addAll(result)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_txLoader.loading) {
      return TrackBlockLoader.shimmer();
    } else {
      if (_trackList.isEmpty) {
        return Column(
          children: [
            BlockHeader(title: widget.block.title),
            Text('No tracks available'),
          ],
        );
      } else {
        return Column(
          children: [
            BlockHeader(
              title: widget.block.title,
              seeAll: widget.block.blockType == 'series'
                  ? PlayListScreen(list: _trackList, block: widget.block)
                  : TrackListScreen(heading: widget.block.title, list: _trackList),
            ),
            TrackListHorizontal(
              trackList: _trackList,
              musicList: widget.block.blockType == 'series',
            ),
          ],
        );
      }
    }
  }
}
