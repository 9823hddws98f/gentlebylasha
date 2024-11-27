import 'package:flutter/material.dart';
import 'package:supa_carbon_icons/supa_carbon_icons.dart';

import '/domain/models/app_page/app_page_config.dart';
import '/domain/models/block_item/audio_playlist.dart';
import '/helper/global_functions.dart';
import '/screens/home/playlist_tracks_screen.dart';
import '/utils/app_theme.dart';
import '/widgets/app_image.dart';
import '/widgets/blocks/config_of_page.dart';
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
    final config = PageConfig.of(context);
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
              Expanded(child: _buildImage(primary, config.showItemDurations)),
              const SizedBox(height: 16),
              _buildTextContent(onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(Color color, bool showDuration) => Stack(
        fit: StackFit.expand,
        children: [
          AppImage(
            image: playlist.thumbnail,
            height: _imageSize,
            borderRadius: AppTheme.largeImageBorderRadius,
          ),
          showDuration
              ? ItemTag(
                  icon: CarbonIcons.playlist,
                  text: '${playlist.trackIds.length} Sessions',
                  color: playlist.thumbnail.dominantColor,
                )
              : ItemTag(
                  icon: CarbonIcons.playlist,
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

  static Widget shimmer(AppPageConfig config) => SizedBox(
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
                      borderRadius: AppTheme.largeImageBorderRadius,
                    ),
                  ),
                  Positioned(
                    bottom: ItemTag.margin,
                    left: ItemTag.margin,
                    child: Shimmerize(
                      child: Material(
                        borderRadius: BorderRadius.circular(ItemTag.borderRadius),
                        child: SizedBox(
                          width: config.showItemDurations ? 62 : 22,
                          height: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
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
