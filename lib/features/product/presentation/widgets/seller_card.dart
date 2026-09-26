import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/utils/public_seller_stats.dart';
import '../../../../shared/widgets/app_cached_network_image.dart';
import '../../../../shared/widgets/orbit_widgets.dart';
import '../../domain/entities/product_seller_entity.dart';

/// Orbit store row on the product sheet: avatar orb, name, stats and a
/// verified tag, opening the seller's store.
class SellerCard extends StatelessWidget {
  const SellerCard({super.key, required this.seller, required this.onTap});

  final ProductSellerEntity seller;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return GlassCard(
      radius: 16,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: orbitOrbGradient(2),
            ),
            clipBehavior: Clip.antiAlias,
            child: seller.avatarUrl.isEmpty
                ? null
                : AppCachedNetworkImage(
                    imageUrl: seller.avatarUrl,
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                    memCacheWidth: 108,
                    memCacheHeight: 108,
                  ),
          ),
          const Gap(AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  seller.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    color: context.textPrimary,
                  ),
                ),
                Text.rich(
                  TextSpan(
                    text: publicSellerStatsLabel(
                      context.l10n,
                      rating: seller.rating,
                      sales: seller.salesCount,
                    ),
                    children: [
                      if (seller.verified)
                        TextSpan(
                          text: ' · ${context.l10n.verifiedSeller}',
                          style: TextStyle(
                            color: context.isDark
                                ? AppColors.nova
                                : AppColors.primary,
                          ),
                        ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall.copyWith(
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            isRtl ? LucideIcons.chevronLeft : LucideIcons.chevronRight,
            size: 18,
            color: context.textSecondary,
          ),
        ],
      ),
    );
  }
}
