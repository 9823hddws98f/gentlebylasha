import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/domain/cubits/favorite_playlists.dart';
import '/domain/cubits/favorite_tracks.dart';
import '/domain/models/block_item/audio_playlist.dart';
import '/domain/models/block_item/audio_track.dart';
import '/domain/services/language_constants.dart';
import '/domain/services/playlists_service.dart';
import '/domain/services/tracks_service.dart';
import '/utils/get.dart';
import '/widgets/app_scaffold/adaptive_app_bar.dart';
import '/widgets/app_scaffold/app_scaffold.dart';
import 'track_list_screen.dart';

class FavoritesScreen extends StatefulWidget {
  final bool isPlaylist;

  const FavoritesScreen({super.key}) : isPlaylist = false;

  const FavoritesScreen.playlist({super.key}) : isPlaylist = true;

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> with Translation {
  late final _favoriteTracksCubit = Get.the<FavoritesTracksCubit>();
  late final _favoritePlaylistsCubit = Get.the<FavoritePlaylistsCubit>();

  late final _tracksService = Get.the<TracksService>();
  late final _playlistsService = Get.the<PlaylistsService>();

  bool get _isPlaylist => widget.isPlaylist;

  @override
  Widget build(BuildContext context) {
    return _isPlaylist
        ? BlocProvider<FavoritePlaylistsCubit>.value(
            value: _favoritePlaylistsCubit,
            child: _buildBlocContent<FavoritePlaylistsCubit>(),
          )
        : BlocProvider<FavoritesTracksCubit>.value(
            value: _favoriteTracksCubit,
            child: _buildBlocContent<FavoritesTracksCubit>(),
          );
  }

  Widget _buildBlocContent<T extends StateStreamable<List<String>>>() =>
      BlocBuilder<T, List<String>>(
        builder: (context, state) => FutureBuilder(
          future: _isPlaylist
              ? _playlistsService.getByIds(state)
              : _tracksService.getByIds(state),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return AppScaffold(
                appBar: (context, isMobile) => AdaptiveAppBar(
                  title: _isPlaylist ? tr.favoritePlaylist : tr.favorites,
                  hasBottomLine: false,
                ),
                body: (context, isMobile) => const Center(
                  child: CupertinoActivityIndicator(),
                ),
              );
            }
            return TrackListScreen(
              heading: _isPlaylist ? tr.favoritePlaylist : tr.favorites,
              tracks: _isPlaylist ? null : snapshot.data as List<AudioTrack>,
              playlists: _isPlaylist ? snapshot.data as List<AudioPlaylist> : null,
            );
          },
        ),
      );
}
