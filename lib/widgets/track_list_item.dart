import 'package:flutter/material.dart';
import 'package:sleeptales/constants/assets.dart';
import 'package:sleeptales/utils/app_theme.dart';

import 'app_image.dart';

class TrackListItemSmall extends StatelessWidget {
  final String imageUrl;
  final String mp3Name;
  final String mp3Category;
  final String mp3Duration;
  final Function() tap;

  const TrackListItemSmall(
      {super.key,
      required this.imageUrl,
      required this.mp3Name,
      required this.mp3Category,
      required this.mp3Duration,
      required this.tap});

  @override
  Widget build(BuildContext context) => SizedBox(
      child: GestureDetector(
          onTap: tap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 164,
                width: double.maxFinite,
                child: AppImage(
                  imageUrl: imageUrl,
                  borderRadius: AppTheme.largeImageBorderRadius,
                  placeholderAsset: Assets.placeholderImage,
                ),
              ),
              SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  mp3Name,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 2),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  mp3Category,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 10,
                  ),
                ),
              )
            ],
          )));
}
