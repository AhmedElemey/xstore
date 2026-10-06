import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/animations/app_dialogs.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../commission/presentation/providers/vendor_commission_wallet_provider.dart';
import '../../../commission/presentation/widgets/vendor_commission_alert_banner.dart';
import '../../domain/entities/listing_entity.dart';
import '../providers/listing_dependencies.dart';
import '../providers/my_listings_notifier.dart';
import '../providers/my_listings_state.dart';
import '../widgets/listing_card_grid.dart';
import '../widgets/listing_card_list.dart';
import '../widgets/listing_empty_state.dart';
import '../widgets/listing_filter_tabs.dart';
import '../widgets/listing_options_sheet.dart';
import '../widgets/listing_sort_bar.dart';
import '../widgets/listing_stats_banner.dart';
import '../widgets/resubmit_listing_sheet.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/orbit_background.dart';
import '../../../../shared/widgets/xstore_button.dart';
import '../../../../shared/widgets/route_reentry_refresh.dart';
import '../../../../shared/widgets/skeletons/my_listings_skeleton.dart';

class MyListingsScreen extends ConsumerStatefulWidget {
  const MyListingsScreen({super.key});

  @override
  ConsumerState<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends ConsumerState<MyListingsScreen> {
  // Bottom padding so the last card scrolls clear of the New Listing pill.
  static const double _fabClearance = 88;

  final ValueNotifier<bool> _fabVisible = ValueNotifier<bool>(true);

  void _onScrollNotification(ScrollNotification n) {
    if (n is! UserScrollNotification) {
      return;
    }
    final dir = n.direction;
    if (dir == ScrollDirection.forward) {
      if (_fabVisible.value) {
        _fabVisible.value = false;
      }
    } else if (dir == ScrollDirection.reverse) {
      if (!_fabVisible.value) {
        _fabVisible.value = true;
      }
    }
  }

  @override
  void dispose() {
    _fabVisible.dispose();
    super.dispose();
  }

  Future<void> _openSearch() async {
    await showAnimatedDialog<void>(
      context: context,
      child: _ListingSearchDialog(
        initialQuery: ref.read(myListingsNotifierProvider).searchQuery,
        onClear: () =>
            ref.read(myListingsNotifierProvider.notifier).setSearchQuery(''),
        onSubmit: (q) =>
            ref.read(myListingsNotifierProvider.notifier).setSearchQuery(q),
      ),
    );
  }

  Future<void> _confirmDelete(ListingEntity listing) async {
    final ok = await showAnimatedDialog<bool>(
      context: context,
      child: Builder(
        builder: (dialogContext) => AlertDialog(
          title: Text(context.l10n.myListingsDeleteTitle),
          content: Text(context.l10n.myListingsDeleteBody(listing.title)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(dialogContext).colorScheme.error,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(context.l10n.deleteListing),
            ),
          ],
        ),
      ),
    );
    if (ok == true && mounted) {
      await ref
          .read(myListingsNotifierProvider.notifier)
          .deleteListing(listing.id);
    }
  }

  Future<void> _openResubmitSheet(ListingEntity listing) async {
    final ok = await showAnimatedBottomSheet<bool>(
      context: context,
      builder: (ctx) => Material(
        color: context.elevatedSurfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        clipBehavior: Clip.antiAlias,
        child: ResubmitListingSheet(
          listing: listing,
          onSubmit: (newPrice) => ref
              .read(myListingsNotifierProvider.notifier)
              .resubmitListing(listing.id, newPrice),
        ),
      ),
    );
    // A failure stays in the sheet, shown inline — nothing to toast here.
    if (!mounted || ok != true) return;
    AppSnackbar.success(context, context.l10n.resubmitSuccess);
  }

  /// The listing already on this screen comes from the my-listings list
  /// response, which may only carry a summary shape — refetch the full
  /// detail (category/condition/brand/stock/shipping/location/attributes)
  /// by id before opening the edit form so every field is actually
  /// prefilled, falling back to the summary entity if the fetch fails.
  Future<void> _openEdit(ListingEntity listing) async {
    final result = await ref
        .read(getListingByIdUseCaseProvider)
        .call(listing.id);
    if (!mounted) return;
    result.fold(
      (_) => context.go(AppRoutes.listingAdd, extra: listing),
      (full) => context.go(AppRoutes.listingAdd, extra: full),
    );
  }

