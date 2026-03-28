import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/mock/mock_images.dart';
import '../../../../core/router/app_routes.dart';
import '../../../home/presentation/widgets/product_card.dart';
import '../../../listing/domain/entities/listing_entity.dart';
import '../../domain/entities/profile_entity.dart';
import '../providers/profile_dependencies.dart';

class VendorStoreScreen extends ConsumerStatefulWidget {
  const VendorStoreScreen({super.key, required this.sellerId});

  final String sellerId;

  @override
  ConsumerState<VendorStoreScreen> createState() => _VendorStoreScreenState();
}

class _VendorStoreScreenState extends ConsumerState<VendorStoreScreen> {
  ProfileEntity? _profile;
  final List<ListingEntity> _listings = [];
  String? _error;
  var _loading = true;
  var _loadingMore = false;
  var _page = 0;
  var _hasMore = true;
  String _category = 'all';
  var _descExpanded = false;

  static const _pageSize = 10;

  Future<void> _fetchPage(int page, {bool replace = false}) async {
    final repo = ref.read(profileRepositoryProvider);
    final res = await repo.fetchVendorStoreListings(
      sellerId: widget.sellerId,
      categoryLabel: _category == 'all' ? null : _category,
      page: page,
      pageSize: _pageSize,
    );
    res.fold(
      (f) {
        if (mounted) {
          setState(() {
            _error = f.toString();
            _loadingMore = false;
          });
        }
      },
      (items) {
        if (mounted) {
          setState(() {
            if (replace) {
              _listings
                ..clear()
                ..addAll(items);
            } else {
              _listings.addAll(items);
            }
            _hasMore = items.length == _pageSize;
            _loadingMore = false;
            _loading = false;
          });
        }
      },
    );
  }

