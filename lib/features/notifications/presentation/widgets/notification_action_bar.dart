import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_typography.dart';
import '../providers/notifications_provider.dart';

class NotificationActionBar extends ConsumerWidget {
  const NotificationActionBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationsProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.x3l,
      ),
      child: Column(
        children: [
          if (state.isLoadingMore)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: CircularProgressIndicator.adaptive(),
            )
          else if (!state.hasMore && state.notifications.isNotEmpty)
            Text(
              AppStrings.notificationsNoMore,
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
        ],
      ),
    );
  }
}
