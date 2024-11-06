import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_image_platform_interface/cached_network_image_platform_interface.dart';
import 'package:flutter/material.dart';

class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.errorWidget,
    this.placeholderAsset,
    this.borderRadius,
    this.height,
    this.width,
    this.fadeInDuration = Durations.medium4,
    this.onLoad,
  });

  final String imageUrl;
  final BoxFit fit;
  final String? placeholderAsset;
  final BorderRadius? borderRadius;
  final double? height;
  final double? width;
  final Duration fadeInDuration;
  final void Function(ImageProvider)? onLoad;
  final Widget Function(BuildContext, String, Object)? errorWidget;

  @override
  Widget build(BuildContext context) => CachedNetworkImage(
        imageUrl: imageUrl,
        fit: fit,
        imageBuilder: (context, imageProvider) {
          onLoad?.call(imageProvider);
          return borderRadius == null
              ? Image(image: imageProvider, fit: fit)
              : ClipRRect(
                  borderRadius: borderRadius!,
                  child: Image(
                    image: imageProvider,
                    fit: fit,
                  ),
                );
        },
        errorWidget: errorWidget,
        imageRenderMethodForWeb: ImageRenderMethodForWeb.HttpGet,
        placeholder: (context, __) => placeholderAsset == null
            ? const Center(child: CircularProgressIndicator())
            : Image.asset(placeholderAsset!),
        height: height,
        width: width,
        fadeInDuration: fadeInDuration,
      );
}
