import 'package:flutter/material.dart';

import '/domain/models/block/block.dart';
import '/domain/models/block_item/audio_playlist.dart';
import '/domain/models/block_item/audio_track.dart';
import '/utils/app_theme.dart';
import '/widgets/blocks/audio_block_item.dart';
import '/widgets/blocks/block_header.dart';
import '/widgets/blocks/hero_block_item.dart';
import '/widgets/blocks/playlist_block_item.dart';
import '/widgets/blocks/track_block_items_loader.dart';
import '../track_list_screen.dart';

class TrackBlockLoader extends StatelessWidget {
  const TrackBlockLoader(this.block, {super.key});

  final Block block;

  @override
  Widget build(BuildContext context) => switch (block.type) {
        BlockType.hero => TrackBlockItemsLoader<AudioTrack>(
            block: block,
            builder: (_, items) => HeroBlockItem(track: items.first),
            loadingBuilder: (_, type) => shimmer(type),
          ),
        BlockType.series => TrackBlockItemsLoader<AudioPlaylist>(
            block: block,
            builder: (_, items) => _buildSeriesBlock(items),
            loadingBuilder: (_, type) => shimmer(type),
          ),
        BlockType.normal || BlockType.featured => TrackBlockItemsLoader<AudioTrack>(
            block: block,
            builder: (_, items) => _buildTrackBlock(
              items,
              block.type == BlockType.featured,
            ),
            loadingBuilder: (_, type) => shimmer(type),
          ),
      };

  Widget _buildSeriesBlock(List<AudioPlaylist> playlists) => Column(
        children: [
          BlockHeader(
            title: block.title,
            seeAll: TrackListScreen(heading: block.title, playlists: playlists),
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
            seeAll: TrackListScreen(heading: block.title, tracks: tracks),
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

  static Widget shimmer(BlockType type) => switch (type) {
        BlockType.hero => HeroBlockItem.shimmer(),
        BlockType.series => Column(
            children: [
              BlockHeader.shimmer(),
              SizedBox(
                height: PlaylistBlockItem.height,
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: AppTheme.sidePadding),
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  separatorBuilder: (_, __) => SizedBox(width: 16),
                  itemBuilder: (_, __) => PlaylistBlockItem.shimmer(),
                ),
              ),
            ],
          ),
        BlockType.normal || BlockType.featured => Column(
            children: [
              BlockHeader.shimmer(),
              SizedBox(
                height: AudioBlockItem.height,
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: AppTheme.sidePadding),
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  separatorBuilder: (_, __) => SizedBox(width: 16),
                  itemBuilder: (_, __) => AudioBlockItem.shimmer(
                    wide: type == BlockType.featured,
                  ),
                ),
              ),
            ],
          )
      };
}
