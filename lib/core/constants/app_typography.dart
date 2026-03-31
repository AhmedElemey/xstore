import 'package:flutter/material.dart';

abstract final class AppTypography {
  static const String fontFamily = 'Inter';
  static const List<String> fontFamilyFallback = [
    '.SF UI Text',
    '.SF UI Display',
    'Roboto',
    'sans-serif',
  ];

  static TextStyle get _base => TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
  );

  static TextStyle get displayLarge => _base.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static TextStyle get displayMedium => _base.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static TextStyle get titleLarge => _base.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static TextStyle get titleMedium => _base.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  static TextStyle get titleSmall => _base.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static TextStyle get bodyLarge => _base.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );

  static TextStyle get bodyMedium => _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static TextStyle get bodySmall => _base.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.35,
  );

  static TextStyle get labelLarge => _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static TextStyle get labelMedium => _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static TextStyle get labelSmall => _base.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  /// Material [TextTheme] for [ThemeData] derived from [ColorScheme].
  static TextTheme textTheme(ColorScheme colorScheme) => TextTheme(
    displayLarge: displayLarge.copyWith(color: colorScheme.onSurface),
    displayMedium: displayMedium.copyWith(color: colorScheme.onSurface),
    titleLarge: titleLarge.copyWith(color: colorScheme.onSurface),
    titleMedium: titleMedium.copyWith(color: colorScheme.onSurface),
    titleSmall: titleSmall.copyWith(color: colorScheme.onSurface),
    bodyLarge: bodyLarge.copyWith(color: colorScheme.onSurface),
    bodyMedium: bodyMedium.copyWith(color: colorScheme.onSurface),
    bodySmall: bodySmall.copyWith(color: colorScheme.onSurfaceVariant),
    labelLarge: labelLarge.copyWith(color: colorScheme.onSurface),
    labelMedium: labelMedium.copyWith(color: colorScheme.onSurfaceVariant),
    labelSmall: labelSmall.copyWith(color: colorScheme.onSurfaceVariant),
  );
}
