import 'package:flutter/material.dart';

import '/domain/models/block/block.dart';
import '/domain/services/playlists_service.dart';
import '/domain/services/tracks_service.dart';
import '/utils/get.dart';

class TrackBlockItemsLoader<T> extends StatefulWidget {
  const TrackBlockItemsLoader({
    super.key,
    required this.block,
    required this.builder,
    required this.loadingBuilder,
  });

  final Block block;
  final Widget Function(BuildContext context, List<T> items) builder;
  final Widget Function(BuildContext context, BlockType type, int length) loadingBuilder;

  @override
  State<TrackBlockItemsLoader<T>> createState() => _TrackBlockItemsLoaderState<T>();
}

class _TrackBlockItemsLoaderState<T> extends State<TrackBlockItemsLoader<T>> {
  final _trackService = Get.the<TracksService>();
  final _playlistService = Get.the<PlaylistsService>();

  bool _loading = true;
  List<T> _items = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
        duration: Durations.medium2,
        child: _loading
            ? widget.loadingBuilder(context, widget.block.type, _getLength())
            : widget.builder(context, _items),
      );

  Future<void> _loadItems() async {
    try {
      _items = switch (widget.block.type) {
        BlockType.normal =>
          await _trackService.getByIds((widget.block as NormalBlock).trackIds) as List<T>,
        BlockType.featured => await _trackService
            .getByIds((widget.block as FeaturedBlock).trackIds) as List<T>,
        BlockType.hero =>
          [await _trackService.getById((widget.block as HeroBlock).trackId)] as List<T>,
        BlockType.series => await _playlistService
            .getByIds((widget.block as SeriesBlock).playlistIds) as List<T>,
      };
    } catch (e) {
      debugPrint('Error loading block items: $e');
      _items = [];
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  int _getLength() => switch (widget.block.type) {
        BlockType.normal => (widget.block as NormalBlock).trackIds.length,
        BlockType.featured => (widget.block as FeaturedBlock).trackIds.length,
        BlockType.hero => 1,
        BlockType.series => (widget.block as SeriesBlock).playlistIds.length,
      };
}
