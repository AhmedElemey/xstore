import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
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
    final ordersState = ref.watch(ordersNotifierProvider);
    final notifier = ref.read(ordersNotifierProvider.notifier);
    ref.listen(ordersNotifierProvider, (p, n) {
      final err = n.error;
      if (err != null && err != p?.error && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
        notifier.clearError();
      }
    });

    final searching = ordersState.isSearching;
    final list = ordersState.filteredOrders;
    final emptyAll = ordersState.orders.isEmpty;

    return ColoredBox(
      color: AppColors.background,
      child: Column(
        children: [
          Material(
            color: AppColors.cardBg,
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
              child: ordersState.isLoading && emptyAll
                  ? const OrdersListShimmer()
                  : list.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            OrderEmptyState(
                              title: ordersState.selectedFilter != null
                                  ? AppStrings.ordersEmptyFilteredTitle
                                  : AppStrings.ordersEmptyTitle,
                              subtitle: ordersState.selectedFilter != null
                                  ? AppStrings.ordersEmptySubtitle
                                  : AppStrings.ordersEmptyConsumerSubtitle,
                              filterActive: ordersState.selectedFilter != null,
                            ),
                          ],
                        )
                      : ListView.builder(
                          controller: _scroll,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          itemCount: list.length + (ordersState.isLoadingMore ? 1 : 0),
                          itemBuilder: (context, i) {
                            if (i >= list.length) {
                              return const Padding(
                                padding: EdgeInsets.all(AppSpacing.lg),
                                child: Center(
                                  child: CircularProgressIndicator.adaptive(),
                                ),
                              );
                            }
                            return Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.md),
                              child: OrderCard(order: list[i], isVendor: false),
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
