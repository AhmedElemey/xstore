import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/cart_clear_cart_sheet.dart';
import '../widgets/cart_consumer_body.dart';
import '../widgets/cart_vendor_buyers_only.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(authProvider).valueOrNull?.role ?? UserRole.consumer;
    final cart = ref.watch(cartProvider);

    if (role == UserRole.vendor) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(AppStrings.cartTitle),
          backgroundColor: AppColors.cardBg,
          surfaceTintColor: AppColors.transparent,
          elevation: 0,
        ),
        body: const CartVendorBuyersOnly(),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.cartAppBarTitle(cart.itemCount)),
        backgroundColor: AppColors.cardBg,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          if (cart.items.isNotEmpty)
            IconButton(
              icon: const Icon(LucideIcons.trash2),
              onPressed: () => showCartClearConfirmSheet(context, ref),
            ),
        ],
      ),
      body: const CartConsumerBody(),
    );
  }
}
