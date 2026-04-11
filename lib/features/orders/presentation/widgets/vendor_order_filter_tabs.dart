import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../domain/entities/order_entity.dart';

class VendorOrderFilterTabs extends StatefulWidget {
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
  State<VendorOrderFilterTabs> createState() => _VendorOrderFilterTabsState();
}

class _VendorOrderFilterTabsState extends State<VendorOrderFilterTabs>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    // Eager init: lazy `late final` + initializer would run on first read only.
    // If `dispose` runs before any `shouldPulse` tab built, lazy init ran while
    // unmounted → TickerMode lookup crashed.
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = <({OrderStatus? status, String label, int count})>[
      (
        status: null,
        label: context.l10n.ordersFilterAll,
        count: widget.totalCount,
      ),
      (
        status: OrderStatus.pending,
        label: context.l10n.ordersFilterPending,
        count: widget.pendingCount,
      ),
      (
        status: OrderStatus.confirmed,
        label: context.l10n.ordersFilterConfirmed,
        count: widget.confirmedCount,
      ),
      (
        status: OrderStatus.processing,
        label: context.l10n.ordersFilterProcessing,
        count: widget.processingCount,
      ),
      (
        status: OrderStatus.shipped,
        label: context.l10n.ordersFilterShipped,
        count: widget.shippedCount,
      ),
      (
        status: OrderStatus.delivered,
        label: context.l10n.ordersFilterDelivered,
        count: widget.deliveredCount,
      ),
      (
        status: OrderStatus.cancelled,
        label: context.l10n.ordersFilterCancelled,
        count: widget.cancelledCount,
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
          final selected = widget.selected == item.status;
          final isPending = item.status == OrderStatus.pending;
          final shouldPulse = isPending && item.count > 0 && !selected;
          return GestureDetector(
            onTap: () => widget.onTap(item.status),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : context.surfaceColor,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: isPending && !selected
                      ? AppColors.warning
                      : context.borderColor.withValues(alpha: 0.7),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (shouldPulse)
                    AnimatedBuilder(
                      animation: _pulse,
                      builder: (context, child) => Transform.scale(
                        scale: 1 + 0.18 * math.sin(_pulse.value * math.pi),
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
                      color: selected
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
                        color: selected
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
