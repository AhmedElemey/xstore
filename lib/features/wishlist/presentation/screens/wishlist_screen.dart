import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../cart/presentation/providers/cart_state.dart';
import '../providers/wishlist_provider.dart';
import '../widgets/wishlist_consumer_body.dart';
import '../widgets/wishlist_vendor_guard.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(authProvider).valueOrNull?.role ?? UserRole.consumer;

    ref.listen<CartState>(cartProvider, (prev, next) {
      Future.microtask(
        () => ref.read(wishlistProvider.notifier).syncWithCart(next.items),
      );
    });

    if (role == UserRole.vendor) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.cardBg,
          surfaceTintColor: AppColors.transparent,
          elevation: 0,
        ),
        body: const WishlistVendorGuard(),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: const WishlistConsumerBody(),
      ),
    );
  }
}
