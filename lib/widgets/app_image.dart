import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_image_platform_interface/cached_network_image_platform_interface.dart';
import 'package:flutter/material.dart';

class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    required this.imageUrl,
    this.fit,
    this.imageBuilder,
    this.errorWidget,
    this.placeholder,
    this.height,
    this.width,
    this.fadeInDuration = const Duration(milliseconds: 500),
  });

  final String imageUrl;
  final BoxFit? fit;
  final Widget Function(BuildContext, ImageProvider)? imageBuilder;
  final Widget Function(BuildContext, String, Object)? errorWidget;
  final WidgetBuilder? placeholder;
  final double? height;
  final double? width;
  final Duration fadeInDuration;

  @override
  Widget build(BuildContext context) => CachedNetworkImage(
        imageUrl: imageUrl,
        fit: fit,
        imageBuilder: imageBuilder,
        errorWidget: errorWidget,
        imageRenderMethodForWeb: ImageRenderMethodForWeb.HttpGet,
        placeholder: (context, __) =>
            placeholder?.call(context) ??
            const Center(child: CircularProgressIndicator()),
        height: height,
        width: width,
        fadeInDuration: fadeInDuration,
      );
}
