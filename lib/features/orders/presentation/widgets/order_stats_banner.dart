import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../providers/orders_provider.dart';

class OrderStatsBanner extends ConsumerWidget {
  const OrderStatsBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(ordersNotifierProvider).stats;
    if (stats == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.profileHeaderGradientEnd.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.04),
            blurRadius: AppSpacing.md,
            offset: const Offset(0, AppSpacing.xs),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _MiniStat(
              icon: LucideIcons.clock,
              value: '${stats.pendingCount}',
              label: AppStrings.ordersStatPendingLabel,
              background: AppColors.orderStatusPending.withValues(alpha: 0.18),
            ),
          ),
          Expanded(
            child: _MiniStat(
              icon: LucideIcons.package,
              value: '${stats.activeCount}',
              label: AppStrings.ordersStatActiveLabelTitle,
              background: AppColors.orderStatusConfirmed.withValues(alpha: 0.1),
            ),
          ),
          Expanded(
            child: _MiniStat(
              icon: LucideIcons.calendar,
              value: '${stats.monthCount}',
              label: AppStrings.ordersStatMonthLabel,
              background: AppColors.cardBg,
            ),
          ),
          Expanded(
            child: _MiniStat(
              icon: LucideIcons.hash,
              value: '${stats.totalCount}',
              label: AppStrings.ordersStatTotalLabel,
              background: AppColors.cardBg,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.background,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppSpacing.md),
      ),
      child: Column(
        children: [
          Icon(icon, size: AppSpacing.x2l, color: AppColors.primary),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.titleMedium.copyWith(fontSize: 18),
          ),
          Text(
            label,
            style: AppTypography.labelSmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
