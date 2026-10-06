import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_cached_network_image.dart';
import '../../../../shared/widgets/auth_back_button.dart';
import '../../../../shared/widgets/orbit_background.dart';
import '../../domain/entities/order_entity.dart';
import '../providers/vendor_order_detail_provider.dart';
import '../widgets/delivery_method_sheet.dart';
import '../widgets/order_item_tile.dart';
import '../widgets/order_price_breakdown.dart';
import '../widgets/order_status_badge.dart';
import '../widgets/order_timeline.dart';
import '../widgets/reject_order_sheet.dart';
import '../widgets/shipping_info_sheet.dart';
import '../widgets/vendor_order_action_sheet.dart';

class VendorOrderDetailScreen extends ConsumerStatefulWidget {
  const VendorOrderDetailScreen({super.key, required this.orderId});
  final String orderId;
  @override
  ConsumerState<VendorOrderDetailScreen> createState() =>
      _VendorOrderDetailScreenState();
}

class _VendorOrderDetailScreenState
    extends ConsumerState<VendorOrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref
          .read(vendorOrderDetailProvider(widget.orderId).notifier)
          .fetchOrder(),
    );
  }

  Future<void> _confirmWithMethodPicker(
    VendorOrderDetailNotifier notifier,
  ) async {
    final method = await showModalBottomSheet<DeliveryMethod>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const DeliveryMethodSheet(),
    );
    if (method == null || !mounted) return;
    await notifier.confirmOrder(method);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(vendorOrderDetailProvider(widget.orderId));
    final notifier = ref.read(
      vendorOrderDetailProvider(widget.orderId).notifier,
    );
    final o = state.order;
    ref.listen(vendorOrderDetailProvider(widget.orderId), (p, n) {
      if (n.error != null && n.error != p?.error) {
        context.showSnack(n.error!);
        notifier.clearError();
      }
    });
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: OrbitBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _Header(order: o),
              Expanded(
                child: o == null
                    ? Center(
                        child: state.isLoading
                            ? const CircularProgressIndicator.adaptive()
                            : Text(state.error ?? context.l10n.errorGeneric),
                      )
                    : CustomScrollView(
                        slivers: [
                          SliverPadding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                              AppSpacing.xl,
                              AppSpacing.lg,
                              AppSpacing.xl,
                              AppSpacing.x4l,
                            ),
                            sliver: SliverToBoxAdapter(
                              child: _Content(order: o),
                            ),
                          ),
                        ],
                      ),
              ),
              if (o != null)
                VendorOrderActionSheet(
                  order: o,
                  onConfirm: () => _confirmWithMethodPicker(notifier),
                  onReject: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) =>
                        RejectOrderSheet(onConfirm: notifier.rejectOrder),
                  ),
                  onProcessing: notifier.markProcessing,
                  onShipped: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) =>
                        ShippingInfoSheet(onConfirm: notifier.markShipped),
                  ),
                  onDelivered: notifier.markDelivered,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Orbit header: frosted back button, order number, and the share action.
class _Header extends StatelessWidget {
  const _Header({required this.order});

  final OrderEntity? order;

