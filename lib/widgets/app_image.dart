import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '/utils/common_extensions.dart';

class AppImage extends StatefulWidget {
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
  final void Function(ImageProvider imageProvider)? onLoad;
  final Widget Function(BuildContext context, String url, Object error)? errorWidget;

  @override
  State<AppImage> createState() => _AppImageState();
}

class _AppImageState extends State<AppImage> {
  String? _lastLoadedUrl;

  @override
  Widget build(BuildContext context) => widget.imageUrl.isEmpty
      ? _buildPlaceholder()
      : CachedNetworkImage(
          imageUrl: widget.imageUrl,
          fit: widget.fit,
          imageBuilder: (context, imageProvider) {
            if (_lastLoadedUrl != widget.imageUrl) {
              _lastLoadedUrl = widget.imageUrl;
              widget.onLoad?.call(imageProvider);
            }
            return _buildImage(imageProvider);
          },
          errorWidget: widget.errorWidget ??
              (context, url, error) {
                error.logDebug();
                return _buildPlaceholder();
              },
          placeholder: (context, __) => _buildPlaceholder(),
          height: widget.height,
          width: widget.width,
          fadeInDuration: widget.fadeInDuration,
        );

  Widget _buildPlaceholder() {
    final Widget placeholder = widget.placeholderAsset == null
        ? const Center(child: CircularProgressIndicator())
        : Image.asset(widget.placeholderAsset!);

    return widget.borderRadius == null
        ? placeholder
        : ClipRRect(borderRadius: widget.borderRadius!, child: placeholder);
  }

  Widget _buildImage(ImageProvider imageProvider) => widget.borderRadius == null
      ? Image(image: imageProvider, fit: widget.fit)
      : ClipRRect(
          borderRadius: widget.borderRadius!,
          child: Image(image: imageProvider, fit: widget.fit),
        );
}
