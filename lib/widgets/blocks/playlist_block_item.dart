import 'package:carbon_icons/carbon_icons.dart';
import 'package:flutter/material.dart';

import '/constants/assets.dart';
import '/domain/models/block_item/audio_playlist.dart';
import '/screens/playlist_tracks_screen.dart';
import '/utils/app_theme.dart';
import '/utils/global_functions.dart';
import '../app_image.dart';
import '../shimmerize.dart';
import 'widgets/item_tag.dart';

class PlaylistBlockItem extends StatelessWidget {
  final AudioPlaylist playlist;

  const PlaylistBlockItem({
    super.key,
    required this.playlist,
  });

  static const height = 219.0;
  static const _imageSize = 164.0;

  @override
  Widget build(context) {
    final ColorScheme(:primary, :onSurfaceVariant) = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => pushName(context, PlayListTracksScreen(block: playlist)),
      child: SizedBox(
        height: height,
        width: _imageSize,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: _imageSize,
              child: _buildImage(primary),
            ),
            const SizedBox(height: 16),
            _buildTextContent(onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(Color color) => playlist.thumbnail.isNotEmpty
      ? Stack(
          fit: StackFit.expand,
          children: [
            AppImage(
              imageUrl: playlist.thumbnail,
              height: _imageSize,
              imageBuilder: (context, imageProvider) => ClipRRect(
                borderRadius: AppTheme.mediumBorderRadius,
                child: Image(image: imageProvider, fit: BoxFit.cover),
              ),
              errorWidget: (_, __, ___) => _buildPlaceholderImage(),
              placeholder: (_) => _buildPlaceholderImage(),
            ),
            ItemTag(
              icon: CarbonIcons.playlist,
              text: '${playlist.trackIds.length} Sessions',
            ),
          ],
        )
      : _buildPlaceholderImage();

  Widget _buildPlaceholderImage() => ClipRRect(
        borderRadius: AppTheme.smallBorderRadius,
        child: Image.asset(Assets.placeholderImage, fit: BoxFit.cover),
      );

  Widget _buildTextContent(Color secondaryColor) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            playlist.title,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 2),
          Text(
            playlist.author,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: secondaryColor,
            ),
          ),
        ],
      );

  static Widget shimmer() => SizedBox(
        width: _imageSize,
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: _imageSize,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Shimmerize(
                    child: Material(
                      borderRadius: AppTheme.smallBorderRadius,
                      color: Colors.white,
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Shimmerize(
                      child: Material(
                        borderRadius: AppTheme.smallBorderRadius,
                        child: const SizedBox(
                          width: 48,
                          height: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Shimmerize(
              child: Material(
                borderRadius: AppTheme.smallBorderRadius,
                child: const SizedBox(
                  height: 16,
                  width: 120,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Shimmerize(
              child: Material(
                borderRadius: AppTheme.smallBorderRadius,
                child: const SizedBox(
                  height: 12,
                  width: 80,
                ),
              ),
            ),
          ],
        ),
      );
}
