import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/notification_bell_button.dart';

/// Collapsible gradient header; title fades in when scrolled past expanded region.
class ProfileSliverAppBar extends StatelessWidget {
  const ProfileSliverAppBar({
    super.key,
    required this.scrollController,
    this.expandedHeight = 220,
  });

  final ScrollController scrollController;
  final double expandedHeight;

  @override
  Widget build(BuildContext context) {
    final threshold = expandedHeight - kToolbarHeight;
    final offset = scrollController.hasClients ? scrollController.offset : 0.0;
    final showCollapsedTitle = offset > threshold * 0.35;

    return SliverAppBar(
      pinned: true,
      stretch: true,
      expandedHeight: expandedHeight,
      backgroundColor: AppColors.primary,
      surfaceTintColor: AppColors.primary.withValues(alpha: 0),
      foregroundColor: AppColors.white,
      title: AnimatedOpacity(
        opacity: showCollapsedTitle ? 1 : 0,
        duration: const Duration(milliseconds: 120),
        child: Text(
          AppStrings.profileTitle,
          style: AppTypography.titleMedium.copyWith(color: AppColors.white),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.profileHeaderGradientEnd,
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(LucideIcons.settings),
          onPressed: () => context.push(AppRoutes.settings),
          tooltip: AppStrings.settings,
        ),
        const NotificationBellButton(
          icon: LucideIcons.bell,
          color: AppColors.white,
          tooltip: AppStrings.notifications,
        ),
        const SizedBox(width: AppSpacing.xs),
      ],
    );
  }
}
