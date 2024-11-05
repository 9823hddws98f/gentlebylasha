import 'package:flutter/material.dart';
import 'package:sleeptales/widgets/blocks/hero_block_item.dart';

import '/domain/models/block/block.dart';
import '/domain/models/block_item/audio_playlist.dart';
import '/domain/models/block_item/audio_track.dart';
import '/domain/services/playlists_service.dart';
import '/domain/services/tracks_service.dart';
import '/utils/app_theme.dart';
import '/utils/get.dart';
import '/widgets/blocks/audio_block_item.dart';
import '/widgets/blocks/block_header.dart';
import '/widgets/blocks/playlist_block_item.dart';

class TrackBlockLoader extends StatefulWidget {
  const TrackBlockLoader(this.block, {super.key});

  final Block block;

  @override
  State<TrackBlockLoader> createState() => _TrackBlockLoaderState();

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
                  separatorBuilder: (_, __) => SizedBox(height: 16),
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
                  itemBuilder: (_, __) => AudioBlockItem.shimmer(),
                ),
              ),
            ],
          )
      };
}

class _TrackBlockLoaderState extends State<TrackBlockLoader> {
  final _trackService = Get.the<TracksService>();
  final _playlistService = Get.the<PlaylistsService>();

  bool _loading = true;

  late List<AudioTrack> _tracks;
  late List<AudioPlaylist> _playlists;
  late AudioTrack _hero;

  Block get _block => widget.block;

  @override
  void initState() {
    super.initState();
    _loadBlock();
  }

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
        duration: Durations.medium2,
        child: _loading ? TrackBlockLoader.shimmer(_block.type) : _buildContent(),
      );

  // TODO: CHECK FOR EMPTY BLOCKS
  Widget _buildContent() => switch (_block.type) {
        BlockType.hero => HeroBlockItem(track: _hero),
        BlockType.series => Column(
            children: [
              BlockHeader(title: _block.title),
              SizedBox(
                height: PlaylistBlockItem.height,
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: AppTheme.sidePadding),
                  separatorBuilder: (context, index) => SizedBox(width: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _playlists.length,
                  itemBuilder: (_, index) =>
                      PlaylistBlockItem(playlist: _playlists[index]),
                ),
              ),
            ],
          ),
        BlockType.normal || BlockType.featured => Column(
            children: [
              BlockHeader(title: _block.title),
              SizedBox(
                height: AudioBlockItem.height,
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: AppTheme.sidePadding),
                  separatorBuilder: (context, index) => SizedBox(width: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _tracks.length,
                  itemBuilder: (context, index) {
                    final track = _tracks[index];
                    return AudioBlockItem(
                      track: track,
                      isWide: _block.type == BlockType.featured,
                    );
                  },
                ),
              )
            ],
          )
      };

  Future<void> _loadBlock() async {
    try {
      switch (_block.type) {
        case BlockType.normal:
          _tracks = await _trackService.getByIds((_block as NormalBlock).trackIds);
        case BlockType.featured:
          _tracks = await _trackService.getByIds((_block as FeaturedBlock).trackIds);
        case BlockType.hero:
          final heroBlock = await _trackService.getById((_block as HeroBlock).trackId);
          _hero = heroBlock;
        case BlockType.series:
          _playlists =
              await _playlistService.getByIds((_block as SeriesBlock).playlistIds);
      }
    } catch (e) {
      debugPrint('Error loading block: $e');
      _tracks = [];
      _playlists = [];
    } finally {
      setState(() => _loading = false);
    }
  }
}
