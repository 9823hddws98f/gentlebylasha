import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';

import '/utils/common_extensions.dart';
import '/utils/tx_image.dart';

class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    required this.image,
    this.fit = BoxFit.cover,
    this.errorWidget,
    this.borderRadius,
    this.height,
    this.width,
    this.fadeInDuration = Durations.medium4,
  });

  final TxImage image;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final double? height;
  final double? width;
  final Duration fadeInDuration;

  final Widget Function(BuildContext context, String url, Object error)? errorWidget;

  @override
  Widget build(BuildContext context) {
    final child = SizedBox(
      height: height,
      width: width,
      child: BlurHash(
        hash: image.blurhash,
        image: image.url,
        duration: fadeInDuration,
        imageFit: BoxFit.cover,
        color: image.dominantColor ?? Colors.transparent,
        errorBuilder: (context, error, stackTrace) {
          error.logDebug();
          return const Icon(Icons.error);
        },
      ),
    );
    if (borderRadius == null) return child;
    return ClipRRect(borderRadius: borderRadius!, child: child);
  }
}
