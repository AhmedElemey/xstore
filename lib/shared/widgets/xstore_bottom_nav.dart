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
import 'notification_icon_badge.dart';

/// Bottom navigation using implicit animations only (no [TickerProviderStateMixin]).
/// Avoids ticker / dispose races when the shell unmounts during transitions.
class XstoreBottomNav extends ConsumerWidget {
  const XstoreBottomNav({
    super.key,
    required this.shell,
  });

  final StatefulNavigationShell shell;

  void _onTap(int index) {
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
    final cartCount = isVendor
        ? 0
        : ref.watch(cartProvider.select((s) => s.itemCount));

    final labels = isVendor
        ? [
            context.l10n.navHome,
            context.l10n.navExplore,
            context.l10n.navAddListing,
            context.l10n.incomingOrders,
            context.l10n.navProfile,
          ]
        : [
            context.l10n.navHome,
            context.l10n.navExplore,
            context.l10n.navWishlist,
            context.l10n.navOrders,
            context.l10n.navProfile,
          ];

    final icons = isVendor
        ? [
            LucideIcons.home,
            LucideIcons.search,
            LucideIcons.plusCircle,
            LucideIcons.list,
            LucideIcons.user,
          ]
        : [
            LucideIcons.home,
            LucideIcons.search,
            LucideIcons.heart,
            LucideIcons.package,
            LucideIcons.user,
          ];

    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: context.cardShadowColor,
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: SizedBox(
            height: 56,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(5, (index) {
                final selected = shell.currentIndex == index;
                final accentMid = isVendor && index == 2;
                final inactiveColor = accentMid && !selected
                    ? AppColors.accent
                    : context.textSecondary;
                final activeColor =
                    accentMid ? AppColors.accent : context.primaryColor;

                return Expanded(
                  child: AnimatedTap(
                    onTap: () => _onTap(index),
                    child: TweenAnimationBuilder<double>(
                      duration: AppAnimations.fast,
                      curve: AppAnimations.enter,
                      tween: Tween<double>(end: selected ? 1.0 : 0.0),
                      builder: (context, t, _) {
                        final blended =
                            Color.lerp(inactiveColor, activeColor, t)!;
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 2,
                            vertical: 2,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              NotificationIconBadge(
                                count:
                                    !isVendor && index == 1 ? cartCount : 0,
                                child: Transform.scale(
                                  scale: 1.0 + (t * 0.12),
                                  child: Icon(
                                    icons[index],
                                    color: blended,
                                    size: 22,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              SizedBox(
                                height: 4,
                                child: Center(
                                  child: AnimatedContainer(
                                    duration: AppAnimations.normal,
                                    curve: AppAnimations.enter,
                                    width: selected ? 18 : 0,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: activeColor,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                labels[index],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.labelSmall.copyWith(
                                  color: blended,
                                  fontSize: AppTypography.rem(0.625),
                                  fontWeight: selected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
