import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../utils/colors.dart';

class ShimmerPlaylistItem extends StatelessWidget {
  const ShimmerPlaylistItem({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Shimmer.fromColors(
            baseColor: shimmerBaseColor,
            highlightColor: gradientColorOne,
            child: Container(
              height: 72.h,
              width: 72.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: shimmerBaseColor,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(height: 4.h),
                Shimmer.fromColors(
                  baseColor: shimmerBaseColor,
                  highlightColor: gradientColorOne,
                  child: Container(
                    height: 16.h,
                    width: 200.w,
                    color: shimmerBaseColor,
                  ),
                ),
                SizedBox(height: 2.h),
                Shimmer.fromColors(
                  baseColor: shimmerBaseColor,
                  highlightColor: gradientColorOne,
                  child: Container(
                    height: 24.h,
                    width: 200.w,
                    color: shimmerBaseColor,
                  ),
                ),
                SizedBox(height: 15.h),
                Shimmer.fromColors(
                  baseColor: shimmerBaseColor,
                  highlightColor: gradientColorOne,
                  child: Container(
                    height: 16.h,
                    width: 100.w,
                    color: shimmerBaseColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
