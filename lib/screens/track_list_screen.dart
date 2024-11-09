import 'package:flutter/material.dart';

import '/domain/models/block_item/audio_playlist.dart';
import '/domain/models/block_item/audio_track.dart';
import '/utils/app_theme.dart';
import '/widgets/app_scaffold/adaptive_app_bar.dart';
import '/widgets/app_scaffold/app_scaffold.dart';
import '/widgets/app_scaffold/bottom_panel_spacer.dart';
import '/widgets/blocks/audio_block_item.dart';
import '/widgets/blocks/playlist_block_item.dart';
import '/widgets/input/tx_search_bar.dart';

class TrackListScreen extends StatefulWidget {
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
  State<TrackListScreen> createState() => _TrackListScreenState();
}

class _TrackListScreenState extends State<TrackListScreen> {
  List<AudioTrack>? _filteredTracks;
  List<AudioPlaylist>? _filteredPlaylists;

  @override
  void initState() {
    super.initState();
    _filteredTracks = widget.tracks;
    _filteredPlaylists = widget.playlists;
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
        appBar: (context, isMobile) => AdaptiveAppBar(
          title: widget.heading,
          bottom: PreferredSize(
            preferredSize: const Size(double.infinity, 80), // 56 + 16 + 8
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.sidePadding) +
                  const EdgeInsets.only(bottom: 16, top: 8),
              child: TxSearchBar(onSearch: _handleSearch),
            ),
          ),
        ),
        body: (context, isMobile) => BottomPanelSpacer.padding(
          child: GridView.builder(
            itemCount: _filteredTracks?.length ?? _filteredPlaylists!.length,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemBuilder: (context, index) => widget.tracks != null
                ? AudioBlockItem(track: _filteredTracks![index], isWide: false)
                : PlaylistBlockItem(playlist: _filteredPlaylists![index]),
          ),
        ),
      );

  Future<void> _handleSearch(String query) async {
    setState(() {
      if (query.isEmpty) {
        _filteredTracks = widget.tracks;
        _filteredPlaylists = widget.playlists;
        return;
      }

      final searchQuery = query.toLowerCase();

      if (widget.tracks != null) {
        _filteredTracks = widget.tracks!.where((track) {
          return track.title.toLowerCase().contains(searchQuery) ||
              track.writer.toLowerCase().contains(searchQuery) ||
              track.speaker.toLowerCase().contains(searchQuery) ||
              track.description.toLowerCase().contains(searchQuery);
        }).toList();
      } else {
        _filteredPlaylists = widget.playlists!.where((playlist) {
          return playlist.title.toLowerCase().contains(searchQuery) ||
              playlist.author.toLowerCase().contains(searchQuery) ||
              playlist.profession.toLowerCase().contains(searchQuery) ||
              playlist.description.toLowerCase().contains(searchQuery);
        }).toList();
      }
    });
  }
}
