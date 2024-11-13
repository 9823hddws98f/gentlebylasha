import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class Shimmerize extends StatelessWidget {
  const Shimmerize({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).colorScheme.secondary;
    return Shimmer.fromColors(
      baseColor: secondary.withValues(alpha: 0.2),
      highlightColor: secondary.withValues(alpha: 0.4),
      child: child,
    );
  }
}
