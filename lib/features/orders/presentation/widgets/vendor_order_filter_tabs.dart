import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
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
      (status: null, label: context.l10n.ordersFilterAll, count: totalCount),
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

    final selectedBg = context.isDark ? context.textPrimary : AppColors.primary;
    final selectedFg = context.isDark ? AppColors.darkOnBrand : AppColors.white;
    final pendingFg = context.isDark
        ? AppColors.warning
        : Color.lerp(AppColors.warning, AppColors.black, 0.35)!;

    // Orbit segmented bar: a frosted capsule holding scrollable pills.
    return Container(
      height: 46,
      margin: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.xl),
      decoration: BoxDecoration(
        color: context.glassColor,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: context.borderColor),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.all(4),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 4),
        itemBuilder: (context, i) {
          final item = items[i];
          final isSelected = selected == item.status;
          final isPending = item.status == OrderStatus.pending;
          final shouldPulse = isPending && item.count > 0 && !isSelected;
          final fg = isSelected
              ? selectedFg
              : (isPending ? pendingFg : context.textSecondary);
          return Material(
            color: isSelected ? selectedBg : AppColors.transparent,
            borderRadius: BorderRadius.circular(19),
            child: InkWell(
              onTap: () => onTap(item.status),
              borderRadius: BorderRadius.circular(19),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (shouldPulse) ...[
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
                      const SizedBox(width: AppSpacing.xs),
                    ],
                    Text(
                      item.count > 0
                          ? '${item.label} (${item.count})'
                          : item.label,
                      style: AppTypography.labelLarge.copyWith(
                        color: fg,
                        fontWeight: isSelected
                            ? FontWeight.w800
                            : FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
