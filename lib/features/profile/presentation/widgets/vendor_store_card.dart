import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/profile_entity.dart';
import '../../../../shared/utils/public_seller_stats.dart';
import '../../../../shared/widgets/app_cached_network_image.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class VendorStoreCard extends ConsumerWidget {
  const VendorStoreCard({super.key, required this.profile});

  final ProfileEntity profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final u = profile.user;
    final storeName = u.storeName ?? u.name;
    final category = u.storeCategory ?? '';
    final joined = u.joinedAt;

    final joinedLine = joined != null ? context.formatMonthYear(joined) : '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.glassColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.borderColor),
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
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (category.isNotEmpty)
                      Text(category, style: AppTypography.bodySmall),
                    const Gap(AppSpacing.xs),
                    Text(
                      '${publicSellerStatsLabel(context.l10n, rating: u.rating, sales: u.totalSales)}'
                      '${joinedLine.isNotEmpty ? ' · ${context.l10n.storeMetaLinePrefix}$joinedLine' : ''}',
                      style: AppTypography.labelSmall,
                    ),
                  ],
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
                count: _compactCount(profile.storeViewCount),
                label: context.l10n.statStoreViews,
              ),
              _StatChip(
                icon: LucideIcons.heart,
                count: '${profile.storeSaveCount}',
                label: context.l10n.statStoreSaves,
              ),
              _StatChip(
                icon: LucideIcons.package,
                count: '${profile.storeActiveListings}',
                label: context.l10n.statStoreActive,
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
  const _StatChip({
    required this.icon,
    required this.count,
    required this.label,
  });

  final IconData icon;
  final String count;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.x3l),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: context.textSecondary),
          const SizedBox(width: AppSpacing.xs),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: count,
                  style: AppTypography.mono.copyWith(
                    fontSize: 12,
                    color: context.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(text: ' $label'),
              ],
            ),
            style: AppTypography.labelSmall,
          ),
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
        child: AppCachedNetworkImage(
          imageUrl: logoUrl!,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          memCacheWidth: 150,
          memCacheHeight: 150,
          errorWidget: (ctx, __, ___) => _gradientBox(ctx, initials),
        ),
      );
    }
    return _gradientBox(context, initials);
  }

  Widget _gradientBox(BuildContext context, String letter) {
    return Container(
      width: 50,
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.sm + AppSpacing.xs),
        gradient: LinearGradient(colors: context.brandGradient),
      ),
      child: Text(
        letter,
        style: AppTypography.headlineSmall.copyWith(
          fontSize: 20,
          color: context.onBrandColor,
        ),
      ),
    );
  }
}
