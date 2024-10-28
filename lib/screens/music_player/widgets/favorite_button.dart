import 'package:flutter/material.dart';
import 'package:sleeptales/domain/cubits/favorites.dart';
import 'package:sleeptales/utils/get.dart';

import '/utils/tx_loader.dart';
import '/widgets/circle_icon_button.dart';

class FavoriteButton extends StatefulWidget {
  const FavoriteButton({super.key, required this.trackId});

  final String trackId;

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  final _favoritesCubit = Get.the<FavoritesCubit>();

  final _txLoader = TxLoader();
  bool _favorite = false;

  @override
  void initState() {
    super.initState();
    _favorite = _favoritesCubit.state.contains(widget.trackId);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme(:primary, :surface) = Theme.of(context).colorScheme;
    return CircleIconButton(
      icon: _favorite ? Icons.favorite : Icons.favorite_border,
      onPressed: _toggleFavorite,
      backgroundColor: (_favorite ? primary : surface).withValues(alpha: 0.6),
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
