import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '/domain/cubits/favorite_playlists.dart';
import '/domain/cubits/favorite_tracks.dart';
import '/utils/get.dart';
import '/utils/tx_loader.dart';

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

  final _txLoader = TxLoader();

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
        icon: favorite ? Icon(Iconsax.heart5) : Icon(Iconsax.heart),
        onPressed: _toggleFavorite,
      );

  Future<void> _toggleFavorite() async {
    late final bool isFavorite;
    if (widget.trackId != null) {
      isFavorite = _favoriteTracksCubit.state.contains(widget.trackId!);
    } else {
      isFavorite = _favoritePlaylistsCubit.state.contains(widget.playlistId!);
    }

    await _txLoader.load(
      () async {
        if (widget.trackId != null) {
          if (!isFavorite) {
            await _favoriteTracksCubit.addTrackToFavorites(widget.trackId!);
          } else {
            await _favoriteTracksCubit.removeFavorite(widget.trackId!);
          }
        } else {
          if (!isFavorite) {
            await _favoritePlaylistsCubit.addPlaylistToFavorites(widget.playlistId!);
          } else {
            await _favoritePlaylistsCubit.removePlaylist(widget.playlistId!);
          }
        }
      },
      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update favorite status.')),
        );
      },
    );
  }
}
