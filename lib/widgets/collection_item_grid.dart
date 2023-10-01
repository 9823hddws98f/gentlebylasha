import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CollectionItemGrid extends StatelessWidget {
  final String imageUrl;
  final String mp3Name;
  final String mp3Category;
  final Function() tap;

  const CollectionItemGrid({
    Key? key,
    required this.imageUrl,
    required this.mp3Name,
    required this.mp3Category,
    required this.tap
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child:GestureDetector(
          onTap: tap,
          child:
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [

                  Container(
                    height: 90.h,
                    width: 200.w,
                    child:   CachedNetworkImage(
                      imageUrl: imageUrl,
                      imageBuilder: (context, imageProvider) => ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                      errorWidget: (context, url, error) =>  ClipRRect(
                          borderRadius: BorderRadius.circular(20), // Adjust the radius as needed
                          child:Image.asset("images/placeholder_image.jpg",fit: BoxFit.cover,)
                      ),
                    ),
                  ),

                ],
              ),
              SizedBox( height:8.h),
              Text(
                mp3Name,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox( height:2.h),
              Text(
                mp3Category,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 10.sp,
                ),
              ),



            ],

          )
          ,
        )
    );
  }
}
