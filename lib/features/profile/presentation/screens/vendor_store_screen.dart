import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/mock/mock_images.dart';
import '../../../../core/router/app_routes.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../home/presentation/widgets/product_card.dart';
import '../../../listing/domain/entities/listing_entity.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../providers/profile_dependencies.dart';
import '../providers/profile_provider.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_cached_network_image.dart';
import '../../../store/presentation/providers/store_hours_provider.dart';
import '../../../store/presentation/widgets/store_hours_summary_card.dart';

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
    final authUser = ref.read(authProvider).valueOrNull;
    final isOwnStore = authUser != null &&
        authUser.id.isNotEmpty &&
        authUser.id == widget.sellerId &&
        authUser.hasStore;

    final profRes = isOwnStore
        ? await _loadOwnStoreProfile(repo, authUser)
        : await repo.getVendorStoreProfile(widget.sellerId);
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

  /// Own store: get-profile carries `store.storeLogoUrl`; the legacy
  /// `/users/{id}/store` route does not exist on the live backend yet.
  Future<Either<Failure, ProfileEntity>> _loadOwnStoreProfile(
    ProfileRepository repo,
    UserEntity sessionUser,
  ) async {
    final cached = ref.read(profileNotifierProvider).profile;
    if (cached != null) return Right(cached);
    return repo.getProfile(sessionUser);
  }

  static String? _nonEmptyUrl(String? url) {
    final trimmed = url?.trim();
    return trimmed != null && trimmed.isNotEmpty ? trimmed : null;
  }

  static Widget _storeBannerFallback(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.profileHeaderGradientEnd,
          ],
        ),
      ),
    );
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
    final storePhoto = _nonEmptyUrl(u.storeLogoUrl);
    final banner = storePhoto ?? MockImages.banner(widget.sellerId.hashCode);
    final desc = u.storeDescription ?? '';
    final authUser = ref.watch(authProvider).valueOrNull;
    final isOwnStore = authUser != null &&
        authUser.id.isNotEmpty &&
        authUser.id == widget.sellerId &&
        authUser.hasStore;
    final storeHoursState =
        isOwnStore ? ref.watch(storeHoursNotifierProvider) : null;
    final isOpen = storeHoursState?.isStoreOpen ?? false;

    return Scaffold(
      backgroundColor: context.backgroundColor,
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
                iconTheme: IconThemeData(color: AppColors.white),
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      AppCachedNetworkImage(
                        imageUrl: banner,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) =>
                            _storeBannerFallback(context),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              context.textPrimary.withValues(alpha: 0.05),
                              context.textPrimary.withValues(alpha: 0.75),
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
                              backgroundColor: AppColors.primary,
                              backgroundImage: storePhoto != null
                                  ? AppNetworkImage.cached(storePhoto)
                                  : null,
                              child: storePhoto == null
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
                                  const Gap(AppSpacing.xs),
                                  if (isOwnStore && storeHoursState != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.sm,
                                        vertical: AppSpacing.xs,
                                      ),
                                      decoration: BoxDecoration(
                                        color: (isOpen ? AppColors.success : AppColors.error).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        isOpen ? '● ${context.l10n.storeOpenNow}' : '● ${context.l10n.storeClosedNow}',
                                        style: AppTypography.labelSmall.copyWith(
                                          color: isOpen ? AppColors.success : AppColors.error,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  Text(
                                    '⭐ ${(u.rating ?? 0).toStringAsFixed(1)} · ${u.totalSales ?? 0} ${context.l10n.statSalesShort}'
                                    '${joinedLine.isNotEmpty ? ' · ${context.l10n.storeJoinedPrefix}$joinedLine' : ''}',
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
                                        child: Text(context.l10n.followStore),
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
                        Text(context.l10n.storeDescriptionHeading, style: AppTypography.titleMedium),
                        const Gap(AppSpacing.sm),
                        Text(
                          desc,
                          maxLines: _descExpanded ? null : 3,
                          overflow: _descExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                          style: AppTypography.bodyMedium,
                        ),
                        TextButton(
                          onPressed: () => setState(() => _descExpanded = !_descExpanded),
                          child: Text(_descExpanded ? context.l10n.readLess : context.l10n.readMore),
                        ),
                      ],
                    ),
                  ),
                ),
              if (isOwnStore && storeHoursState?.current != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.l10n.storeHours, style: AppTypography.titleMedium),
                        const Gap(AppSpacing.sm),
                        StoreHoursSummaryCard(schedule: storeHoursState!.current!.schedule),
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
                        label: Text(context.l10n.allCategoriesChip),
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
                 SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.x3l),
                    child: Center(child: Text(context.l10n.emptyInbox)),
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
                          listingId: item.id,
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
        context.l10n.vendorStoreStatListings,
      ),
      (
        '${u.totalSales ?? 0}',
        context.l10n.vendorStoreStatSales,
      ),
      (
        '${profile.responseRatePercent}%',
        context.l10n.vendorStoreStatResponse,
      ),
      (
        (u.rating ?? 0).toStringAsFixed(1),
        context.l10n.statRating,
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg, horizontal: AppSpacing.xs),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        boxShadow: [
          BoxShadow(
            color: context.textPrimary.withValues(alpha: 0.06),
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
                color: context.textDisabled.withValues(alpha: 0.45),
              ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    cells[i].$1,
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
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
