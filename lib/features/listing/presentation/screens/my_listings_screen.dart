import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/router/app_routes.dart';
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

class MyListingsScreen extends ConsumerStatefulWidget {
  const MyListingsScreen({super.key});

  @override
  ConsumerState<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends ConsumerState<MyListingsScreen> {
  var _handledPublishToast = false;
  var _fabVisible = true;

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Listing published successfully'),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
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
      if (_fabVisible) {
        setState(() => _fabVisible = false);
      }
    } else if (dir == ScrollDirection.reverse) {
      if (!_fabVisible) {
        setState(() => _fabVisible = true);
      }
    }
  }

  void _openSearch() {
    final controller = TextEditingController(text: ref.read(myListingsNotifierProvider).searchQuery);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Search listings'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Search by title'),
          onSubmitted: (v) {
            ref.read(myListingsNotifierProvider.notifier).setSearchQuery(v);
            Navigator.of(ctx).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(myListingsNotifierProvider.notifier).setSearchQuery('');
              Navigator.of(ctx).pop();
            },
            child: const Text('Clear'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(myListingsNotifierProvider.notifier).setSearchQuery(controller.text);
              Navigator.of(ctx).pop();
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(ListingEntity listing) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete listing?'),
        content: Text('“${listing.title}” will be removed permanently.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      await ref.read(myListingsNotifierProvider.notifier).deleteListing(listing.id);
    }
  }

  void _showOptions(ListingEntity listing) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: false,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => ListingOptionsSheet(
        listing: listing,
        onEdit: () {
          context.push(AppRoutes.listingAdd);
        },
        onPause: () => ref.read(myListingsNotifierProvider.notifier).pauseListing(listing.id),
        onResume: () => ref.read(myListingsNotifierProvider.notifier).resumeListing(listing.id),
        onViewStats: () {
          showModalBottomSheet<void>(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (_) => ListingStatsSheet(listing: listing),
          );
        },
        onDelete: () => _confirmDelete(listing),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myListingsNotifierProvider);

    ref.listen<MyListingsState>(myListingsNotifierProvider, (prev, next) {
      final msg = next.error;
      if (msg != null && msg.isNotEmpty && msg != prev?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
        );
      }
    });

    final listings = state.listings;
    final filtered = state.filteredListings;
    final activeCount = listings.where((e) => e.status == ListingStatus.active).length;
    final soldCount = listings.where((e) => e.status == ListingStatus.sold).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: const Text('My Listings'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.search),
            onPressed: _openSearch,
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: AnimatedSlide(
        duration: const Duration(milliseconds: 220),
        offset: _fabVisible ? Offset.zero : const Offset(0, 2),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _fabVisible ? 1 : 0,
          child: FloatingActionButton.extended(
            onPressed: () => context.push(AppRoutes.listingAdd),
            icon: const Icon(LucideIcons.plus),
            label: const Text('New Listing'),
          ),
        ),
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
              totalCount: listings.length,
              activeCount: activeCount,
              soldCount: soldCount,
            ),
          ),
          ListingFilterTabs(
            selected: state.selectedFilter,
            onFilterSelected: ref.read(myListingsNotifierProvider.notifier).applyFilter,
          ),
          const Gap(AppSpacing.md),
          ListingSortBar(
            sort: state.selectedSort,
            viewMode: state.viewMode,
            onSortChanged: ref.read(myListingsNotifierProvider.notifier).applySort,
            onViewModeChanged: ref.read(myListingsNotifierProvider.notifier).setViewMode,
          ),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (n) {
                _onScrollNotification(n);
                return false;
              },
              child: _buildBody(
                state: state,
                filtered: filtered,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody({
    required MyListingsState state,
    required List<ListingEntity> filtered,
  }) {
    if (state.isLoading && state.listings.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => ref.read(myListingsNotifierProvider.notifier).refreshListings(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: const [
            _ListingListSkeleton(),
            Gap(AppSpacing.md),
            _ListingListSkeleton(),
            Gap(AppSpacing.md),
            _ListingListSkeleton(),
          ],
        ),
      );
    }

    if (state.listings.isEmpty && state.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.x2l),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(state.error!, textAlign: TextAlign.center),
              const Gap(AppSpacing.lg),
              FilledButton(
                onPressed: () => ref.read(myListingsNotifierProvider.notifier).fetchListings(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (filtered.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => ref.read(myListingsNotifierProvider.notifier).refreshListings(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.55,
              child: ListingEmptyState(
                selectedFilter: state.selectedFilter,
                onAddListing: () => context.push(AppRoutes.listingAdd),
              ),
            ),
          ],
        ),
      );
    }

    if (state.viewMode == ViewMode.list) {
      return RefreshIndicator(
        onRefresh: () => ref.read(myListingsNotifierProvider.notifier).refreshListings(),
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
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
            return ListingCardList(
              listing: item,
              onOpenMenu: () => _showOptions(item),
            );
          },
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(myListingsNotifierProvider.notifier).refreshListings(),
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
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
          return ListingCardGrid(
            listing: item,
            onOpenMenu: () => _showOptions(item),
          );
        },
      ),
    );
  }
}

class _ListingListSkeleton extends StatelessWidget {
  const _ListingListSkeleton();

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Shimmer.fromColors(
      baseColor: base.withValues(alpha: 0.45),
      highlightColor: base.withValues(alpha: 0.9),
      child: Container(
        height: 112,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
