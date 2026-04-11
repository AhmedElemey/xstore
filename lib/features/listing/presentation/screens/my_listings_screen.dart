import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/animations/app_animations.dart';
import '../../../../core/animations/app_dialogs.dart';
import '../../../../core/animations/animation_extensions.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../domain/entities/listing_entity.dart';
import '../providers/my_listings_notifier.dart';
import '../providers/my_listings_state.dart';
import '../widgets/listing_card_grid.dart';
import '../widgets/listing_card_list.dart';
import '../widgets/listing_empty_state.dart';
import '../widgets/listing_filter_tabs.dart';
import '../widgets/listing_options_sheet.dart';
import '../widgets/listing_sort_bar.dart';
import '../widgets/listing_stats_banner.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/skeletons/my_listings_skeleton.dart';

class MyListingsScreen extends ConsumerStatefulWidget {
  const MyListingsScreen({super.key});

  @override
  ConsumerState<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends ConsumerState<MyListingsScreen> {
  var _handledPublishToast = false;
  final ValueNotifier<bool> _fabVisible = ValueNotifier<bool>(true);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_handledPublishToast) {
      return;
    }
    final msg = GoRouterState.of(context).uri.queryParameters['msg'];
    if (msg == 'published') {
      _handledPublishToast = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        AppSnackbar.success(context, 'Listing published successfully');
        context.go(AppRoutes.listingMy);
        ref.read(myListingsNotifierProvider.notifier).fetchListings();
      });
    }
  }

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

  void _openSearch() {
    final controller = TextEditingController(
      text: ref.read(myListingsNotifierProvider).searchQuery,
    );
    showAnimatedDialog<void>(
      context: context,
      child: AlertDialog(
        title: Text('Search listings'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Search by title'),
          onSubmitted: (v) {
            ref.read(myListingsNotifierProvider.notifier).setSearchQuery(v);
            Navigator.of(context).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(myListingsNotifierProvider.notifier).setSearchQuery('');
              Navigator.of(context).pop();
            },
            child: Text('Clear'),
          ),
          FilledButton(
            onPressed: () {
              ref
                  .read(myListingsNotifierProvider.notifier)
                  .setSearchQuery(controller.text);
              Navigator.of(context).pop();
            },
            child: Text('Search'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(ListingEntity listing) async {
    final ok = await showAnimatedDialog<bool>(
      context: context,
      child: AlertDialog(
        title: Text('Delete listing?'),
        content: Text('“${listing.title}” will be removed permanently.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      await ref
          .read(myListingsNotifierProvider.notifier)
          .deleteListing(listing.id);
    }
  }

  void _showOptions(ListingEntity listing) {
    showAnimatedBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: ListingOptionsSheet(
          listing: listing,
          onEdit: () {
            context.push(AppRoutes.listingAdd);
          },
          onPause: () => ref
              .read(myListingsNotifierProvider.notifier)
              .pauseListing(listing.id),
          onResume: () => ref
              .read(myListingsNotifierProvider.notifier)
              .resumeListing(listing.id),
          onViewStats: () {
            showAnimatedBottomSheet<void>(
              context: context,
              builder: (_) => Material(
                color: Theme.of(context).colorScheme.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                clipBehavior: Clip.antiAlias,
                child: ListingStatsSheet(listing: listing),
              ),
            );
          },
          onDelete: () => _confirmDelete(listing),
        ),
      ),
    );
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

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: context.surfaceColor,
        surfaceTintColor: Colors.transparent,
        title: Text('My Listings'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.search),
            onPressed: _openSearch,
          ),
        ],
      ),
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
              child: FloatingActionButton.extended(
                onPressed: () => context.push(AppRoutes.listingAdd),
                icon: const Icon(LucideIcons.plus),
                label: Text(context.l10n.newListing),
              ),
            ),
          );
        },
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: ListingStatsBanner(
              totalCount: stats.totalCount,
              activeCount: stats.activeCount,
              soldCount: stats.soldCount,
            ),
          ),
          ListingFilterTabs(
            selected: selectedFilter,
            onFilterSelected: ref
                .read(myListingsNotifierProvider.notifier)
                .applyFilter,
          ),
          const Gap(AppSpacing.md),
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
              FilledButton(
                onPressed: () => ref
                    .read(myListingsNotifierProvider.notifier)
                    .fetchListings(),
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (filtered.isEmpty) {
      return RefreshIndicator(
        onRefresh: () =>
            ref.read(myListingsNotifierProvider.notifier).refreshListings(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.55,
              child: ListingEmptyState(
                selectedFilter: selectedFilter,
                onAddListing: () => context.push(AppRoutes.listingAdd),
              ),
            ),
          ],
        ),
      );
    }

    if (viewMode == ViewMode.list) {
      return RefreshIndicator(
        onRefresh: () =>
            ref.read(myListingsNotifierProvider.notifier).refreshListings(),
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          cacheExtent: 700,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            88,
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
              ).fadeSlideIn(
                delay: AppAnimations.staggerDelayCapped(i),
              ),
            );
          },
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(myListingsNotifierProvider.notifier).refreshListings(),
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        cacheExtent: 700,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          88,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
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
            ).fadeSlideIn(
              delay: AppAnimations.staggerDelayCapped(i),
            ),
          );
        },
      ),
    );
  }
}

