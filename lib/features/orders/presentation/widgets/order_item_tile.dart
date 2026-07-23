import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/app_cached_network_image.dart';
import '../../domain/entities/order_item_entity.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class OrderItemTile extends StatelessWidget {
  const OrderItemTile({
    super.key,
    required this.item,
    this.showStockHint = false,
  });

  final OrderItemEntity item;
  final bool showStockHint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.sm),
            child: SizedBox(
              width: 60,
              height: 60,
              child: item.listingImage.isNotEmpty
                  ? AppCachedNetworkImage(
                      imageUrl: item.listingImage,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: context.textDisabled.withValues(alpha: 0.25),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: context.textDisabled.withValues(alpha: 0.25),
                        child: const Icon(Icons.image_not_supported_outlined),
                      ),
                    )
                  : Container(
                      color: context.textDisabled.withValues(alpha: 0.25),
                    ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.listingName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.sm,
                  children: [
                    Chip(
                      label: Text(item.category),
                      visualDensity: VisualDensity.compact,
                      backgroundColor:
                          context.backgroundColor,
                      side: BorderSide.none,
                    ),
                    Chip(
                      label: Text(item.condition),
                      visualDensity: VisualDensity.compact,
                      backgroundColor:
                          context.backgroundColor,
                      side: BorderSide.none,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${context.formatCurrency(item.price)} × ${item.quantity} = ${context.formatCurrency(item.total)}',
                  style: AppTypography.bodyMedium.copyWith(
                    color: context.textSecondary,
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      context.push('${AppRoutes.product}/${item.listingId}'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    foregroundColor: AppColors.primary,
                  ),
                  child: Text(context.l10n.ordersViewProduct),
                ),
                if (showStockHint)
                  Text(
                    context.l10n.vendorLowStockHint(item.quantity),
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.warning,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
