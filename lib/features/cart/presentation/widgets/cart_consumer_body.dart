import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/network/app_error_messages.dart';
import '../providers/cart_provider.dart';
import 'cart_checkout_bar.dart';
import 'cart_empty_state.dart';
import 'cart_recommended_strip.dart';
import 'cart_summary_card.dart';
import 'cart_vendor_group.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/skeletons/cart_skeleton.dart';

class CartConsumerBody extends ConsumerWidget {
  const CartConsumerBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(cartProvider.select((c) => c.isLoading));
    final items = ref.watch(cartProvider.select((c) => c.items));
    final groups = ref.watch(cartProvider.select((c) => c.vendorGroups));
    final error = ref.watch(cartProvider.select((c) => c.error));

    if (isLoading && items.isEmpty) {
      return const CartSkeleton();
    }

    if (items.isEmpty) {
      if (error != null) {
        return ErrorStateWidget(
          message: resolveAppError(context, error),
          retryLabel: context.l10n.retry,
          onRetry: () => ref.read(cartProvider.notifier).fetchCart(),
        );
      }
      return const CartEmptyState();
    }
    final childCount = groups.length + 5;

    return Column(
      children: [
        if (error != null)
          Container(
            margin: const EdgeInsetsDirectional.fromSTEB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.lg),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
            ),
            child: ListTile(
              leading: const Icon(Icons.error_outline, color: AppColors.error),
              title: Text(
                resolveAppError(context, error),
                style: TextStyle(color: AppColors.error),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => ref.read(cartProvider.notifier).clearError(),
              ),
            ),
          ),
        Expanded(
          child: CustomScrollView(
            cacheExtent: 1000,
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  0,
                  AppSpacing.xl,
                  AppSpacing.lg,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    if (index < groups.length) {
                      final group = groups[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                        child: RepaintBoundary(
                          child: CartVendorGroupBlock(
                            key: ValueKey<String>(
                              'cart-vendor-${group.vendorId}',
                            ),
                            group: group,
                          ),
                        ),
                      );
                    }
                    final tail = index - groups.length;
                    switch (tail) {
                      case 0:
                        return const Gap(AppSpacing.lg);
                      case 1:
                        return const CartSummaryCard();
                      case 2:
                        return const Gap(AppSpacing.x2l);
                      case 3:
                        return const CartRecommendedStrip();
                      case 4:
                        return const Gap(AppSpacing.x4l);
                      default:
                        return const SizedBox.shrink();
                    }
                  }, childCount: childCount),
                ),
              ),
            ],
          ),
        ),
        const CartCheckoutBar(),
      ],
    );
  }
}
