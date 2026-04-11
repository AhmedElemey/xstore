import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../domain/entities/order_entity.dart';

class VendorOrderActionSheet extends StatelessWidget {
  const VendorOrderActionSheet({
    super.key,
    required this.order,
    required this.onConfirm,
    required this.onReject,
    required this.onProcessing,
    required this.onShipped,
  });

  final OrderEntity order;
  final VoidCallback onConfirm;
  final VoidCallback onReject;
  final VoidCallback onProcessing;
  final VoidCallback onShipped;

  @override
  Widget build(BuildContext context) {
    if (order.status == OrderStatus.shipped ||
        order.status == OrderStatus.delivered ||
        order.status == OrderStatus.cancelled ||
        order.status == OrderStatus.refunded) {
      return const SizedBox.shrink();
    }
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        child: _buildByStatus(context),
      ),
    );
  }

  Widget _buildByStatus(BuildContext context) {
    if (order.status == OrderStatus.pending) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onReject,
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
              child: Text(context.l10n.vendorRejectOrder),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            flex: 2,
            child: FilledButton(
              onPressed: onConfirm,
              style: FilledButton.styleFrom(backgroundColor: AppColors.success),
              child: Text(context.l10n.vendorConfirmOrderShort),
            ),
          ),
        ],
      );
    }
    if (order.status == OrderStatus.confirmed) {
      return FilledButton(
        onPressed: onProcessing,
        child: Text(context.l10n.vendorMarkProcessing),
      );
    }
    return FilledButton(
      onPressed: onShipped,
      child: Text(context.l10n.vendorMarkShipped),
    );
  }
}