  Future<void> _showOptions(ListingEntity listing) async {
    final action = await showAnimatedBottomSheet<ListingOptionsAction>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Material(
        color: context.elevatedSurfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        clipBehavior: Clip.antiAlias,
        child: ListingOptionsSheet(listing: listing),
      ),
    );
    if (!mounted || action == null) return;
    switch (action) {
      case ListingOptionsAction.edit:
        await _openEdit(listing);
      case ListingOptionsAction.pause:
        await ref
            .read(myListingsNotifierProvider.notifier)
            .pauseListing(listing.id);
      case ListingOptionsAction.resume:
        await ref
            .read(myListingsNotifierProvider.notifier)
            .resumeListing(listing.id);
      case ListingOptionsAction.stats:
        await showAnimatedBottomSheet<void>(
          context: context,
          builder: (_) => Material(
            color: context.elevatedSurfaceColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            clipBehavior: Clip.antiAlias,
            child: ListingStatsSheet(listing: listing),
          ),
        );
      case ListingOptionsAction.delete:
        await _confirmDelete(listing);
      case ListingOptionsAction.resubmit:
        await _openResubmitSheet(listing);
    }
  }

  @override
  Widget build(BuildContext context) {
    final listings = ref.watch(
      myListingsNotifierProvider.select((s) => s.listings),
    );
    final filtered = ref.watch(
      myListingsNotifierProvider.select((s) => s.filteredListings),
    );
    final selectedFilter = ref.watch(
      myListingsNotifierProvider.select((s) => s.selectedFilter),
    );
    final selectedSort = ref.watch(
      myListingsNotifierProvider.select((s) => s.selectedSort),
    );
    final viewMode = ref.watch(
      myListingsNotifierProvider.select((s) => s.viewMode),
    );
    final isLoading = ref.watch(
      myListingsNotifierProvider.select((s) => s.isLoading),
    );
    final error = ref.watch(myListingsNotifierProvider.select((s) => s.error));
    final stats = ref.watch(
      myListingsNotifierProvider.select((s) {
        final all = s.listings;
        final active = all
            .where((e) => e.status == ListingStatus.active)
            .length;
        final sold = all.where((e) => e.status == ListingStatus.sold).length;
        return (totalCount: all.length, activeCount: active, soldCount: sold);
      }),
    );

    ref.listen<String?>(myListingsNotifierProvider.select((s) => s.error), (
      prev,
      next,
    ) {
      if (next != null && next.isNotEmpty && next != prev) {
        AppSnackbar.error(context, next);
      }
    });

    return RouteReentryRefresh(
      isTarget: (location) => location == AppRoutes.listingMy,
      onReentry: (ref) =>
          ref.read(myListingsNotifierProvider.notifier).fetchListings(),
      child: Material(
        type: MaterialType.transparency,
        child: OrbitBackground(
          child: Scaffold(
            // The sky paints behind; the Scaffold only hosts the FAB.
            backgroundColor: Colors.transparent,
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            floatingActionButton: ValueListenableBuilder<bool>(
              valueListenable: _fabVisible,
              builder: (context, fabVisible, _) {
                return AnimatedSlide(
                  duration: const Duration(milliseconds: 220),
                  offset: fabVisible ? Offset.zero : const Offset(0, 2),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: fabVisible ? 1 : 0,
                    child: _NewListingPill(
                      label: context.l10n.newListing,
                      onPressed: () => context.go(AppRoutes.listingAdd),
                    ),
                  ),
                );
              },
            ),
            body: SafeArea(
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
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              context.l10n.myListings,
                              style: AppTypography.headlineSmall.copyWith(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          _GlassIconButton(
                            icon: LucideIcons.search,
                            onPressed: _openSearch,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      AppSpacing.xl,
                      0,
                      AppSpacing.xl,
                      AppSpacing.lg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Consumer(
                          builder: (context, ref, _) {
                            final wallet = ref
                                .watch(vendorCommissionWalletProvider)
                                .valueOrNull;
                            if (wallet == null) return const SizedBox.shrink();
                            return VendorCommissionAlertBanner(wallet: wallet);
                          },
                        ),
                        ListingStatsBanner(
                          totalCount: stats.totalCount,
                          activeCount: stats.activeCount,
                          soldCount: stats.soldCount,
                        ),
                      ],
                    ),
                  ),
                  ListingFilterTabs(
                    selected: selectedFilter,
                    onFilterSelected: ref
                        .read(myListingsNotifierProvider.notifier)
                        .applyFilter,
                  ),
                  ListingSortBar(
                    sort: selectedSort,
                    viewMode: viewMode,
                    onSortChanged: ref
                        .read(myListingsNotifierProvider.notifier)
                        .applySort,
                    onViewModeChanged: ref
                        .read(myListingsNotifierProvider.notifier)
                        .setViewMode,
                  ),
                  Expanded(
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (n) {
                        _onScrollNotification(n);
                        return false;
                      },
                      child: _buildBody(
                        isLoading: isLoading,
                        listings: listings,
                        filtered: filtered,
                        selectedFilter: selectedFilter,
                        viewMode: viewMode,
                        error: error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody({
    required bool isLoading,
    required List<ListingEntity> listings,
    required List<ListingEntity> filtered,
    required ListingStatus? selectedFilter,
    required ViewMode viewMode,
    required String? error,
  }) {
    if (isLoading && listings.isEmpty) {
      return RefreshIndicator(
        color: context.linkColor,
        onRefresh: () =>
            ref.read(myListingsNotifierProvider.notifier).refreshListings(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [SizedBox(height: 900, child: MyListingsSkeleton())],
        ),
      );
    }

    if (listings.isEmpty && error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.x2l),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(error, textAlign: TextAlign.center),
              const Gap(AppSpacing.lg),
              XstoreButton(
                label: context.l10n.retry,
                onPressed: () => ref
                    .read(myListingsNotifierProvider.notifier)
                    .fetchListings(),
              ),
            ],
          ),
        ),
      );
    }

    if (filtered.isEmpty) {
      return RefreshIndicator(
        color: context.linkColor,
        onRefresh: () =>
            ref.read(myListingsNotifierProvider.notifier).refreshListings(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.55,
              child: ListingEmptyState(
                selectedFilter: selectedFilter,
                onAddListing: () => context.go(AppRoutes.listingAdd),
              ),
            ),
          ],
        ),
      );
    }

    if (viewMode == ViewMode.list) {
      return RefreshIndicator(
        color: context.linkColor,
        onRefresh: () =>
            ref.read(myListingsNotifierProvider.notifier).refreshListings(),
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          cacheExtent: 700,
          padding: const EdgeInsetsDirectional.fromSTEB(
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.xl,
            _fabClearance,
          ),
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const Gap(AppSpacing.md),
          itemBuilder: (context, i) {
            final item = filtered[i];
            return RepaintBoundary(
              child: ListingCardList(
                key: ValueKey(item.id),
                listing: item,
                onOpenMenu: () => _showOptions(item),
              ),
            );
          },
        ),
      );
    }

    return RefreshIndicator(
      color: context.linkColor,
      onRefresh: () =>
          ref.read(myListingsNotifierProvider.notifier).refreshListings(),
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        cacheExtent: 700,
        padding: const EdgeInsetsDirectional.fromSTEB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          _fabClearance,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 0,
          crossAxisSpacing: 0,
          childAspectRatio: 0.72,
        ),
        itemCount: filtered.length,
        itemBuilder: (context, i) {
          final item = filtered[i];
          return RepaintBoundary(
            child: ListingCardGrid(
              key: ValueKey(item.id),
              listing: item,
              onOpenMenu: () => _showOptions(item),
            ),
          );
        },
      ),
    );
  }
}

