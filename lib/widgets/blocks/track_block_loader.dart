import 'package:flutter/material.dart';

import '/domain/models/block/block.dart';
import '/domain/models/block_item/audio_playlist.dart';
import '/domain/models/block_item/audio_track.dart';
import '/screens/home/searchable_tracks_screen.dart';
import '/utils/app_theme.dart';
import '/widgets/blocks/items/audio_block_item.dart';
import '/widgets/blocks/items/hero_block_item.dart';
import '/widgets/blocks/items/playlist_block_item.dart';
import '/widgets/blocks/track_block_items_loader.dart';
import '/widgets/blocks/widgets/block_header.dart';
import 'config_of_page.dart';

class TrackBlockLoader extends StatelessWidget {
  const TrackBlockLoader(this.block, {super.key});

  final Block block;

  @override
  Widget build(BuildContext context) => switch (block.type) {
        BlockType.hero => TrackBlockItemsLoader<AudioTrack>(
            block: block,
            builder: (_, items) =>
                items.isNotEmpty ? HeroBlockItem(track: items.first) : Container(),
            loadingBuilder: _shimmer,
          ),
        BlockType.series => TrackBlockItemsLoader<AudioPlaylist>(
            block: block,
            builder: (_, items) => _buildSeriesBlock(items),
            loadingBuilder: _shimmer,
          ),
        BlockType.normal || BlockType.featured => TrackBlockItemsLoader<AudioTrack>(
            block: block,
            builder: (_, items) => _buildTrackBlock(
              items,
              block.type == BlockType.featured,
            ),
            loadingBuilder: _shimmer,
          ),
      };

  Widget _buildSeriesBlock(List<AudioPlaylist> playlists) => Column(
        children: [
          BlockHeader(
            title: block.title,
            seeAll: SearchableTracksScreen(heading: block.title, playlists: playlists),
          ),
          SizedBox(
            height: PlaylistBlockItem.height,
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: AppTheme.sidePadding),
              separatorBuilder: (context, index) => SizedBox(width: 16),
              scrollDirection: Axis.horizontal,
              itemCount: playlists.length,
              itemBuilder: (_, index) => PlaylistBlockItem(playlist: playlists[index]),
            ),
          ),
        ],
      );

  Widget _buildTrackBlock(List<AudioTrack> tracks, bool isWide) => Column(
        children: [
          BlockHeader(
            title: block.title,
            seeAll: SearchableTracksScreen(heading: block.title, tracks: tracks),
          ),
          SizedBox(
            height: AudioBlockItem.height,
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: AppTheme.sidePadding),
              separatorBuilder: (context, index) => SizedBox(width: 16),
              scrollDirection: Axis.horizontal,
              itemCount: tracks.length,
              itemBuilder: (context, index) => AudioBlockItem(
                track: tracks[index],
                isWide: isWide,
              ),
            ),
          ),
        ],
      );

  static Widget _shimmer(BuildContext context, BlockType type, int length) {
    final config = PageConfig.of(context);
    return switch (type) {
      BlockType.hero => HeroBlockItem.shimmer(config),
      BlockType.series => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BlockHeader.shimmer(),
            SizedBox(
              height: PlaylistBlockItem.height,
              child: ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: AppTheme.sidePadding),
                scrollDirection: Axis.horizontal,
                itemCount: length,
                separatorBuilder: (_, __) => SizedBox(width: 16),
                itemBuilder: (_, __) => PlaylistBlockItem.shimmer(config),
              ),
            ),
          ],
        ),
      BlockType.normal || BlockType.featured => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BlockHeader.shimmer(),
            SizedBox(
              height: AudioBlockItem.height,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: AppTheme.sidePadding),
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: length,
                separatorBuilder: (_, __) => SizedBox(width: 16),
                itemBuilder: (_, __) => AudioBlockItem.shimmer(
                  config,
                  wide: type == BlockType.featured,
                ),
              ),
            ),
          ],
        )
    };
  }
}
