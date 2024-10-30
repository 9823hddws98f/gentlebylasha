import 'package:carbon_icons/carbon_icons.dart';
import 'package:flutter/material.dart';

import '/constants/assets.dart';
import '/utils/app_theme.dart';
import '/widgets/shimmerwidgets/shimmerize.dart';
import 'app_image.dart';

class Mp3ListItem extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String category;
  final String duration;
  final VoidCallback onTap;
  final bool isWide;

  const Mp3ListItem({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.category,
    required this.duration,
    required this.onTap,
    this.isWide = false,
  });

  static const height = 164.0;

  static const wideWidth = 242.0;
  static const narrowWidth = 164.0;

  static final borderRadius = BorderRadius.circular(12);

  @override
  Widget build(context) {
    final ColorScheme(:primary, :onSurfaceVariant) = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: isWide ? wideWidth : narrowWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(primary),
            const SizedBox(height: 8),
            _buildTextContent(onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(Color color) => SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildNetworkImage(),
            Positioned(
              bottom: 12,
              left: 12,
              child: _buildDurationIndicator(color),
            ),
          ],
        ),
      );

  Widget _buildNetworkImage() => imageUrl.isNotEmpty
      ? AppImage(
          imageUrl: imageUrl,
          imageBuilder: (context, imageProvider) => ClipRRect(
            borderRadius: borderRadius,
            child: Image(image: imageProvider, fit: BoxFit.cover),
          ),
          errorWidget: (_, __, ___) => _buildPlaceholderImage(),
        )
      : _buildPlaceholderImage();

  Widget _buildPlaceholderImage() => ClipRRect(
        borderRadius: borderRadius,
        child: Image.asset(Assets.placeholderImage, fit: BoxFit.cover),
      );

  Widget _buildDurationIndicator(Color color) => Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: AppTheme.smallBorderRadius,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(CarbonIcons.play_filled_alt, size: 10),
            const SizedBox(width: 4),
            Text(
              '$duration min',
              style: const TextStyle(
                fontSize: 7,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );

  Widget _buildTextContent(Color secondaryColor) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            category,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              color: secondaryColor,
            ),
          ),
        ],
      );

  static Widget shimmer([bool isWide = false]) => SizedBox(
        width: isWide ? wideWidth : narrowWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Shimmerize(
              child: SizedBox(
                height: height,
                width: double.infinity,
                child: Material(borderRadius: borderRadius),
              ),
            ),
            const SizedBox(height: 8),
            Shimmerize(
              child: SizedBox(
                height: 14,
                width: 100,
                child: Material(borderRadius: AppTheme.smallBorderRadius),
              ),
            ),
            const SizedBox(height: 8),
            Shimmerize(
              child: SizedBox(
                height: 14,
                width: 50,
                child: Material(borderRadius: AppTheme.smallBorderRadius),
              ),
            ),
          ],
        ),
      );
}
