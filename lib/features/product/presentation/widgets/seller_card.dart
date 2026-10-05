import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/app_cached_network_image.dart';
import '../../domain/entities/product_seller_entity.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/utils/public_seller_stats.dart';

class SellerCard extends StatelessWidget {
  const SellerCard({
    super.key,
    required this.seller,
    required this.onVisitStore,
    required this.onCardTap,
  });

  final ProductSellerEntity seller;
  final VoidCallback onVisitStore;
  final VoidCallback onCardTap;

  @override
  Widget build(BuildContext context) {
    final successColor = context.isDark
        ? AppColors.successLight
        : AppColors.success;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Material(
        color: context.glassColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.lg),
          side: BorderSide(color: context.borderColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onCardTap,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppSpacing.md,
              10,
              AppSpacing.sm,
              10,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: context.brandGradient,
                    ),
                    image: seller.avatarUrl.isNotEmpty
                        ? DecorationImage(
                            image: AppNetworkImage.cached(
                              seller.avatarUrl,
                              cacheSize: 120,
                            ),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: seller.avatarUrl.isEmpty
                      ? Icon(
                          LucideIcons.store,
                          size: 18,
                          color: context.onBrandColor,
                        )
                      : null,
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
                      const Gap(2),
                      Text(
                        publicSellerStatsLabel(
                          context.l10n,
                          rating: seller.rating,
                          sales: seller.salesCount,
                        ),
                        style: AppTypography.body12.copyWith(
                          color: context.labelColor,
                        ),
                      ),
                      if (seller.verified) ...[
                        const Gap(2),
                        Text(
                          context.l10n.verifiedSeller,
                          style: AppTypography.body12.copyWith(
                            fontWeight: FontWeight.w700,
                            color: successColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                TextButton(
                  onPressed: onVisitStore,
                  style: TextButton.styleFrom(
                    foregroundColor: context.linkColor,
                    textStyle: AppTypography.labelMedium.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(context.l10n.visitStore),
                      Icon(context.chevronForward, size: 18),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
