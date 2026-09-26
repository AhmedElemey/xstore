import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

/// Orbit radar at the top of Explore: result count and query on the left,
/// a static radar (rings, sweep, one blip per result up to [_maxBlips]) on
/// the right. The radar is decoration — blips are not store positions.
class ExploreRadarHeader extends StatelessWidget {
  const ExploreRadarHeader({
    super.key,
    required this.resultCount,
    required this.queryLabel,
  });

  final int resultCount;
  final String queryLabel;

  static const _maxBlips = 6;

  @override
  Widget build(BuildContext context) {
    final accent = context.primaryColor;
    return Container(
      height: 150,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: accent.withValues(alpha: 0.06),
        border: Border.all(color: accent.withValues(alpha: 0.28)),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ExcludeSemantics(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _RadarPainter(
                    color: accent,
                    blips: math.min(resultCount, _maxBlips),
                    textDirection: Directionality.of(context),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: FractionallySizedBox(
              widthFactor: 0.55,
              alignment: AlignmentDirectional.centerStart,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    context.l10n.exploreRadarLabel.toUpperCase(),
                    style: AppTypography.labelSmall.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    context.l10n.exploreRadarResults(resultCount),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.titleLarge.copyWith(
                      color: context.textPrimary,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${context.l10n.resultsFor} $queryLabel',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmall.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  const _RadarPainter({
    required this.color,
    required this.blips,
    required this.textDirection,
  });

  final Color color;
  final int blips;
  final TextDirection textDirection;

  // Fixed blip spots (angle in radians, distance as a fraction of the
  // outer ring) so the sky doesn't jump between rebuilds.
  static const _spots = [
    (-0.6, 0.55),
    (0.9, 0.35),
    (2.3, 0.7),
    (-2.2, 0.45),
    (0.2, 0.85),
    (3.0, 0.25),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rtl = textDirection == TextDirection.rtl;
    final center = Offset(
      rtl ? size.width * 0.26 : size.width * 0.74,
      size.height * 0.55,
    );
    final outer = size.height * 0.95;

    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final (fraction, alpha) in [(1.0, 0.16), (0.66, 0.22), (0.33, 0.3)]) {
      ring.color = color.withValues(alpha: alpha);
      canvas.drawCircle(center, outer * fraction, ring);
    }

    // Sweep: a 40° wedge fading out behind the beam.
    const sweepStart = -2.2;
    const sweepAngle = 0.7;
    final sweepRect = Rect.fromCircle(center: center, radius: outer);
    final sweep = Paint()
      ..shader = SweepGradient(
        startAngle: sweepStart,
        endAngle: sweepStart + sweepAngle,
        colors: [color.withValues(alpha: 0), color.withValues(alpha: 0.35)],
      ).createShader(sweepRect);
    canvas.drawArc(sweepRect, sweepStart, sweepAngle, true, sweep);

    final blip = Paint();
    for (var i = 0; i < blips; i++) {
      final (angle, distance) = _spots[i];
      final spot = Offset(
        center.dx + math.cos(angle) * outer * distance,
        center.dy + math.sin(angle) * outer * distance,
      );
      final blipColor = i.isEven ? color : AppColors.cash;
      blip
        ..color = blipColor.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(spot, 6, blip);
      blip
        ..color = blipColor
        ..maskFilter = null;
      canvas.drawCircle(spot, 3.5, blip);
    }

    // "You" at the centre.
    canvas.drawCircle(center, 11, Paint()..color = color.withValues(alpha: 0.3));
    canvas.drawCircle(center, 6.5, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_RadarPainter old) =>
      old.color != color ||
      old.blips != blips ||
      old.textDirection != textDirection;
}
