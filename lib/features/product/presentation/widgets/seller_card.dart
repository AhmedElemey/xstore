import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/app_cached_network_image.dart';
import '../../domain/entities/product_seller_entity.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../store/presentation/providers/store_hours_provider.dart';

class SellerCard extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isOpen = ref.watch(storeHoursNotifierProvider.select((s) => s.isStoreOpen));
    final message = ref.watch(storeHoursNotifierProvider.select((s) => s.current?.temporaryMessage));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Material(
        elevation: 3,
        shadowColor: context.textPrimary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        color: context.surfaceColor,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onCardTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: AppSpacing.x2l,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      backgroundImage: seller.avatarUrl.isNotEmpty
                          ? AppNetworkImage.cached(seller.avatarUrl)
                          : null,
                      child: seller.avatarUrl.isEmpty
                          ? const Icon(LucideIcons.store)
                          : null,
                    ),
                    const Gap(AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            seller.name,
                            style: AppTypography.titleSmall.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Gap(AppSpacing.xs),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: isOpen ? AppColors.success : AppColors.error,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const Gap(AppSpacing.xs),
                              Text(
                                isOpen ? context.l10n.storeOpenNow : context.l10n.storeClosedNow,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: isOpen ? AppColors.success : AppColors.error,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          if (!isOpen && message != null && message.isNotEmpty)
                            Text(
                              message,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          const Gap(AppSpacing.xs),
                          Text(
                            '⭐ ${seller.rating.toStringAsFixed(1)}${context.l10n.sellerRatingMid}${seller.salesCount}${context.l10n.sellerSalesSuffix}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(AppSpacing.sm),
                   
                  ],
                ),
                 const Gap(AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                   OutlinedButton(
                      onPressed: onVisitStore,
                      child: Text(context.l10n.visitStore),
                    ), 
                   
                      if (seller.verified) ...[
                  
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppSpacing.sm),
                    ),
                    child: Text(
                      context.l10n.verifiedSeller,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                  ],),
              
                if (!isOpen) ...[
                  const Gap(AppSpacing.sm),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppSpacing.sm),
                    ),
                    child: Text(
                      context.l10n.storeClosedWarning,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
