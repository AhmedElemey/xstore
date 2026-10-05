import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../domain/entities/order_entity.dart';

Color orderStatusColor(OrderStatus s) => switch (s) {
  OrderStatus.pending => AppColors.orderStatusPending,
  OrderStatus.confirmed => AppColors.orderStatusConfirmed,
  OrderStatus.processing => AppColors.orderStatusProcessing,
  OrderStatus.shipped => AppColors.orderStatusShipped,
  OrderStatus.delivered => AppColors.orderStatusDelivered,
  OrderStatus.cancelled => AppColors.orderStatusCancelled,
};

String orderStatusLabel(BuildContext context, OrderStatus s) => switch (s) {
  OrderStatus.pending => context.l10n.ordersFilterPending,
  OrderStatus.confirmed => context.l10n.ordersFilterConfirmed,
  OrderStatus.processing => context.l10n.ordersFilterProcessing,
  OrderStatus.shipped => context.l10n.ordersFilterShipped,
  OrderStatus.delivered => context.l10n.ordersFilterDelivered,
  OrderStatus.cancelled => context.l10n.ordersFilterCancelled,
};

/// Orbit status pill: the status colour at 16% behind its own text. Light
/// mode darkens the text so it stays readable on the pale card.
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
    final accent = orderStatusColor(status);
    final fg = context.isDark
        ? accent
        : Color.lerp(accent, AppColors.black, 0.35)!;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppSpacing.sm : AppSpacing.md,
        vertical: compact ? AppSpacing.xs : AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        orderStatusLabel(context, status),
        style: AppTypography.labelSmall.copyWith(
          color: fg,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
