import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/pulsing_animation_builder.dart';
import '../../domain/entities/order_entity.dart';

class VendorOrderFilterTabs extends StatelessWidget {
  const VendorOrderFilterTabs({
    super.key,
    required this.selected,
    required this.totalCount,
    required this.pendingCount,
    required this.confirmedCount,
    required this.processingCount,
    required this.shippedCount,
    required this.deliveredCount,
    required this.cancelledCount,
    required this.onTap,
  });

  final OrderStatus? selected;
  final int totalCount;
  final int pendingCount;
  final int confirmedCount;
  final int processingCount;
  final int shippedCount;
  final int deliveredCount;
  final int cancelledCount;
  final ValueChanged<OrderStatus?> onTap;

  @override
  Widget build(BuildContext context) {
    final items = <({OrderStatus? status, String label, int count})>[
      (
        status: null,
        label: context.l10n.ordersFilterAll,
        count: totalCount,
      ),
      (
        status: OrderStatus.pending,
        label: context.l10n.ordersFilterPending,
        count: pendingCount,
      ),
      (
        status: OrderStatus.confirmed,
        label: context.l10n.ordersFilterConfirmed,
        count: confirmedCount,
      ),
      (
        status: OrderStatus.processing,
        label: context.l10n.ordersFilterProcessing,
        count: processingCount,
      ),
      (
        status: OrderStatus.shipped,
        label: context.l10n.ordersFilterShipped,
        count: shippedCount,
      ),
      (
        status: OrderStatus.delivered,
        label: context.l10n.ordersFilterDelivered,
        count: deliveredCount,
      ),
      (
        status: OrderStatus.cancelled,
        label: context.l10n.ordersFilterCancelled,
        count: cancelledCount,
      ),
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, i) {
          final item = items[i];
          final isSelected = selected == item.status;
          final isPending = item.status == OrderStatus.pending;
          final shouldPulse = isPending && item.count > 0 && !isSelected;
          return GestureDetector(
            onTap: () => onTap(item.status),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : context.surfaceColor,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: isPending && !isSelected
                      ? AppColors.warning
                      : context.borderColor.withValues(alpha: 0.7),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (shouldPulse)
                    PulsingAnimationBuilder(
                      duration: const Duration(milliseconds: 1100),
                      builder: (context, animation, child) => Transform.scale(
                        scale: 1 + 0.18 * math.sin(animation.value * math.pi),
                        child: child,
                      ),
                      child: const Icon(
                        Icons.circle,
                        size: 8,
                        color: AppColors.warning,
                      ),
                    ),
                  if (shouldPulse) const SizedBox(width: AppSpacing.xs),
                  Text(
                    item.label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimary
                          : (isPending
                                ? AppColors.warning
                                : context.textPrimary),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (item.count > 0) ...[
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '(${item.count})',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : context.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
