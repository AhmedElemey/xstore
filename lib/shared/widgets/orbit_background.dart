import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/extensions/context_extensions.dart';

/// Orbit "sky": deep space with stars in dark mode, a lavender-to-peach
/// daylight wash in light mode. Fills its parent and paints [child] on top.
class OrbitBackground extends StatelessWidget {
  const OrbitBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SkyPainter(isDark: context.isDark),
      child: SizedBox.expand(child: child),
    );
  }
}

class _SkyPainter extends CustomPainter {
  const _SkyPainter({required this.isDark});

  final bool isDark;

  // Star positions as fractions of a 180×200 tile, repeated across the sky.
  static const _stars = <(double, double, double)>[
    (0.08, 0.12, 1.0),
    (0.27, 0.64, 1.0),
    (0.71, 0.22, 1.5),
    (0.88, 0.78, 1.0),
    (0.46, 0.90, 1.0),
    (0.58, 0.44, 1.5),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    if (isDark) {
      canvas.drawRect(rect, Paint()..color = AppColors.darkBackground);
      _glow(canvas, size, const Alignment(1, -1), 420,
          const Color(0x528E62FF));
      _glow(canvas, size, const Alignment(-1, 0.1), 380,
          const Color(0x2400D2FF));
    } else {
      canvas.drawRect(
        rect,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEDE8FF), Color(0xFFF6F5FF), Color(0xFFFFF4EC)],
            stops: [0, 0.55, 1],
          ).createShader(rect),
      );
      _glow(canvas, size, const Alignment(1, -1), 420,
          const Color(0x61B69CFF));
      _glow(canvas, size, const Alignment(-1, -0.1), 380,
          const Color(0x3D7B5CFF));
      _glow(canvas, size, const Alignment(0.8, 1), 360,
          const Color(0x47FFB58A));
    }

    final starPaint = Paint()
      ..color = isDark ? const Color(0xE6FFFFFF) : const Color(0x737B5CFF);
    const tileW = 180.0;
    const tileH = 200.0;
    for (var ty = 0.0; ty < size.height; ty += tileH) {
      for (var tx = 0.0; tx < size.width; tx += tileW) {
        for (final (x, y, r) in _stars) {
          canvas.drawCircle(
            Offset(tx + x * tileW, ty + y * tileH),
            r * (isDark ? 0.6 : 0.7),
            starPaint,
          );
        }
      }
    }
  }

  void _glow(
    Canvas canvas,
    Size size,
    Alignment at,
    double radius,
    Color color,
  ) {
    final center = at.alongSize(size);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  @override
  bool shouldRepaint(_SkyPainter oldDelegate) => oldDelegate.isDark != isDark;
}

/// The glowing planet used on the splash and sign-in screens.
class OrbitPlanet extends StatelessWidget {
  const OrbitPlanet({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: Alignment(-0.36, -0.44),
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFF9EE9FF),
            Color(0xFF6C7BFF),
            Color(0xFF2A1B6B),
            Color(0xFF0C0F2A),
          ],
          stops: [0, 0.12, 0.45, 0.78, 1],
        ),
        boxShadow: [BoxShadow(color: Color(0x807CA0FF), blurRadius: 60)],
      ),
    );
  }
}
