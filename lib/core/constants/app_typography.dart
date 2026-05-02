import 'package:flutter/material.dart';

/// Typography tokens for [ThemeData].
///
/// Sizes use a **CSS-rem-style baseline**: `rem(r) => 16 * r` logical pixels at
/// [TextScaler] 1.0 (same mapping as `1rem = 16px` when the platform default is
/// 16). **Always** apply via [Text] / material [TextTheme]; Flutter then
/// multiplies by [MediaQuery.textScalerOf] so OS accessibility text settings
/// are respected. Pair text-adjacent padding with [BuildContext.scaledPx].
abstract final class AppTypography {
  /// Logical pixels for `1rem` at text-scale 1.0 (aligns with `html { font-size: 100%; }` on web).
  static const double remPx = 16.0;

  /// CSS-equivalent rem: `rem(1) == 16px`, `rem(0.875) == 14px`, etc.
  static double rem(double factor) => remPx * factor;

  static const String fontFamily = 'Inter';
  static const List<String> fontFamilyFallback = [
    '.SF UI Text',
    '.SF UI Display',
    'Roboto',
    'sans-serif',
  ];

  /// Default “xStore” wordmark on auth headers (= `rem(2)`).
  static const double authWordmarkSize = remPx * 2;

  static TextStyle get _base => TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
  );

  static TextStyle get displayLarge => _base.copyWith(
    fontSize: rem(2),
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static TextStyle get displayMedium => _base.copyWith(
    fontSize: rem(1.75),
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static TextStyle get titleLarge => _base.copyWith(
    fontSize: rem(1.5),
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static TextStyle get titleMedium => _base.copyWith(
    fontSize: rem(1.25),
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  static TextStyle get titleSmall => _base.copyWith(
    fontSize: rem(1.125),
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static TextStyle get bodyLarge => _base.copyWith(
    fontSize: rem(1),
    fontWeight: FontWeight.w400,
    height: 1.45,
  );

  static TextStyle get bodyMedium => _base.copyWith(
    fontSize: rem(0.875),
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static TextStyle get bodySmall => _base.copyWith(
    fontSize: rem(0.8125),
    fontWeight: FontWeight.w400,
    height: 1.35,
  );

  /// 12 logical px (between [labelMedium] and [bodySmall] line metrics).
  static TextStyle get body12 => _base.copyWith(
    fontSize: rem(0.75),
    fontWeight: FontWeight.w400,
    height: 1.35,
  );

  static TextStyle get labelLarge => _base.copyWith(
    fontSize: rem(0.875),
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static TextStyle get labelMedium => _base.copyWith(
    fontSize: rem(0.75),
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static TextStyle get labelSmall => _base.copyWith(
    fontSize: rem(0.6875),
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  /// 15 logical px — between [bodyMedium] and [bodyLarge].
  static TextStyle get body15 => _base.copyWith(
    fontSize: rem(0.9375),
    fontWeight: FontWeight.w400,
    height: 1.35,
  );

  /// Compact section title (~22 px).
  static TextStyle get titleCompact => _base.copyWith(
    fontSize: rem(1.375),
    fontWeight: FontWeight.w600,
    height: 1.25,
  );

  /// Auth tab emphasis (~17 px — use [copyWith] for weight/color).
  static TextStyle get navTabLarge => _base.copyWith(
    fontSize: rem(1.0625),
    fontWeight: FontWeight.w700,
    height: 1.25,
  );

  /// Secondary auth tab (~17 px).
  static TextStyle get navTabMedium => _base.copyWith(
    fontSize: rem(1.0625),
    fontWeight: FontWeight.w600,
    height: 1.25,
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
