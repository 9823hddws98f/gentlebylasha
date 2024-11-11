import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_image_platform_interface/cached_network_image_platform_interface.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '/utils/common_extensions.dart';

class AppImage extends StatefulWidget {
  const AppImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.errorWidget,
    this.placeholderAsset,
    this.placeholderUri,
    this.borderRadius,
    this.height,
    this.width,
    this.fadeInDuration = Durations.medium4,
    this.onLoad,
  }) : assert(placeholderAsset == null || placeholderUri == null);

  final String imageUrl;
  final BoxFit fit;
  final String? placeholderAsset;
  final Uri? placeholderUri;
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
          imageRenderMethodForWeb: ImageRenderMethodForWeb.HttpGet,
        );

  Widget _buildPlaceholder() {
    if (widget.placeholderUri != null) {
      return _buildImage(CachedNetworkImageProvider(widget.placeholderUri!.toString()));
    }
    final Widget placeholder = widget.placeholderAsset == null
        ? const Center(child: CupertinoActivityIndicator())
        : _buildImage(AssetImage(widget.placeholderAsset!));

    return widget.borderRadius == null
        ? placeholder
        : Container(
            decoration: BoxDecoration(borderRadius: widget.borderRadius!),
            clipBehavior: Clip.antiAlias,
            child: placeholder,
          );
  }

  Widget _buildImage(ImageProvider imageProvider) => widget.borderRadius == null
      ? Image(
          image: imageProvider,
          fit: widget.fit,
          height: widget.height,
          width: widget.width)
      : Container(
          decoration: BoxDecoration(borderRadius: widget.borderRadius!),
          clipBehavior: Clip.antiAlias,
          child: Image(
            image: imageProvider,
            fit: widget.fit,
            height: widget.height,
            width: widget.width,
          ),
        );
}
