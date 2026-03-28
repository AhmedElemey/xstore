import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/product_skeleton_card.dart';
import '../../../home/presentation/providers/recommended_provider.dart';
import '../../../home/presentation/widgets/product_card.dart';

class CartRecommendedStrip extends ConsumerWidget {
  const CartRecommendedStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(recommendedProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.cartYouMayAlsoLike,
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const Gap(AppSpacing.md),
        async.when(
          data: (items) {
            if (items.isEmpty) return const SizedBox.shrink();
            return SizedBox(
              height: AppSpacing.x4l * 5 + AppSpacing.md,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuilder: (_, __) => const Gap(AppSpacing.md),
                itemBuilder: (context, i) {
                  final listing = items[i];
                  return SizedBox(
                    width: AppSpacing.x4l * 3 + AppSpacing.lg,
                    child: ProductCard(
                      title: listing.title,
                      price: listing.price,
                      imageUrl: listing.imageUrls.isNotEmpty
                          ? listing.imageUrls.first
                          : null,
                      discountPercent: 0,
                      listingId: listing.id,
                      onTap: () => context.push(
                        '${AppRoutes.product}/${listing.id}',
                      ),
                    ),
                  );
                },
              ),
            );
          },
          loading: () => SizedBox(
            height: AppSpacing.x4l * 5,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              separatorBuilder: (_, __) => const Gap(AppSpacing.md),
              itemBuilder: (_, __) => SizedBox(
                width: AppSpacing.x4l * 3 + AppSpacing.lg,
                child: const ProductSkeletonCard(),
              ),
            ),
          ),
          error: (e, _) => ErrorStateWidget(
            message: e.toString(),
            onRetry: () => ref.invalidate(recommendedProvider),
          ),
        ),
      ],
    );
  }
}
