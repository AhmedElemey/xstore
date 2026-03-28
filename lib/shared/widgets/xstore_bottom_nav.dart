import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_typography.dart';
import '../../core/enums/user_role.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

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
    final role = ref.watch(authProvider).valueOrNull.toUserRole;
    final isVendor = role == UserRole.vendor;

    final labels = isVendor
        ? [
            AppStrings.navHome,
            AppStrings.navExplore,
            AppStrings.navAddListing,
            AppStrings.myListings,
            AppStrings.navProfile,
          ]
        : [
            AppStrings.navHome,
            AppStrings.navExplore,
            AppStrings.navWishlist,
            AppStrings.navOrders,
            AppStrings.navProfile,
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
      color: AppColors.cardBg,
      shadowColor: AppColors.textPrimary.withValues(alpha: 0.08),
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
                  : (selected ? AppColors.primary : AppColors.textSecondary);
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
                        Icon(
                          icons[i],
                          color: color,
                          size: AppSpacing.x2l,
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
