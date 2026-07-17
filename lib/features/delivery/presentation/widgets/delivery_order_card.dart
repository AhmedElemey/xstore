import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../orders/presentation/widgets/order_status_badge.dart';
import '../../domain/courier_order_flow.dart';

/// One delivery task on the courier's run: where to pick up, where to drop
/// off, and how much cash to collect at the door.
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

  /// Google Maps directions to the buyer's door. The order carries a plain
  /// text address (no lat/lng on the wire yet), so navigate by query —
  /// Maps geocodes it and starts routing.
  Uri _mapsDirectionsUri(OrderAddress address) => Uri.https(
        'www.google.com',
        '/maps/dir/',
        {
          'api': '1',
          'destination': '${address.street}, ${address.city}',
        },
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
                child: Text(
                  order.formattedOrderId,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              OrderStatusBadge(status: order.status, compact: true),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _InfoLine(
            icon: LucideIcons.store,
            text: order.vendorStoreName,
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => launchUrl(
                    _mapsDirectionsUri(address),
                    mode: LaunchMode.externalApplication,
                  ),
                  child: _InfoLine(
                    icon: LucideIcons.mapPin,
                    text: '${address.street}, ${address.city}',
                  ),
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
                onPressed: () => launchUrl(
                  _mapsDirectionsUri(address),
                  mode: LaunchMode.externalApplication,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(
                child: _InfoLine(
                  icon: LucideIcons.user,
                  text: order.consumerName,
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

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: context.textSecondary),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: context.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
