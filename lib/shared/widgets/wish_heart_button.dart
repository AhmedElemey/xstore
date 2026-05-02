import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/router/app_routes.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/wishlist/presentation/providers/wishlist_provider.dart';
import '../../core/utils/extensions/context_extensions.dart';
import 'app_snackbar.dart';
import 'heart_burst_animation.dart';

/// Single entry point for wishlist heart UI: state, toggle, and snackbars.
class WishHeartButton extends ConsumerWidget {
  const WishHeartButton({
    super.key,
    required this.listingId,
    this.size = 24,
    this.onDarkBackground = false,
  });

  final String listingId;
  final double size;
  final bool onDarkBackground;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(
      authProvider.select((a) => a.valueOrNull?.role ?? UserRole.consumer),
    );
    if (role == UserRole.vendor) {
      return SizedBox(width: size, height: size);
    }

    final isWishlisted = ref.watch(
      wishlistProvider.select(
        (s) => s.wishlistedListingIds.contains(listingId),
      ),
    );

    final outlineColor = onDarkBackground
        ? AppColors.white.withValues(alpha: 0.92)
        : context.textSecondary;

    return Material(
      color: onDarkBackground
          ? context.textPrimary.withValues(alpha: 0.38)
          : context.surfaceColor.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: IconButton(
        tooltip: isWishlisted
            ? context.l10n.wishlistRemovedSnack
            : context.l10n.buyerFeature4,
        padding: EdgeInsets.zero,
        constraints: BoxConstraints.tightFor(width: size + 8, height: size + 8),
        iconSize: size,
        onPressed: () => _onTap(context, ref, isWishlisted),
        icon: HeartBurstAnimation(
          isFavorite: isWishlisted,
          child: Icon(
            isWishlisted
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            color: isWishlisted ? AppColors.error : outlineColor,
          ),
        ),
      ),
    );
  }

  Future<void> _onTap(
    BuildContext context,
    WidgetRef ref,
    bool wasWishlisted,
  ) async {
    HapticFeedback.lightImpact();
    await ref.read(wishlistProvider.notifier).toggleWishlist(listingId);
    if (!context.mounted) return;
    final nowWishlisted = ref.read(wishlistProvider).wishlistedListingIds
        .contains(listingId);
    ScaffoldMessenger.of(context).clearSnackBars();
    if (nowWishlisted && !wasWishlisted) {
      AppSnackbar.show(
        context,
        message: AppStrings.wishlistSavedSnack,
        action: SnackBarAction(
          label: AppStrings.wishlistView,
          onPressed: () => context.go(AppRoutes.wishlist),
        ),
      );
    } else if (!nowWishlisted && wasWishlisted) {
      AppSnackbar.show(
        context,
        message: AppStrings.wishlistRemovedSnack,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: AppStrings.cartUndo,
          onPressed: () => ref.read(wishlistProvider.notifier).undoRemove(),
        ),
      );
    }
  }
}
