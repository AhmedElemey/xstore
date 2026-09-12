import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/analytics/analytics_service.dart';
import '../../../../core/analytics/event_names.dart';
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
import '../../../../shared/utils/whatsapp.dart';
import '../../../../shared/widgets/app_cached_network_image.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/error_state_widget.dart';

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

  Future<void> _openStoreWhatsApp(String? phone, String storeName) async {
    final text = context.l10n.whatsappStorePrefill(storeName);
    final opened = await launchWhatsApp(
      phone: phone ?? '',
      prefilledText: text,
    );
    if (!mounted) return;
    if (!opened) {
      AppSnackbar.info(context, context.l10n.whatsappSellerUnavailable);
      return;
    }
    ref
        .read(analyticsServiceProvider)
        .track(
          AnalyticsEvents.whatsappSellerTap,
          properties: {
            AnalyticsProps.source: 'store',
            AnalyticsProps.sellerId: widget.sellerId,
          },
        );
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
        body: ErrorStateWidget(
          message: context.l10n.storeUnavailableNow,
          retryLabel: context.l10n.retry,
          onRetry: _refresh,
        ),
      );
    }
    final profile = _profile!;
    final u = profile.user;
    final name = u.storeName ?? u.name;
    final joined = u.joinedAt;
    final joinedLine = joined != null ? DateFormat('MMM y').format(joined) : '';
    final storePhoto = _nonEmptyUrl(u.storeLogoUrl);
    final desc = u.storeDescription ?? '';
    final authUser = ref.watch(authProvider).valueOrNull;
    final isOwnStore = _isOwnStore(authUser);
    final whatsapp = (u.whatsappNumber ?? '').trim();

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
                backgroundColor: context.surfaceColor,
                surfaceTintColor: AppColors.transparent,
                foregroundColor: context.textPrimary,
                title: Text(context.l10n.stepStore),
                actions: [
                  IconButton(
                    onPressed: () => Share.share(name),
                    icon: const Icon(LucideIcons.share2, size: 20),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.lg,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: context.surfaceColor,
                      borderRadius: BorderRadius.circular(AppSpacing.xl),
                      boxShadow: [
                        BoxShadow(
                          color: context.cardShadowColor,
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
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
                                color: context.surfaceColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: context.cardShadowColor,
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                backgroundColor: AppColors.primary,
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
                                            style: AppTypography.titleLarge
                                                .copyWith(
                                              color: AppColors.white,
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
                                    style: AppTypography.titleMedium,
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
                        if (!isOwnStore && whatsapp.isNotEmpty) ...[
                          const Gap(AppSpacing.lg),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  _openStoreWhatsApp(u.whatsappNumber, name),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.success,
                                side: BorderSide(
                                  color: AppColors.success.withValues(alpha: 0.5),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.md,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppSpacing.md),
                                ),
                              ),
                              icon: const Icon(
                                LucideIcons.messageCircle,
                                size: 18,
                              ),
                              label: Text(
                                context.l10n.ordersWhatsapp,
                                style: AppTypography.labelLarge,
                              ),
                            ),
                          ),
                        ],
                        const Gap(AppSpacing.lg),
                        Divider(height: 1, color: context.dividerColor),
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
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      0,
                      AppSpacing.lg,
                      AppSpacing.lg,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: context.surfaceColor,
                        borderRadius: BorderRadius.circular(AppSpacing.lg),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.storeDescriptionHeading,
                            style: AppTypography.titleSmall,
                          ),
                          const Gap(AppSpacing.sm),
                          Text(
                            desc,
                            maxLines: _descExpanded ? null : 3,
                            overflow: _descExpanded
                                ? TextOverflow.visible
                                : TextOverflow.ellipsis,
                            style: AppTypography.bodyMedium.copyWith(
                              color: context.textSecondary,
                            ),
                          ),
                          if (desc.length > 120)
                            Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(0, 0),
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () =>
                                    setState(() => _descExpanded = !_descExpanded),
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
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    children: [
                      _CategoryChip(
                        label: context.l10n.allCategoriesChip,
                        selected: _category == 'all',
                        onTap: () => _onCategorySelected('all'),
                      ),
                      ..._categories.map(
                        (c) => Padding(
                          padding: const EdgeInsets.only(left: AppSpacing.sm),
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
                          size: AppSpacing.x3l * 2,
                          color: context.textDisabled,
                        ),
                        const Gap(AppSpacing.lg),
                        Text(
                          context.l10n.noResultsTitle,
                          style: AppTypography.titleSmall,
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
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 0,
                      crossAxisSpacing: 0,
                      childAspectRatio: 0.82,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final item = _listings[i];
                        return ListingCardGrid(
                          listing: item,
                          imageHeight: 110,
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
    return Material(
      color: selected ? AppColors.primary : context.surfaceColor,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? AppColors.primary : context.borderColor,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTypography.labelLarge.copyWith(
              color: selected ? AppColors.white : context.textSecondary,
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
        '${profile.responseRatePercent}%',
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
                Icon(cells[i].$1, size: 18, color: AppColors.primary),
                const Gap(AppSpacing.xs),
                Text(
                  cells[i].$2,
                  textAlign: TextAlign.center,
                  style: AppTypography.body15.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Gap(2),
                Text(
                  cells[i].$3,
                  textAlign: TextAlign.center,
                  style: AppTypography.labelSmall,
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
