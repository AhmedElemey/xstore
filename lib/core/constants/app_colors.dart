import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand — "Orbit" palette. [primary] is Nova violet: it reads on both the
  // light ground and the deep-space dark ground, and carries white text.
  static const primary = Color(0xFF7B5CFF);
  static const primaryLight = Color(0xFFB69CFF);
  static const primaryDark = Color(0xFF4A2BD0);
  static const accent = Color(0xFFFF8A3D);
  static const accentLight = Color(0xFFFFC069);
  static const success = Color(0xFF22C55E);
  static const successLight = Color(0xFF6CF2B4);
  static const warning = Color(0xFFF59E0B);
  static const warningLight = Color(0xFFFCD34D);
  static const error = Color(0xFFEF4444);
  static const errorLight = Color(0xFFFF7A8A);

  /// Orbit accents: plasma is the dark theme's primary (cyan glow), cash is
  /// the amber every cash-on-delivery amount uses.
  static const plasma = Color(0xFF7CF0FF);
  static const nova = primaryLight;
  static const cash = accentLight;
  static const space = Color(0xFF06081A);

  // Light scheme
  static const lightBackground = Color(0xFFF6F5FF);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceVariant = Color(0xFFEFEDFB);
  static const lightBorder = Color(0xFFE2DFF5);
  static const lightDivider = Color(0xFFEFEDFB);
  static const lightTextPrimary = Color(0xFF0E1030);
  static const lightTextSecondary = Color(0xFF5B5F84);
  static const lightTextDisabled = Color(0xFFC9C7DE);
  static const lightTextHint = Color(0xFF8E92B3);
  static const lightIconPrimary = Color(0xFF2B2E52);
  static const lightIconSecondary = Color(0xFF8E92B3);
  static const lightShadow = Color(0x1A0E1030);
  static const lightOverlay = Color(0x0D0E1030);
  static const lightCardShadow = Color(0x140E1030);

  // Dark scheme — deep space.
  static const darkBackground = space;
  static const darkSurface = Color(0xFF0E1233);
  static const darkSurfaceVariant = Color(0xFF161B45);
  static const darkSurfaceElevated = Color(0xFF1C2254);
  static const darkBorder = Color(0xFF2A3172);
  static const darkDivider = Color(0xFF1A1F4D);
  static const darkTextPrimary = Color(0xFFEEF1FF);
  static const darkTextSecondary = Color(0xFFA3ABD6);
  static const darkTextDisabled = Color(0xFF4A527E);
  static const darkTextHint = Color(0xFF7F88BA);
  static const darkIconPrimary = Color(0xFFD6DBF7);
  static const darkIconSecondary = Color(0xFF8C94C2);
  static const darkShadow = Color(0x66000000);
  static const darkOverlay = Color(0x1A7CF0FF);
  static const darkCardShadow = Color(0x80000000);

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

  /// Google sign-in border color.
  static const googleOAuthOutlineGrey = Color(0xFFDADCE0);

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
}
