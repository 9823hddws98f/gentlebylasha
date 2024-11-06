import 'package:flutter/material.dart';
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
  bool _favorite = false;

  @override
  void initState() {
    super.initState();
    _favorite = widget.trackId != null
        ? _favoriteTracksCubit.state.contains(widget.trackId!)
        : _favoritePlaylistsCubit.state.contains(widget.playlistId!);
  }

  @override
  Widget build(BuildContext context) => IconButton(
        iconSize: widget.size,
        icon: _favorite ? Icon(Iconsax.heart5) : Icon(Iconsax.heart),
        onPressed: _toggleFavorite,
      );

  Future<void> _toggleFavorite() async {
    final previousFavoriteStatus = _favorite;
    setState(() => _favorite = !_favorite);

    await _txLoader.load(
      () async {
        if (widget.trackId != null) {
          if (_favorite) {
            await _favoriteTracksCubit.addTrackToFavorites(widget.trackId!);
          } else {
            await _favoriteTracksCubit.removeFavorite(widget.trackId!);
          }
        } else {
          if (_favorite) {
            await _favoritePlaylistsCubit.addPlaylistToFavorites(widget.playlistId!);
          } else {
            await _favoritePlaylistsCubit.removePlaylist(widget.playlistId!);
          }
        }
      },
      onError: (error) {
        setState(() => _favorite = previousFavoriteStatus);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update favorite status.')),
        );
      },
    );
  }
}
