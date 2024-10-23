import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Mp3Item extends StatelessWidget {
  final String imageUrl;
  final String mp3Name;
  final String mp3Category;
  final String mp3Duration;
  final Function() tap;

  const Mp3Item({
    super.key,
    required this.imageUrl,
    required this.mp3Name,
    required this.mp3Category,
    required this.mp3Duration,
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
                  height: 175.h,
                  width: 187.w,
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
                          "images/placeholder_image.jpg",
                          fit: BoxFit.cover,
                        )),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.5),
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.play_arrow,
                          size: 12.h,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          "$mp3Duration min",
                          style: TextStyle(
                            fontSize: 7.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              mp3Category,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                fontSize: 10.sp,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              mp3Name.length > 25 ? "${mp3Name.substring(0, 25)}..." : mp3Name,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ));
  }
}
