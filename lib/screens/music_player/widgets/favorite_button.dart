import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/domain/cubits/favorite_playlists.dart';
import '/domain/cubits/favorite_tracks.dart';
import '/utils/get.dart';

class FavoriteButton extends StatefulWidget {
  const FavoriteButton({
    super.key,
    this.trackId,
    this.playlistId,
    this.size,
  }) : assert(trackId != null || playlistId != null,
            'Either trackId or playlistId must be provided');

  final String? trackId;
  final String? playlistId;
  final double? size;

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  final _favoriteTracksCubit = Get.the<FavoritesTracksCubit>();
  final _favoritePlaylistsCubit = Get.the<FavoritePlaylistsCubit>();

  @override
  Widget build(BuildContext context) {
    if (widget.trackId != null) {
      return BlocBuilder<FavoritesTracksCubit, List<String>>(
        bloc: _favoriteTracksCubit,
        builder: (context, state) => _buildButton(state.contains(widget.trackId!)),
      );
    } else {
      return BlocBuilder<FavoritePlaylistsCubit, List<String>>(
        bloc: _favoritePlaylistsCubit,
        builder: (context, state) => _buildButton(state.contains(widget.playlistId!)),
      );
    }
  }

  Widget _buildButton(bool favorite) => IconButton(
        iconSize: widget.size,
        icon: favorite ? Icon(Icons.favorite_rounded) : Icon(Icons.favorite_border_rounded),
        onPressed: _toggleFavorite,
      );

  /// The cubit shows the change right away, and undoes it with a message
  /// when it can't be saved.
  Future<void> _toggleFavorite() async {
    final trackId = widget.trackId;
    if (trackId != null) {
      if (_favoriteTracksCubit.state.contains(trackId)) {
        await _favoriteTracksCubit.removeFavorite(trackId);
      } else {
        await _favoriteTracksCubit.addTrackToFavorites(trackId);
      }
      return;
    }
    final playlistId = widget.playlistId!;
    if (_favoritePlaylistsCubit.state.contains(playlistId)) {
      await _favoritePlaylistsCubit.removePlaylist(playlistId);
    } else {
      await _favoritePlaylistsCubit.addPlaylistToFavorites(playlistId);
    }
  }
}
