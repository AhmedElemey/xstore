import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/formatters.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.title,
    required this.price,
    this.imageUrl,
    this.discountPercent = 0,
    this.onTap,
  });

  final String title;
  final double price;
  final String? imageUrl;
  final double discountPercent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final boundedH = constraints.hasBoundedHeight;

            if (boundedH) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _ProductImage(
                      theme: theme,
                      imageUrl: imageUrl,
                    ),
                  ),
                  _Footer(
                    theme: theme,
                    title: title,
                    price: price,
                    discountPercent: discountPercent,
                  ),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: _ProductImage(
                    theme: theme,
                    imageUrl: imageUrl,
                  ),
                ),
                _Footer(
                  theme: theme,
                  title: title,
                  price: price,
                  discountPercent: discountPercent,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({
    required this.theme,
    this.imageUrl,
  });

  final ThemeData theme;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        width: double.infinity,
        placeholder: (_, __) => const Center(
          child: CircularProgressIndicator.adaptive(),
        ),
        errorWidget: (_, __, ___) => const Icon(Icons.image),
      );
    }
    return ColoredBox(
      color: theme.colorScheme.surfaceContainerHighest,
      child: const Center(child: Icon(Icons.image_outlined)),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.theme,
    required this.title,
    required this.price,
    required this.discountPercent,
  });

  final ThemeData theme;
  final String title;
  final double price;
  final double discountPercent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall,
          ),
          const Gap(AppSpacing.xxs),
          Row(
            children: [
              Flexible(
                child: Text(
                  Formatters.currency(price),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (discountPercent > 0) ...[
                const Gap(AppSpacing.xs),
                Text(
                  '-${discountPercent.toStringAsFixed(0)}%',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
