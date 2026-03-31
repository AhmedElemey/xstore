import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/extensions/async_value_extensions.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/product_skeleton_card.dart';
import '../../domain/entities/deal_entity.dart';
import '../providers/banners_provider.dart';
import '../providers/categories_provider.dart';
import '../providers/hot_deals_provider.dart';
import '../providers/new_arrivals_provider.dart';
import '../providers/recommended_provider.dart';
import '../widgets/category_chip_row.dart';
import '../widgets/featured_categories_banner.dart';
import '../widgets/flash_sale_banner.dart';
import '../widgets/hero_banner_carousel.dart';
import '../widgets/home_header.dart';
import '../widgets/hot_deals_section.dart';
import '../widgets/new_arrivals_grid.dart';
import '../widgets/recommended_section.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

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

    return Scaffold(
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(bannersProvider);
          ref.invalidate(hotDealsProvider);
          ref.invalidate(categoriesProvider);
          ref.invalidate(newArrivalsProvider);
          ref.invalidate(recommendedProvider);
          await Future.wait([
            ref.read(bannersProvider.future),
            ref.read(hotDealsProvider.future),
            ref.read(categoriesProvider.future),
            ref.read(newArrivalsProvider.future),
            ref.read(recommendedProvider.future),
          ]);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              elevation: 0,
              scrolledUnderElevation: 0,
              backgroundColor: context.backgroundColor,
              automaticallyImplyLeading: false,
              toolbarHeight: 0,
              expandedHeight:
                  AppSpacing.x4l * 3 + AppSpacing.x3l + AppSpacing.lg,
              flexibleSpace: FlexibleSpaceBar(
                background: HomeHeader(
                  onSearchTap: () => context.go(AppRoutes.explore),
                  onCartTap: isConsumer
                      ? () => context.push(AppRoutes.cart)
                      : null,
                  cartItemCount: cartCount,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  banners.toWidget(
                    data: (data) => HeroBannerCarousel(banners: data),
                    loading: () => _BannerShimmer(),
                    errorBuilder: (e) => ErrorStateWidget(
                      message: e.toString(),
                      onRetry: () => ref.invalidate(bannersProvider),
                    ),
                  ),
                  const Gap(AppSpacing.lg),
                  const FlashSaleBanner(),
                  const Gap(AppSpacing.lg),
                  Text(
                    AppStrings.shopByCategory,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Gap(AppSpacing.md),
                  categories.toWidget(
                    data: (data) => CategoryChipRow(categories: data),
                    loading: () => SizedBox(
                      height: AppSpacing.x3l + AppSpacing.sm,
                      child: _BannerShimmer(),
                    ),
                    errorBuilder: (e) => ErrorStateWidget(
                      message: e.toString(),
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
                      message: e.toString(),
                      onRetry: () => ref.invalidate(hotDealsProvider),
                    ),
                  ),
                  const Gap(AppSpacing.lg),
                  const FeaturedCategoriesBanner(),
                  const Gap(AppSpacing.lg),
                  newArrivals.toWidget(
                    data: (data) => NewArrivalsGrid(
                      items: data,
                      onOpenProduct: (listing) =>
                          _openListing(context, listing.id),
                    ),
                    loading: () => const _DealsSkeleton(),
                    errorBuilder: (e) => ErrorStateWidget(
                      message: e.toString(),
                      onRetry: () => ref.invalidate(newArrivalsProvider),
                    ),
                  ),
                  const Gap(AppSpacing.lg),
                  const RecommendedSection(),
                  const Gap(AppSpacing.x3l),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BannerShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final base = context.isDark
        ? context.surfaceVariantColor.withValues(alpha: 0.55)
        : context.surfaceVariantColor.withValues(alpha: 0.35);
    final highlight = context.isDark
        ? context.surfaceColor.withValues(alpha: 0.9)
        : context.surfaceColor;
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        height: AppSpacing.x4l * 3 + AppSpacing.x3l + AppSpacing.sm,
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(AppSpacing.lg),
        ),
      ),
    );
  }
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
