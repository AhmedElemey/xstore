import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_cached_network_image.dart';
import '../../../../shared/widgets/orbit_widgets.dart';
import '../../../../shared/widgets/xstore_button.dart';
import '../../domain/entities/order_entity.dart';
import 'order_status_badge.dart';

class VendorOrderCard extends StatelessWidget {
  const VendorOrderCard({
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
    final name = order.consumerName.trim();
    final place = [
      if (name.isNotEmpty) name,
      if (order.deliveryAddress.city.trim().isNotEmpty)
        order.deliveryAddress.city.trim(),
    ].join(' · ');
    final item = order.items.isEmpty ? null : order.items.first;
    final isNew = order.status == OrderStatus.pending;
    final warm = context.cashColor;
    final accent = isNew ? warm : orderStatusColor(order.status);
    final extra = order.items.length - 1;
    final title = item == null
        ? '${context.l10n.orderHashPrefix}${order.formattedOrderId}'
        : '${item.listingName}${item.quantity > 1 ? ' × ${item.quantity}' : ''}'
            '${extra > 0 ? ' +$extra' : ''}';
    final actions = _actions(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: isNew
            ? [
                BoxShadow(color: warm.withValues(alpha: 0.08), spreadRadius: 4),
                BoxShadow(color: warm.withValues(alpha: 0.12), blurRadius: 30),
              ]
            : null,
      ),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        borderColor: isNew ? warm.withValues(alpha: 0.5) : null,
        onTap: () => context.push('${AppRoutes.vendorOrders}/${order.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent,
                    boxShadow: [BoxShadow(color: accent, blurRadius: 10)],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    '${orderStatusLabel(context, order.status).toUpperCase()}'
                    ' · ${Formatters.formatNotificationTime(order.createdAt, context.l10n)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelSmall.copyWith(
                      fontWeight: FontWeight.w800,
                      color: accent,
                    ),
                  ),
                ),
                Text(
                  '#${order.formattedOrderId}',
                  style: AppTypography.labelSmall.copyWith(
                    color: context.textSecondary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: 52,
                    height: 52,
                    child: item != null && item.listingImage.trim().isNotEmpty
                        ? AppCachedNetworkImage(
                            imageUrl: item.listingImage,
                            fit: BoxFit.cover,
                            memCacheWidth: 156,
                            memCacheHeight: 156,
                          )
                        : DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: orbitOrbGradient(3),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodyLarge.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: context.textPrimary,
                        ),
                      ),
                      if (place.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          place,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySmall.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  context.formatCurrency(order.total),
                  style: AppTypography.bodyLarge.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: warm,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
            if (actions != null) ...[
              const SizedBox(height: AppSpacing.md),
              actions,
            ],
          ],
        ),
      ),
    );
  }

  Widget? _actions(BuildContext context) {
    Widget warmAction(String label, VoidCallback onTap) => XstoreButton(
          label: label,
          warm: true,
          height: 44,
          onPressed: onTap,
        );
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
                minimumSize: const Size(0, 44),
                padding: const EdgeInsets.symmetric(horizontal: 18),
              ),
              child: Text(context.l10n.vendorRejectOrder),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: warmAction(context.l10n.vendorConfirmOrder, onConfirm),
            ),
          ],
        ),
      OrderStatus.confirmed =>
        warmAction(context.l10n.vendorMarkProcessing, onProcessing),
      OrderStatus.processing =>
        warmAction(context.l10n.vendorMarkShipped, onShipped),
      OrderStatus.shipped =>
        warmAction(context.l10n.vendorMarkDelivered, onDelivered),
      OrderStatus.delivered || OrderStatus.cancelled => null,
    };
  }
}
