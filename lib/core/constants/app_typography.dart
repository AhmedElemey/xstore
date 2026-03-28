import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTypography {
  static const String fontFamily = 'Roboto';

  static TextTheme textTheme(ColorScheme scheme) => TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          height: 1.4,
          color: scheme.onSurface,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 1.35,
          color: scheme.onSurfaceVariant,
        ),
        labelLarge: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.onPrimary,
        ),
      );
}
