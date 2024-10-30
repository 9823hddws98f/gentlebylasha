import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '/utils/colors.dart';

class ShimmerSeriesTrackListImageWidget extends StatelessWidget {
  const ShimmerSeriesTrackListImageWidget({super.key});

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
              height: 72,
              width: 72,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: shimmerBaseColor,
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Shimmer.fromColors(
                  baseColor: shimmerBaseColor,
                  highlightColor: gradientColorOne,
                  child: Container(
                    height: 16,
                    width: 180,
                    color: shimmerBaseColor,
                  ),
                ),
                SizedBox(height: 2),
                Shimmer.fromColors(
                  baseColor: shimmerBaseColor,
                  highlightColor: gradientColorOne,
                  child: Container(
                    height: 16,
                    width: 200,
                    color: shimmerBaseColor,
                  ),
                ),
                SizedBox(height: 15),
                Shimmer.fromColors(
                  baseColor: shimmerBaseColor,
                  highlightColor: gradientColorOne,
                  child: Container(
                    height: 16,
                    width: 120,
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
