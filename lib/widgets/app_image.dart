import 'package:cached_network_image/cached_network_image.dart';
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
  Widget build(BuildContext context) => imageUrl.isEmpty
      ? _buildPlaceholder()
      : CachedNetworkImage(
          imageUrl: imageUrl,
          fit: fit,
          imageBuilder: (context, imageProvider) {
            onLoad?.call(imageProvider);
            return _buildImage(imageProvider);
          },
          errorWidget: errorWidget ?? (_, __, ___) => _buildPlaceholder(),
          placeholder: (context, __) => _buildPlaceholder(),
          height: height,
          width: width,
          fadeInDuration: fadeInDuration,
        );

  Widget _buildPlaceholder() => placeholderAsset == null
      ? const Center(child: CircularProgressIndicator())
      : Image.asset(placeholderAsset!);

  Widget _buildImage(ImageProvider imageProvider) => borderRadius == null
      ? Image(image: imageProvider, fit: fit)
      : ClipRRect(
          borderRadius: borderRadius!,
          child: Image(image: imageProvider, fit: fit),
        );
}
