import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/mock/mock_deals.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/pulsing_dot.dart';

class FlashSaleBanner extends StatefulWidget {
  const FlashSaleBanner({super.key});

  @override
  State<FlashSaleBanner> createState() => _FlashSaleBannerState();
}

class _FlashSaleBannerState extends State<FlashSaleBanner> {
  late final ValueNotifier<Duration> _remaining = ValueNotifier<Duration>(
    _remainingDuration(),
  );
  Timer? _ticker;

  Duration _remainingDuration() {
    final diff = flashSaleEndTime.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _remaining.value = _remainingDuration();
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _remaining.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.md),
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.accent],
        ),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.zap, color: context.surfaceColor),
          const Gap(AppSpacing.md),
          Expanded(
            child: Text(
              context.l10n.flashSaleBannerBody,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(color: context.surfaceColor),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: context.surfaceColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppSpacing.x3l),
            ),
            child: ValueListenableBuilder<Duration>(
              valueListenable: _remaining,
              builder: (context, remaining, _) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PulsingDot(
                      size: AppSpacing.sm,
                      color: context.surfaceColor,
                    ),
                    const Gap(AppSpacing.xs),
                    Text(
                      _formatDuration(remaining),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: context.surfaceColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
