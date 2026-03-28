import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/extensions/async_value_extensions.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/product_skeleton_card.dart';
import '../../domain/entities/deal_entity.dart';
import '../providers/banners_provider.dart';
import '../providers/categories_provider.dart';
import '../providers/hot_deals_provider.dart';
import '../widgets/category_chip_row.dart';
import '../widgets/flash_sale_banner.dart';
import '../widgets/hero_banner_carousel.dart';
import '../widgets/hot_deals_section.dart';
import '../widgets/new_arrivals_grid.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _openDeal(BuildContext context, DealEntity deal) {
    context.push('${AppRoutes.product}/${deal.id}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final banners = ref.watch(bannersProvider);
    final deals = ref.watch(hotDealsProvider);
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.homeTitle)),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(bannersProvider);
          ref.invalidate(hotDealsProvider);
          ref.invalidate(categoriesProvider);
          await Future.wait([
            ref.read(bannersProvider.future),
            ref.read(hotDealsProvider.future),
            ref.read(categoriesProvider.future),
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            banners.toWidget(
              data: (data) => HeroBannerCarousel(banners: data),
              loading: () => const SizedBox(
                height: 180,
                child: Center(child: CircularProgressIndicator.adaptive()),
              ),
              errorBuilder: (e) => ErrorStateWidget(
                message: e.toString(),
                onRetry: () => ref.invalidate(bannersProvider),
              ),
            ),
            const Gap(AppSpacing.md),
            const FlashSaleBanner(),
            const Gap(AppSpacing.md),
            categories.toWidget(
              data: (data) => CategoryChipRow(categories: data),
              loading: () => const SizedBox(
                height: 40,
                child: Center(child: CircularProgressIndicator.adaptive()),
              ),
            ),
            const Gap(AppSpacing.md),
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
            deals.toWidget(
              data: (data) => NewArrivalsGrid(
                items: data,
                onOpenProduct: (d) => _openDeal(context, d),
              ),
              loading: () => const SizedBox.shrink(),
              errorBuilder: (_) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _DealsSkeleton extends StatelessWidget {
  const _DealsSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        SizedBox(width: 160, child: ProductSkeletonCard()),
        SizedBox(width: 160, child: ProductSkeletonCard()),
      ],
    );
  }
}
