import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/extensions/context_extensions.dart';
import '../../features/cart/presentation/providers/cart_provider.dart';
import 'orbit_widgets.dart';

/// Add-to-cart as a cart icon on a glass disc. The icon turns green once
/// the listing is in the cart; tapping still calls [onPressed].
class CartIconButton extends ConsumerWidget {
  const CartIconButton({
    super.key,
    required this.listingId,
    required this.onPressed,
  });

  final String listingId;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inCart = ref.watch(
      cartProvider.select((s) => s.items.any((i) => i.listingId == listingId)),
    );
    return OrbitCircleButton(
      tooltip: inCart ? context.l10n.cartIconInCart : context.l10n.addToCart,
      onPressed: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      child: Icon(
        LucideIcons.shoppingCart,
        size: 18,
        color: inCart ? AppColors.success : context.primaryColor,
      ),
    );
  }
}
