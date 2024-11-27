import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '/domain/cubits/favorite_playlists.dart';
import '/domain/cubits/favorite_tracks.dart';
import '/domain/models/block_item/audio_playlist.dart';
import '/domain/models/block_item/audio_track.dart';
import '/domain/services/language_cubit.dart';
import '/domain/services/playlists_service.dart';
import '/domain/services/tracks_service.dart';
import '/screens/home/searchable_tracks_screen.dart';
import '/utils/app_theme.dart';
import '/utils/get.dart';
import '/widgets/app_scaffold/adaptive_app_bar.dart';
import '/widgets/app_scaffold/app_scaffold.dart';
import '/widgets/app_scaffold/bottom_panel_spacer.dart';
import '/widgets/input/tx_search_bar.dart';

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

  // Optimization: avoid re-fetching the same data multiple times
  Future? _future;

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
          future: _future ??= _isPlaylist
              ? _playlistsService.getByIds(state)
              : _tracksService.getByIds(state),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return AppScaffold(
                appBar: (context, isMobile) => AdaptiveAppBar(
                  title: _isPlaylist ? tr.favoritePlaylist : tr.favorites,
                  hasBottomLine: false,
                  // bottom only for good app bar visual on loading (not functional)
                  bottom: PreferredSize(
                    preferredSize: const Size(double.infinity, 72),
                    child: IgnorePointer(
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: AppTheme.sidePadding) +
                                const EdgeInsets.only(bottom: 16, top: 8),
                        child: TxSearchBar(onSearch: (_) async {}),
                      ),
                    ),
                  ),
                ),
                body: (context, isMobile) => const Center(
                  child: CupertinoActivityIndicator(),
                ),
              );
            }
            return SearchableTracksScreen(
              heading: _isPlaylist ? tr.favoritePlaylist : tr.favorites,
              tracks: _isPlaylist ? null : snapshot.data as List<AudioTrack>,
              playlists: _isPlaylist ? snapshot.data as List<AudioPlaylist> : null,
              emptyBuilder: _buildEmptyView,
            );
          },
        ),
      );

  Widget _buildEmptyView(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return BottomPanelSpacer.padding(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.sidePadding),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: AppTheme.smallBorderRadius,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Your favorite ${_isPlaylist ? 'playlists' : 'tracks'} are empty',
                  style: TextStyle(
                    color: colors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'To save any ${_isPlaylist ? 'series' : 'audio'}, tap the ',
                      ),
                      WidgetSpan(
                        child: Icon(Iconsax.heart5, size: 16),
                        alignment: PlaceholderAlignment.middle,
                      ),
                      const TextSpan(text: ' icon'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
