import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/animations/animated_widgets.dart';
import '../../core/animations/app_animations.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/router/app_routes.dart';
import '../../core/utils/extensions/context_extensions.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/cart/presentation/providers/cart_provider.dart';
import '../utils/require_login.dart';
import 'notification_icon_badge.dart';

/// Bottom navigation using implicit animations only (no [TickerProviderStateMixin]).
/// Avoids ticker / dispose races when the shell unmounts during transitions.
class XstoreBottomNav extends ConsumerWidget {
  const XstoreBottomNav({super.key, required this.shell});

  final StatefulNavigationShell shell;

  void _goBranch(BuildContext context, WidgetRef ref, int branch) {
    // Home (0) and Explore (1) are guest-browsable; every other tab is
    // account-bound. Ask guests to sign in instead of letting the route
    // redirect bounce them to the login screen with no explanation.
    // Signed-in users (any role) pass straight through.
    if (branch >= 2 && !requireLogin(context, ref)) return;
    shell.goBranch(branch, initialLocation: branch == shell.currentIndex);
  }

  void _openCart(BuildContext context, WidgetRef ref) {
    if (!requireLogin(context, ref)) return;
    context.push(AppRoutes.cart);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(
      authProvider.select((a) => a.valueOrNull?.role ?? UserRole.consumer),
    );
    final cartCount = role == UserRole.consumer
        ? ref.watch(cartProvider.select((s) => s.itemCount))
        : 0;

    // Items mirror the shell branches per role in app_router.dart — keep both
    // in sync. An item with a `branch` switches tabs; the shopper's Cart orb
    // is not a tab, it pushes the cart screen.
    final items = switch (role) {
      UserRole.vendor => [
        _DockItem(context.l10n.navOrders, LucideIcons.package, branch: 0),
        _DockItem(context.l10n.myListings, LucideIcons.layoutGrid, branch: 1),
        _DockItem(context.l10n.navAddListing, LucideIcons.plus, branch: 2, orb: true),
        _DockItem(context.l10n.navWallet, LucideIcons.wallet, branch: 3),
        _DockItem(context.l10n.navProfile, LucideIcons.user, branch: 4),
      ],
      UserRole.courier => [
        _DockItem(context.l10n.navDeliveries, LucideIcons.truck, branch: 0),
        _DockItem(context.l10n.navCash, LucideIcons.wallet, branch: 1),
        _DockItem(context.l10n.navProfile, LucideIcons.user, branch: 2),
      ],
      UserRole.consumer => [
        _DockItem(context.l10n.navHome, LucideIcons.home, branch: 0),
        _DockItem(context.l10n.navExplore, LucideIcons.compass, branch: 1),
        _DockItem(
          context.l10n.cartTitle,
          LucideIcons.shoppingCart,
          orb: true,
          badge: cartCount,
        ),
        _DockItem(context.l10n.navOrders, LucideIcons.package, branch: 2),
        _DockItem(context.l10n.navProfile, LucideIcons.user, branch: 3),
      ],
    };

    // Orbit dock: a floating glass pill on the page background; the centre
    // item is a glowing orb (shopper cart, seller Add Listing).
    final dark = context.isDark;
    return ColoredBox(
      color: context.backgroundColor,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
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
              height: 68,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  for (final item in items)
                    Expanded(
                      child: AnimatedTap(
                        onTap: () => item.branch == null
                            ? _openCart(context, ref)
                            : _goBranch(context, ref, item.branch!),
                        child: item.orb
                            ? _DockOrb(
                                icon: item.icon,
                                label: item.label,
                                selected: item.branch == shell.currentIndex,
                                badgeCount: item.badge,
                                // Shopper cart glows plasma; seller Add
                                // Listing glows amber.
                                warm: role == UserRole.vendor,
                              )
                            : _DockTab(
                                icon: item.icon,
                                label: item.label,
                                selected: item.branch == shell.currentIndex,
                              ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DockItem {
  const _DockItem(
    this.label,
    this.icon, {
    this.branch,
    this.orb = false,
    this.badge = 0,
  });

  final String label;
  final IconData icon;

  /// Shell branch to switch to; null for the cart orb (a pushed route).
  final int? branch;
  final bool orb;
  final int badge;
}

class _DockTab extends StatelessWidget {
  const _DockTab({
    required this.icon,
    required this.label,
    required this.selected,
  });

  final IconData icon;
  final String label;
  final bool selected;

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
            Transform.scale(
              scale: 1.0 + (t * 0.12),
              child: Icon(icon, color: blended, size: 22),
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
    required this.badgeCount,
    required this.warm,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final int badgeCount;
  final bool warm;

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
          alignment: Alignment.center,
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              center: const Alignment(-0.3, -0.4),
              colors: warm
                  ? const [Color(0xFFFFF4DE), AppColors.cash, AppColors.primary]
                  : const [Color(0xFFE9FDFF), AppColors.plasma, AppColors.primary],
              stops: const [0, 0.4, 1],
            ),
            boxShadow: [
              BoxShadow(
                color: (warm ? AppColors.cash : AppColors.plasma)
                    .withValues(alpha: selected ? 0.75 : 0.5),
                blurRadius: selected ? 24 : 16,
              ),
            ],
          ),
          child: NotificationIconBadge(
            count: badgeCount,
            child: Icon(icon, color: AppColors.space, size: 26),
          ),
        ),
      ),
    );
  }
}
