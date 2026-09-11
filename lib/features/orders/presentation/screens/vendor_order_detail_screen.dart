import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/utils/whatsapp.dart';
import '../../../../shared/widgets/app_cached_network_image.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../domain/entities/order_entity.dart';
import '../providers/vendor_order_detail_provider.dart';
import '../widgets/delivery_method_sheet.dart';
import '../widgets/order_item_tile.dart';
import '../widgets/order_price_breakdown.dart';
import '../widgets/order_timeline.dart';
import '../widgets/reject_order_sheet.dart';
import '../widgets/shipping_info_sheet.dart';
import '../widgets/vendor_order_action_sheet.dart';

class VendorOrderDetailScreen extends ConsumerStatefulWidget {
  const VendorOrderDetailScreen({super.key, required this.orderId});
  final String orderId;
  @override
  ConsumerState<VendorOrderDetailScreen> createState() => _VendorOrderDetailScreenState();
}

class _VendorOrderDetailScreenState extends ConsumerState<VendorOrderDetailScreen> {
  @override
  void initState() { super.initState(); WidgetsBinding.instance.addPostFrameCallback((_) => ref.read(vendorOrderDetailProvider(widget.orderId).notifier).fetchOrder()); }

  Future<void> _confirmWithMethodPicker(VendorOrderDetailNotifier notifier) async {
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
    final notifier = ref.read(vendorOrderDetailProvider(widget.orderId).notifier);
    final o = state.order;
    if (state.isLoading && o == null) return const Scaffold(body: Center(child: CircularProgressIndicator.adaptive()));
    if (o == null) return Scaffold(body: Center(child: Text(state.error ?? context.l10n.errorGeneric)));
    ref.listen(vendorOrderDetailProvider(widget.orderId), (p, n) { if (n.error != null && n.error != p?.error) { context.showSnack(n.error!); notifier.clearError(); } });
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true, backgroundColor: context.surfaceColor, elevation: 0,
            title: Text('${context.l10n.orderHashPrefix}${o.formattedOrderId}'),
            actions: [
              IconButton(
                tooltip: context.l10n.share,
                icon: const Icon(Icons.ios_share_rounded),
                onPressed: () => Share.share(
                  '${context.l10n.orderHashPrefix}${o.formattedOrderId}\n${context.formatCurrency(o.total)}',
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _StatusHeader(order: o),
                const SizedBox(height: AppSpacing.lg),
                _Card(child: OrderTimeline(order: o)),
                const SizedBox(height: AppSpacing.lg),
                _BuyerInfoCard(order: o),
                const SizedBox(height: AppSpacing.lg),
                _DeliveryAddressCard(address: o.deliveryAddress),
                const SizedBox(height: AppSpacing.lg),
                // Package delivery ("request custom delivery") deferred to
                // phase 2 — out of scope for phase 1 launch.
                // if (o.deliveryMethod == DeliveryMethod.platform &&
                //     o.status != OrderStatus.cancelled &&
                //     o.status != OrderStatus.delivered) ...[
                //   _Card(
                //     child: Column(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children: [
                //         Text(context.l10n.requestCustomDeliveryTitle, style: Theme.of(context).textTheme.titleMedium),
                //         const SizedBox(height: AppSpacing.sm),
                //         Text(context.l10n.requestCustomDeliverySubtitle, style: Theme.of(context).textTheme.bodySmall),
                //         const SizedBox(height: AppSpacing.md),
                //         OutlinedButton(
                //           onPressed: () => context.push(
                //             AppRoutes.sendPackage,
                //             extra: SendPackageArgs(
                //               orderId: o.id,
                //               initialDropoff: o.deliveryAddress,
                //             ),
                //           ),
                //           child: Text(context.l10n.requestCustomDeliveryAction),
                //         ),
                //       ],
                //     ),
                //   ),
                //   const SizedBox(height: AppSpacing.lg),
                // ],
                _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(context.l10n.ordersItemsSectionCount(o.items.length), style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: AppSpacing.sm), ...o.items.map((e) => OrderItemTile(item: e, showStockHint: true))])),
                const SizedBox(height: AppSpacing.lg),
                _Card(child: OrderPriceBreakdown(order: o, vendorMode: true)),
                if (o.status == OrderStatus.shipped) ...[
                  const SizedBox(height: AppSpacing.lg),
                  _ShippingInfoCard(order: o),
                ],
                if (o.status == OrderStatus.cancelled) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Container(padding: const EdgeInsets.all(AppSpacing.md), decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(AppSpacing.md)), child: Text('${context.l10n.ordersCancelReasonSection}: ${o.cancelReason ?? '-'}')),
                ],
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Material(
        color: context.surfaceColor,
        child: VendorOrderActionSheet(
          order: o,
          onConfirm: () => _confirmWithMethodPicker(notifier),
          onReject: () => showModalBottomSheet(context: context, isScrollControlled: true, builder: (_) => RejectOrderSheet(onConfirm: notifier.rejectOrder)),
          onProcessing: notifier.markProcessing,
          onShipped: () => showModalBottomSheet(context: context, isScrollControlled: true, builder: (_) => ShippingInfoSheet(onConfirm: notifier.markShipped)),
        ),
      ),
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
        decoration: BoxDecoration(color: context.surfaceColor, borderRadius: BorderRadius.circular(AppSpacing.lg), boxShadow: [BoxShadow(color: context.cardShadowColor, blurRadius: 10)]),
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
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (phone.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            OutlinedButton(
              onPressed: () async {
                final opened = await launchWhatsApp(phone: phone);
                if (!opened && context.mounted) {
                  AppSnackbar.info(
                    context,
                    context.l10n.whatsappSellerUnavailable,
                  );
                }
              },
              child: Text(context.l10n.ordersWhatsapp),
            ),
          ],
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
          if (street.isNotEmpty)
            Text(street, style: AppTypography.bodyMedium),
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
                      Text(tracking, style: AppTypography.bodyMedium),
                    ],
                  ),
                ),
                IconButton(
                  tooltip:
                      MaterialLocalizations.of(context).copyButtonLabel,
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
              DateFormat('EEEE, MMM d, yyyy').format(eta.toLocal()),
              style: AppTypography.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusHeader extends StatelessWidget {
  const _StatusHeader({required this.order});
  final OrderEntity order;
  @override
  Widget build(BuildContext context) {
    final c = switch (order.status) { OrderStatus.pending => AppColors.warning, OrderStatus.confirmed => AppColors.primary, OrderStatus.processing => AppColors.orderStatusProcessing, OrderStatus.shipped => AppColors.orderStatusShipped, OrderStatus.delivered => AppColors.success, _ => AppColors.error };
    final text = switch (order.status) {
      OrderStatus.pending => context.l10n.vendorStatusPending,
      OrderStatus.confirmed => context.l10n.vendorStatusConfirmed,
      OrderStatus.processing => context.l10n.vendorStatusProcessing,
      OrderStatus.shipped => context.l10n.vendorStatusShipped,
      OrderStatus.delivered => context.l10n.vendorStatusDelivered,
      OrderStatus.cancelled => context.l10n.vendorStatusCancelled,
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(AppSpacing.md),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
