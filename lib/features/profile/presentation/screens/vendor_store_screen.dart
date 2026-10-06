import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/router/app_routes.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../listing/domain/entities/listing_entity.dart';
import '../../../listing/presentation/providers/listing_dependencies.dart';
import '../../../listing/presentation/widgets/listing_card_grid.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../providers/profile_dependencies.dart';
import '../providers/profile_provider.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/utils/public_seller_stats.dart';
import '../../../../shared/widgets/app_cached_network_image.dart';
import '../../../../shared/widgets/auth_back_button.dart';
import '../../../../shared/widgets/orbit_background.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/expandable_text.dart';

/// Radius of the storefront avatar in the profile card header.
const double _kAvatarRadius = 38;

class VendorStoreScreen extends ConsumerStatefulWidget {
  const VendorStoreScreen({super.key, required this.sellerId});

  final String sellerId;

  @override
  ConsumerState<VendorStoreScreen> createState() => _VendorStoreScreenState();
}

class _VendorStoreScreenState extends ConsumerState<VendorStoreScreen> {
  ProfileEntity? _profile;
  final List<ListingEntity> _listings = [];
  List<ListingEntity>? _ownListingsCache;
  String? _error;
  var _loading = true;
  var _loadingMore = false;
  var _page = 0;
  var _hasMore = true;
  String _category = 'all';
  var _descExpanded = false;

  static const _pageSize = 10;

  bool _isOwnStore(UserEntity? authUser) {
    return authUser != null &&
        authUser.hasStore &&
        authUser.id.isNotEmpty &&
        authUser.id == widget.sellerId;
  }

  Future<void> _fetchPage(int page, {bool replace = false}) async {
    final authUser = ref.read(authProvider).valueOrNull;
    if (_isOwnStore(authUser)) {
      await _fetchOwnListingsPage(page, replace: replace);
      return;
    }

    final repo = ref.read(profileRepositoryProvider);
    final res = await repo.fetchVendorStoreListings(
      sellerId: widget.sellerId,
      categoryLabel: _category == 'all' ? null : _category,
      page: page,
      pageSize: _pageSize,
    );
    if (!mounted) return;
    res.fold(
      (_) {
        setState(() {
          _loadingMore = false;
          _loading = false;
          if (replace) {
            _listings.clear();
            _hasMore = false;
          }
        });
      },
      (items) {
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
      },
    );
  }

  /// Own storefront: `GET /users/{id}/listings` is not on the live API.
  /// `GET /api/listings/my-listings` is the confirmed vendor list.
  Future<void> _fetchOwnListingsPage(int page, {required bool replace}) async {
    if (_ownListingsCache == null) {
      final result = await ref.read(listingRepositoryProvider).getMyListings();
      if (!mounted) return;
      final failed = result.fold(
        (_) {
          setState(() {
            _loading = false;
            _loadingMore = false;
            _hasMore = false;
            if (replace) _listings.clear();
          });
          return true;
        },
        (items) {
          _ownListingsCache = items;
          return false;
        },
      );
      if (failed) return;
    }

    var rows = _ownListingsCache ?? const <ListingEntity>[];
    if (_category != 'all') {
      rows = [
        for (final e in rows)
          if (e.categoryLabel == _category) e,
      ];
    }
    final start = page * _pageSize;
    final slice = start >= rows.length
        ? const <ListingEntity>[]
        : rows.skip(start).take(_pageSize).toList();
    setState(() {
      if (replace) {
        _listings
          ..clear()
          ..addAll(slice);
      } else {
        _listings.addAll(slice);
      }
      _hasMore = start + slice.length < rows.length;
      _loading = false;
      _loadingMore = false;
    });
  }

  Future<void> _bootstrap() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final repo = ref.read(profileRepositoryProvider);
    var authUser = ref.read(authProvider).valueOrNull;
    if (authUser == null) {
      authUser = await ref.read(authProvider.future);
      if (!mounted) return;
    }
    final isOwnStore = _isOwnStore(authUser);

