import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/profile_entity.dart';

class VendorStoreCard extends StatelessWidget {
  const VendorStoreCard({
    super.key,
    required this.profile,
    this.onManageStore,
  });

  final ProfileEntity profile;
  final VoidCallback? onManageStore;

  @override
  Widget build(BuildContext context) {
    final u = profile.user;
    final storeName = u.storeName ?? u.name;
    final category = u.storeCategory ?? '';
    final rating = u.rating ?? 0;
    final sales = u.totalSales ?? 0;
    final joined = u.joinedAt;

    final joinedLine =
        joined != null ? DateFormat('MMM y').format(joined) : '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StoreLogo(name: storeName, logoUrl: u.storeLogoUrl),
              const Gap(AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      storeName,
                      style: AppTypography.titleMedium.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (category.isNotEmpty)
                      Text(
                        category,
                        style: AppTypography.bodySmall,
                      ),
                    const Gap(AppSpacing.xs),
                    Text(
                      '⭐ ${rating.toStringAsFixed(1)} · $sales ${AppStrings.statSalesShort}'
                      '${joinedLine.isNotEmpty ? ' · ${AppStrings.storeMetaLinePrefix}$joinedLine' : ''}',
                      style: AppTypography.labelSmall,
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: onManageStore,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                ),
                child: Text(
                  AppStrings.manageStore,
                  style: AppTypography.labelLarge.copyWith(fontSize: 11),
                ),
              ),
            ],
          ),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _StatChip(
                icon: LucideIcons.eye,
                label:
                    '${_compactCount(profile.storeViewCount)} ${AppStrings.statStoreViews}',
              ),
              _StatChip(
                icon: LucideIcons.heart,
                label:
                    '${profile.storeSaveCount} ${AppStrings.statStoreSaves}',
              ),
              _StatChip(
                icon: LucideIcons.package,
                label:
                    '${profile.storeActiveListings} ${AppStrings.statStoreActive}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _compactCount(int n) {
  if (n >= 1000) {
    return '${(n / 1000).toStringAsFixed(1)}k';
  }
  return '$n';
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.x3l),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.xs),
          Text(label, style: AppTypography.labelSmall),
        ],
      ),
    );
  }
}

class _StoreLogo extends StatelessWidget {
  const _StoreLogo({required this.name, this.logoUrl});

  final String name;
  final String? logoUrl;

  @override
  Widget build(BuildContext context) {
    final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';
    if (logoUrl != null && logoUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.sm + AppSpacing.xs),
        child: Image.network(
          logoUrl!,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _gradientBox(initials),
        ),
      );
    }
    return _gradientBox(initials);
  }

  Widget _gradientBox(String letter) {
    return Container(
      width: 50,
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.sm + AppSpacing.xs),
        gradient: const LinearGradient(
          colors: [AppColors.accent, AppColors.warning],
        ),
      ),
      child: Text(
        letter,
        style: AppTypography.titleMedium.copyWith(color: AppColors.white),
      ),
    );
  }
}
