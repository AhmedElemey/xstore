import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../providers/notifications_provider.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class NotificationActionBar extends ConsumerWidget {
  const NotificationActionBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoadingMore = ref.watch(
      notificationsProvider.select((s) => s.isLoadingMore),
    );
    final hasMore = ref.watch(notificationsProvider.select((s) => s.hasMore));
    final hasNotifications = ref.watch(
      notificationsProvider.select((s) => s.notifications.isNotEmpty),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.x3l,
      ),
      child: Column(
        children: [
          if (isLoadingMore)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: CircularProgressIndicator.adaptive(),
            )
          else if (!hasMore && hasNotifications)
            Text(
              context.l10n.notificationsNoMore,
              style: AppTypography.bodySmall.copyWith(color: context.textSecondary),
            ),
        ],
      ),
    );
  }
}
