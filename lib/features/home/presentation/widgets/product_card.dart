import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/app_cached_network_image.dart';
import '../../../../shared/widgets/sold_out_overlay.dart';
import '../../../../shared/widgets/wish_heart_button.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.title,
    required this.price,
    this.imageUrl,
    this.discountPercent = 0,
    this.listingId,
    this.onTap,
    this.isSoldOut = false,
  });

  final String title;
  final double price;
  final String? imageUrl;
  final double discountPercent;
  final String? listingId;
  final VoidCallback? onTap;
  final bool isSoldOut;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final image = ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.lg),
      child: _ProductImage(
        theme: theme,
        imageUrl: imageUrl,
        listingId: listingId,
        isSoldOut: isSoldOut,
      ),
    );
    final footer = _Footer(
      theme: theme,
      title: title,
      price: price,
      discountPercent: discountPercent,
    );
    return Material(
      color: context.glassColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: context.borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.spacing10),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (constraints.hasBoundedHeight)
                    Expanded(child: image)
                  else
                    AspectRatio(aspectRatio: 1, child: image),
                  footer,
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({
    required this.theme,
    required this.isSoldOut,
    this.imageUrl,
    this.listingId,
  });

  final ThemeData theme;
  final bool isSoldOut;
  final String? imageUrl;
  final String? listingId;

  @override
  Widget build(BuildContext context) {
    Widget image;
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      image = AppCachedNetworkImage(
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        width: double.infinity,
        // Square (aspectRatio: 1) grid tile — cap decode size generously
        // above typical 2-column tile width instead of full network res.
        memCacheWidth: 600,
        placeholder: (_, __) => ColoredBox(
          color: theme.colorScheme.surfaceContainerHighest,
          child: const Center(child: CircularProgressIndicator.adaptive()),
        ),
        errorWidget: (_, __, ___) => ColoredBox(
          color: theme.colorScheme.surfaceContainerHighest,
          child: const Icon(LucideIcons.imageOff),
        ),
      );
    } else {
      image = ColoredBox(
        color: theme.colorScheme.surfaceContainerHighest,
        child: const Center(child: Icon(LucideIcons.image)),
      );
    }

    image = SoldOutOverlay(soldOut: isSoldOut, child: image);

    if (listingId == null) {
      return image;
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        image,
        PositionedDirectional(
          top: AppSpacing.spacing6,
          end: AppSpacing.spacing6,
          child: WishHeartButton(listingId: listingId!, size: AppSpacing.xl),
        ),
      ],
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
      padding: const EdgeInsetsDirectional.only(
        top: AppSpacing.sm,
        start: AppSpacing.xs,
        end: AppSpacing.xs,
        bottom: AppSpacing.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: context.textPrimary,
            ),
          ),
          const Gap(AppSpacing.xs),
          Row(
            children: [
              Flexible(
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    context.formatCurrency(price),
                    style: AppTypography.mono.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: context.amberColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              if (discountPercent > 0) ...[
                const Gap(AppSpacing.sm),
                Text(
                  '-${discountPercent.toStringAsFixed(0)}%',
                  style: AppTypography.mono.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
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
