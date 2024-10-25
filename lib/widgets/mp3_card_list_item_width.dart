import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sleeptales/constants/assets.dart';

class Mp3ListItem extends StatelessWidget {
  final String imageUrl;
  final String mp3Name;
  final String mp3Category;
  final String mp3Duration;
  final void Function() onPress;

  const Mp3ListItem(
      {super.key,
      required this.imageUrl,
      required this.mp3Name,
      required this.mp3Category,
      required this.mp3Duration,
      required this.onPress});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              SizedBox(
                  height: 185,
                  width: 282,
                  child: imageUrl != ""
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          imageBuilder: (context, imageProvider) => ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                          errorWidget: (context, url, error) => ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  20), // Adjust the radius as needed
                              child: Image.asset(
                                Assets.placeholderImage,
                                fit: BoxFit.cover,
                              )),
                        )
                      : ClipRRect(
                          borderRadius:
                              BorderRadius.circular(20), // Adjust the radius as needed
                          child: Image.asset(
                            Assets.placeholderImage,
                            fit: BoxFit.cover,
                          ))),
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.5),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.play_arrow,
                        size: 12,
                      ),
                      SizedBox(width: 2),
                      Text(
                        "$mp3Duration min",
                        style: TextStyle(
                          fontSize: 7,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            mp3Name.length > 35 ? "${mp3Name.substring(0, 35)}..." : mp3Name,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 2,
          ),
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
