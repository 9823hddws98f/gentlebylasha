import 'package:flutter/material.dart';

import '/domain/models/audiofile_model.dart';
import '/domain/models/block.dart';
import '/screens/playlist_screen.dart';
import '/screens/track_list.dart';
import '/utils/firestore_helper.dart';
import '/utils/tx_loader.dart';
import '/widgets/shimmerwidgets/shimmer_mp3_card_list_item_height.dart';
import '/widgets/tracklist_horizontal_widget.dart';
import 'block_header.dart';

class TrackListLoader extends StatefulWidget {
  const TrackListLoader(this.block, {super.key});

  final Block block;

  @override
  State<TrackListLoader> createState() => _TrackListLoaderState();
}

class _TrackListLoaderState extends State<TrackListLoader> {
  final _txLoader = TxLoader();

  final _trackList = <AudioTrack>[];

  @override
  void initState() {
    super.initState();
    fetchAndSetTracks(widget.block.id);
  }

  @override
  Widget build(BuildContext context) {
    if (_txLoader.loading) {
      return _buildShimmerListViewHeight();
    } else {
      if (_trackList.isEmpty) {
        return Column(
          children: [
            BlockHeader(
              title: widget.block.title,
            ),
            Text('No tracks available')
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
              onTap: () {},
              trackList: _trackList,
              musicList: widget.block.blockType == 'series',
            ),
          ],
        );
      }
    }
  }

  Widget _buildShimmerListViewHeight() => Column(
        children: [
          BlockHeader.shimmer(),
          SizedBox(
            height: 261,
            child: ListView.separated(
              padding: EdgeInsets.only(left: 16),
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              separatorBuilder: (context, index) => SizedBox(width: 16),
              itemBuilder: (context, index) => Mp3ListItemShimmerHeight(),
            ),
          ),
        ],
      );

  Future<void> fetchAndSetTracks(String blockId) async {
    _txLoader.load(
      () => fetchTracksForBlock(blockId),
      onError: (error) => debugPrint(error.toString()),
      onSuccess: (result) => setState(() {
        _trackList.addAll(result);
      }),
    );
  }
}
