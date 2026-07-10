import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../domain/entities/vendor_commission_wallet.dart';

/// Shown to vendors when their owed platform-commission balance crosses the
/// warn or pause threshold (see design memory). Renders nothing at
/// [VendorCommissionAlertLevel.none].
class VendorCommissionAlertBanner extends StatelessWidget {
  const VendorCommissionAlertBanner({super.key, required this.wallet});

  final VendorCommissionWallet wallet;

  @override
  Widget build(BuildContext context) {
    final level = wallet.alertLevel;
    if (level == VendorCommissionAlertLevel.none) {
      return const SizedBox.shrink();
    }

    final isPaused = level == VendorCommissionAlertLevel.paused;
    final color = isPaused ? AppColors.error : AppColors.warning;
    final amount = context.formatCurrency(wallet.outstandingEgp);
    final limit = context.formatCurrency(
      isPaused ? wallet.pauseThresholdEgp : wallet.warnThresholdEgp,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isPaused ? LucideIcons.alertCircle : LucideIcons.alertTriangle,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPaused
                      ? context.l10n.commissionWalletPausedTitle
                      : context.l10n.commissionWalletWarnTitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  isPaused
                      ? context.l10n
                          .commissionWalletPausedBody(amount, limit)
                      : context.l10n
                          .commissionWalletWarnBody(amount, limit),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.textSecondary,
                        height: 1.35,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
