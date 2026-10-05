import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/order_entity.dart';
import '../providers/orders_provider.dart';
import 'order_status_badge.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class OrderFilterTabs extends ConsumerWidget {
  const OrderFilterTabs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(
      ordersNotifierProvider.select((s) => s.selectedFilter),
    );
    final counts = ref.watch(
      ordersNotifierProvider.select((s) {
        final map = <OrderStatus, int>{};
        for (final order in s.orders) {
          map.update(order.status, (value) => value + 1, ifAbsent: () => 1);
        }
        return (all: s.orders.length, byStatus: map);
      }),
    );
    final notifier = ref.read(ordersNotifierProvider.notifier);

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        children: [
          _chip(
            context,
            label: context.l10n.ordersFilterAll,
            count: counts.all,
            selected: selected == null,
            onTap: () => notifier.applyFilter(null),
          ),
          ...OrderStatus.values.map((f) {
            return Padding(
              padding: const EdgeInsets.only(left: AppSpacing.sm),
              child: _chip(
                context,
                label: orderStatusLabel(context, f),
                count: counts.byStatus[f] ?? 0,
                selected: selected == f,
                onTap: () => notifier.applyFilter(f),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _chip(
    BuildContext context, {
    required String label,
    required int count,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: selected ? AppColors.primary : context.surfaceColor,
      borderRadius: BorderRadius.circular(AppSpacing.x4l),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.x4l),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Text(
            '$label ($count)',
            style: AppTypography.labelLarge.copyWith(
              color: selected ? AppColors.white : context.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
