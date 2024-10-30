import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '/constants/assets.dart';

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
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  imageBuilder: (context, imageProvider) => ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                  errorWidget: (context, url, error) => ClipRRect(
                      borderRadius:
                          BorderRadius.circular(20), // Adjust the radius as needed
                      child: Image.asset(
                        Assets.placeholderImage,
                        fit: BoxFit.cover,
                      )),
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
