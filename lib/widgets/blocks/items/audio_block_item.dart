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

class AudioBlockItem extends StatelessWidget {
  final AudioTrack track;
  final bool isWide;

  AudioBlockItem({
    super.key,
    required this.track,
    this.isWide = false,
  });

  static const height = 219.0;

  static const _imageSize = 164.0;
  static const _wideWidth = 242.0;
  static const _narrowWidth = _imageSize;

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
          width: isWide ? _wideWidth : _narrowWidth,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            track.title,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 2),
          Text(
            track.speaker,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: secondaryColor,
            ),
          ),
        ],
      );

  static Widget shimmer({bool wide = false}) => SizedBox(
        width: wide ? _wideWidth : _narrowWidth,
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
