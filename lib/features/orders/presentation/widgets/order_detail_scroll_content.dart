import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/app_routes.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../domain/entities/order_entity.dart';
import 'order_item_tile.dart';
import 'order_price_breakdown.dart';
import 'order_status_badge.dart';
import 'order_timeline.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_snackbar.dart';

class OrderDetailScrollContent extends ConsumerWidget {
  const OrderDetailScrollContent({super.key, required this.order});

  final OrderEntity order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isVendor = ref.watch(
      authProvider.select((a) => a.valueOrNull?.role == UserRole.vendor),
    );
    final vendorWhatsApp = ref.watch(
      profileNotifierProvider.select((s) => s.profile?.user.whatsappNumber),
    );

    return SliverList(
      delegate: SliverChildListDelegate([
        _StatusBanner(order: order),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: OrderTimeline(order: order),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              context.l10n.ordersItemsSectionCount(order.items.length),
              style: AppTypography.titleMedium,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            children: order.items.map((i) => OrderItemTile(item: i)).toList(),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            context.l10n.ordersDeliveryAddressTitle,
            style: AppTypography.titleMedium,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: _AddressCard(address: order.deliveryAddress),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (!isVendor)
          _SellerSection(order: order)
        else
          _BuyerSection(order: order, whatsapp: vendorWhatsApp),
        if (order.status == OrderStatus.shipped &&
            (order.trackingNumber != null || order.courierName != null)) ...[
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              context.l10n.ordersTrackingSectionTitle,
              style: AppTypography.titleMedium,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: _TrackingCard(order: order),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            context.l10n.ordersPaymentSectionTitle,
            style: AppTypography.titleMedium,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: _WhiteCard(child: OrderPriceBreakdown(order: order)),
        ),
        if (order.notes != null && order.notes!.trim().isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              context.l10n.ordersNotesSectionTitle,
              style: AppTypography.titleMedium,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: context.textDisabled.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSpacing.md),
              ),
              child: Text(
                order.notes!,
                style: AppTypography.bodyMedium.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.x4l),
      ]),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.order});

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    final c = orderStatusColor(order.status);
    final sub = _subtitle(context, order.status);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.x2l),
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        boxShadow: [
          BoxShadow(
            color: c.withValues(alpha: 0.35),
            blurRadius: AppSpacing.lg,
            offset: const Offset(0, AppSpacing.sm),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_iconFor(order.status), color: AppColors.white, size: 32),
          const SizedBox(height: AppSpacing.md),
          Text(
            orderStatusLabel(context, order.status),
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            sub,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.white.withValues(alpha: 0.95),
            ),
          ),
          if (order.estimatedDelivery != null &&
              (order.status == OrderStatus.shipped ||
                  order.status == OrderStatus.confirmed)) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              '${context.l10n.ordersExpectedPrefix} ${DateFormat('EEEE, MMM d').format(order.estimatedDelivery!.toLocal())}',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _iconFor(OrderStatus s) => switch (s) {
    OrderStatus.pending => Icons.hourglass_top_rounded,
    OrderStatus.confirmed => Icons.check_circle_outline,
    OrderStatus.processing => Icons.inventory_2_outlined,
    OrderStatus.shipped => Icons.local_shipping_outlined,
    OrderStatus.delivered => Icons.verified_rounded,
    OrderStatus.cancelled => Icons.cancel_outlined,
    OrderStatus.refunded => Icons.replay_rounded,
  };

  String _subtitle(BuildContext context, OrderStatus s) => switch (s) {
    OrderStatus.pending => context.l10n.statusSubtitlePending,
    OrderStatus.confirmed => context.l10n.statusSubtitleConfirmed,
    OrderStatus.processing => context.l10n.statusSubtitleProcessing,
    OrderStatus.shipped => context.l10n.statusSubtitleShipped,
    OrderStatus.delivered => context.l10n.statusSubtitleDelivered,
    OrderStatus.cancelled => context.l10n.statusSubtitleCancelled,
    OrderStatus.refunded => context.l10n.statusSubtitleRefunded,
  };
}

