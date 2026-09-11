import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_cached_network_image.dart';

/// Rounded listing image — network URL or local file path.
class ListingThumbnail extends StatelessWidget {
  const ListingThumbnail({
    super.key,
    required this.imageUrl,
    this.size = 80,
    this.width,
    this.height,
    this.borderRadius = AppSpacing.md,
  });

  final String imageUrl;
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
        width: w.isFinite ? w : null,
        height: h.isFinite ? h : null,
        child: _imageChild(context, bg, w, h),
      ),
    );
  }

  Widget _imageChild(
    BuildContext context,
    Color placeholderBg,
    double w,
    double h,
  ) {
    if (imageUrl.isEmpty) {
      return ColoredBox(
        color: placeholderBg,
        child: Icon(LucideIcons.imageOff, color: context.textDisabled),
      );
    }
    final isRemote =
        imageUrl.startsWith('http://') || imageUrl.startsWith('https://');
    if (isRemote) {
      return AppCachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        memCacheWidth: _memCachePx(w),
        memCacheHeight: _memCachePx(h),
        placeholder: (_, __) => ColoredBox(color: placeholderBg),
        errorWidget: (_, __, ___) => ColoredBox(
          color: placeholderBg,
          child: const Icon(LucideIcons.imageOff),
        ),
      );
    }
    return Image.file(
      File(imageUrl),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => ColoredBox(
        color: placeholderBg,
        child: const Icon(LucideIcons.imageOff),
      ),
    );
  }

  /// CachedNetworkImage converts this to int — Infinity/NaN throws.
  int? _memCachePx(double dim) {
    if (!dim.isFinite || dim <= 0) return null;
    return (dim * 3).round();
  }
}
