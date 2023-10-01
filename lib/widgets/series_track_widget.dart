import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sleeptales/models/audiofile_model.dart';

class SeriesTrackListWidget extends StatelessWidget {

  final AudioTrack audioTrack;
  final Function() tap;
  final Function() onTapPlayPause;
  final Function() favoriteTap;
  final bool favorite;
  final bool currentPlaying;

  const SeriesTrackListWidget({
    Key? key,
    required this.audioTrack,
    required this.tap,
    required this.favoriteTap,
    required this.favorite,
    required this.currentPlaying,
    required this.onTapPlayPause
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        child:GestureDetector(
            onTap: tap,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,

              children: [

                IconButton(onPressed: onTapPlayPause, icon: Icon(currentPlaying?Icons.pause :Icons.play_arrow_outlined,size: 30.h,),constraints:BoxConstraints(),padding: EdgeInsets.only(right: 10.w,top: 0.h,bottom: 8.h,left: 0.w),),

                Expanded(child:
                Text(
                  audioTrack.title,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ),

                //Spacer(),
                SizedBox(width:15.h),
                Align(
                  alignment: Alignment.bottomLeft,
                  child:  Text(
                    audioTrack.length,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 14.sp,
                    ),
                  ),
                ),

                SizedBox(width: 12.w,),

                Padding(padding: EdgeInsets.only(top: 4.h),
                  child:IconButton(onPressed: favoriteTap, icon: favorite?Icon(Icons.favorite):Icon(Icons.favorite_border),padding:EdgeInsets.only(top: 8.h,bottom: 8.h),constraints: BoxConstraints(),),
                )

              ],

            )
        ));
  }
}