  @override
  Widget build(BuildContext context) {
    final o = order;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          if (Navigator.of(context).canPop()) ...[
            const AuthBackButton(),
            const SizedBox(width: AppSpacing.md),
          ],
          if (o != null) ...[
            Expanded(
              child: Text(
                '${context.l10n.orderHashPrefix}${o.formattedOrderId}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.headlineSmall.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Material(
              color: context.glassColor,
              shape: CircleBorder(side: BorderSide(color: context.borderColor)),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => Share.share(
                  '${context.l10n.orderHashPrefix}${o.formattedOrderId}\n${context.formatCurrency(o.total)}',
                ),
                child: SizedBox.square(
                  dimension: 44,
                  child: Icon(
                    Icons.ios_share_rounded,
                    size: 20,
                    color: context.textPrimary,
                    semanticLabel: context.l10n.share,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.order});

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    final o = order;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StatusHeader(order: o),
        const SizedBox(height: AppSpacing.lg),
        _Card(child: OrderTimeline(order: o)),
        const SizedBox(height: AppSpacing.lg),
        _BuyerInfoCard(order: o),
        const SizedBox(height: AppSpacing.lg),
        _DeliveryAddressCard(address: o.deliveryAddress),
        const SizedBox(height: AppSpacing.lg),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.ordersItemsSectionCount(o.items.length),
                style: AppTypography.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              ...o.items.map(
                (e) => OrderItemTile(item: e, showStockHint: true),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _Card(child: OrderPriceBreakdown(order: o, vendorMode: true)),
        if (o.status == OrderStatus.shipped) ...[
          const SizedBox(height: AppSpacing.lg),
          _ShippingInfoCard(order: o),
        ],
        if (o.status == OrderStatus.cancelled) ...[
          const SizedBox(height: AppSpacing.lg),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
            ),
            child: Text(
              '${context.l10n.ordersCancelReasonSection}: ${o.cancelReason ?? '-'}',
            ),
          ),
        ],
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(AppSpacing.lg),
    decoration: BoxDecoration(
      color: context.glassColor,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: context.borderColor),
    ),
    child: child,
  );
}

class _BuyerInfoCard extends StatelessWidget {
  const _BuyerInfoCard({required this.order});
  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    final name = order.consumerName.trim();
    final phone = order.consumerPhone.trim();
    final letter = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.ordersBuyerInfo, style: AppTypography.titleMedium),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              ClipOval(
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: order.consumerAvatar.trim().isNotEmpty
                      ? AppCachedNetworkImage(
                          imageUrl: order.consumerAvatar,
                          fit: BoxFit.cover,
                          memCacheWidth: 96,
                          memCacheHeight: 96,
                          placeholder: (_, __) => _letterBox(letter),
                          errorWidget: (_, __, ___) => _letterBox(letter),
                        )
                      : _letterBox(letter),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (name.isNotEmpty)
                      Text(
                        name,
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    if (phone.isNotEmpty)
                      InkWell(
                        onTap: () async {
                          final uri = Uri(scheme: 'tel', path: phone);
                          if (await canLaunchUrl(uri)) await launchUrl(uri);
                        },
                        child: Text(
                          phone,
                          style: AppTypography.bodyMedium.copyWith(
                            color: context.linkColor,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _letterBox(String letter) {
    return ColoredBox(
      color: AppColors.primary,
      child: Center(
        child: Text(
          letter,
          style: AppTypography.titleMedium.copyWith(color: AppColors.white),
        ),
      ),
    );
  }
}

class _DeliveryAddressCard extends StatelessWidget {
  const _DeliveryAddressCard({required this.address});
  final OrderAddress address;

  @override
  Widget build(BuildContext context) {
    final street = address.street.trim();
    final cityLine = [
      if (address.city.trim().isNotEmpty) address.city.trim(),
      if (address.wilaya.trim().isNotEmpty) address.wilaya.trim(),
      if (address.postalCode != null && address.postalCode!.trim().isNotEmpty)
        address.postalCode!.trim(),
    ].join(', ');
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.ordersDeliveryAddressTitle,
            style: AppTypography.titleMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          if (street.isNotEmpty) Text(street, style: AppTypography.bodyMedium),
          if (cityLine.isNotEmpty) ...[
            if (street.isNotEmpty) const SizedBox(height: AppSpacing.xs),
            Text(cityLine, style: AppTypography.bodyMedium),
          ],
        ],
      ),
    );
  }
}

class _ShippingInfoCard extends StatelessWidget {
  const _ShippingInfoCard({required this.order});
  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    final tracking = order.trackingNumber?.trim() ?? '';
    final courier = order.courierName?.trim() ?? '';
    final eta = order.estimatedDelivery;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.vendorShippingInfoTitle,
            style: AppTypography.titleMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          if (tracking.isNotEmpty)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.ordersTrackingNumberLabel,
                        style: AppTypography.bodySmall.copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                      Text(
                        tracking,
                        style: AppTypography.mono.copyWith(
                          fontSize: 14,
                          color: context.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: MaterialLocalizations.of(context).copyButtonLabel,
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: tracking));
                    context.showSnack(context.l10n.ordersTrackingCopied);
                  },
                  icon: const Icon(Icons.copy_rounded),
                ),
              ],
            ),
          if (courier.isNotEmpty) ...[
            if (tracking.isNotEmpty) const SizedBox(height: AppSpacing.sm),
            Text(
              context.l10n.ordersCourierNameLabel,
              style: AppTypography.bodySmall.copyWith(
                color: context.textSecondary,
              ),
            ),
            Text(courier, style: AppTypography.bodyMedium),
          ],
          if (eta != null) ...[
            if (tracking.isNotEmpty || courier.isNotEmpty)
              const SizedBox(height: AppSpacing.sm),
            Text(
              context.l10n.ordersEstimatedDeliveryLabel,
              style: AppTypography.bodySmall.copyWith(
                color: context.textSecondary,
              ),
            ),
            Text(
              context.formatLongDate(eta.toLocal()),
              style: AppTypography.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}

/// Glass status banner: status icon and word on a status-tinted outline.
class _StatusHeader extends StatelessWidget {
  const _StatusHeader({required this.order});

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    final c = orderStatusColor(order.status);
    final text = switch (order.status) {
      OrderStatus.pending => context.l10n.vendorStatusPending,
      OrderStatus.confirmed => context.l10n.vendorStatusConfirmed,
      OrderStatus.processing => context.l10n.vendorStatusProcessing,
      OrderStatus.shipped => context.l10n.vendorStatusShipped,
      OrderStatus.delivered => context.l10n.vendorStatusDelivered,
      OrderStatus.cancelled => context.l10n.vendorStatusCancelled,
    };
    final icon = switch (order.status) {
      OrderStatus.pending => Icons.hourglass_top_rounded,
      OrderStatus.confirmed => Icons.check_circle_outline,
      OrderStatus.processing => Icons.inventory_2_outlined,
      OrderStatus.shipped => Icons.local_shipping_outlined,
      OrderStatus.delivered => Icons.verified_rounded,
      OrderStatus.cancelled => Icons.cancel_outlined,
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.glassColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: c, size: 28),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: AppTypography.titleCompact.copyWith(
                color: context.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
