import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class Shimmerize extends StatelessWidget {
  const Shimmerize({super.key, required this.child});

  final Widget child;

  static const baseColor = Color(0xff372953);
  static const highlightColor = Color(0xff261c39);

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: child,
      );
}
