import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Rounded listing image — network URL or local file path.
class ListingThumbnail extends StatelessWidget {
  const ListingThumbnail({
    super.key,
    required this.imageUrl,
    this.size = 80,
    this.width,
    this.height,
    this.borderRadius = 10,
  });

  final String imageUrl;
  /// Square dimension when [width] / [height] are null.
  final double size;
  final double? width;
  final double? height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).colorScheme.surfaceContainerHighest;
    final w = width ?? size;
    final h = height ?? size;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: w,
        height: h,
        child: _imageChild(bg),
      ),
    );
  }

  Widget _imageChild(Color placeholderBg) {
    if (imageUrl.isEmpty) {
      return ColoredBox(
        color: placeholderBg,
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Colors.grey.shade400,
        ),
      );
    }
    final isRemote =
        imageUrl.startsWith('http://') || imageUrl.startsWith('https://');
    if (isRemote) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (_, __) => ColoredBox(color: placeholderBg),
        errorWidget: (_, __, ___) => ColoredBox(
          color: placeholderBg,
          child: const Icon(Icons.broken_image_outlined),
        ),
      );
    }
    return Image.file(
      File(imageUrl),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => ColoredBox(
        color: placeholderBg,
        child: const Icon(Icons.broken_image_outlined),
      ),
    );
  }
}
