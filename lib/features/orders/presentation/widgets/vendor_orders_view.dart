import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/entities/order_entity.dart';
import '../providers/orders_provider.dart';
import 'order_card.dart';
import 'order_empty_state.dart';
import 'order_filter_tabs.dart';
import 'order_stats_banner.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/skeletons/vendor_orders_skeleton.dart';

class VendorOrdersView extends ConsumerStatefulWidget {
  const VendorOrdersView({super.key});

  @override
  ConsumerState<VendorOrdersView> createState() => _VendorOrdersViewState();
}

class _VendorOrdersViewState extends ConsumerState<VendorOrdersView> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ordersNotifierProvider.notifier).fetchOrders();
    });
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final max = _scroll.position.maxScrollExtent;
    if (_scroll.offset > max - 200) {
      ref.read(ordersNotifierProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final searching = ref.watch(
      ordersNotifierProvider.select((s) => s.isSearching),
    );
    final list = ref.watch(
      ordersNotifierProvider.select((s) => s.filteredOrders),
    );
    final emptyAll = ref.watch(
      ordersNotifierProvider.select((s) => s.orders.isEmpty),
    );
    final selectedFilter = ref.watch(
      ordersNotifierProvider.select((s) => s.selectedFilter),
    );
    final sortOption = ref.watch(
      ordersNotifierProvider.select((s) => s.sortOption),
    );
    final isLoading = ref.watch(
      ordersNotifierProvider.select((s) => s.isLoading),
    );
    final isLoadingMore = ref.watch(
      ordersNotifierProvider.select((s) => s.isLoadingMore),
    );
    final notifier = ref.read(ordersNotifierProvider.notifier);
    ref.listen<String?>(ordersNotifierProvider.select((s) => s.error), (p, n) {
      final err = n;
      if (err != null && err != p && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(err)));
        notifier.clearError();
      }
    });

    return ColoredBox(
      color: context.backgroundColor,
      child: Column(
        children: [
          Material(
            color: context.surfaceColor,
            elevation: 0,
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: kToolbarHeight,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_rounded),
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                        Expanded(
                          child: searching
                              ? TextField(
                                  autofocus: true,
                                  decoration: InputDecoration(
                                    hintText: context.l10n.ordersSearchHint,
                                    border: InputBorder.none,
                                    suffixIcon: IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () {
                                        notifier.setSearching(false);
                                        notifier.updateSearch('');
                                      },
                                    ),
                                  ),
                                  onChanged: notifier.updateSearch,
                                )
                              : Text(
                                  context.l10n.ordersIncomingTitle,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                        ),
                        if (!searching) ...[
                          IconButton(
                            icon: const Icon(Icons.search_rounded),
                            onPressed: () => notifier.setSearching(true),
                          ),
                          IconButton(
                            icon: const Icon(Icons.filter_list_rounded),
                            onPressed: () =>
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      context.l10n.ordersFiltersMoreSoon,
                                    ),
                                  ),
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const OrderFilterTabs(isVendor: true),
                ],
              ),
            ),
          ),
          const OrderStatsBanner(),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                Text(
                  context.l10n.sortBy,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(width: AppSpacing.sm),
                DropdownButton<OrderSortOption>(
                  value: sortOption,
                  underline: const SizedBox.shrink(),
                  items: [
                    DropdownMenuItem(
                      value: OrderSortOption.newest,
                      child: Text(context.l10n.sortNewest),
                    ),
                    DropdownMenuItem(
                      value: OrderSortOption.oldest,
                      child: Text(context.l10n.sortOldest),
                    ),
                    DropdownMenuItem(
                      value: OrderSortOption.highestValue,
                      child: Text(context.l10n.ordersSortHighestValue),
                    ),
                    DropdownMenuItem(
                      value: OrderSortOption.needsAction,
                      child: Text(context.l10n.ordersSortNeedsAction),
                    ),
                  ],
                  onChanged: (v) {
                    if (v != null) notifier.applySort(v);
                  },
                ),
                const Spacer(),
                Text(
                  context.l10n.ordersCountLine(list.length),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => notifier.refreshOrders(),
              child: isLoading && emptyAll
                  ? const VendorOrdersSkeleton()
                  : list.isEmpty
                  ? ListView(
                      cacheExtent: 300,
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        OrderEmptyState(
                          title: selectedFilter != null
                              ? context.l10n.ordersEmptyFilteredTitle
                              : context.l10n.ordersEmptyTitle,
                          subtitle: context.l10n.vendorOrdersEmptySubtitle,
                          filterActive: selectedFilter != null,
                        ),
                      ],
                    )
                  : ListView.builder(
                      controller: _scroll,
                      physics: const AlwaysScrollableScrollPhysics(),
                      cacheExtent: 700,
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.sm,
                        AppSpacing.lg,
                        AppSpacing.lg,
                      ),
                      itemCount: list.length + (isLoadingMore ? 1 : 0),
                      itemBuilder: (context, i) {
                        if (i >= list.length) {
                          return const Padding(
                            padding: EdgeInsets.all(AppSpacing.lg),
                            child: Center(
                              child: CircularProgressIndicator.adaptive(),
                            ),
                          );
                        }
                        return RepaintBoundary(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.md,
                            ),
                            child: OrderCard(
                              key: ValueKey(list[i].id),
                              order: list[i],
                              isVendor: true,
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
