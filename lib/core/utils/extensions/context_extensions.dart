import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../constants/app_colors.dart';
import '../../localization/app_localizations.dart';
import '../../../shared/widgets/app_snackbar.dart';

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
    AppSnackbar.info(this, message);
  }
}

extension LocalizationContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  bool get isArabic => Localizations.localeOf(this).languageCode == 'ar';
  bool get isEnglish => Localizations.localeOf(this).languageCode == 'en';

  ui.TextDirection get localizedTextDirection =>
      isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr;

  String get arrowForward => isArabic ? '←' : '→';
  String get arrowBack => isArabic ? '→' : '←';

  IconData get chevronForward =>
      isArabic ? LucideIcons.chevronLeft : LucideIcons.chevronRight;
  IconData get chevronBack =>
      isArabic ? LucideIcons.chevronRight : LucideIcons.chevronLeft;

  IconData get arrowForwardIcon =>
      isArabic ? LucideIcons.arrowLeft : LucideIcons.arrowRight;
  IconData get arrowBackIcon =>
      isArabic ? LucideIcons.arrowRight : LucideIcons.arrowLeft;

  String formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: isArabic ? 'ar_EG' : 'en_EG',
      symbol: isArabic ? 'ج.م ' : 'EGP ',
      decimalDigits: 0,
    ).format(amount);
  }

  String formatDate(DateTime date) {
    return DateFormat(
      'd MMM yyyy',
      isArabic ? 'ar' : 'en',
    ).format(date);
  }

  String formatShortDate(DateTime date) {
    return DateFormat(
      'd/M/yyyy',
      isArabic ? 'ar' : 'en',
    ).format(date);
  }
}
