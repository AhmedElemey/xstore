import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand
  static const primary = Color(0xFF4F46E5);
  static const primaryLight = Color(0xFF818CF8);
  static const primaryDark = Color(0xFF3730A3);
  static const accent = Color(0xFFF97316);
  static const accentLight = Color(0xFFFB923C);
  static const success = Color(0xFF22C55E);
  static const successLight = Color(0xFF86EFAC);
  static const warning = Color(0xFFF59E0B);
  static const warningLight = Color(0xFFFCD34D);
  static const error = Color(0xFFEF4444);
  static const errorLight = Color(0xFFFCA5A5);

  // Light scheme
  static const lightBackground = Color(0xFFFAFAFA);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceVariant = Color(0xFFF3F4F6);
  static const lightBorder = Color(0xFFE5E7EB);
  static const lightDivider = Color(0xFFF3F4F6);
  static const lightTextPrimary = Color(0xFF111827);
  static const lightTextSecondary = Color(0xFF6B7280);
  static const lightTextDisabled = Color(0xFFD1D5DB);
  static const lightTextHint = Color(0xFF9CA3AF);
  static const lightIconPrimary = Color(0xFF374151);
  static const lightIconSecondary = Color(0xFF9CA3AF);
  static const lightShadow = Color(0x1A000000);
  static const lightOverlay = Color(0x0D000000);
  static const lightCardShadow = Color(0x14000000);

  // Dark scheme
  static const darkBackground = Color(0xFF0F0F13);
  static const darkSurface = Color(0xFF1A1A24);
  static const darkSurfaceVariant = Color(0xFF252533);
  static const darkSurfaceElevated = Color(0xFF2E2E3E);
  static const darkBorder = Color(0xFF2E2E3E);
  static const darkDivider = Color(0xFF252533);
  static const darkTextPrimary = Color(0xFFF9FAFB);
  static const darkTextSecondary = Color(0xFF9CA3AF);
  static const darkTextDisabled = Color(0xFF4B5563);
  static const darkTextHint = Color(0xFF6B7280);
  static const darkIconPrimary = Color(0xFFE5E7EB);
  static const darkIconSecondary = Color(0xFF6B7280);
  static const darkShadow = Color(0x40000000);
  static const darkOverlay = Color(0x1A000000);
  static const darkCardShadow = Color(0x66000000);

  // Compatibility aliases used across feature UIs.
  static const background = lightBackground;
  static const cardBg = lightSurface;
  static const textPrimary = lightTextPrimary;
  static const textSecondary = lightTextSecondary;
  static const textDisabled = lightTextDisabled;
  static const white = Color(0xFFFFFFFF);
  static const transparent = Color(0x00000000);
  static const profileHeaderGradientEnd = primaryDark;

  /// Order status badges (aligned with design spec).
  static const orderStatusPending = Color(0xFFF59E0B);
  static const orderStatusConfirmed = Color(0xFF3B82F6);
  static const orderStatusProcessing = Color(0xFF6366F1);
  static const orderStatusShipped = Color(0xFF8B5CF6);
  static const orderStatusDelivered = Color(0xFF22C55E);
  static const orderStatusCancelled = Color(0xFFEF4444);
  static const orderStatusRefunded = Color(0xFF6B7280);

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
