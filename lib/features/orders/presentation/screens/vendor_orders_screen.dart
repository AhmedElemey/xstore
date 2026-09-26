import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/orbit_widgets.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../domain/entities/order_entity.dart';
import '../providers/vendor_orders_provider.dart';
import '../widgets/delivery_method_sheet.dart';
import '../widgets/order_empty_state.dart';
import '../widgets/reject_order_sheet.dart';
import '../widgets/shipping_info_sheet.dart';
import '../widgets/vendor_order_card.dart';
import '../widgets/vendor_order_filter_tabs.dart';
import '../widgets/vendor_order_sort_row.dart';
import '../widgets/vendor_order_stats_banner.dart';
import '../../../../shared/widgets/pulsing_animation_builder.dart';
import '../../../../shared/widgets/route_reentry_refresh.dart';
import '../../../../shared/widgets/skeletons/vendor_orders_skeleton.dart';
import '../../../../shared/widgets/space_background.dart';

class VendorOrdersScreen extends ConsumerStatefulWidget {
  const VendorOrdersScreen({super.key});
  @override
  ConsumerState<VendorOrdersScreen> createState() => _VendorOrdersScreenState();
}

class _VendorOrdersScreenState extends ConsumerState<VendorOrdersScreen> {
  Future<DeliveryMethod?> _pickDeliveryMethod() =>
      showModalBottomSheet<DeliveryMethod>(
        context: context,
        isScrollControlled: true,
        builder: (_) => const DeliveryMethodSheet(),
      );

  final _scroll = ScrollController();
  final _search = TextEditingController();
  var _searching = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(vendorOrdersProvider.notifier).fetchOrders();
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    _search.dispose();
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
    final hasOrders = ref.watch(
      vendorOrdersProvider.select((s) => s.orders.isNotEmpty),
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
    return RouteReentryRefresh(
      isTarget: (location) => location == AppRoutes.vendorOrders,
      onReentry: (ref) => ref.read(vendorOrdersProvider.notifier).fetchOrders(),
      child: Scaffold(
      backgroundColor: context.backgroundColor,
      body: SpaceBackground(child: Column(
        children: [
          SafeArea(
            bottom: false,
            child: _Header(
              pendingCount: pendingCount,
              searching: _searching,
              search: _search,
              onToggleSearch: () {
                setState(() => _searching = !_searching);
                if (!_searching) {
                  _search.clear();
                  ref.read(vendorOrdersProvider.notifier).updateSearch('');
                }
              },
              onSearch: ref.read(vendorOrdersProvider.notifier).updateSearch,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          VendorOrderStatsBanner(
            pendingCount: pendingCount,
            processingCount: statusCounts.processing,
            shippedCount: statusCounts.shipped,
            totalCount: totalCount,
            totalRevenue: totalRevenue,
            onFilter: ref.read(vendorOrdersProvider.notifier).applyFilter,
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
              if (ok != true) return;
              final method = await _pickDeliveryMethod();
              if (method == null || !context.mounted) return;
              final count = await ref
                  .read(vendorOrdersProvider.notifier)
                  .confirmAllPending(method);
              if (!context.mounted) return;
              context.showSnack(context.l10n.vendorOrdersConfirmed(count));
            },
          ),
          const SizedBox(height: AppSpacing.xs),
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
              child: isLoading && !hasOrders
                  ? const VendorOrdersSkeleton()
                  : filteredOrders.isEmpty
                  ? ListView(
                      cacheExtent: 300,
                      children: [
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.6,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final content = selectedFilter == null
                                  ? Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        OrderEmptyState(
                                          title: context
                                              .l10n
                                              .vendorOrdersEmptyTitle,
                                          subtitle: context
                                              .l10n
                                              .vendorOrdersEmptySubtitle,
                                        ),
                                        const SizedBox(height: AppSpacing.md),
                                        OutlinedButton(
                                          onPressed: () =>
                                              context.go(AppRoutes.listingMy),
                                          child: Text(
                                            context.l10n.menuMyListings,
                                          ),
                                        ),
                                      ],
                                    )
                                  : OrderEmptyState(
                                      title: context.l10n.vendorNoStatusOrders,
                                      subtitle: context
                                          .l10n
                                          .vendorNoStatusOrdersSubtitle,
                                      filterActive: true,
                                    );
                              // A fixed-fraction height can be shorter than
                              // this content's natural height on a short
                              // viewport or with larger accessibility text
                              // scaling — SingleChildScrollView plus a
                              // minHeight-constrained Center keeps that from
                              // turning into a RenderFlex overflow while
                              // still centering the content when it fits.
                              return SingleChildScrollView(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minHeight: constraints.maxHeight,
                                  ),
                                  child: Center(child: content),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    )
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
                              final method = await _pickDeliveryMethod();
                              if (method == null || !context.mounted) return;
                              final ok = await ref
                                  .read(vendorOrdersProvider.notifier)
                                  .confirmOrder(order.id, method);
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
                            onDelivered: () async {
                              final ok = await ref
                                  .read(vendorOrdersProvider.notifier)
                                  .markDelivered(order.id);
                              if (!context.mounted) return;
                              if (ok) {
                                context.showSnack(
                                  context.l10n.vendorOrderDeliveredSnack,
                                );
                              }
                            },
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      )),
      ),
    );
  }
}

/// Store orb, store name and the screen title, with search (app-only) on
/// the end.
class _Header extends ConsumerWidget {
  const _Header({
    required this.pendingCount,
    required this.searching,
    required this.search,
    required this.onToggleSearch,
    required this.onSearch,
  });

  final int pendingCount;
  final bool searching;
  final TextEditingController search;
  final VoidCallback onToggleSearch;
  final ValueChanged<String> onSearch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeName = ref.watch(
      authProvider.select((a) => a.valueOrNull?.storeName?.trim() ?? ''),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        0,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: orbitOrbGradient(2),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: searching
                ? TextField(
                    controller: search,
                    autofocus: true,
                    onChanged: onSearch,
                    decoration: InputDecoration(
                      hintText: context.l10n.vendorSearchHint,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (storeName.isNotEmpty)
                        Text(
                          storeName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.labelSmall.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              context.l10n.ordersIncomingTitle,
                              style: AppTypography.titleMedium.copyWith(
                                fontFamily: AppTypography.displayFontFamily,
                                fontWeight: FontWeight.w800,
                                color: context.textPrimary,
                              ),
                            ),
                          ),
                          if (pendingCount > 0) ...[
                            const SizedBox(width: AppSpacing.sm),
                            PulsingAnimationBuilder(
                              duration: const Duration(milliseconds: 1000),
                              builder: (_, animation, child) =>
                                  Transform.scale(
                                scale: 1 +
                                    0.16 * math.sin(animation.value * math.pi),
                                child: child,
                              ),
                              child: Icon(
                                Icons.circle,
                                size: 10,
                                color: context.cashColor,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
          ),
          const SizedBox(width: AppSpacing.sm),
          OrbitCircleButton(
            tooltip: context.l10n.vendorSearchHint,
            onPressed: onToggleSearch,
            child: Icon(
              searching ? LucideIcons.x : LucideIcons.search,
              size: 20,
              color: context.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
