import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Make sure you import this for height and width calculations
import 'package:shimmer/shimmer.dart';

import '../../utils/colors.dart';

class ShimmerCustomTabButton extends StatelessWidget {
  const ShimmerCustomTabButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30.h,
      child: Shimmer.fromColors(
        baseColor: shimmerBaseColor,
        highlightColor: gradientColorOne,// Change to your preferred highlight color
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: shimmerBaseColor,
          ),
          width: 100.w,
        )
      ),
    );
  }
}
