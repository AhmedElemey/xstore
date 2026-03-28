import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primary = Color(0xFF4F46E5); // deep indigo
  /// End color for profile header gradient (`primary` → this).
  static const profileHeaderGradientEnd = Color(0xFF3730A3);
  static const accent = Color(0xFFF97316); // orange
  static const success = Color(0xFF22C55E); // green
  static const warning = Color(0xFFF59E0B); // amber
  static const error = Color(0xFFEF4444); // red
  static const background = Color(0xFFFAFAFA);
  static const cardBg = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const textDisabled = Color(0xFFD1D5DB);
  static const white = Color(0xFFFFFFFF);
  static const transparent = Color(0x00000000);

  /// Order status badges (aligned with design spec).
  static const orderStatusPending = Color(0xFFF59E0B);
  static const orderStatusConfirmed = Color(0xFF3B82F6);
  static const orderStatusProcessing = Color(0xFF6366F1);
  static const orderStatusShipped = Color(0xFF8B5CF6);
  static const orderStatusDelivered = Color(0xFF22C55E);
  static const orderStatusCancelled = Color(0xFFEF4444);
  static const orderStatusRefunded = Color(0xFF6B7280);
}
