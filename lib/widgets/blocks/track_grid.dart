import 'package:flutter/material.dart';

import '/domain/models/block_item/audio_playlist.dart';
import '/domain/models/block_item/audio_track.dart';
import '/utils/app_theme.dart';
import '/widgets/app_scaffold/bottom_panel_spacer.dart';
import 'items/audio_block_item.dart';
import 'items/playlist_block_item.dart';

class TrackGrid extends StatelessWidget {
  const TrackGrid({
    super.key,
    this.tracks,
    this.playlists,
    this.padding = const EdgeInsets.symmetric(vertical: AppTheme.sidePadding),
  }) : assert((tracks == null) != (playlists == null),
            'Exactly one of tracks or playlists must be provided');

  final List<AudioTrack>? tracks;
  final List<AudioPlaylist>? playlists;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => BottomPanelSpacer.padding(
        child: GridView.builder(
          padding: padding,
          itemCount: tracks?.length ?? playlists!.length,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.75,
          ),
          itemBuilder: (context, index) => tracks != null
              ? AudioBlockItem(track: tracks![index], isWide: false)
              : PlaylistBlockItem(playlist: playlists![index]),
        ),
      );
}
