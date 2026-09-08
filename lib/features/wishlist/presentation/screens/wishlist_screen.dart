import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/route_reentry_refresh.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../widgets/wishlist_consumer_body.dart';
import '../widgets/wishlist_vendor_guard.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(
      authProvider.select((a) => a.valueOrNull?.role ?? UserRole.consumer),
    );

    ref.listen(
      cartProvider.select((s) => s.items),
      (prev, next) {
      Future.microtask(
        () => ref.read(wishlistProvider.notifier).syncWithCart(next),
      );
    });

    if (role == UserRole.vendor) {
      return Scaffold(
        backgroundColor: context.backgroundColor,
        appBar: AppBar(
          backgroundColor: context.surfaceColor,
          surfaceTintColor: AppColors.transparent,
          elevation: 0,
        ),
        body: const WishlistVendorGuard(),
      );
    }

    final selection = ref.watch(
      wishlistProvider.select(
        (s) => (
          isSelectionMode: s.isSelectionMode,
          selectedCount: s.selectedItemIds.length,
        ),
      ),
    );

    return RouteReentryRefresh(
      isTarget: (location) => location == AppRoutes.wishlist,
      onReentry: (ref) => ref.read(wishlistProvider.notifier).fetchWishlist(),
      child: Scaffold(
        backgroundColor: context.backgroundColor,
        appBar: AppBar(
          title: Text(
            selection.isSelectionMode
                ? context.l10n.wishlistSelectedCount(selection.selectedCount)
                : context.l10n.navWishlist,
          ),
          backgroundColor: context.backgroundColor,
          surfaceTintColor: AppColors.transparent,
          elevation: 0,
        ),
        body: const WishlistConsumerBody(),
      ),
    );
  }
}
