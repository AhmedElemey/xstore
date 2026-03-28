import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/order_entity.dart';

Color orderStatusColor(OrderStatus s) => switch (s) {
      OrderStatus.pending => AppColors.orderStatusPending,
      OrderStatus.confirmed => AppColors.orderStatusConfirmed,
      OrderStatus.processing => AppColors.orderStatusProcessing,
      OrderStatus.shipped => AppColors.orderStatusShipped,
      OrderStatus.delivered => AppColors.orderStatusDelivered,
      OrderStatus.cancelled => AppColors.orderStatusCancelled,
      OrderStatus.refunded => AppColors.orderStatusRefunded,
    };

String orderStatusLabel(OrderStatus s) => switch (s) {
      OrderStatus.pending => AppStrings.ordersFilterPending,
      OrderStatus.confirmed => AppStrings.ordersFilterConfirmed,
      OrderStatus.processing => AppStrings.ordersFilterProcessing,
      OrderStatus.shipped => AppStrings.ordersFilterShipped,
      OrderStatus.delivered => AppStrings.ordersFilterDelivered,
      OrderStatus.cancelled => AppStrings.ordersFilterCancelled,
      OrderStatus.refunded => AppStrings.ordersFilterRefunded,
    };

class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  final OrderStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final bg = orderStatusColor(status);
    final fg = AppColors.white;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppSpacing.sm : AppSpacing.md,
        vertical: compact ? AppSpacing.xs : AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.x4l),
      ),
      child: Text(
        orderStatusLabel(status),
        style: AppTypography.labelSmall.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
