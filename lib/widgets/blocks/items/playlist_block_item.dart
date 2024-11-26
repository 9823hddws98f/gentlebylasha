import 'package:flutter/material.dart';
import 'package:supa_carbon_icons/supa_carbon_icons.dart';

import '/domain/models/block_item/audio_playlist.dart';
import '/helper/global_functions.dart';
import '/screens/home/playlist_tracks_screen.dart';
import '/utils/app_theme.dart';
import '/widgets/app_image.dart';
import '/widgets/shimmerize.dart';
import '../widgets/item_tag.dart';

class PlaylistBlockItem extends StatelessWidget {
  static const height = 219.0;

  static const _imageSize = 164.0;

  final AudioPlaylist playlist;
  const PlaylistBlockItem({
    super.key,
    required this.playlist,
  });

  @override
  Widget build(context) {
    final ColorScheme(:primary, :onSurfaceVariant) = Theme.of(context).colorScheme;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => pushName(context, PlayListTracksScreen(playlist: playlist)),
        child: SizedBox(
          height: height,
          width: _imageSize,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _buildImage(primary)),
              const SizedBox(height: 16),
              _buildTextContent(onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(Color color) => Stack(
        fit: StackFit.expand,
        children: [
          AppImage(
            image: playlist.thumbnail,
            height: _imageSize,
            borderRadius: AppTheme.largeImageBorderRadius,
          ),
          ItemTag(
            icon: CarbonIcons.playlist,
            text: '${playlist.trackIds.length} Sessions',
            color: playlist.thumbnail.dominantColor,
          ),
        ],
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
