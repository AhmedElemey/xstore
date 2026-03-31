import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class NotificationGroupHeaderDelegate extends SliverPersistentHeaderDelegate {
  NotificationGroupHeaderDelegate(this.label);

  final String label;

  @override
  double get minExtent => AppSpacing.x3l + AppSpacing.sm;

  @override
  double get maxExtent => AppSpacing.x3l + AppSpacing.sm;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return NotificationGroupHeaderBar(label: label);
  }

  @override
  bool shouldRebuild(covariant NotificationGroupHeaderDelegate oldDelegate) =>
      oldDelegate.label != label;
}

class NotificationGroupHeaderBar extends StatelessWidget {
  const NotificationGroupHeaderBar({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: context.backgroundColor,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.labelSmall.copyWith(
          color: context.textSecondary,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}
