import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'app_animations.dart';

extension AnimateExtensions on Widget {
  Widget fadeSlideIn({
    Duration delay = Duration.zero,
    Duration duration = const Duration(milliseconds: 300),
    double offsetY = 0.08,
  }) {
    return animate(delay: delay)
        .fadeIn(
          duration: duration,
          curve: AppAnimations.enter,
        )
        .slideY(
          begin: offsetY,
          end: 0,
          duration: duration,
          curve: AppAnimations.enter,
        );
  }

  Widget scaleIn({
    Duration delay = Duration.zero,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return animate(delay: delay)
        .fadeIn(duration: duration)
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1.0, 1.0),
          duration: duration,
          curve: AppAnimations.spring,
        );
  }

  Widget slideFromRight({
    Duration delay = Duration.zero,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return animate(delay: delay)
        .fadeIn(duration: duration)
        .slideX(
          begin: 0.1,
          end: 0,
          duration: duration,
          curve: AppAnimations.enter,
        );
  }

  Widget pulse({
    Duration duration = const Duration(milliseconds: 800),
  }) {
    return animate(
      onPlay: (c) => c.repeat(reverse: true),
    ).scale(
      begin: const Offset(1.0, 1.0),
      end: const Offset(1.05, 1.05),
      duration: duration,
      curve: Curves.easeInOut,
    );
  }

  Widget shake({
    Duration duration = const Duration(milliseconds: 500),
  }) {
    return animate().shake(
      hz: 4,
      offset: const Offset(4, 0),
      duration: duration,
    );
  }
}
