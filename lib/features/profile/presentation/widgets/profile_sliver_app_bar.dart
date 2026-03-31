import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
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
    required this.userName,
    this.avatarUrl,
    this.avatarFile,
    this.expandedHeight = 200,
  });

  final ScrollController scrollController;
  final String userName;
  final String? avatarUrl;
  final File? avatarFile;
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
        background: Stack(
          fit: StackFit.expand,
          children: [
            _buildBackgroundImage(),
            // const DecoratedBox(
            //   decoration: BoxDecoration(
            //     gradient: LinearGradient(
            //       begin: Alignment.topCenter,
            //       end: Alignment.bottomCenter,
            //       colors: [
            //         Color(0x2D000000),
            //         Color(0x8F000000),
            //       ],
            //     ),
            //   ),
            // ),
          ],
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

  Widget _buildBackgroundImage() {
    if (avatarFile != null) {
      return Image.file(avatarFile!, fit: BoxFit.cover);
    }

    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: avatarUrl!,
        fit: BoxFit.cover,
        placeholder: (_, __) => _buildFallback(),
        errorWidget: (_, __, ___) => _buildFallback(),
      );
    }

    return _buildFallback();
  }

  Widget _buildFallback() {
    final parts = userName
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    final initials = parts.take(2).map((e) => e[0].toUpperCase()).join();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.profileHeaderGradientEnd,
          ],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initials.isEmpty ? '?' : initials,
        style: AppTypography.titleLarge.copyWith(
          color: AppColors.white.withValues(alpha: 0.9),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
