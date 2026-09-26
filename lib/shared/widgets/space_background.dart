import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/extensions/context_extensions.dart';

/// Orbit backdrop: a static starfield with two soft nebula glows in dark mode,
/// a plain lavender wash in light mode. Paints once and is cached behind a
/// [RepaintBoundary], so it is safe under scrolling content.
///
/// Screens using it give their [Scaffold] a transparent background.
class SpaceBackground extends StatelessWidget {
  const SpaceBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return ColoredBox(
      color: context.backgroundColor,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: dark
              ? const RadialGradient(
                  center: Alignment(1.1, -1.1),
                  radius: 1.1,
                  colors: [Color(0x528E62FF), Color(0x008E62FF)],
                )
              : null,
        ),
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            if (dark)
              const Positioned.fill(
                child: RepaintBoundary(
                  child: CustomPaint(painter: _StarfieldPainter()),
                ),
              ),
            child,
          ],
        ),
      ),
    );
  }
}

class _StarfieldPainter extends CustomPainter {
  const _StarfieldPainter();

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
    final glow = Paint()
      ..shader =
          RadialGradient(
            colors: [
              AppColors.plasma.withValues(alpha: 0.12),
              AppColors.plasma.withValues(alpha: 0),
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(0, size.height * 0.55),
              radius: size.width * 0.9,
            ),
          );
    canvas.drawRect(Offset.zero & size, glow);

    final star = Paint();
    for (final (x, y, radius, alpha) in _stars) {
      star.color = AppColors.white.withValues(alpha: alpha);
      canvas.drawCircle(Offset(x * size.width, y * size.height), radius, star);
    }
  }

  @override
  bool shouldRepaint(_StarfieldPainter oldDelegate) => false;
}
