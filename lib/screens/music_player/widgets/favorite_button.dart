import 'package:carbon_icons/carbon_icons.dart';
import 'package:flutter/material.dart';

import '/utils/get.dart';
import '/utils/tx_loader.dart';
import '/widgets/circle_icon_button.dart';
import '../../../domain/cubits/favorite_tracks.dart';

class FavoriteButton extends StatefulWidget {
  const FavoriteButton({super.key, required this.trackId});

  final String trackId;

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  final _favoritesCubit = Get.the<FavoritesTracksCubit>();

  final _txLoader = TxLoader();
  bool _favorite = false;

  @override
  void initState() {
    super.initState();
    _favorite = _favoritesCubit.state.contains(widget.trackId);
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return CircleIconButton(
      icon: _favorite ? CarbonIcons.favorite_filled : CarbonIcons.favorite,
      onPressed: _toggleFavorite,
      iconColor: _favorite ? primary : null,
    );
  }

  Future<void> _toggleFavorite() async {
    final previousFavoriteStatus = _favorite;
    setState(() => _favorite = !_favorite);

    await _txLoader.load(
      () async {
        if (_favorite) {
          await _favoritesCubit.addTrackToFavorites(widget.trackId);
        } else {
          await _favoritesCubit.removeFavorite(widget.trackId);
        }
      },
      onError: (error) {
        // Revert the favorite status on error
        setState(() => _favorite = previousFavoriteStatus);
        // Optionally, display an error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update favorite status.')),
        );
      },
    );
  }
}