/// Owns search text as a plain field so we never dispose a
/// [TextEditingController] while [showAnimatedDialog]'s exit animation
/// still holds the [TextField] (that race asserts `_dependents.isEmpty`
/// on [OfflineBannerHost]'s Stack).
class _ListingSearchDialog extends StatefulWidget {
  const _ListingSearchDialog({
    required this.initialQuery,
    required this.onClear,
    required this.onSubmit,
  });

  final String initialQuery;
  final VoidCallback onClear;
  final ValueChanged<String> onSubmit;

  @override
  State<_ListingSearchDialog> createState() => _ListingSearchDialogState();
}

class _ListingSearchDialogState extends State<_ListingSearchDialog> {
  late String _query = widget.initialQuery;

  void _pop() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.myListingsSearchTitle),
      content: TextFormField(
        initialValue: widget.initialQuery,
        autofocus: true,
        decoration: InputDecoration(
          hintText: context.l10n.myListingsSearchHint,
        ),
        onChanged: (v) => _query = v,
        onFieldSubmitted: (_) {
          widget.onSubmit(_query);
          _pop();
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onClear();
            _pop();
          },
          child: Text(context.l10n.myListingsSearchClear),
        ),
        FilledButton(
          onPressed: () {
            widget.onSubmit(_query);
            _pop();
          },
          child: Text(context.l10n.myListingsSearchSubmit),
        ),
      ],
    );
  }
}

/// Frosted circular header action (same look as the orders screen).
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

/// "New Listing" action: the brand-gradient pill, with a plus.
class _NewListingPill extends StatelessWidget {
  const _NewListingPill({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final gradient = context.brandGradient;
    final onBrand = context.onBrandColor;
    return Semantics(
      button: true,
      label: label,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient),
          borderRadius: BorderRadius.circular(27),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withValues(alpha: 0.35),
              blurRadius: 24,
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(27),
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.lg,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.plus, size: 20, color: onBrand),
                  const Gap(AppSpacing.sm),
                  Text(
                    label,
                    style: AppTypography.labelLarge.copyWith(
                      color: onBrand,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
