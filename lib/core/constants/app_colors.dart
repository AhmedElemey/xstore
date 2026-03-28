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
}