class _WhiteCard extends StatelessWidget {
  const _WhiteCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        boxShadow: [
          BoxShadow(
            color: context.textPrimary.withValues(alpha: 0.05),
            blurRadius: AppSpacing.md,
            offset: const Offset(0, AppSpacing.xs),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.address});

  final OrderAddress address;

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📍 ${address.fullName}',
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(address.street, style: AppTypography.bodyMedium),
          Text(
            '${address.city}, ${address.wilaya}${address.postalCode != null ? ' ${address.postalCode}' : ''}',
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text('📞 ${address.phone}', style: AppTypography.bodyMedium),
        ],
      ),
    );
  }
}

class _SellerSection extends StatelessWidget {
  const _SellerSection({required this.order});

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: _WhiteCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.ordersSoldBy, style: AppTypography.titleMedium),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: order.vendorAvatar.isNotEmpty
                      ? NetworkImage(order.vendorAvatar)
                      : null,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.vendorStoreName,
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '⭐ ${order.vendorRating.toStringAsFixed(1)}',
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton(
              onPressed: () => AppSnackbar.info(
                context,
                context.l10n.ordersMessageSellerSoon,
              ),
              child: Text(context.l10n.ordersMessageSeller),
            ),
            const SizedBox(height: AppSpacing.sm),
            FilledButton(
              onPressed: () =>
                  context.push('${AppRoutes.sellerProfile}/${order.vendorId}'),
              child: Text(context.l10n.visitStore),
            ),
          ],
        ),
      ),
    );
  }
}

class _BuyerSection extends StatelessWidget {
  const _BuyerSection({required this.order, required this.whatsapp});

  final OrderEntity order;
  final String? whatsapp;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: _WhiteCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.ordersBuyerInfo, style: AppTypography.titleMedium),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: order.consumerAvatar.isNotEmpty
                      ? NetworkImage(order.consumerAvatar)
                      : null,
                  child: order.consumerAvatar.isEmpty
                      ? Text(
                          order.consumerName.isNotEmpty
                              ? order.consumerName[0].toUpperCase()
                              : '?',
                        )
                      : null,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.consumerName,
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          final uri = Uri(
                            scheme: 'tel',
                            path: order.consumerPhone,
                          );
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          }
                        },
                        child: Text(
                          '📞 ${order.consumerPhone}',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      Text(
                        '📍 ${order.deliveryAddress.city}, ${order.deliveryAddress.wilaya}',
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (whatsapp != null && whatsapp!.trim().isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              OutlinedButton(
                onPressed: () async {
                  final digits = whatsapp!.replaceAll(RegExp(r'\D'), '');
                  final uri = Uri.parse('https://wa.me/$digits');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                child: Text(context.l10n.ordersWhatsapp),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TrackingCard extends StatelessWidget {
  const _TrackingCard({required this.order});

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: SelectableText(
                  order.trackingNumber ?? '—',
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy_rounded),
                onPressed: order.trackingNumber == null
                    ? null
                    : () {
                        Clipboard.setData(
                          ClipboardData(text: order.trackingNumber!),
                        );
                        AppSnackbar.success(
                          context,
                          context.l10n.ordersTrackingCopied,
                        );
                      },
              ),
            ],
          ),
          if (order.courierName != null)
            Text(order.courierName!, style: AppTypography.bodyMedium),
          Text(
            context.l10n.ordersCurrentLocationMock,
            style: AppTypography.bodySmall,
          ),
          if (order.estimatedDelivery != null)
            Text(
              '${context.l10n.ordersExpectedPrefix} ${DateFormat('EEEE, MMM d').format(order.estimatedDelivery!.toLocal())}',
              style: AppTypography.bodySmall,
            ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton(
            onPressed: () => AppSnackbar.info(
              context,
              context.l10n.ordersCourierWebsiteSoon,
            ),
            child: Text(context.l10n.ordersTrackOnCourier),
          ),
        ],
      ),
    );
  }
}
