import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
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

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        bottom: false,
        child: const WishlistConsumerBody(),
      ),
    );
  }
}
