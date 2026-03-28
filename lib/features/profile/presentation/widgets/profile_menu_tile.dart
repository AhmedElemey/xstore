import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';

class ProfileMenuTile extends StatelessWidget {
  const ProfileMenuTile({
    super.key,
    required this.icon,
    required this.iconBackground,
    required this.label,
    this.onTap,
    this.showChevron = true,
    this.trailing,
  });

  final IconData icon;
  final Color iconBackground;
  final String label;
  final VoidCallback? onTap;
  final bool showChevron;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final padded = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            width: AppSpacing.x3l + AppSpacing.xs,
            height: AppSpacing.x3l + AppSpacing.xs,
            decoration: BoxDecoration(
              color: iconBackground.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSpacing.md),
            ),
            child: Icon(
              icon,
              color: iconBackground,
              size: AppSpacing.x2l - AppSpacing.xs,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodyLarge,
            ),
          ),
          if (trailing != null)
            trailing!
          else if (showChevron)
            Icon(
              LucideIcons.chevronRight,
              size: AppSpacing.x2l,
              color: AppColors.textSecondary,
            ),
        ],
      ),
    );

    if (onTap != null) {
      return Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.sm),
          child: padded,
        ),
      );
    }
    return padded;
  }
}
