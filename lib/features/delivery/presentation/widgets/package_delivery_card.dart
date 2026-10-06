import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/xstore_button.dart';
import '../../domain/delivery_request_flow.dart';
import '../../domain/entities/delivery_request.dart';
import 'courier_card_sections.dart';

/// One point-to-point package task on the courier's run: sender's address →
/// recipient's address, the cash to collect from the sender at pickup, and
/// the next action. Cash changes hands at PICKUP (admin-priced, the app
/// never holds money), so the collect row is prominent at that stage and
/// navigation targets the pickup address first.
class PackageDeliveryCard extends StatelessWidget {
  const PackageDeliveryCard({
    super.key,
    required this.request,
    this.onPickedUp,
    this.onDelivered,
  });

  final DeliveryRequestEntity request;
  final VoidCallback? onPickedUp;
  final VoidCallback? onDelivered;

  @override
  Widget build(BuildContext context) {
    final action = courierPackageNextAction(request.status);
    final cashAmount = cashToCollectFromSender(request);
    final atPickupStage = action == CourierPackageAction.collectAndPickUp;
    // Heading to the sender first; once the parcel is on board, to the
    // recipient.
    final navigationTarget = atPickupStage ? request.pickup : request.dropoff;

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
                      // No human-readable package reference exists: use the
                      // linked order when there is one, never the raw id.
                      request.orderId != null
                          ? context.l10n.orderPlacedNumber(request.orderId!)
                          : context.l10n.courierPackageTitle,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      context.formatShortDate(request.createdAt),
                      style: AppTypography.bodySmall.copyWith(
                        color: context.labelColor,
                      ),
                    ),
                  ],
                ),
              ),
              _PackageStatusChip(status: request.status),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          CourierRouteStops(
            pickupValue: '${request.pickup.street}, ${request.pickup.city}',
            dropoffValue: '${request.dropoff.street}, ${request.dropoff.city}',
            onNavigate: () => launchUrl(
              courierMapsDirectionsUri(navigationTarget),
              mode: LaunchMode.externalApplication,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Sender identity — masked until the request is confirmed.
          CourierIdentityRow(
            visible: courierSeesCustomerIdentity(request.status),
            name: request.pickup.fullName,
            phone: request.pickup.phone,
          ),
          if (request.packageNote.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  LucideIcons.stickyNote,
                  size: 15,
                  color: context.labelColor,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    request.packageNote,
                    style: AppTypography.bodySmall.copyWith(
                      color: context.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          if (cashAmount > 0) ...[
            const SizedBox(height: AppSpacing.sm),
            CourierCollectRow(
              label: context.l10n.courierCollectFromSender,
              amountText: context.formatCurrency(cashAmount),
              prominent: atPickupStage,
            ),
          ],
          if (action != CourierPackageAction.none) ...[
            const SizedBox(height: AppSpacing.md),
            XstoreButton(
              gradient: AppColors.courierGradient,
              foregroundColor: AppColors.onCourier,
              label: atPickupStage
                  ? context.l10n.courierPackagePickUpAction
                  : context.l10n.courierDeliverAction,
              onPressed: atPickupStage ? onPickedUp : onDelivered,
            ),
          ],
        ],
      ),
    );
  }
}

class _PackageStatusChip extends StatelessWidget {
  const _PackageStatusChip({required this.status});

  final DeliveryRequestStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (label, color) = switch (status) {
      DeliveryRequestStatus.submitted => (
        l10n.courierPkgStatusSubmitted,
        context.labelColor,
      ),
      DeliveryRequestStatus.priced => (
        l10n.courierPkgStatusPriced,
        context.labelColor,
      ),
      DeliveryRequestStatus.confirmed => (
        l10n.courierPkgStatusConfirmed,
        AppColors.warning,
      ),
      DeliveryRequestStatus.pickedUp => (
        l10n.courierPkgStatusPickedUp,
        context.primaryColor,
      ),
      DeliveryRequestStatus.delivered => (
        l10n.courierPkgStatusDelivered,
        AppColors.success,
      ),
      DeliveryRequestStatus.cancelled => (
        l10n.courierPkgStatusCancelled,
        AppColors.error,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: context.isDark
              ? color
              : Color.lerp(color, AppColors.black, 0.35),
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
