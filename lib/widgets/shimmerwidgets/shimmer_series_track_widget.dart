import 'package:flutter/material.dart';

import 'package:shimmer/shimmer.dart';

import '../../utils/colors.dart';

class ShimmerSeriesTrackListWidget extends StatelessWidget {
  const ShimmerSeriesTrackListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Shimmer.fromColors(
            baseColor: shimmerBaseColor,
            highlightColor: gradientColorOne,
            child: Container(
              width: 24,
              height: 24,
              color: shimmerBaseColor,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Shimmer.fromColors(
              baseColor: shimmerBaseColor,
              highlightColor: gradientColorOne,
              child: Container(
                height: 14,
                width: 220,
                color: shimmerBaseColor,
              ),
            ),
          ),
          SizedBox(width: 15),
          Shimmer.fromColors(
            baseColor: shimmerBaseColor,
            highlightColor: gradientColorOne,
            child: Container(
              height: 14,
              width: 60,
              color: shimmerBaseColor,
            ),
          ),
          SizedBox(width: 12),
        ],
      ),
    );
  }
}
