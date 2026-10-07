import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/animations/app_animations.dart';
import '../../../../core/animations/animation_extensions.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/extensions/async_value_extensions.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../../shared/utils/require_login.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/orbit_background.dart';
import '../../../../shared/widgets/product_skeleton_card.dart';
import '../../../../shared/widgets/route_reentry_refresh.dart';
import '../../../../shared/widgets/skeletons/home_skeleton.dart';
import '../../domain/entities/deal_entity.dart';
import '../providers/banners_provider.dart';
import '../providers/categories_provider.dart';
import '../providers/home_dependencies.dart';
import '../providers/hot_deals_provider.dart';
import '../providers/new_arrivals_provider.dart';
import '../widgets/category_chip_row.dart';
import '../widgets/featured_categories_banner.dart';
import '../widgets/hero_banner_carousel.dart';
import '../widgets/home_header.dart';
import '../widgets/hot_deals_section.dart';
import '../widgets/new_arrivals_grid.dart';
import '../widgets/recommended_section.dart';
import '../../../../core/network/dio_error_mapper.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const double _dockClearance = 124;

  void _openDeal(BuildContext context, DealEntity deal) {
    context.push('${AppRoutes.product}/${deal.id}');
  }

  void _openListing(BuildContext context, String id) {
    context.push('${AppRoutes.product}/$id');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final banners = ref.watch(bannersProvider.select((value) => value));
    final deals = ref.watch(hotDealsProvider.select((value) => value));
    final categories = ref.watch(categoriesProvider.select((value) => value));
    final newArrivals = ref.watch(newArrivalsProvider.select((value) => value));
    final isConsumer = ref.watch(
      authProvider.select((auth) => auth.valueOrNull?.role != UserRole.vendor),
    );
    final cartCount = isConsumer
        ? ref.watch(cartProvider.select((s) => s.itemCount))
        : 0;

    final initialLoading =
        (!banners.hasValue && banners.isLoading) ||
        (!deals.hasValue && deals.isLoading) ||
        (!categories.hasValue && categories.isLoading) ||
        (!newArrivals.hasValue && newArrivals.isLoading);

    if (initialLoading) {
      return const Scaffold(body: OrbitBackground(child: HomeSkeleton()));
    }

    return RouteReentryRefresh(
      isTarget: (location) => location == AppRoutes.home,
      onReentry: (ref) {
        ref.invalidate(bannersProvider);
        ref.invalidate(categoriesProvider);
        ref.invalidate(homeFeedProvider);
      },
      child: Scaffold(
        body: OrbitBackground(
          child: RefreshIndicator(
            color: context.linkColor,
            onRefresh: () async {
              ref.invalidate(bannersProvider);
              ref.invalidate(categoriesProvider);
              // Hot deals, new arrivals and recommended rebuild from this one
              // fetch.
              ref.invalidate(homeFeedProvider);
              await Future.wait([
                ref.read(bannersProvider.future),
                ref.read(categoriesProvider.future),
                ref.read(homeFeedProvider.future),
              ]);
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: HomeHeader(
                    onSearchTap: () => context.go(AppRoutes.explore),
                    onCartTap: isConsumer
                        ? () {
                            if (!requireLogin(context, ref)) return;
                            context.push(AppRoutes.cart);
                          }
                        : null,
                    cartItemCount: cartCount,
                  ).fadeSlideIn(duration: AppAnimations.medium),
                ),
                SliverPadding(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      banners.toWidget(
                        data: (data) => HeroBannerCarousel(
                          banners: data,
                          onBannerTap: (url) => context.go(url),
                        ).scaleIn(delay: const Duration(milliseconds: 100)),
                        loading: () => const _BannerShimmer(),
                        errorBuilder: (e) => ErrorStateWidget(
                          message: userErrorMessage(e),
                          onRetry: () => ref.invalidate(bannersProvider),
                        ),
                      ),
                      const Gap(AppSpacing.lg),
                      Text(
                        context.l10n.shopByCategory,
                        style: AppTypography.headlineSmall.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ).fadeSlideIn(delay: const Duration(milliseconds: 200)),
                      const Gap(AppSpacing.md),
                      categories.toWidget(
                        data: (data) => CategoryChipRow(
                          categories: data,
                          onSelected: (c) => context.go(
                            Uri(
                              path: AppRoutes.explore,
                              queryParameters: {'category': c.name},
                            ).toString(),
                          ),
                        ),
                        loading: () => const SizedBox(
                          height: AppSpacing.x3l + AppSpacing.sm,
                          child: _BannerShimmer(),
                        ),
                        errorBuilder: (e) => ErrorStateWidget(
                          message: userErrorMessage(e),
                          onRetry: () => ref.invalidate(categoriesProvider),
                        ),
                      ),
                      const Gap(AppSpacing.lg),
                      deals.toWidget(
                        data: (data) => HotDealsSection(
                          deals: data,
                          onOpenProduct: (d) => _openDeal(context, d),
                        ),
                        loading: () => const _DealsSkeleton(),
                        errorBuilder: (e) => ErrorStateWidget(
                          message: userErrorMessage(e),
                          onRetry: () => ref.invalidate(homeFeedProvider),
                        ),
                      ),
                      const Gap(AppSpacing.lg),
                      FeaturedCategoriesBanner()
                          .animate()
                          .fadeIn(duration: AppAnimations.normal)
                          .slideY(
                            begin: 0.06,
                            end: 0,
                            duration: AppAnimations.medium,
                            curve: AppAnimations.enter,
                          ),
                      const Gap(AppSpacing.lg),
                      newArrivals.toWidget(
                        data: (data) => NewArrivalsGrid(
                          items: data,
                          onOpenProduct: (listing) =>
                              _openListing(context, listing.id),
                        ),
                        loading: () => const _DealsSkeleton(),
                        errorBuilder: (e) => ErrorStateWidget(
                          message: userErrorMessage(e),
                          onRetry: () => ref.invalidate(homeFeedProvider),
                        ),
                      ),
                      const Gap(AppSpacing.lg),
                      const RecommendedSection(),
                      // Clears the floating dock.
                      const Gap(_dockClearance),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BannerShimmer extends StatelessWidget {
  const _BannerShimmer();

  @override
  Widget build(BuildContext context) => const ProductSkeletonCard();
}

class _DealsSkeleton extends StatelessWidget {
  const _DealsSkeleton();

  @override
  Widget build(BuildContext context) {
    final w = AppSpacing.x4l * 3 + AppSpacing.lg;
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        SizedBox(width: w, child: const ProductSkeletonCard()),
        SizedBox(width: w, child: const ProductSkeletonCard()),
      ],
    );
  }
}
