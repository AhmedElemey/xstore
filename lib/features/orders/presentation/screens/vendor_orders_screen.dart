import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../domain/entities/order_entity.dart';
import '../providers/vendor_orders_provider.dart';
import '../widgets/order_empty_state.dart';
import '../widgets/reject_order_sheet.dart';
import '../widgets/shipping_info_sheet.dart';
import '../widgets/vendor_order_card.dart';
import '../widgets/vendor_order_filter_tabs.dart';
import '../widgets/vendor_order_sort_row.dart';
import '../widgets/vendor_order_stats_banner.dart';
import '../../../../shared/widgets/skeletons/vendor_orders_skeleton.dart';

class VendorOrdersScreen extends ConsumerStatefulWidget {
  const VendorOrdersScreen({super.key});
  @override
  ConsumerState<VendorOrdersScreen> createState() => _VendorOrdersScreenState();
}

class _VendorOrdersScreenState extends ConsumerState<VendorOrdersScreen>
    with SingleTickerProviderStateMixin {
  final _scroll = ScrollController();
  final _search = TextEditingController();
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..repeat(reverse: true);
  var _searching = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(vendorOrdersProvider.notifier).fetchOrders(),
    );
  }

  @override
  void dispose() {
    _scroll.dispose();
    _search.dispose();
    _pulse.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.hasClients &&
        _scroll.offset > _scroll.position.maxScrollExtent - 180) {
      ref.read(vendorOrdersProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = ref.watch(
      vendorOrdersProvider.select((s) => s.pendingCount),
    );
    final activeCount = ref.watch(
      vendorOrdersProvider.select((s) => s.activeCount),
    );
    final totalCount = ref.watch(
      vendorOrdersProvider.select((s) => s.totalCount),
    );
    final totalRevenue = ref.watch(
      vendorOrdersProvider.select((s) => s.totalRevenue),
    );
    final selectedFilter = ref.watch(
      vendorOrdersProvider.select((s) => s.selectedFilter),
    );
    final sortOption = ref.watch(
      vendorOrdersProvider.select((s) => s.sortOption),
    );
    final filteredOrders = ref.watch(
      vendorOrdersProvider.select((s) => s.filteredOrders),
    );
    final isLoadingMore = ref.watch(
      vendorOrdersProvider.select((s) => s.isLoadingMore),
    );
    final isLoading = ref.watch(
      vendorOrdersProvider.select((s) => s.isLoading),
    );
    final statusCounts = ref.watch(
      vendorOrdersProvider.select((s) {
        final orders = s.orders;
        int count(OrderStatus status) =>
            orders.where((o) => o.status == status).length;
        return (
          confirmed: count(OrderStatus.confirmed),
          processing: count(OrderStatus.processing),
          shipped: count(OrderStatus.shipped),
          delivered: count(OrderStatus.delivered),
          cancelled: count(OrderStatus.cancelled),
        );
      }),
    );
    ref.listen<String?>(vendorOrdersProvider.select((s) => s.error), (p, n) {
      if (n != null && n != p) {
        context.showSnack(n);
        ref.read(vendorOrdersProvider.notifier).clearError();
      }
    });
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.surfaceColor,
        elevation: 0,
        title: _searching
            ? TextField(
                controller: _search,
                autofocus: true,
                onChanged: ref.read(vendorOrdersProvider.notifier).updateSearch,
                decoration: InputDecoration(
                  hintText: context.l10n.vendorSearchHint,
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _search.clear();
                      ref.read(vendorOrdersProvider.notifier).updateSearch('');
                    },
                  ),
                ),
              )
            : Row(
                children: [
                  Text(context.l10n.ordersIncomingTitle),
                  if (pendingCount > 0) ...[
                    const SizedBox(width: AppSpacing.xs),
                    AnimatedBuilder(
                      animation: _pulse,
                      builder: (_, child) => Transform.scale(
                        scale: 1 + 0.16 * math.sin(_pulse.value * math.pi),
                        child: child,
                      ),
                      child: const Icon(
                        Icons.circle,
                        size: 10,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ],
              ),
        actions: [
          IconButton(
            icon: Icon(_searching ? Icons.arrow_back : Icons.search),
            onPressed: () {
              setState(() => _searching = !_searching);
              if (!_searching) {
                _search.clear();
                ref.read(vendorOrdersProvider.notifier).updateSearch('');
              }
            },
          ),
          PopupMenuButton<String>(
            onSelected: (v) => context.showSnack(v),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: context.l10n.vendorExportOrders,
                child: Text(context.l10n.vendorExportOrders),
              ),
              PopupMenuItem(
                value: context.l10n.vendorOrderSettings,
                child: Text(context.l10n.vendorOrderSettings),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: AppSpacing.md),
          VendorOrderStatsBanner(
            pendingCount: pendingCount,
            activeCount: activeCount,
            totalCount: totalCount,
            totalRevenue: totalRevenue,
            onConfirmAllPending: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: Text(context.l10n.vendorConfirmAllPendingTitle),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: Text(context.l10n.cancel),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(dialogContext, true),
                      child: Text(context.l10n.ordersConfirm),
                    ),
                  ],
                ),
              );
              if (ok == true) {
                final count = await ref
                    .read(vendorOrdersProvider.notifier)
                    .confirmAllPending();
                if (!context.mounted) return;
                context.showSnack(context.l10n.vendorOrdersConfirmed(count));
              }
            },
            onViewAnalytics: () => context.push(AppRoutes.analytics),
          ),
          const SizedBox(height: AppSpacing.md),
          VendorOrderFilterTabs(
            selected: selectedFilter,
            totalCount: totalCount,
            pendingCount: pendingCount,
            confirmedCount: statusCounts.confirmed,
            processingCount: statusCounts.processing,
            shippedCount: statusCounts.shipped,
            deliveredCount: statusCounts.delivered,
            cancelledCount: statusCounts.cancelled,
            onTap: ref.read(vendorOrdersProvider.notifier).applyFilter,
          ),
           const SizedBox(height: AppSpacing.md),
          VendorOrderSortRow(
            sort: sortOption,
            count: filteredOrders.length,
            onChanged: ref.read(vendorOrdersProvider.notifier).applySort,
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: ref.read(vendorOrdersProvider.notifier).refreshOrders,
              child:  filteredOrders.isEmpty
                  ? ListView(
                      cacheExtent: 300,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: selectedFilter == null
                              ? Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      OrderEmptyState(
                                        title: context.l10n.vendorOrdersEmptyTitle,
                                        subtitle: context.l10n
                                            .vendorOrdersEmptySubtitle,
                                      ),
                                      const SizedBox(height: AppSpacing.md),
                                      OutlinedButton(
                                        onPressed: () =>
                                            context.push(AppRoutes.listingMy),
                                        child: Text(context.l10n.menuMyListings),
                                      ),
                                    ],
                                  ),
                                )
                              : OrderEmptyState(
                                  title: context.l10n.vendorNoStatusOrders,
                                  subtitle: context.l10n.vendorNoStatusOrdersSubtitle,
                                  filterActive: true,
                                ),
                        ),
                      ],
                    )
                 : isLoading 
                  ? const VendorOrdersSkeleton()
                  : ListView.separated(
                      controller: _scroll,
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      cacheExtent: 700,
                      itemCount:
                          filteredOrders.length + (isLoadingMore ? 1 : 0),
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, i) {
                        if (i >= filteredOrders.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(AppSpacing.lg),
                              child: CircularProgressIndicator.adaptive(),
                            ),
                          );
                        }
                        final order = filteredOrders[i];
                        return RepaintBoundary(
                          child: VendorOrderCard(
                            key: ValueKey(order.id),
                            order: order,
                            onConfirm: () async {
                              final ok = await ref
                                  .read(vendorOrdersProvider.notifier)
                                  .confirmOrder(order.id);
                              if (!context.mounted) return;
                              if (ok) {
                                context.showSnack(
                                  context.l10n.vendorOrderConfirmedSnack,
                                );
                              }
                            },
                            onReject: () => showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (_) => RejectOrderSheet(
                                onConfirm: (reason) async {
                                  final ok = await ref
                                      .read(vendorOrdersProvider.notifier)
                                      .rejectOrder(order.id, reason);
                                  if (!context.mounted) return;
                                  if (ok) {
                                    context.showSnack(
                                      context.l10n.vendorOrderRejectedSnack,
                                    );
                                  }
                                },
                              ),
                            ),
                            onProcessing: () async {
                              final ok = await ref
                                  .read(vendorOrdersProvider.notifier)
                                  .markProcessing(order.id);
                              if (!context.mounted) return;
                              if (ok) {
                                context.showSnack(
                                  context.l10n.vendorOrderProcessingSnack,
                                );
                              }
                            },
                            onShipped: () => showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (_) => ShippingInfoSheet(
                                onConfirm: (info) async {
                                  final ok = await ref
                                      .read(vendorOrdersProvider.notifier)
                                      .markShipped(order.id, info);
                                  if (!context.mounted) return;
                                  if (ok) {
                                    context.showSnack(
                                      context.l10n.vendorOrderShippedSnack,
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
