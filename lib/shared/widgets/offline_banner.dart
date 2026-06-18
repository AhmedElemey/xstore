import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/network/connectivity_provider.dart';
import '../../core/utils/extensions/context_extensions.dart';

/// Persistent, non-blocking banner shown app-wide when offline.
class OfflineBannerHost extends ConsumerWidget {
  const OfflineBannerHost({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(isOnlineProvider);

    return Column(
      children: [
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          crossFadeState:
              online ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          firstChild: Material(
            color: AppColors.warning,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    const Icon(
                      LucideIcons.wifiOff,
                      size: AppSpacing.lg,
                      color: AppColors.white,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        context.l10n.noInternet,
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          secondChild: const SizedBox.shrink(),
        ),
        Expanded(child: child),
      ],
    );
  }
}
