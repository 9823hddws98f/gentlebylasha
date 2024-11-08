import 'package:flutter/material.dart';

import '/domain/models/block_item/audio_playlist.dart';
import '/domain/models/block_item/audio_track.dart';
import '/widgets/app_scaffold/adaptive_app_bar.dart';
import '/widgets/app_scaffold/app_scaffold.dart';
import '/widgets/blocks/audio_block_item.dart';
import '/widgets/blocks/playlist_block_item.dart';

class TrackListScreen extends StatelessWidget {
  final String heading;
  final List<AudioTrack>? tracks;
  final List<AudioPlaylist>? playlists;

  const TrackListScreen({
    super.key,
    required this.heading,
    this.tracks,
    this.playlists,
  }) : assert((tracks == null) != (playlists == null),
            'Exactly one of tracks or playlists must be provided');

  @override
  Widget build(BuildContext context) => AppScaffold(
        appBar: (context, isMobile) => AdaptiveAppBar(
          title: heading,
        ),
        body: (context, isMobile) => GridView.builder(
          itemCount: tracks?.length ?? playlists!.length,
          padding: const EdgeInsets.only(bottom: 165),
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
