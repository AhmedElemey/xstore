import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

/// Red count badge (top-right). Hidden when [count] is 0.
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
    if (count <= 0) return child;
    final label = count > maxCount ? '$maxCount+' : '$count';
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          right: -AppSpacing.xs,
          top: -AppSpacing.xs,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.xs / 2,
            ),
            constraints: const BoxConstraints(minWidth: AppSpacing.md + AppSpacing.xs),
            decoration: BoxDecoration(
              color: AppColors.error,
              borderRadius: BorderRadius.circular(AppSpacing.x3l),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
