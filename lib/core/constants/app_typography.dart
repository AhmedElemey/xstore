import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTypography {
  static const String fontFamily = 'Inter';
  static const List<String> fontFamilyFallback = [
    '.SF UI Text',
    '.SF UI Display',
    'Roboto',
    'sans-serif',
  ];

  static TextStyle get _base => const TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFamilyFallback,
      );

  static TextStyle get displayLarge => _base.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: AppColors.textPrimary,
      );

  static TextStyle get displayMedium => _base.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: AppColors.textPrimary,
      );

  static TextStyle get titleLarge => _base.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: AppColors.textPrimary,
      );

  static TextStyle get titleMedium => _base.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyLarge => _base.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyMedium => _base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodySmall => _base.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.35,
        color: AppColors.textSecondary,
      );

  static TextStyle get labelLarge => _base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: AppColors.textPrimary,
      );

  static TextStyle get labelSmall => _base.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.2,
        color: AppColors.textSecondary,
      );

  /// Material [TextTheme] for [ThemeData]; colors use [AppColors] only.
  static TextTheme textTheme(ColorScheme _) => TextTheme(
        displayLarge: displayLarge,
        displayMedium: displayMedium,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelSmall: labelSmall,
      );
}
