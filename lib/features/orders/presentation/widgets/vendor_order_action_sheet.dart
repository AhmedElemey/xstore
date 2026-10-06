import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/xstore_button.dart';
import '../../domain/entities/order_entity.dart';

class VendorOrderActionSheet extends StatelessWidget {
  const VendorOrderActionSheet({
    super.key,
    required this.order,
    required this.onConfirm,
    required this.onReject,
    required this.onProcessing,
    required this.onShipped,
    required this.onDelivered,
  });

  final OrderEntity order;
  final VoidCallback onConfirm;
  final VoidCallback onReject;
  final VoidCallback onProcessing;
  final VoidCallback onShipped;
  final VoidCallback onDelivered;

  @override
  Widget build(BuildContext context) {
    if (order.status == OrderStatus.delivered ||
        order.status == OrderStatus.cancelled) {
      return const SizedBox.shrink();
    }
    // Same sticky footer chrome as the consumer order detail.
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.backgroundColor.withValues(alpha: 0.96),
        border: Border(top: BorderSide(color: context.borderColor)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.xl,
            AppSpacing.md,
          ),
          child: _buildByStatus(context),
        ),
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
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                context.l10n.vendorRejectOrder,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: FilledButton(
              onPressed: onConfirm,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.success,
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                context.l10n.vendorConfirmOrderShort,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      );
    }
    if (order.status == OrderStatus.confirmed) {
      return XstoreButton(
        label: context.l10n.vendorMarkProcessing,
        onPressed: onProcessing,
      );
    }
    if (order.status == OrderStatus.shipped) {
      return XstoreButton(
        label: context.l10n.vendorMarkDelivered,
        onPressed: onDelivered,
      );
    }
    return XstoreButton(
      label: context.l10n.vendorMarkShipped,
      onPressed: onShipped,
    );
  }
}
