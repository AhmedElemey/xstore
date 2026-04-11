import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';

/// Styled floating snackbars used app-wide.
abstract final class AppSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    Color? backgroundColor,
    IconData? icon,
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: AppColors.white, size: 18),
              const Gap(AppSpacing.sm),
            ],
            Expanded(
              child: Text(
                message,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor ?? AppColors.lightTextPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(AppSpacing.lg),
        duration: duration,
        action: action,
      ),
    );
  }

  static void success(BuildContext context, String message) => show(
        context,
        message: message,
        backgroundColor: AppColors.success,
        icon: LucideIcons.checkCircle,
      );

  static void error(BuildContext context, String message) => show(
        context,
        message: message,
        backgroundColor: AppColors.error,
        icon: LucideIcons.alertCircle,
      );

  static void info(BuildContext context, String message) => show(
        context,
        message: message,
        icon: LucideIcons.info,
      );
}
