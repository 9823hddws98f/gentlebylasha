import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../utils/colors.dart';

class ShimmerSeriesTrackListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
         height: 40.h,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Shimmer.fromColors(
              baseColor: shimmerBaseColor,
              highlightColor: gradientColorOne,
              child: Container(
                width: 24.w,
                height: 24.h,
                color: shimmerBaseColor,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Shimmer.fromColors(
                baseColor: shimmerBaseColor,
                highlightColor: gradientColorOne,
                child: Container(
                  height: 14.h,
                  width: 220.w,
                  color: shimmerBaseColor,
                ),
              ),
            ),
            SizedBox(width: 15.h),
            Shimmer.fromColors(
              baseColor: shimmerBaseColor,
              highlightColor: gradientColorOne,
              child: Container(
                height: 14.h,
                width: 60.w,
                color: shimmerBaseColor,
              ),
            ),
            SizedBox(width: 12.w),
          ],
        ),

    );
  }
}
