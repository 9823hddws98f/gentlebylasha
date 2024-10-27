import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '/constants/assets.dart';

class Mp3ListItem extends StatelessWidget {
  final String imageUrl;
  final String mp3Name;
  final String mp3Category;
  final String mp3Duration;
  final VoidCallback onTap;
  final bool isWidthOriented;

  const Mp3ListItem({
    super.key,
    required this.imageUrl,
    required this.mp3Name,
    required this.mp3Category,
    required this.mp3Duration,
    required this.onTap,
    this.isWidthOriented = false,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(),
            const SizedBox(height: 8),
            _buildTextContent(),
          ],
        ),
      );

  Widget _buildImage() => Stack(
        children: [
          SizedBox(
            height: isWidthOriented ? 185 : 175,
            width: isWidthOriented ? 282 : 187,
            child: _buildNetworkImage(),
          ),
          Positioned(
            bottom: 12,
            left: 12,
            child: _buildDurationIndicator(),
          ),
        ],
      );

  Widget _buildNetworkImage() => imageUrl.isNotEmpty
      ? CachedNetworkImage(
          imageUrl: imageUrl,
          imageBuilder: (context, imageProvider) => ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image(image: imageProvider, fit: BoxFit.cover),
          ),
          errorWidget: (_, __, ___) => _buildPlaceholderImage(),
        )
      : _buildPlaceholderImage();

  Widget _buildPlaceholderImage() => ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(Assets.placeholderImage, fit: BoxFit.cover),
      );

  Widget _buildDurationIndicator() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.play_arrow, size: 12),
            const SizedBox(width: 2),
            Text(
              "$mp3Duration min",
              style: const TextStyle(fontSize: 7, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );

  Widget _buildTextContent() => isWidthOriented
      ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTruncatedText(mp3Name, 35, 14, FontWeight.bold),
            const SizedBox(height: 2),
            _buildTruncatedText(mp3Category, 35, 10, FontWeight.normal),
          ],
        )
      : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTruncatedText(mp3Category, 25, 10, FontWeight.normal),
            const SizedBox(height: 2),
            _buildTruncatedText(mp3Name, 25, 14, FontWeight.bold),
          ],
        );

  Widget _buildTruncatedText(
    String text,
    int maxLength,
    double fontSize,
    FontWeight fontWeight,
  ) =>
      Text(
        text.length > maxLength ? "${text.substring(0, maxLength)}..." : text,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
      );
}
