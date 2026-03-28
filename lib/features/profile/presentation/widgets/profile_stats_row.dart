import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../auth/domain/entities/user_entity.dart';

class ProfileStatsRow extends StatelessWidget {
  const ProfileStatsRow({
    super.key,
    required this.role,
    this.sales,
    this.rating,
    this.responsePercent,
    this.orders,
    this.wishlistCount,
    this.savedDzd,
    this.onSalesTap,
    this.onRatingTap,
    this.onResponseTap,
    this.onOrdersTap,
    this.onWishlistTap,
    this.onSavedTap,
  });

  final UserRole role;
  final int? sales;
  final double? rating;
  final int? responsePercent;
  final int? orders;
  final int? wishlistCount;
  final int? savedDzd;
  final VoidCallback? onSalesTap;
  final VoidCallback? onRatingTap;
  final VoidCallback? onResponseTap;
  final VoidCallback? onOrdersTap;
  final VoidCallback? onWishlistTap;
  final VoidCallback? onSavedTap;

  @override
  Widget build(BuildContext context) {
    if (role == UserRole.vendor) {
      return _Card(
        child: Row(
          children: [
            Expanded(
              child: _StatCell(
                value: '${sales ?? 0}',
                label: AppStrings.statSales,
                onTap: onSalesTap,
              ),
            ),
            const _VertDivider(),
            Expanded(
              child: _StatCell(
                value: '${rating?.toStringAsFixed(1) ?? '0.0'} ★',
                label: AppStrings.statRating,
                onTap: onRatingTap,
              ),
            ),
            const _VertDivider(),
            Expanded(
              child: _StatCell(
                value: '${responsePercent ?? 0}%',
                label: AppStrings.statResponse,
                onTap: onResponseTap,
              ),
            ),
          ],
        ),
      );
    }

    return _Card(
      child: Row(
        children: [
          Expanded(
            child: _StatCell(
              value: '${orders ?? 0}',
              label: AppStrings.statOrders,
              onTap: onOrdersTap,
            ),
          ),
          const _VertDivider(),
          Expanded(
            child: _StatCell(
              value: '${wishlistCount ?? 0}',
              label: AppStrings.statWishlist,
              onTap: onWishlistTap,
            ),
          ),
          const _VertDivider(),
          Expanded(
            child: _StatCell(
              value: Formatters.dzdSavedDisplay(savedDzd ?? 0),
              label: AppStrings.statDzdSaved,
              onTap: onSavedTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _VertDivider extends StatelessWidget {
  const _VertDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: AppColors.textDisabled.withValues(alpha: 0.5),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.value,
    required this.label,
    this.onTap,
  });

  final String value;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        child: Column(
          children: [
            Text(
              value,
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Gap(AppSpacing.xs),
            Text(
              label,
              style: AppTypography.bodySmall,
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
