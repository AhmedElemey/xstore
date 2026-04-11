import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../domain/entities/order_entity.dart';
import '../providers/vendor_order_detail_provider.dart';
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
              IconButton(icon: const Icon(Icons.ios_share_rounded), onPressed: () => Share.share('${context.l10n.orderHashPrefix}${o.formattedOrderId}\n${o.total} ${context.l10n.currencyDzd}')),
              PopupMenuButton<String>(onSelected: (v) => context.showSnack(v), itemBuilder: (_) => [PopupMenuItem(value: context.l10n.vendorPrintOrder, child: Text(context.l10n.vendorPrintOrder)), PopupMenuItem(value: context.l10n.vendorReportIssue, child: Text(context.l10n.vendorReportIssue))]),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _StatusHeader(order: o),
                const SizedBox(height: AppSpacing.lg),
                if (o.status == OrderStatus.pending || o.status == OrderStatus.confirmed || o.status == OrderStatus.processing) _Urgent(order: o, onConfirm: notifier.confirmOrder, onReject: () => showModalBottomSheet(context: context, isScrollControlled: true, builder: (_) => RejectOrderSheet(onConfirm: notifier.rejectOrder)), onProcessing: notifier.markProcessing, onShipped: () => showModalBottomSheet(context: context, isScrollControlled: true, builder: (_) => ShippingInfoSheet(onConfirm: notifier.markShipped))),
                const SizedBox(height: AppSpacing.lg),
                _Card(child: OrderTimeline(order: o)),
                const SizedBox(height: AppSpacing.lg),
                _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(context.l10n.ordersBuyerInfo, style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: AppSpacing.sm), Text(o.consumerName), InkWell(onTap: () => launchUrl(Uri(scheme: 'tel', path: o.consumerPhone)), child: Text(o.consumerPhone, style: TextStyle(color: AppColors.primary))), Text('${o.deliveryAddress.city}, ${o.deliveryAddress.wilaya}')])),
                const SizedBox(height: AppSpacing.lg),
                _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(context.l10n.ordersDeliveryAddressTitle, style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: AppSpacing.sm), Text(o.deliveryAddress.fullName), Text(o.deliveryAddress.street), Text('${o.deliveryAddress.city}, ${o.deliveryAddress.wilaya}'), TextButton(onPressed: () {}, child: Text(context.l10n.vendorViewOnMap))])),
                const SizedBox(height: AppSpacing.lg),
                _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(context.l10n.ordersItemsSectionCount(o.items.length), style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: AppSpacing.sm), ...o.items.map((e) => OrderItemTile(item: e, showStockHint: true))])),
                const SizedBox(height: AppSpacing.lg),
                _Card(child: OrderPriceBreakdown(order: o, vendorMode: true)),
                if (o.status == OrderStatus.shipped) ...[
                  const SizedBox(height: AppSpacing.lg),
                  _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(context.l10n.vendorShippingInfoTitle, style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: AppSpacing.sm), Row(children: [Expanded(child: Text(o.trackingNumber ?? '—')), IconButton(onPressed: () { if ((o.trackingNumber ?? '').isNotEmpty) { Clipboard.setData(ClipboardData(text: o.trackingNumber!)); context.showSnack(context.l10n.ordersTrackingCopied); } }, icon: const Icon(Icons.copy_rounded))]), Text(o.courierName ?? '—')])),
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
          onConfirm: notifier.confirmOrder,
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

class _StatusHeader extends StatelessWidget {
  const _StatusHeader({required this.order});
  final OrderEntity order;
  @override
  Widget build(BuildContext context) {
    final c = switch (order.status) { OrderStatus.pending => AppColors.warning, OrderStatus.confirmed => AppColors.primary, OrderStatus.processing => const Color(0xFF6366F1), OrderStatus.shipped => const Color(0xFF8B5CF6), OrderStatus.delivered => AppColors.success, _ => AppColors.error };
    final text = switch (order.status) {
      OrderStatus.pending => context.l10n.vendorStatusPending,
      OrderStatus.confirmed => context.l10n.vendorStatusConfirmed,
      OrderStatus.processing => context.l10n.vendorStatusProcessing,
      OrderStatus.shipped => context.l10n.vendorStatusShipped,
      OrderStatus.delivered => context.l10n.vendorStatusDelivered,
      OrderStatus.cancelled => context.l10n.vendorStatusCancelled,
      OrderStatus.refunded => context.l10n.vendorStatusRefunded,
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(AppSpacing.lg)),
      child: Text(text, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.white, fontWeight: FontWeight.w700)),
    );
  }
}

class _Urgent extends StatelessWidget {
  const _Urgent({required this.order, required this.onConfirm, required this.onReject, required this.onProcessing, required this.onShipped});
  final OrderEntity order; final VoidCallback onConfirm; final VoidCallback onReject; final VoidCallback onProcessing; final VoidCallback onShipped;
  @override
  Widget build(BuildContext context) => _Card(child: order.status == OrderStatus.pending ? Row(children: [Expanded(child: OutlinedButton(onPressed: onReject, child: Text(context.l10n.vendorRejectOrder))), const SizedBox(width: AppSpacing.sm), Expanded(child: FilledButton(onPressed: onConfirm, style: FilledButton.styleFrom(backgroundColor: AppColors.success), child: Text(context.l10n.vendorConfirmOrder)))]) : order.status == OrderStatus.confirmed ? FilledButton(onPressed: onProcessing, child: Text(context.l10n.vendorMarkProcessing)) : FilledButton(onPressed: onShipped, child: Text(context.l10n.vendorMarkShipped)));
}
