import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../providers/orders_provider.dart';
import 'order_card.dart';
import 'order_empty_state.dart';
import 'order_filter_tabs.dart';
import 'orders_list_shimmer.dart';

class ConsumerOrdersView extends ConsumerStatefulWidget {
  const ConsumerOrdersView({super.key});

  @override
  ConsumerState<ConsumerOrdersView> createState() => _ConsumerOrdersViewState();
}

class _ConsumerOrdersViewState extends ConsumerState<ConsumerOrdersView> {
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
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: searching
                              ? TextField(
                                  autofocus: true,
                                  decoration: InputDecoration(
                                    hintText: AppStrings.ordersSearchHint,
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
                                  AppStrings.ordersMyTitle,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                        ),
                        if (!searching)
                          IconButton(
                            icon: const Icon(Icons.search_rounded),
                            onPressed: () => notifier.setSearching(true),
                          ),
                      ],
                    ),
                  ),
                  const OrderFilterTabs(isVendor: false),
                ],
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => notifier.refreshOrders(),
              child: isLoading && emptyAll
                  ? const OrdersListShimmer()
                  : list.isEmpty
                  ? ListView(
                      cacheExtent: 300,
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        OrderEmptyState(
                          title: selectedFilter != null
                              ? AppStrings.ordersEmptyFilteredTitle
                              : AppStrings.ordersEmptyTitle,
                          subtitle: selectedFilter != null
                              ? AppStrings.ordersEmptySubtitle
                              : AppStrings.ordersEmptyConsumerSubtitle,
                          filterActive: selectedFilter != null,
                        ),
                      ],
                    )
                  : ListView.builder(
                      controller: _scroll,
                      physics: const AlwaysScrollableScrollPhysics(),
                      cacheExtent: 700,
                      padding: const EdgeInsets.all(AppSpacing.lg),
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
                              isVendor: false,
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
