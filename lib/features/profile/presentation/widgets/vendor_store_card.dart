import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/profile_entity.dart';
import '../../../store/presentation/providers/store_hours_provider.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class VendorStoreCard extends ConsumerWidget {
  const VendorStoreCard({
    super.key,
    required this.profile,
    this.onManageStore,
  });

  final ProfileEntity profile;
  final VoidCallback? onManageStore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOpen = ref.watch(storeHoursNotifierProvider.select((s) => s.isStoreOpen));
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
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        boxShadow: [
          BoxShadow(
            color: context.textPrimary.withValues(alpha: 0.06),
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
                      '⭐ ${rating.toStringAsFixed(1)} · $sales ${context.l10n.statSalesShort}'
                      '${joinedLine.isNotEmpty ? ' · ${context.l10n.storeMetaLinePrefix}$joinedLine' : ''}',
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
                  context.l10n.manageStore,
                  style: AppTypography.labelLarge.copyWith(fontSize: 11),
                ),
              ),
            ],
          ),
          const Gap(AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _StatChip(
                icon: LucideIcons.eye,
                label:
                    '${_compactCount(profile.storeViewCount)} ${context.l10n.statStoreViews}',
              ),
              _StatChip(
                icon: LucideIcons.heart,
                label:
                    '${profile.storeSaveCount} ${context.l10n.statStoreSaves}',
              ),
              _StatChip(
                icon: LucideIcons.package,
                label:
                    '${profile.storeActiveListings} ${context.l10n.statStoreActive}',
              ),
            ],
          ),
          const Gap(AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: (isOpen ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isOpen ? AppColors.success : AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
                const Gap(AppSpacing.xs),
                Text(
                  isOpen ? context.l10n.storeOpenNow : context.l10n.storeClosedNow,
                  style: AppTypography.labelSmall.copyWith(
                    color: isOpen ? AppColors.success : AppColors.error,
                    fontWeight: FontWeight.w600,
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
        color: context.backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.x3l),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: context.textSecondary),
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
