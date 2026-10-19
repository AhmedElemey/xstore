import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../orders/domain/entities/order_entity.dart';

/// Google Maps directions to [address] (shared by every courier card).
Uri courierMapsDirectionsUri(OrderAddress address) => Uri.https(
  'www.google.com',
  '/maps/dir/',
  {'api': '1', 'destination': '${address.street}, ${address.city}'},
);

/// Orbit glass chrome shared by the order and package cards.
class CourierCardShell extends StatelessWidget {
  const CourierCardShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.glassColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.borderColor),
      ),
      child: child,
    );
  }
}

/// Pickup → drop-off as a two-stop node-and-trail route (hollow ring, solid
/// amber trail, filled amber node); the drop-off text and the trailing
/// navigation button both trigger [onNavigate].
class CourierRouteStops extends StatelessWidget {
  const CourierRouteStops({
    super.key,
    required this.pickupValue,
    required this.dropoffValue,
    required this.onNavigate,
  });

  final String pickupValue;
  final String dropoffValue;
  final VoidCallback onNavigate;

  @override
  Widget build(BuildContext context) {
    final amber = context.amberColor;
    final labelStyle = AppTypography.fieldLabel.copyWith(
      color: context.labelColor,
      fontSize: 11,
    );
    final valueStyle = AppTypography.bodySmall.copyWith(
      color: context.textPrimary,
      fontWeight: FontWeight.w700,
    );

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 18,
            child: Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: amber, width: 2),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    decoration: BoxDecoration(
                      color: amber.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: amber,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: amber.withValues(alpha: 0.35),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.courierPickupLabel.toUpperCase(),
                  style: labelStyle,
                ),
                const SizedBox(height: 2),
                Text(
                  pickupValue,
                  style: valueStyle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  context.l10n.courierDropoffLabel.toUpperCase(),
                  style: labelStyle,
                ),
                const SizedBox(height: 2),
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
            icon: Icon(LucideIcons.navigation, size: 18, color: amber),
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
            Icon(LucideIcons.lock, size: 15, color: context.labelColor),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                context.l10n.courierIdentityLocked,
                style: AppTypography.bodySmall.copyWith(
                  color: context.labelColor,
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
        Icon(LucideIcons.user, size: 15, color: context.labelColor),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            name,
            style: AppTypography.bodySmall.copyWith(
              color: context.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          icon: Icon(LucideIcons.phone, size: 18, color: context.amberColor),
          onPressed: () => launchUrl(Uri(scheme: 'tel', path: phone)),
        ),
      ],
    );
  }
}

/// Labeled cash-collection row: "Collect from …" + amber mono EGP amount on a
/// glass amber-accent strip. [prominent] turns up the visual weight where
/// cash actually changes hands (a package pickup from the sender).
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
    final color = context.amberColor;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: prominent ? AppSpacing.md : AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: prominent ? 0.16 : 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: prominent ? 0.5 : 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.banknote, size: prominent ? 18 : 15, color: color),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            amountText,
            style: AppTypography.mono.copyWith(
              color: color,
              fontSize: prominent ? 18 : 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Glass cash-limit warning with a warning accent, shown on both courier tabs
/// while a handover is due.
class CourierHandoverBanner extends StatelessWidget {
  const CourierHandoverBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.glassColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.55)),
      ),
      child: Row(
        children: [
          const Icon(
            LucideIcons.alertTriangle,
            color: AppColors.warning,
            size: 18,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              context.l10n.courierHandoverDueBanner,
              style: AppTypography.bodySmall.copyWith(
                color: context.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
