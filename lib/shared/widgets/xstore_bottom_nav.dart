import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/animations/animated_widgets.dart';
import '../../core/constants/app_colors.dart';
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
  const XstoreBottomNav({
    super.key,
    required this.shell,
  });

  final StatefulNavigationShell shell;

  void _onTap(BuildContext context, WidgetRef ref, int index) {
    // Home (0) and Explore (1) are guest-browsable; every other tab is
    // account-bound. Ask guests to sign in instead of letting the route
    // redirect bounce them to the login screen with no explanation.
    // Signed-in users (any role) pass straight through.
    if (index >= 2 && !requireLogin(context, ref)) return;
    shell.goBranch(
      index,
      initialLocation: index == shell.currentIndex,
    );
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
    final hasWishlistItems = role == UserRole.consumer &&
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
          LucideIcons.plusCircle,
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

    // Orbit dock: a floating frosted pill. The middle tab of the 5-tab
    // shopper and seller docks (Wishlist / Add listing) is a raised orb.
    final hasOrb = labels.length == 5;
    final isDark = context.isDark;
    return ColoredBox(
      color: context.backgroundColor,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: SizedBox(
            height: 92,
            child: Stack(
              alignment: Alignment.bottomCenter,
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xE00E1230)
                        : const Color(0xE0FFFFFF),
                    borderRadius: BorderRadius.circular(35),
                    border: Border.all(color: context.borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? const Color(0x8C000000)
                            : const Color(0x2B3C288C),
                        blurRadius: 40,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                ),
                Positioned.fill(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(labels.length, (index) {
                      final selected = shell.currentIndex == index;
                      // Same filled+red heart as product cards when the list
                      // isn't empty, so "you have saved items" isn't lost.
                      final wishlistFilled = role == UserRole.consumer &&
                          index == 2 &&
                          hasWishlistItems;
                      if (hasOrb && index == 2) {
                        return Expanded(
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Semantics(
                              button: true,
                              selected: selected,
                              label: labels[index],
                              child: AnimatedTap(
                                onTap: () => _onTap(context, ref, index),
                                child: _DockOrb(
                                  icon: wishlistFilled
                                      ? Icons.favorite_rounded
                                      : icons[index],
                                  vendor: isVendor,
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                      final accent = isVendor
                          ? context.amberColor
                          : context.linkColor;
                      final color =
                          selected ? accent : context.textHint;
                      return Expanded(
                        child: AnimatedTap(
                          onTap: () => _onTap(context, ref, index),
                          child: SizedBox(
                            height: 70,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                NotificationIconBadge(
                                  // Cart has no dock tab of its own (it's
                                  // opened from Home's app bar) — echo the
                                  // count on Home.
                                  count: role == UserRole.consumer && index == 0
                                      ? cartCount
                                      : 0,
                                  child: Icon(icons[index], color: color, size: 22),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  labels[index],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.labelSmall.copyWith(
                                    color: color,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The raised center orb: cyan plasma for shoppers, solar amber for sellers.
class _DockOrb extends StatelessWidget {
  const _DockOrb({required this.icon, required this.vendor});

  final IconData icon;
  final bool vendor;

  @override
  Widget build(BuildContext context) {
    final colors = vendor
        ? const [Color(0xFFFFF4DE), Color(0xFFFFC069), Color(0xFFB069FF)]
        : const [Color(0xFFE9FDFF), Color(0xFF7CF0FF), Color(0xFF8A6BFF)];
    final glow = vendor
        ? const Color(0x8CFFC069)
        : (context.isDark ? const Color(0x997CF0FF) : const Color(0x997B5CFF));
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.4),
          colors: colors,
          stops: vendor ? const [0, 0.38, 0.9] : const [0, 0.35, 0.85],
        ),
        border: Border.all(color: context.backgroundColor, width: 6),
        boxShadow: [BoxShadow(color: glow, blurRadius: 36)],
      ),
      child: Icon(icon, color: AppColors.darkOnBrand, size: 26),
    );
  }
}
