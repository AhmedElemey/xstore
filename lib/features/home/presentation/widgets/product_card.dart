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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: imageUrl != null && imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
                      errorWidget: (_, __, ___) => const Icon(Icons.image),
                    )
                  : ColoredBox(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: const Icon(Icons.image_outlined),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                      Text(
                        Formatters.currency(price),
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.primary,
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
            ),
          ],
        ),
      ),
    );
  }
}
