import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/xstore_button.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../orders/presentation/widgets/order_status_badge.dart';
import '../../domain/courier_order_flow.dart';
import '../../domain/delivery_request_flow.dart';
import 'courier_card_sections.dart';

/// One delivery task on the courier's run: a pickup→drop-off route, who to
/// hand over to, what to collect at the door, and the next action.
class DeliveryOrderCard extends StatelessWidget {
  const DeliveryOrderCard({
    super.key,
    required this.order,
    this.onPickedUp,
    this.onDelivered,
    this.onFailed,
  });

  final OrderEntity order;
  final VoidCallback? onPickedUp;
  final VoidCallback? onDelivered;
  final VoidCallback? onFailed;

  @override
  Widget build(BuildContext context) {
    final action = courierNextAction(order.status);
    final codAmount = codAmountToCollect(order);
    final address = order.deliveryAddress;

    return CourierCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.formattedOrderId,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      context.formatShortDate(order.createdAt),
                      style: AppTypography.bodySmall.copyWith(
                        color: context.labelColor,
                      ),
                    ),
                  ],
                ),
              ),
              OrderStatusBadge(status: order.status, compact: true),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          CourierRouteStops(
            pickupValue: order.vendorStoreName,
            dropoffValue: '${address.street}, ${address.city}',
            onNavigate: () => launchUrl(
              courierMapsDirectionsUri(address),
              mode: LaunchMode.externalApplication,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          CourierIdentityRow(
            visible: courierSeesOrderCustomerIdentity(order.status),
            name: order.consumerName,
            phone: order.consumerPhone,
          ),
          if (order.items.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Icon(LucideIcons.package, size: 15, color: context.labelColor),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    context.l10n.courierItemsSummary(
                      order.items.length,
                      context.formatCurrency(order.total),
                    ),
                    style: AppTypography.bodySmall.copyWith(
                      color: context.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          if (codAmount > 0)
            CourierCollectRow(
              label: context.l10n.courierCollectFromCustomer,
              amountText: context.formatCurrency(codAmount),
            )
          else
            const _PrepaidChip(),
          if (action != CourierOrderAction.none) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                if (onFailed != null) ...[
                  TextButton(
                    onPressed: onFailed,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                    child: Text(context.l10n.courierFailAction),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Expanded(
                  child: XstoreButton(
                    gradient: AppColors.courierGradient,
                    foregroundColor: AppColors.onCourier,
                    label: action == CourierOrderAction.pickUp
                        ? context.l10n.courierPickUpAction
                        : context.l10n.courierDeliverAction,
                    onPressed: action == CourierOrderAction.pickUp
                        ? onPickedUp
                        : onDelivered,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Zero-cash variant: nothing to collect at the door.
class _PrepaidChip extends StatelessWidget {
  const _PrepaidChip();

  @override
  Widget build(BuildContext context) {
    const color = AppColors.success;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.creditCard, size: 15, color: color),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              context.l10n.courierPrepaidChip,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
