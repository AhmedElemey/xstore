import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../orders/domain/entities/order_entity.dart';

/// Google Maps directions to [address] (shared by every courier card).
Uri courierMapsDirectionsUri(OrderAddress address) => Uri.https(
      'www.google.com',
      '/maps/dir/',
      {'api': '1', 'destination': '${address.street}, ${address.city}'},
    );

/// Pickup → drop-off as a two-stop route with a connector line; the drop-off
/// text and the trailing navigation button both trigger [onNavigate].
class CourierRouteStops extends StatelessWidget {
  const CourierRouteStops({
    super.key,
    required this.pickupValue,
    required this.dropoffValue,
    required this.onNavigate,
    this.pickupIcon = LucideIcons.store,
  });

  final String pickupValue;
  final String dropoffValue;
  final VoidCallback onNavigate;
  final IconData pickupIcon;

  @override
  Widget build(BuildContext context) {
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
              Icon(pickupIcon, size: 16, color: context.textSecondary),
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
                  pickupValue,
                  style: valueStyle,
                  maxLines: 2,
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
                    dropoffValue,
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

/// Customer/sender identity line. While [visible] is false the courier sees a
/// masked placeholder and no call affordance (privacy rule: identity unlocks
/// only once the task is confirmed).
class CourierIdentityRow extends StatelessWidget {
  const CourierIdentityRow({
    super.key,
    required this.visible,
    required this.name,
    required this.phone,
  });

  final bool visible;
  final String name;
  final String phone;

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            Icon(LucideIcons.lock, size: 15, color: context.textSecondary),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                context.l10n.courierIdentityLocked,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        Icon(LucideIcons.user, size: 15, color: context.textSecondary),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            name,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: context.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          icon: Icon(
            LucideIcons.phone,
            size: 18,
            color: context.primaryColor,
          ),
          onPressed: () => launchUrl(Uri(scheme: 'tel', path: phone)),
        ),
      ],
    );
  }
}

/// Labeled cash-collection row: "Collect from …" + bold EGP amount.
/// [prominent] turns up the visual weight where cash actually changes hands
/// (a package pickup from the sender).
class CourierCollectRow extends StatelessWidget {
  const CourierCollectRow({
    super.key,
    required this.label,
    required this.amountText,
    this.prominent = false,
  });

  final String label;
  final String amountText;
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    const color = AppColors.warning;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: prominent ? AppSpacing.md : AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: prominent ? 0.16 : 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        border: prominent
            ? Border.all(color: color.withValues(alpha: 0.5))
            : null,
      ),
      child: Row(
        children: [
          Icon(
            LucideIcons.banknote,
            size: prominent ? 18 : 15,
            color: color,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
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
          Text(
            amountText,
            style: (prominent
                    ? Theme.of(context).textTheme.titleMedium
                    : Theme.of(context).textTheme.labelLarge)
                ?.copyWith(color: color, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
