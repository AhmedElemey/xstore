import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/extensions/context_extensions.dart';

/// Greys out a catalog tile's image and centers a "Sold out" badge on it.
/// Pass-through when [soldOut] is false.
class SoldOutOverlay extends StatelessWidget {
  const SoldOutOverlay({super.key, required this.soldOut, required this.child});

  final bool soldOut;
  final Widget child;

  // Luminance-weighted greyscale matrix.
  static const _greyscale = ColorFilter.matrix(<double>[
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0, 0, 0, 1, 0, //
  ]);

  @override
  Widget build(BuildContext context) {
    if (!soldOut) return child;
    return Stack(
      fit: StackFit.passthrough,
      children: [
        ColorFiltered(colorFilter: _greyscale, child: child),
        Positioned.fill(
          child: ColoredBox(
            color: context.surfaceColor.withValues(alpha: 0.35),
            child: Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: context.textPrimary.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(AppSpacing.xs),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  child: Text(
                    context.l10n.soldOut,
                    style: AppTypography.labelSmall.copyWith(
                      color: context.surfaceColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
