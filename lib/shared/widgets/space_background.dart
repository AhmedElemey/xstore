import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/extensions/context_extensions.dart';

/// Orbit backdrop, drawn once and cached behind a [RepaintBoundary] so it is
/// safe under scrolling content.
///
/// - Dark ("deep space"): white starfield, violet nebula top-right, cyan glow
///   on the left.
/// - Light ("daylight orbit"): a dawn sky — lilac to peach — with soft
///   lilac/cyan/peach nebulae, faint violet stars and two thin orbit rings.
///
/// Wrap a Scaffold `body` with it; keep the Scaffold itself opaque.
class SpaceBackground extends StatelessWidget {
  const SpaceBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: dark ? context.backgroundColor : null,
        gradient: dark
            ? null
            : const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFEDE8FF),
                  AppColors.lightBackground,
                  Color(0xFFFFF4EC),
                ],
                stops: [0, 0.55, 1],
              ),
      ),
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: dark ? _SkyPainter.deepSpace : _SkyPainter.daylight,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _SkyPainter extends CustomPainter {
  const _SkyPainter._({
    required this.dark,
    required this.starColor,
    required this.nebulae,
  });

  static const deepSpace = _SkyPainter._(
    dark: true,
    starColor: AppColors.white,
    nebulae: [
      (Alignment(1.1, -1.1), 1.1, Color(0x528E62FF)),
      (Alignment(-1, 0.1), 0.9, Color(0x1F7CF0FF)),
    ],
  );

  static const daylight = _SkyPainter._(
    dark: false,
    starColor: AppColors.primary,
    nebulae: [
      (Alignment(1.1, -1), 0.9, Color(0x40B69CFF)),
      (Alignment(-1.1, -0.2), 0.8, Color(0x307CF0FF)),
      (Alignment(0.9, 0.9), 0.8, Color(0x33FFB58A)),
    ],
  );

  final bool dark;
  final Color starColor;

  /// (centre, radius as a fraction of the shortest side, colour).
  final List<(Alignment, double, Color)> nebulae;

  // Fixed seed: every screen shows the same sky, and the list is built once.
  static final List<(double, double, double, double)> _stars = () {
    final random = math.Random(7);
    return List.generate(90, (_) {
      return (
        random.nextDouble(),
        random.nextDouble(),
        0.5 + random.nextDouble() * 1.1,
        0.25 + random.nextDouble() * 0.6,
      );
    });
  }();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final side = size.shortestSide;

    for (final (center, radius, color) in nebulae) {
      final glow = Paint()
        ..shader = RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ).createShader(
          Rect.fromCircle(
            center: center.withinRect(rect),
            radius: side * radius,
          ),
        );
      canvas.drawRect(rect, glow);
    }

    if (!dark) {
      // Two thin tilted orbit rings across the sky.
      final ring = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = AppColors.primary.withValues(alpha: 0.12);
      for (final (cy, w, tilt) in [(0.18, 1.5, -0.22), (0.62, 1.8, 0.14)]) {
        canvas.save();
        canvas.translate(size.width * 0.5, size.height * cy);
        canvas.rotate(tilt);
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset.zero,
            width: size.width * w,
            height: side * 0.32,
          ),
          ring,
        );
        canvas.restore();
      }
    }

    // Light mode keeps the stars sparse and faint so text stays crisp.
    final star = Paint();
    final count = dark ? _stars.length : _stars.length ~/ 2;
    for (var i = 0; i < count; i++) {
      final (x, y, radius, alpha) = _stars[i];
      star.color = starColor.withValues(alpha: dark ? alpha : alpha * 0.45);
      canvas.drawCircle(Offset(x * size.width, y * size.height), radius, star);
    }
  }

  @override
  bool shouldRepaint(_SkyPainter oldDelegate) => oldDelegate.dark != dark;
}
