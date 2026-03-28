import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/prefs_keys.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../shared/providers/shared_providers.dart';
import '../explore_provider.dart';
import '../explore_state.dart';
import '../widgets/active_filters_row.dart';
import '../widgets/explore_empty_state.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/product_grid_card.dart';
import '../widgets/product_list_card.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/search_suggestions_overlay.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final _q = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final cat = GoRouterState.of(context).uri.queryParameters['category'];
      final n = ref.read(exploreProvider.notifier);
      if (cat != null) {
        n.bootstrapFromRouteCategory(cat);
      } else {
        await n.search('');
      }
      _q.text = ref.read(exploreProvider).query;
    });
  }

  @override
  void dispose() {
    _q.dispose();
    _focus.dispose();
    super.dispose();
  }

  int _filterCount(FilterState f) {
    var c = f.categories.length + f.conditions.length;
    if (f.minPrice != null || f.maxPrice != null) c++;
    if (f.minRating != null) c++;
    if (f.location != null && f.location!.isNotEmpty) c++;
    if (f.shippingOnly) c++;
    return c;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(exploreProvider);
    final notifier = ref.read(exploreProvider.notifier);
    final isVendor = ref.watch(authProvider).valueOrNull?.isVendor == true;
    final recentAsync = ref.watch(sharedPreferencesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.exploreTitle)),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          await notifier.search(state.query);
        },
        child: NotificationListener<ScrollNotification>(
          onNotification: (n) {
            if (n.metrics.pixels > n.metrics.maxScrollExtent - 200) {
              notifier.loadMore();
            }
            return false;
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      SearchBarWidget(
                        controller: _q,
                        focusNode: _focus,
                        onChanged: (v) {
                          notifier.onQueryChanged(v);
                        },
                        onClear: () {
                          _q.clear();
                          notifier.clearQueryField();
                        },
                      ),
                      if (state.suggestions.isNotEmpty && _focus.hasFocus) ...[
                        const Gap(AppSpacing.sm),
                        SearchSuggestionsOverlay(
                          suggestions: state.suggestions,
                          onSelect: (s) {
                            _q.text = s;
                            notifier.onQueryChanged(s);
                            _focus.unfocus();
                          },
                        ),
                      ],
                      recentAsync.when(
                        data: (prefs) {
                          final recent =
                              prefs.getStringList(PrefsKeys.exploreRecentSearches) ?? [];
                          if (recent.isEmpty || _focus.hasFocus || state.query.isNotEmpty) {
                            return const SizedBox.shrink();
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Gap(AppSpacing.md),
                              const RecentSearchesHeader(),
                              Wrap(
                                spacing: AppSpacing.sm,
                                children: recent
                                    .map(
                                      (t) => ActionChip(
                                        label: Text(t),
                                        onPressed: () {
                                          _q.text = t;
                                          notifier.onQueryChanged(t);
                                        },
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                      const Gap(AppSpacing.lg),
                      ActiveFiltersRow(
                        filters: state.filters,
                        activeFilterCount: _filterCount(state.filters),
                        onRemoveCategory: (c) {
                          final next = List<String>.from(state.filters.categories)
                            ..remove(c);
                          notifier.applyFilters(state.filters.copyWith(categories: next));
                        },
                        onRemoveCondition: (c) {
                          final next = List<String>.from(state.filters.conditions)
                            ..remove(c);
                          notifier.applyFilters(state.filters.copyWith(conditions: next));
                        },
                        onClearAll: notifier.resetFilters,
                        onOpenFilters: () => showExploreFilterBottomSheet(
                          context: context,
                          initial: state.filters,
                          onApply: notifier.applyFilters,
                          onReset: notifier.resetFilters,
                        ),
                      ),
                      const Gap(AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                                children: [
                                  TextSpan(
                                    text: '${state.results.length}',
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TextSpan(text: ' · ${AppStrings.resultsFor} '),
                                  TextSpan(
                                    text: state.query.isEmpty
                                        ? AppStrings.allListingsLabel
                                        : state.query,
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          DropdownButton<ExploreSortOption>(
                            value: state.sortOption,
                            underline: const SizedBox.shrink(),
                            items: [
                              DropdownMenuItem(
                                value: ExploreSortOption.relevance,
                                child: Text(AppStrings.sortRelevance),
                              ),
                              DropdownMenuItem(
                                value: ExploreSortOption.priceAsc,
                                child: Text(AppStrings.sortPriceAsc),
                              ),
                              DropdownMenuItem(
                                value: ExploreSortOption.priceDesc,
                                child: Text(AppStrings.sortPriceDesc),
                              ),
                              DropdownMenuItem(
                                value: ExploreSortOption.ratingDesc,
                                child: Text(AppStrings.sortByRating),
                              ),
                            ],
                            onChanged: (v) {
                              if (v != null) notifier.setSort(v);
                            },
                          ),
                          IconButton(
                            onPressed: notifier.toggleViewMode,
                            icon: Icon(
                              state.viewMode == ExploreViewMode.grid
                                  ? LucideIcons.list
                                  : LucideIcons.layoutGrid,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const Gap(AppSpacing.lg),
                    ],
                  ),
                ),
              ),
              if (state.isSearching)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator.adaptive()),
                )
              else if (state.results.isEmpty)
                SliverFillRemaining(
                  child: ExploreEmptyState(
                    onPickCategory: (slug) {
                      notifier.bootstrapFromRouteCategory(slug);
                      _q.text = ref.read(exploreProvider).query;
                    },
                  ),
                )
              else if (state.viewMode == ExploreViewMode.grid)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: AppSpacing.md,
                      crossAxisSpacing: AppSpacing.md,
                      childAspectRatio: 0.58,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final item = state.results[i];
                        return ProductGridCard(
                          item: item,
                          isFavorite: state.favoriteIds.contains(item.id),
                          onToggleFavorite: () => notifier.toggleFavorite(item.id),
                          onAddToCart: () {},
                          showAddToCart: !isVendor,
                          onTap: () => context.push('${AppRoutes.product}/${item.id}'),
                        );
                      },
                      childCount: state.results.length,
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final item = state.results[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: ProductListCard(
                            item: item,
                            isFavorite: state.favoriteIds.contains(item.id),
                            onToggleFavorite: () => notifier.toggleFavorite(item.id),
                            onAddToCart: () {},
                            showAddToCart: !isVendor,
                            onTap: () => context.push('${AppRoutes.product}/${item.id}'),
                          ),
                        );
                      },
                      childCount: state.results.length,
                    ),
                  ),
                ),
              if (state.isLoadingMore)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.x2l),
                    child: Center(child: CircularProgressIndicator.adaptive()),
                  ),
                ),
              SliverToBoxAdapter(child: SizedBox(height: AppSpacing.x3l)),
            ],
          ),
        ),
      ),
    );
  }
}
