import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => Theme.of(this).textTheme;

  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  bool get isDark => theme.brightness == Brightness.dark;

  Color get backgroundColor => theme.scaffoldBackgroundColor;

  Color get surfaceColor => colorScheme.surface;

  Color get surfaceVariantColor => colorScheme.surfaceContainerHighest;

  Color get elevatedSurfaceColor =>
      isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurface;

  Color get textPrimary => colorScheme.onSurface;

  Color get textSecondary => colorScheme.onSurfaceVariant;

  Color get textDisabled => theme.disabledColor;

  Color get textHint =>
      isDark ? AppColors.darkTextHint : AppColors.lightTextHint;

  Color get iconPrimary => colorScheme.onSurface;

  Color get iconSecondary => colorScheme.onSurfaceVariant;

  Color get borderColor => colorScheme.outlineVariant;

  Color get dividerColor => theme.dividerColor;

  Color get shadowColor =>
      isDark ? AppColors.darkShadow : AppColors.lightShadow;

  Color get cardShadowColor =>
      Colors.black.withValues(alpha: isDark ? 0.28 : 0.08);

  Color get primaryColor => colorScheme.primary;

  Color get overlayColor =>
      isDark ? AppColors.darkOverlay : AppColors.lightOverlay;

  void showSnack(String message) {
    ScaffoldMessenger.maybeOf(
      this,
    )?.showSnackBar(SnackBar(content: Text(message)));
  }
}
