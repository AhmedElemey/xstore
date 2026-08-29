import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/network/app_error_messages.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

/// Shown instead of [ExploreEmptyState] when a search failed (network/server
/// error) rather than genuinely returning zero results — distinguishes "try
/// a different search" from "something went wrong, try again".
class ExploreErrorState extends StatelessWidget {
  const ExploreErrorState({
    super.key,
    required this.error,
    required this.onRetry,
  });

  final String? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x2l),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.wifiOff,
              size: AppSpacing.x3l * 2,
              color: context.textDisabled,
            ),
            const Gap(AppSpacing.lg),
            Text(
              resolveAppError(context, error),
              style: AppTypography.bodyMedium.copyWith(color: context.textSecondary),
              textAlign: TextAlign.center,
            ),
            const Gap(AppSpacing.x2l),
            OutlinedButton(
              onPressed: onRetry,
              child: Text(context.l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}
