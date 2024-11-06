import 'package:flutter/material.dart';
import 'package:sleeptales/utils/app_theme.dart';

import '/constants/assets.dart';
import 'app_image.dart';

class CollectionItemGrid extends StatelessWidget {
  final String imageUrl;
  final String mp3Name;
  final String mp3Category;
  final Function() tap;

  const CollectionItemGrid({
    super.key,
    required this.imageUrl,
    required this.mp3Name,
    required this.mp3Category,
    required this.tap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: tap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              SizedBox(
                height: 90,
                width: 200,
                child: AppImage(
                  imageUrl: imageUrl,
                  borderRadius: AppTheme.largeImageBorderRadius,
                  placeholderAsset: Assets.placeholderImage,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            mp3Name,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 2),
          Text(
            mp3Category,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
