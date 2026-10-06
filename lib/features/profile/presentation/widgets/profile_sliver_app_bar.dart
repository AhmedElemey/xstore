import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/notification_bell_button.dart';

/// Orbit tab header: Unbounded title and the notification bell, sitting
/// straight on the sky and scrolling away with the content.
class ProfileSliverAppBar extends StatelessWidget {
  const ProfileSliverAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverSafeArea(
      bottom: false,
      sliver: SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.navProfile,
                  style: AppTypography.headlineSmall.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              NotificationBellButton(
                icon: LucideIcons.bell,
                tooltip: context.l10n.notifications,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
