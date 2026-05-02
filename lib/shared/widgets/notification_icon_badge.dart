import 'package:flutter/material.dart';

import '../../core/animations/app_animations.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';

/// Red count badge (top-right). Uses a stable [Stack] so implicit animations are
/// not torn down mid-flight (avoids "deactivated ancestor" from flutter_animate).
class NotificationIconBadge extends StatelessWidget {
  const NotificationIconBadge({
    super.key,
    required this.child,
    required this.count,
    this.maxCount = 99,
  });

  final Widget child;
  final int count;
  final int maxCount;

  @override
  Widget build(BuildContext context) {
    final show = count > 0;
    final label = show ? (count > maxCount ? '$maxCount+' : '$count') : '';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          right: -AppSpacing.xs,
          top: -AppSpacing.xs,
          child: IgnorePointer(
            ignoring: !show,
            child: AnimatedOpacity(
              opacity: show ? 1.0 : 0.0,
              duration: AppAnimations.fast,
              curve: AppAnimations.enter,
              child: AnimatedScale(
                scale: show ? 1.0 : 0.0,
                duration: AppAnimations.fast,
                curve: AppAnimations.enter,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: AppSpacing.xs / 2,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: AppSpacing.md + AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(AppSpacing.x3l),
                  ),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.white,
                      fontFamily: AppTypography.fontFamily,
                      fontFamilyFallback: AppTypography.fontFamilyFallback,
                      fontSize: AppTypography.rem(0.625),
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
