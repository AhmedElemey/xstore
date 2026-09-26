import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/animations/animated_widgets.dart';
import '../../core/animations/app_animations.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/extensions/context_extensions.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/cart/presentation/providers/cart_provider.dart';
import '../../features/wishlist/presentation/providers/wishlist_provider.dart';
import '../utils/require_login.dart';
import 'notification_icon_badge.dart';

/// Bottom navigation using implicit animations only (no [TickerProviderStateMixin]).
/// Avoids ticker / dispose races when the shell unmounts during transitions.
class XstoreBottomNav extends ConsumerWidget {
  const XstoreBottomNav({super.key, required this.shell});

  final StatefulNavigationShell shell;

  void _onTap(BuildContext context, WidgetRef ref, int index) {
    // Home (0) and Explore (1) are guest-browsable; every other tab is
    // account-bound. Ask guests to sign in instead of letting the route
    // redirect bounce them to the login screen with no explanation.
    // Signed-in users (any role) pass straight through.
    if (index >= 2 && !requireLogin(context, ref)) return;
    shell.goBranch(index, initialLocation: index == shell.currentIndex);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(
      authProvider.select((a) => a.valueOrNull?.role ?? UserRole.consumer),
    );
    final isVendor = role == UserRole.vendor;
    final cartCount = role == UserRole.consumer
        ? ref.watch(cartProvider.select((s) => s.itemCount))
        : 0;
    final hasWishlistItems =
        role == UserRole.consumer &&
        ref.watch(wishlistProvider.select((s) => s.itemCount > 0));

    // Tab sets mirror the shell branches per role in app_router.dart —
    // keep both lists in sync when adding a tab. Vendors have no Home/Explore
    // tab — they don't browse the marketplace inside their own shell.
    final labels = switch (role) {
      UserRole.vendor => [
        context.l10n.navOrders,
        context.l10n.myListings,
        context.l10n.navAddListing,
        context.l10n.navWallet,
        context.l10n.navProfile,
      ],
      UserRole.courier => [
        context.l10n.navDeliveries,
        context.l10n.navCash,
        context.l10n.navProfile,
      ],
      UserRole.consumer => [
        context.l10n.navHome,
        context.l10n.navExplore,
        context.l10n.navWishlist,
        context.l10n.navOrders,
        context.l10n.navProfile,
      ],
    };

    final icons = switch (role) {
      UserRole.vendor => [
        LucideIcons.list,
        LucideIcons.layoutGrid,
        LucideIcons.plus,
        LucideIcons.wallet,
        LucideIcons.user,
      ],
      UserRole.courier => [
        LucideIcons.truck,
        LucideIcons.wallet,
        LucideIcons.user,
      ],
      UserRole.consumer => [
        LucideIcons.home,
        LucideIcons.search,
        LucideIcons.heart,
        LucideIcons.package,
        LucideIcons.user,
      ],
    };

    // Orbit dock: a floating glass pill on the page background. The vendor
    // Add Listing tab is the glowing orb in the middle.
    final dark = context.isDark;
    return ColoredBox(
      color: context.backgroundColor,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xs,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: dark
                  ? context.surfaceColor.withValues(alpha: 0.94)
                  : context.surfaceColor,
              borderRadius: BorderRadius.circular(34),
              border: Border.all(color: context.borderColor),
              boxShadow: [
                BoxShadow(
                  // Light mode: a soft violet halo instead of a grey drop.
                  color: dark
                      ? context.cardShadowColor
                      : AppColors.primary.withValues(alpha: 0.16),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SizedBox(
              height: 64,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List.generate(labels.length, (index) {
                  final selected = shell.currentIndex == index;
                  final accentMid = isVendor && index == 2;
                  // Same filled+red heart as product cards when the list
                  // isn't empty. Color stays error even on the selected tab
                  // so "you have saved items" isn't lost in the primary tint.
                  final wishlistFilled =
                      role == UserRole.consumer &&
                      index == 2 &&
                      hasWishlistItems;

                  return Expanded(
                    child: AnimatedTap(
                      onTap: () => _onTap(context, ref, index),
                      child: accentMid
                          ? _DockOrb(
                              icon: icons[index],
                              label: labels[index],
                              selected: selected,
                            )
                          : _DockTab(
                              icon: wishlistFilled
                                  ? Icons.favorite_rounded
                                  : icons[index],
                              iconColor: wishlistFilled
                                  ? AppColors.error
                                  : null,
                              label: labels[index],
                              selected: selected,
                              // Cart has no tab of its own (it's opened from
                              // Home's app bar) — echo the count on Home.
                              badgeCount:
                                  role == UserRole.consumer && index == 0
                                  ? cartCount
                                  : 0,
                            ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DockTab extends StatelessWidget {
  const _DockTab({
    required this.icon,
    required this.label,
    required this.selected,
    required this.badgeCount,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final int badgeCount;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final activeColor = context.primaryColor;
    return TweenAnimationBuilder<double>(
      duration: AppAnimations.fast,
      curve: AppAnimations.enter,
      tween: Tween<double>(end: selected ? 1.0 : 0.0),
      builder: (context, t, _) {
        final blended = Color.lerp(context.textSecondary, activeColor, t)!;
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            NotificationIconBadge(
              count: badgeCount,
              child: Transform.scale(
                scale: 1.0 + (t * 0.12),
                child: Icon(icon, color: iconColor ?? blended, size: 22),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelSmall.copyWith(
                color: blended,
                fontSize: AppTypography.rem(0.625),
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedContainer(
              duration: AppAnimations.normal,
              curve: AppAnimations.enter,
              width: selected ? 5 : 0,
              height: 5,
              decoration: BoxDecoration(
                color: activeColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.7),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DockOrb extends StatelessWidget {
  const _DockOrb({
    required this.icon,
    required this.label,
    required this.selected,
  });

  final IconData icon;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      selected: selected,
      excludeSemantics: true,
      child: Center(
        child: AnimatedContainer(
          duration: AppAnimations.normal,
          curve: AppAnimations.enter,
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              center: Alignment(-0.3, -0.4),
              colors: [Color(0xFFFFF4DE), AppColors.cash, AppColors.primary],
              stops: [0, 0.4, 1],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.cash.withValues(alpha: selected ? 0.75 : 0.45),
                blurRadius: selected ? 24 : 16,
              ),
            ],
          ),
          child: Icon(icon, color: AppColors.space, size: 26),
        ),
      ),
    );
  }
}
