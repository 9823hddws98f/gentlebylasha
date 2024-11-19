import 'package:flutter/material.dart';
import 'package:supa_carbon_icons/supa_carbon_icons.dart';

import '/constants/assets.dart';
import '/domain/models/block_item/audio_track.dart';
import '/domain/services/audio_panel_manager.dart';
import '/helper/global_functions.dart';
import '/utils/app_theme.dart';
import '/utils/get.dart';
import '/widgets/app_image.dart';
import '/widgets/shimmerize.dart';
import '../widgets/item_tag.dart';

class HeroBlockItem extends StatelessWidget {
  final AudioTrack track;

  HeroBlockItem({super.key, required this.track});

  static const height = 336.0;

  static const _imageSize = 255.0;
  final _audioPanelManager = Get.the<AudioPanelManager>();

  @override
  Widget build(context) {
    final ColorScheme(:primary, :onSurfaceVariant) = Theme.of(context).colorScheme;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          playTrack(track);
          _audioPanelManager.maximizeAndPlay(false);
        },
        child: SizedBox(
          height: height,
          width: _imageSize,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
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
      ),
    );
  }

  Widget _buildImage(Color color) => Stack(
        fit: StackFit.expand,
        children: [
          AppImage(
            imageUrl: track.thumbnail,
            height: _imageSize,
            borderRadius: AppTheme.largeImageBorderRadius,
            placeholderAsset: Assets.placeholderImage,
          ),
          ItemTag(
            icon: CarbonIcons.play_filled_alt,
            text: '${track.durationString} min',
            color: track.dominantColor,
          ),
        ],
      );

  Widget _buildTextContent(Color secondaryColor) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            track.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            track.speaker,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              color: secondaryColor,
            ),
          ),
        ],
      );

  static Widget shimmer() => SizedBox(
        height: height,
        width: _imageSize,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: _imageSize,
              width: _imageSize,
              child: Shimmerize(
                child: Material(
                  borderRadius: AppTheme.largeImageBorderRadius,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Shimmerize(
                  child: Material(
                    borderRadius: AppTheme.smallBorderRadius,
                    child: const SizedBox(
                      height: 24,
                      width: _imageSize * 0.8, // 80% of image width for title
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Shimmerize(
                  child: Material(
                    borderRadius: AppTheme.smallBorderRadius,
                    child: const SizedBox(
                      height: 16,
                      width: _imageSize * 0.6, // 60% of image width for speaker
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}
