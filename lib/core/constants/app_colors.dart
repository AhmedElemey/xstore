import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand — "Orbit" design (xStore Orbit Redesign canvas). Light mode runs
  // on violet; dark mode ("deep space") swaps the primary to cyan plasma.
  static const primary = Color(0xFF7B5CFF);
  static const primaryLight = Color(0xFF7CF0FF);
  static const primaryDark = Color(0xFF6B4DE6);
  static const accent = Color(0xFFB45309);
  static const accentLight = Color(0xFFFFC069);
  static const success = Color(0xFF0E9F6E);
  static const successLight = Color(0xFF6CF2B4);
  static const warning = Color(0xFFD97706);
  static const warningLight = Color(0xFFFFC069);
  static const error = Color(0xFFD92D4B);
  static const errorLight = Color(0xFFFF9AA6);

  /// Primary-button gradients and the text drawn on them.
  static const lightBrandGradient = [Color(0xFF7B5CFF), Color(0xFF9B7BFF)];
  static const darkBrandGradient = [Color(0xFF7CF0FF), Color(0xFFB69CFF)];
  static const darkOnBrand = Color(0xFF06081A);

  /// Second dark-mode accent (violet).
  static const darkSecondary = Color(0xFFB69CFF);

  // Light scheme ("daylight orbit")
  static const lightBackground = Color(0xFFF6F5FF);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceVariant = Color(0xFFFCFBFF);
  static const lightBorder = Color(0xFFDCD4FF);
  static const lightDivider = Color(0xFFE6E0FF);
  static const lightTextPrimary = Color(0xFF0E1030);
  static const lightTextSecondary = Color(0xFF3F4370);
  static const lightTextDisabled = Color(0xFFB9BBD6);
  static const lightTextHint = Color(0xFF6E7299);
  static const lightTextLabel = Color(0xFF5B5F84);
  static const lightIconPrimary = Color(0xFF0E1030);
  static const lightIconSecondary = Color(0xFF5B5F84);
  static const lightShadow = Color(0x1A2A1B6B);
  static const lightOverlay = Color(0x0D0E1030);
  static const lightCardShadow = Color(0x142A1B6B);
  static const lightGlass = Color(0xCCFFFFFF);

  // Dark scheme ("deep space")
  static const darkBackground = Color(0xFF06081A);
  static const darkSurface = Color(0xFF0E1230);
  static const darkSurfaceVariant = Color(0xFF12163A);
  static const darkSurfaceElevated = Color(0xFF171C46);
  static const darkBorder = Color(0xFF262B52);
  static const darkDivider = Color(0xFF1C2044);
  static const darkTextPrimary = Color(0xFFEEF1FF);
  static const darkTextSecondary = Color(0xFFC9D0F5);
  static const darkTextDisabled = Color(0xFF4A5080);
  static const darkTextHint = Color(0xFF8C94C2);
  static const darkTextLabel = Color(0xFFA3ABD6);
  static const darkIconPrimary = Color(0xFFEEF1FF);
  static const darkIconSecondary = Color(0xFFA3ABD6);
  static const darkShadow = Color(0x66000000);
  static const darkOverlay = Color(0x1AFFFFFF);
  static const darkCardShadow = Color(0x66000000);
  static const darkGlass = Color(0x0DFFFFFF);

  // Compatibility aliases used across feature UIs.
  static const background = lightBackground;
  static const textPrimary = lightTextPrimary;
  static const textSecondary = lightTextSecondary;
  static const textDisabled = lightTextDisabled;
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
  static const transparent = Color(0x00000000);
  static const profileHeaderGradientEnd = primaryDark;

  /// Material `Colors.grey` shades (preserve exact hues when swapping off `material.dart`).
  static const materialGrey400 = Color(0xFFBDBDBD);
  static const materialGrey500 = Color(0xFF9E9E9E);
  static const materialGrey600 = Color(0xFF757575);

  /// `Colors.green.shade600`.
  static const materialGreen600 = Color(0xFF43A047);


  /// Skeleton / shimmer neutral highlight (~gray-50).
  static const neutral50 = Color(0xFFF9FAFB);

  /// Indigo-50 surface tint (listing / schedule highlights).
  static const indigoTint50 = Color(0xFFF5F3FF);

  /// Order status badges (aligned with design spec).
  static const orderStatusPending = Color(0xFFF59E0B);
  static const orderStatusConfirmed = Color(0xFF3B82F6);
  static const orderStatusProcessing = Color(0xFF6366F1);
  static const orderStatusShipped = Color(0xFF8B5CF6);
  static const orderStatusDelivered = Color(0xFF22C55E);
  static const orderStatusCancelled = Color(0xFFEF4444);

  /// Unread notification row (tint + banner accents).
  static const notificationUnreadBackground = Color(0xFFEEF2FF);
  static const notificationBannerBackground = Color(0xFFE0E7FF);
  static const notificationIconTintGreen = Color(0xFFDCFCE7);
  static const notificationIconTintBlue = Color(0xFFDBEAFE);
  static const notificationIconTintPurple = Color(0xFFEDE9FE);
  static const notificationIconTintRed = Color(0xFFFEE2E2);
  static const notificationIconTintOrange = Color(0xFFFFEDD5);
  static const notificationIconTintAmber = Color(0xFFFEF3C7);

  /// Brand accents for the platform-fee payment methods.
  static const paymentInstaPay = Color(0xFF5B2C83);
  static const paymentVodafoneCash = Color(0xFFE60000);
  static const paymentOrangeCash = Color(0xFFFF7900);
  static const paymentEtisalatCash = Color(0xFF6E9E1E);
}
