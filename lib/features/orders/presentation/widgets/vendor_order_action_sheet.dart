import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/xstore_button.dart';
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
    Widget warm(String label, VoidCallback onTap) =>
        XstoreButton(label: label, warm: true, onPressed: onTap);
    return switch (order.status) {
      OrderStatus.pending => Row(
          children: [
            OutlinedButton(
              onPressed: onReject,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.errorLight,
                side: BorderSide(
                  color: AppColors.errorLight.withValues(alpha: 0.45),
                ),
                minimumSize: const Size(0, 56),
                padding: const EdgeInsets.symmetric(horizontal: 18),
              ),
              child: Text(context.l10n.vendorRejectOrder),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: warm(context.l10n.vendorConfirmOrderShort, onConfirm),
            ),
          ],
        ),
      OrderStatus.confirmed => warm(context.l10n.vendorMarkProcessing, onProcessing),
      OrderStatus.shipped => warm(context.l10n.vendorMarkDelivered, onDelivered),
      _ => warm(context.l10n.vendorMarkShipped, onShipped),
    };
  }
}
