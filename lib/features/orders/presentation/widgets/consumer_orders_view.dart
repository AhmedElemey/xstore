import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/animations/app_animations.dart';
import '../../../../core/animations/animation_extensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../providers/orders_provider.dart';
import 'order_card.dart';
import 'order_empty_state.dart';
import 'order_filter_tabs.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/orbit_background.dart';
import '../../../../shared/widgets/skeletons/consumer_orders_skeleton.dart';

class ConsumerOrdersView extends ConsumerStatefulWidget {
  const ConsumerOrdersView({super.key});

  @override
  ConsumerState<ConsumerOrdersView> createState() => _ConsumerOrdersViewState();
}

class _ConsumerOrdersViewState extends ConsumerState<ConsumerOrdersView> {
  // Clears the floating dock on this shell tab.
  static const double _dockClearance = 124;

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
        AppSnackbar.error(context, err);
        notifier.clearError();
      }
    });

    return Material(
      type: MaterialType.transparency,
      child: OrbitBackground(
        child: Column(
          children: [
            SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      AppSpacing.xl,
                      AppSpacing.lg,
                      AppSpacing.xl,
                      AppSpacing.lg,
                    ),
                    child: SizedBox(
                      height: 44,
                      child: searching
                          ? _SearchField(notifier: notifier)
                          : Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    context.l10n.ordersMyTitle,
                                    style: AppTypography.headlineSmall.copyWith(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                _GlassIconButton(
                                  icon: Icons.search_rounded,
                                  onPressed: () => notifier.setSearching(true),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const OrderFilterTabs(),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: context.linkColor,
                onRefresh: () => notifier.refreshOrders(),
                child: isLoading && emptyAll
                    ? const ConsumerOrdersSkeleton()
                    : list.isEmpty
                    ? ListView(
                        cacheExtent: 300,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: _dockClearance),
                        children: [
                          OrderEmptyState(
                            title: selectedFilter != null
                                ? context.l10n.ordersEmptyFilteredTitle
                                : context.l10n.ordersEmptyTitle,
                            subtitle: context.l10n.ordersBrowseProducts,
                            filterActive: selectedFilter != null,
                          ),
                        ],
                      )
                    : ListView.builder(
                        controller: _scroll,
                        physics: const AlwaysScrollableScrollPhysics(),
                        cacheExtent: 700,
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          AppSpacing.xl,
                          0,
                          AppSpacing.xl,
                          _dockClearance,
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
                                bottom: AppSpacing.lg,
                              ),
                              child:
                                  OrderCard(
                                    key: ValueKey(list[i].id),
                                    order: list[i],
                                  ).fadeSlideIn(
                                    delay: AppAnimations.staggerDelayCapped(i),
                                  ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.notifier});

  final OrdersNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.glassColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.borderColor),
      ),
      child: TextField(
        autofocus: true,
        decoration: InputDecoration(
          hintText: context.l10n.ordersSearchHint,
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsetsDirectional.only(
            start: AppSpacing.lg,
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              notifier.setSearching(false);
              notifier.updateSearch('');
            },
          ),
        ),
        onChanged: notifier.updateSearch,
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.glassColor,
      shape: CircleBorder(side: BorderSide(color: context.borderColor)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox.square(
          dimension: 44,
          child: Icon(icon, size: 22, color: context.textPrimary),
        ),
      ),
    );
  }
}