    final profRes = isOwnStore
        ? await _loadOwnStoreProfile(repo, authUser!)
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

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _refresh() async {
    setState(() {
      _listings.clear();
      _ownListingsCache = null;
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
    if (_loadingMore || !_hasMore || n.metrics.axis != Axis.vertical) {
      return false;
    }
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
      return _OrbitPage(
        child: Column(
          children: [
            const _StoreHeader(),
            const Expanded(
              child: Center(child: CircularProgressIndicator.adaptive()),
            ),
          ],
        ),
      );
    }
    if (_error != null && _profile == null) {
      return _OrbitPage(
        child: Column(
          children: [
            const _StoreHeader(),
            Expanded(
              child: ErrorStateWidget(
                message: context.l10n.storeUnavailableNow,
                retryLabel: context.l10n.retry,
                onRetry: _refresh,
              ),
            ),
          ],
        ),
      );
    }
    final profile = _profile!;
    final u = profile.user;
    final name = u.storeName ?? u.name;
    final joined = u.joinedAt;
    final joinedLine = joined != null ? context.formatMonthYear(joined) : '';
    final storePhoto = _nonEmptyUrl(u.storeLogoUrl);
    final desc = u.storeDescription ?? '';

    return _OrbitPage(
      child: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          _handleScroll(n);
          return false;
        },
        child: RefreshIndicator(
          color: context.linkColor,
          onRefresh: _refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _StoreHeader(onShare: () => Share.share(name)),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    AppSpacing.xl,
                    AppSpacing.md,
                    AppSpacing.xl,
                    AppSpacing.lg,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: context.glassColor,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: context.borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: _kAvatarRadius * 2,
                              height: _kAvatarRadius * 2,
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: context.brandGradient,
                                ),
                              ),
                              child: CircleAvatar(
                                backgroundColor: Colors.transparent,
                                backgroundImage: storePhoto != null
                                    ? AppNetworkImage.cached(storePhoto)
                                    : null,
                                child: storePhoto == null
                                    ? FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Padding(
                                          padding: const EdgeInsets.all(
                                            AppSpacing.sm,
                                          ),
                                          child: Text(
                                            name.isNotEmpty
                                                ? name[0].toUpperCase()
                                                : '?',
                                            style: AppTypography.headlineSmall
                                                .copyWith(
                                                  color: context.onBrandColor,
                                                  height: 1,
                                                ),
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                            const Gap(AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.headlineSmall.copyWith(
                                      fontSize: 20,
                                      color: context.textPrimary,
                                    ),
                                  ),
                                  const Gap(AppSpacing.xs),
                                  Text(
                                    '${publicSellerStatsLabel(context.l10n, rating: u.rating, sales: u.totalSales)}'
                                    '${joinedLine.isNotEmpty ? ' · ${context.l10n.storeJoinedPrefix}$joinedLine' : ''}',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: context.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Gap(AppSpacing.lg),
                        Divider(height: 1, color: context.borderColor),
                        const Gap(AppSpacing.lg),
                        _VendorStoreStatsRow(profile: profile),
                      ],
                    ),
                  ),
                ),
              ),
              if (desc.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      AppSpacing.xl,
                      0,
                      AppSpacing.xl,
                      AppSpacing.lg,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: context.glassColor,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: context.borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.storeDescriptionHeading.toUpperCase(),
                            style: AppTypography.fieldLabel.copyWith(
                              color: context.labelColor,
                            ),
                          ),
                          const Gap(AppSpacing.sm),
                          ExpandableText(
                            text: desc,
                            maxLines: 3,
                            expanded: _descExpanded,
                            style: AppTypography.bodyMedium.copyWith(
                              color: context.textSecondary,
                            ),
                            toggle: TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                foregroundColor: context.linkColor,
                              ),
                              onPressed: () => setState(
                                () => _descExpanded = !_descExpanded,
                              ),
                              child: Text(
                                _descExpanded
                                    ? context.l10n.readLess
                                    : context.l10n.readMore,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: AppSpacing.xl,
                    ),
                    children: [
                      _CategoryChip(
                        label: context.l10n.allCategoriesChip,
                        selected: _category == 'all',
                        onTap: () => _onCategorySelected('all'),
                      ),
                      ..._categories.map(
                        (c) => Padding(
                          padding: const EdgeInsetsDirectional.only(
                            start: AppSpacing.sm,
                          ),
                          child: _CategoryChip(
                            label: c,
                            selected: _category == c,
                            onTap: () => _onCategorySelected(c),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: Gap(AppSpacing.lg)),
              if (_listings.isEmpty && !_loading)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.x2l,
                      vertical: AppSpacing.x3l,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.packageSearch,
                          size: AppSpacing.x4l + AppSpacing.lg,
                          color: context.linkColor.withValues(alpha: 0.5),
                        ),
                        const Gap(AppSpacing.lg),
                        Text(
                          context.l10n.noResultsTitle,
                          style: AppTypography.titleMedium.copyWith(
                            color: context.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const Gap(AppSpacing.xs),
                        Text(
                          context.l10n.noResultsSubtitle,
                          style: AppTypography.bodyMedium.copyWith(
                            color: context.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 0,
                          crossAxisSpacing: 0,
                          childAspectRatio: 0.78,
                        ),
                    delegate: SliverChildBuilderDelegate((context, i) {
                      final item = _listings[i];
                      return ListingCardGrid(
                        listing: item,
                        imageHeight: 110,
                        onTap: () =>
                            context.push('${AppRoutes.product}/${item.id}'),
                      );
                    }, childCount: _listings.length),
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

/// Orbit sky behind the store page (a pushed route, so no dock to clear).
class _OrbitPage extends StatelessWidget {
  const _OrbitPage({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: OrbitBackground(child: SafeArea(child: child)),
    );
  }
}

/// Back button, title and (once the store has loaded) a share action.
class _StoreHeader extends StatelessWidget {
  const _StoreHeader({this.onShare});

  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        0,
      ),
      child: SizedBox(
        height: 44,
        child: Row(
          children: [
            // A shared store link opens with nothing to pop back to.
            if (Navigator.of(context).canPop()) ...[
              const AuthBackButton(),
              const Gap(AppSpacing.md),
            ],
            Expanded(
              child: Text(
                context.l10n.stepStore,
                style: AppTypography.headlineSmall.copyWith(
                  fontSize: 20,
                  color: context.textPrimary,
                ),
              ),
            ),
            if (onShare != null)
              Material(
                color: context.glassColor,
                shape: CircleBorder(
                  side: BorderSide(color: context.borderColor),
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onShare,
                  child: SizedBox.square(
                    dimension: 44,
                    child: Icon(
                      LucideIcons.share2,
                      size: 20,
                      color: context.textPrimary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final selectedBg = context.isDark ? context.textPrimary : AppColors.primary;
    final selectedFg = context.isDark ? AppColors.darkOnBrand : AppColors.white;
    return Material(
      color: selected ? selectedBg : context.glassColor,
      shape: StadiumBorder(
        side: BorderSide(color: selected ? selectedBg : context.borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Center(
            child: Text(
              label,
              style: AppTypography.labelLarge.copyWith(
                color: selected ? selectedFg : context.textSecondary,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _VendorStoreStatsRow extends StatelessWidget {
  const _VendorStoreStatsRow({required this.profile});

  final ProfileEntity profile;

  @override
  Widget build(BuildContext context) {
    final u = profile.user;
    final cells = [
      (
        LucideIcons.package,
        '${profile.storeActiveListings}',
        context.l10n.vendorStoreStatListings,
      ),
      (
        LucideIcons.shoppingBag,
        u.totalSales != null && u.totalSales! > 0
            ? '${u.totalSales}'
            : context.l10n.newSellerEmDash,
        context.l10n.vendorStoreStatSales,
      ),
      (
        LucideIcons.messageCircle,
        profile.responseRatePercent > 0
            ? '${profile.responseRatePercent}%'
            : context.l10n.newSellerEmDash,
        context.l10n.vendorStoreStatResponse,
      ),
      (
        LucideIcons.star,
        u.rating != null && u.rating! > 0
            ? u.rating!.toStringAsFixed(1)
            : context.l10n.newSellerEmDash,
        context.l10n.statRating,
      ),
    ];

    return Row(
      children: [
        for (var i = 0; i < cells.length; i++) ...[
          if (i > 0) const Gap(AppSpacing.xs),
          Expanded(
            child: Column(
              children: [
                Icon(cells[i].$1, size: 18, color: context.linkColor),
                const Gap(AppSpacing.xs),
                Text(
                  cells[i].$2,
                  textAlign: TextAlign.center,
                  style: AppTypography.mono.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                  ),
                ),
                const Gap(2),
                Text(
                  cells[i].$3.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: AppTypography.fieldLabel.copyWith(
                    fontSize: 9,
                    letterSpacing: 0.6,
                    color: context.labelColor,
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
