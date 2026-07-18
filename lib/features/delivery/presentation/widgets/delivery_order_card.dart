import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../orders/presentation/widgets/order_status_badge.dart';
import '../../domain/courier_order_flow.dart';

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

  Uri _mapsDirectionsUri(OrderAddress a) => Uri.https(
        'www.google.com',
        '/maps/dir/',
        {'api': '1', 'destination': '${a.street}, ${a.city}'},
      );

  @override
  Widget build(BuildContext context) {
    final action = courierNextAction(order.status);
    final codAmount = codAmountToCollect(order);
    final address = order.deliveryAddress;

    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        border: Border.all(color: context.borderColor.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(color: context.cardShadowColor, blurRadius: 12),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
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
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      context.formatShortDate(order.createdAt),
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: context.textSecondary),
                    ),
                  ],
                ),
              ),
              OrderStatusBadge(status: order.status, compact: true),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _RouteStops(
            order: order,
            onNavigate: () => launchUrl(
              _mapsDirectionsUri(address),
              mode: LaunchMode.externalApplication,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.user,
                      size: 15,
                      color: context.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        order.consumerName,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: context.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  LucideIcons.phone,
                  size: 18,
                  color: context.primaryColor,
                ),
                onPressed: () =>
                    launchUrl(Uri(scheme: 'tel', path: order.consumerPhone)),
              ),
            ],
          ),
          if (order.items.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Icon(
                  LucideIcons.package,
                  size: 15,
                  color: context.textSecondary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    context.l10n.courierItemsSummary(
                      order.items.length,
                      context.formatCurrency(order.total),
                    ),
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: context.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          _CollectChip(codAmount: codAmount, status: order.status),
          if (action != CourierOrderAction.none) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                if (onFailed != null)
                  TextButton(
                    onPressed: onFailed,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                    child: Text(context.l10n.courierFailAction),
                  ),
                const Spacer(),
                if (action == CourierOrderAction.pickUp)
                  FilledButton.icon(
                    onPressed: onPickedUp,
                    icon: const Icon(LucideIcons.packageCheck, size: 16),
                    label: Text(context.l10n.courierPickUpAction),
                  )
                else
                  FilledButton.icon(
                    onPressed: onDelivered,
                    icon: const Icon(LucideIcons.checkCircle2, size: 16),
                    label: Text(context.l10n.courierDeliverAction),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Pickup (vendor store) → drop-off (buyer address) as a two-stop route with
/// a connector line; the drop-off stop opens Google Maps directions.
class _RouteStops extends StatelessWidget {
  const _RouteStops({required this.order, required this.onNavigate});

  final OrderEntity order;
  final VoidCallback onNavigate;

  @override
  Widget build(BuildContext context) {
    final address = order.deliveryAddress;
    final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: context.textSecondary,
          letterSpacing: 0.4,
        );
    final valueStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: context.textPrimary,
          fontWeight: FontWeight.w600,
        );

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Icon(LucideIcons.store, size: 16, color: context.textSecondary),
              Expanded(
                child: Container(
                  width: 2,
                  margin: const EdgeInsets.symmetric(vertical: 3),
                  decoration: BoxDecoration(
                    color: context.borderColor,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
              Icon(LucideIcons.mapPin, size: 16, color: context.primaryColor),
            ],
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.courierPickupLabel.toUpperCase(),
                  style: labelStyle,
                ),
                Text(
                  order.vendorStoreName,
                  style: valueStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  context.l10n.courierDropoffLabel.toUpperCase(),
                  style: labelStyle,
                ),
                InkWell(
                  onTap: onNavigate,
                  child: Text(
                    '${address.street}, ${address.city}',
                    style: valueStyle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: context.l10n.courierNavigateHint,
            icon: Icon(
              LucideIcons.navigation,
              size: 18,
              color: context.primaryColor,
            ),
            onPressed: onNavigate,
          ),
        ],
      ),
    );
  }
}

class _CollectChip extends StatelessWidget {
  const _CollectChip({required this.codAmount, required this.status});

  final double codAmount;
  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final isCod = codAmount > 0;
    final color = isCod ? AppColors.warning : AppColors.success;
    final label = isCod
        ? context.l10n.courierCollectAmount(context.formatCurrency(codAmount))
        : context.l10n.courierPrepaidChip;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCod ? LucideIcons.banknote : LucideIcons.creditCard,
            size: 15,
            color: color,
          ),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
