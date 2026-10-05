import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/orbit_background.dart';
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

    ref.listen(cartProvider.select((s) => s.items), (prev, next) {
      Future.microtask(
        () => ref.read(wishlistProvider.notifier).syncWithCart(next),
      );
    });

    if (role == UserRole.vendor) {
      return const Scaffold(
        body: OrbitBackground(child: WishlistVendorGuard()),
      );
    }

    return RouteReentryRefresh(
      isTarget: (location) => location == AppRoutes.wishlist,
      onReentry: (ref) => ref.read(wishlistProvider.notifier).fetchWishlist(),
      child: Scaffold(
        body: OrbitBackground(
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    AppSpacing.xl,
                    AppSpacing.lg,
                    AppSpacing.xl,
                    AppSpacing.md,
                  ),
                  child: Text(
                    context.l10n.navWishlist,
                    style: AppTypography.headlineSmall.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Expanded(child: WishlistConsumerBody()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
