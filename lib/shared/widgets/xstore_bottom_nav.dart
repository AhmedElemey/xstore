import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/cart/presentation/providers/cart_provider.dart';
import 'notification_icon_badge.dart';
import '../../core/utils/extensions/context_extensions.dart';

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

    return Material(
      elevation: 8,
      color: context.surfaceColor,
      shadowColor: context.textPrimary.withValues(alpha: 0.08),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            children: List.generate(5, (i) {
              final selected = shell.currentIndex == i;
              final accentMid = isVendor && i == 2;
              final color = accentMid
                  ? AppColors.accent
                  : (selected ? AppColors.primary : context.textSecondary);
              final style = AppTypography.labelSmall.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              );
              return Expanded(
                child: InkWell(
                  onTap: () => _onTap(i),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        NotificationIconBadge(
                          count: !isVendor && i == 1 ? cartCount : 0,
                          child: Icon(
                            icons[i],
                            color: color,
                            size: AppSpacing.x2l,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          labels[i],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: style,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
