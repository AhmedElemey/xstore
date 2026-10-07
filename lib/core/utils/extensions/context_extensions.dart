import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../constants/app_colors.dart';
import '../../localization/app_localizations.dart';
import '../../../shared/widgets/app_snackbar.dart';

extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => Theme.of(this).textTheme;

  TextScaler get textScaler => MediaQuery.textScalerOf(this);

  /// Lengths that should grow/shrink with the user’s text-size setting (spacing
  /// around type, badges). Prefer this over raw logical px for text-adjacent UI.
  ///
  /// `TextScaler.scale` expects non-negative values, while UI metrics like
  /// `letterSpacing` can be negative. Keep sign externally and scale magnitude.
  double scaledPx(double logicalPixels) {
    final sign = logicalPixels.isNegative ? -1.0 : 1.0;
    return sign * textScaler.scale(logicalPixels.abs());
  }

  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  bool get isDark => theme.brightness == Brightness.dark;

  Color get backgroundColor => theme.scaffoldBackgroundColor;

  Color get surfaceColor => colorScheme.surface;

  /// Filled inputs use app surface-variant tokens — do not rely on derived
  /// [ColorScheme.surfaceContainerHighest] alone (can break contrast in dark mode).
  Color get surfaceVariantColor =>
      isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant;

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

  // Orbit design tokens that ThemeData has no slot for.

  /// Primary-button gradient (violet in light, cyan→violet in dark).
  List<Color> get brandGradient =>
      isDark ? AppColors.darkBrandGradient : AppColors.lightBrandGradient;

  /// Text and icons drawn on [brandGradient].
  Color get onBrandColor => isDark ? AppColors.darkOnBrand : AppColors.white;

  /// Frosted fill for fields, ghost buttons and segmented controls.
  Color get glassColor => isDark ? AppColors.darkGlass : AppColors.lightGlass;

  /// Uppercase field-label grey.
  Color get labelColor =>
      isDark ? AppColors.darkTextLabel : AppColors.lightTextLabel;

  /// Inline links ("Forgot password?", "Create an account").
  Color get linkColor =>
      isDark ? AppColors.primaryLight : AppColors.primaryDark;

  /// Amber: courier and cash accents.
  Color get amberColor => isDark ? AppColors.accentLight : AppColors.accent;

  void showSnack(String message) {
    AppSnackbar.info(this, message);
  }
}

extension LocalizationContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  /// [message] in the current language. Errors are worded when they happen
  /// (repositories have no context), so the generic fallback is re-resolved
  /// here — it follows a language switch made after the error.
  String localizedError(String message) {
    final isGeneric = AppLocalizations.supportedLocales.any(
      (l) => lookupAppLocalizations(l).genericError == message,
    );
    return isGeneric ? l10n.genericError : message;
  }

  bool get isArabic => Localizations.localeOf(this).languageCode == 'ar';
  bool get isEnglish => Localizations.localeOf(this).languageCode == 'en';

  ui.TextDirection get localizedTextDirection =>
      isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr;

  String get arrowForward => isArabic ? '←' : '→';
  String get arrowBack => isArabic ? '→' : '←';

  IconData get chevronForward =>
      isArabic ? LucideIcons.chevronLeft : LucideIcons.chevronRight;

  IconData get arrowForwardIcon =>
      isArabic ? LucideIcons.arrowLeft : LucideIcons.arrowRight;
  IconData get arrowBackIcon =>
      isArabic ? LucideIcons.arrowRight : LucideIcons.arrowLeft;

  String formatCurrency(double amount) {
    // Arabic already reads as "٢٬٠٠٠ ج.م " — the currency symbol trails the
    // number under the 'ar_EG' pattern. English used to show "EGP 2,000"
    // (symbol first); switched to the same trailing convention, using "LE"
    // instead of "EGP", since NumberFormat.currency has no locale-agnostic
    // way to force a leading symbol to a suffix — only the ready-made
    // 'ar_EG' currency pattern already suffixes it.
    if (isArabic) {
      return NumberFormat.currency(
        locale: 'ar_EG',
        symbol: 'ج.م ',
        decimalDigits: 0,
      ).format(amount);
    }
    final number = NumberFormat.decimalPattern('en_EG').format(amount.round());
    return '$number LE';
  }

  String formatDate(DateTime date) {
    return DateFormat('d MMM yyyy', isArabic ? 'ar' : 'en').format(date);
  }

  /// Day-first with a month name ("6 Oct 2026"), never "6/10/2026".
  String formatShortDate(DateTime date) => formatDate(date);

  /// "Mar 5, 2026" in both locales (fixed field order).
  String formatMediumDate(DateTime date) =>
      DateFormat('MMM d, yyyy', isArabic ? 'ar' : 'en').format(date);

  /// The locale's own medium date order (Arabic puts the day first).
  String formatLocaleMediumDate(DateTime date) =>
      DateFormat.yMMMd(isArabic ? 'ar' : 'en').format(date);

  /// "Thursday, Mar 5".
  String formatWeekdayDate(DateTime date) =>
      DateFormat('EEEE, MMM d', isArabic ? 'ar' : 'en').format(date);

  /// "Thursday, Mar 5, 2026".
  String formatLongDate(DateTime date) =>
      DateFormat('EEEE, MMM d, yyyy', isArabic ? 'ar' : 'en').format(date);

  /// "Mar 2026".
  String formatMonthYear(DateTime date) =>
      DateFormat('MMM y', isArabic ? 'ar' : 'en').format(date);

  /// 24-hour "14:05".
  String formatTime(DateTime date) =>
      DateFormat('HH:mm', isArabic ? 'ar' : 'en').format(date);
}
