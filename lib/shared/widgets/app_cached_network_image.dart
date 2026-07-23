import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/network/image_cache_manager.dart';

/// Network image with the app Basic license header and shared cache manager.
class AppCachedNetworkImage extends StatelessWidget {
  const AppCachedNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit,
    this.alignment = Alignment.center,
    this.width,
    this.height,
    this.memCacheWidth,
    this.memCacheHeight,
    this.placeholder,
    this.errorWidget,
  });

  final String imageUrl;
  final BoxFit? fit;
  final Alignment alignment;
  final double? width;
  final double? height;
  final int? memCacheWidth;
  final int? memCacheHeight;
  final PlaceholderWidgetBuilder? placeholder;
  final LoadingErrorWidgetBuilder? errorWidget;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      httpHeaders: AppNetworkImageHeaders.httpHeaders,
      cacheManager: AppImageCacheManager.instance,
      fit: fit,
      alignment: alignment,
      width: width,
      height: height,
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
      placeholder: placeholder,
      errorWidget: errorWidget,
    );
  }
}

/// [ImageProvider] helpers that attach the same auth headers as API calls.
abstract final class AppNetworkImage {
  static ImageProvider cached(String url) => CachedNetworkImageProvider(
        url,
        headers: AppNetworkImageHeaders.httpHeaders,
        cacheManager: AppImageCacheManager.instance,
      );

  static ImageProvider network(String url) => NetworkImage(
        url,
        headers: AppNetworkImageHeaders.httpHeaders,
      );
}