  Future<void> _bootstrap() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final repo = ref.read(profileRepositoryProvider);
    final profRes = await repo.getVendorStoreProfile(widget.sellerId);
    final failed = profRes.fold(
      (f) {
        if (mounted) {
          setState(() {
            _error = f.toString();
            _loading = false;
          });
        }
        return true;
      },
      (profile) {
        if (mounted) setState(() => _profile = profile);
        return false;
      },
    );
    if (failed) return;
    _page = 0;
    await _fetchPage(0, replace: true);
  }

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _refresh() async {
    setState(() {
      _listings.clear();
      _page = 0;
      _hasMore = true;
    });
    await _bootstrap();
  }

  Future<void> _onCategorySelected(String next) async {
    setState(() {
      _category = next;
      _listings.clear();
      _page = 0;
      _hasMore = true;
      _loading = true;
    });
    await _fetchPage(0, replace: true);
  }

  bool _handleScroll(ScrollNotification n) {
    if (_loadingMore || !_hasMore || n.metrics.axis != Axis.vertical) return false;
    if (n.metrics.pixels >= n.metrics.maxScrollExtent - 280) {
      setState(() => _loadingMore = true);
      final nextPage = _page + 1;
      _page = nextPage;
      _fetchPage(nextPage, replace: false);
    }
    return false;
  }

  Set<String> get _categories {
    final set = <String>{};
    for (final e in _listings) {
      if (e.categoryLabel.isNotEmpty) set.add(e.categoryLabel);
    }
    return set;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _profile == null && _error == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator.adaptive()));
    }
    if (_error != null && _profile == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.x2l),
            child: Text(_error!, textAlign: TextAlign.center),
          ),
        ),
      );
    }
    final profile = _profile!;
    final u = profile.user;
    final name = u.storeName ?? u.name;
    final joined = u.joinedAt;
    final joinedLine = joined != null ? DateFormat('MMM y').format(joined) : '';
    final banner = MockImages.banner(widget.sellerId.hashCode);
    final desc = u.storeDescription ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          _handleScroll(n);
          return false;
        },
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 200,
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        banner,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.profileHeaderGradientEnd,
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.textPrimary.withValues(alpha: 0.05),
                              AppColors.textPrimary.withValues(alpha: 0.75),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: AppSpacing.lg,
                        bottom: AppSpacing.lg,
                        right: AppSpacing.lg,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            CircleAvatar(
                              radius: 35,
                              backgroundImage: u.storeLogoUrl != null
                                  ? NetworkImage(u.storeLogoUrl!)
                                  : null,
                              child: u.storeLogoUrl == null
                                  ? Text(
                                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                                      style: AppTypography.titleLarge.copyWith(
                                        color: AppColors.white,
                                      ),
                                    )
                                  : null,
                            ),
                            const Gap(AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    name,
                                    style: AppTypography.titleMedium.copyWith(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    '⭐ ${(u.rating ?? 0).toStringAsFixed(1)} · ${u.totalSales ?? 0} ${AppStrings.statSalesShort}'
                                    '${joinedLine.isNotEmpty ? ' · ${AppStrings.storeJoinedPrefix}$joinedLine' : ''}',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.white.withValues(alpha: 0.9),
                                    ),
                                  ),
                                  const Gap(AppSpacing.sm),
                                  Row(
                                    children: [
                                      FilledButton(
                                        style: FilledButton.styleFrom(
                                          backgroundColor: AppColors.white,
                                          foregroundColor: AppColors.primary,
                                        ),
                                        onPressed: () {},
                                        child: Text(AppStrings.followStore),
                                      ),
                                      const Gap(AppSpacing.sm),
                                      IconButton.filled(
                                        style: IconButton.styleFrom(
                                          backgroundColor: AppColors.white.withValues(alpha: 0.2),
                                          foregroundColor: AppColors.white,
                                        ),
                                        onPressed: () => Share.share(name),
                                        icon: const Icon(LucideIcons.share2),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: _VendorStoreStatsCard(profile: profile),
                ),
              ),
              if (desc.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppStrings.storeDescriptionHeading, style: AppTypography.titleMedium),
                        const Gap(AppSpacing.sm),
                        Text(
                          desc,
                          maxLines: _descExpanded ? null : 3,
                          overflow: _descExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                          style: AppTypography.bodyMedium,
                        ),
                        TextButton(
                          onPressed: () => setState(() => _descExpanded = !_descExpanded),
                          child: Text(_descExpanded ? AppStrings.readLess : AppStrings.readMore),
                        ),
                      ],
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    children: [
                      ChoiceChip(
                        label: Text(AppStrings.allCategoriesChip),
                        selected: _category == 'all',
                        onSelected: (_) => _onCategorySelected('all'),
                      ),
                      ..._categories.map(
                        (c) => Padding(
                          padding: const EdgeInsets.only(left: AppSpacing.sm),
                          child: ChoiceChip(
                            label: Text(c),
                            selected: _category == c,
                            onSelected: (_) => _onCategorySelected(c),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: Gap(AppSpacing.md)),
              if (_listings.isEmpty && !_loading)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.x3l),
                    child: Center(child: Text(AppStrings.emptyInbox)),
                  ),
                )
              else
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
                        final item = _listings[i];
                        final img = item.imageUrls.isNotEmpty ? item.imageUrls.first : null;
                        return ProductCard(
                          title: item.title,
                          price: item.price,
                          imageUrl: img,
                          onTap: () => context.push('${AppRoutes.product}/${item.id}'),
                        );
                      },
                      childCount: _listings.length,
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.x2l),
                  child: Center(
                    child: _loadingMore
                        ? const CircularProgressIndicator.adaptive()
                        : const SizedBox.shrink(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VendorStoreStatsCard extends StatelessWidget {
  const _VendorStoreStatsCard({required this.profile});

  final ProfileEntity profile;

  @override
  Widget build(BuildContext context) {
    final u = profile.user;
    final cells = [
      (
        '${profile.storeActiveListings}',
        AppStrings.vendorStoreStatListings,
      ),
      (
        '${u.totalSales ?? 0}',
        AppStrings.vendorStoreStatSales,
      ),
      (
        '${profile.responseRatePercent}%',
        AppStrings.vendorStoreStatResponse,
      ),
      (
        (u.rating ?? 0).toStringAsFixed(1),
        AppStrings.statRating,
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg, horizontal: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          for (var i = 0; i < cells.length; i++) ...[
            if (i > 0)
              Container(
                width: 1,
                height: 36,
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                color: AppColors.textDisabled.withValues(alpha: 0.45),
              ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    cells[i].$1,
                    textAlign: TextAlign.center,
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const Gap(AppSpacing.xs),
                  Text(
                    cells[i].$2,
                    textAlign: TextAlign.center,
                    style: AppTypography.labelSmall,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
