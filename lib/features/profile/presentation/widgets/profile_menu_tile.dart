import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

/// Orbit profile row: tinted icon tile, bold label and an optional value
/// ("2 active", "English") or trailing widget at the end.
class ProfileMenuTile extends StatelessWidget {
  const ProfileMenuTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    this.value,
    this.onTap,
    this.trailing,
    this.trailingBadgeCount,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String? value;
  final VoidCallback? onTap;
  final Widget? trailing;
  final int? trailingBadgeCount;

  @override
  Widget build(BuildContext context) {
    final badge = trailingBadgeCount ?? 0;
    final row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 54),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyLarge.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
              ),
            ),
            if (value != null)
              Text(
                value!,
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.textSecondary,
                ),
              ),
            if (badge > 0)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(AppSpacing.x4l),
                ),
                child: Text(
                  '$badge',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
    if (onTap == null) return row;
    return InkWell(onTap: onTap, child: row);
  }
}
