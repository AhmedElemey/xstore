import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../providers/notifications_provider.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class NotificationUnreadSummaryBanner extends ConsumerWidget {
  const NotificationUnreadSummaryBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(notificationsProvider.select((s) => s.unreadCount));
    return AnimatedSlide(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      offset: unread > 0 ? Offset.zero : const Offset(0, -0.2),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 280),
        opacity: unread > 0 ? 1 : 0,
        child: unread <= 0
            ? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.notificationBannerBackground,
                    borderRadius: BorderRadius.circular(AppSpacing.md),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    child: Text(
                      context.l10n.notificationsUnreadBannerLine(unread),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
