import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
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
    final role = ref.watch(
      authProvider.select((a) => a.valueOrNull?.role ?? UserRole.consumer),
    );
    final itemCount = ref.watch(cartProvider.select((c) => c.itemCount));
    final hasItems = ref.watch(cartProvider.select((c) => c.items.isNotEmpty));

    if (role == UserRole.vendor) {
      return Scaffold(
        backgroundColor: context.backgroundColor,
        appBar: AppBar(
          title: Text(context.l10n.cartTitle),
          backgroundColor: context.surfaceColor,
          surfaceTintColor: AppColors.transparent,
          elevation: 0,
        ),
        body: const CartVendorBuyersOnly(),
      );
    }

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: Text(context.l10n.cartAppBarTitle(itemCount)),
        backgroundColor: context.surfaceColor,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
        leading: IconButton(
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          if (hasItems)
            IconButton(
              tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
              icon: const Icon(LucideIcons.trash2),
              onPressed: () => showCartClearConfirmSheet(context, ref),
            ),
        ],
      ),
      body: const CartConsumerBody(),
    );
  }
}
