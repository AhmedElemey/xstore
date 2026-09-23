import 'package:flutter/material.dart';

/// Durations, curves, and layout tokens for motion across the app.
abstract final class AppAnimations {
  // ── DURATIONS
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration medium = Duration(milliseconds: 400);
  static const Duration pageEnter = Duration(milliseconds: 350);
  static const Duration stagger = Duration(milliseconds: 80);

  // ── CURVES
  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
  static const Curve bounce = Curves.elasticOut;
  static const Curve smooth = Curves.easeInOutCubic;
  static const Curve spring = Curves.easeOutBack;

  // ── SLIDE OFFSETS (fraction of parent)
  static const Offset slideFromRight = Offset(0.12, 0);

  // ── SCALE VALUES
  static const double scalePressed = 0.96;

  /// Stagger delays for list items (cap at 8 in callers).
  static Duration staggerDelay(int index) =>
      Duration(milliseconds: index * stagger.inMilliseconds);

  /// First [maxStagger] items stagger; later items appear immediately.
  static Duration staggerDelayCapped(int index, {int maxStagger = 8}) =>
      index < maxStagger ? staggerDelay(index) : Duration.zero;
}
