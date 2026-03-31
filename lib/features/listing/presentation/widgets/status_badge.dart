import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/listing_entity.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  final ListingStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      ListingStatus.draft => AppStrings.draft,
      ListingStatus.pending => AppStrings.pending,
      ListingStatus.active => AppStrings.active,
      ListingStatus.paused => AppStrings.paused,
      ListingStatus.sold => AppStrings.sold,
      ListingStatus.rejected => AppStrings.rejected,
    };
    final (bg, fg) = _colors(context, status);
    final pad = compact
        ? const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs)
        : const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm);
    final fontSize = compact ? 11.0 : 12.0;
    return Container(
      padding: pad,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
              fontSize: fontSize,
            ),
      ),
    );
  }

  (Color bg, Color fg) _colors(BuildContext context, ListingStatus s) {
    switch (s) {
      case ListingStatus.active:
        return (
          AppColors.success.withValues(alpha: 0.15),
          AppColors.success,
        );
      case ListingStatus.pending:
        return (
          AppColors.warning.withValues(alpha: 0.18),
          AppColors.warning,
        );
      case ListingStatus.paused:
        return (
          context.textDisabled.withValues(alpha: 0.35),
          context.textSecondary,
        );
      case ListingStatus.sold:
        return (
          AppColors.primary.withValues(alpha: 0.12),
          AppColors.primary,
        );
      case ListingStatus.rejected:
        return (
          AppColors.error.withValues(alpha: 0.12),
          AppColors.error,
        );
      case ListingStatus.draft:
        return (
          context.textDisabled.withValues(alpha: 0.45),
          context.textSecondary,
        );
    }
  }
}
