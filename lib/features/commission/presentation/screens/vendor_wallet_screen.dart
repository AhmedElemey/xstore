import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../domain/entities/vendor_commission_wallet.dart';
import '../providers/commission_config_provider.dart';
import '../providers/vendor_commission_wallet_provider.dart';
import '../widgets/vendor_commission_alert_banner.dart';

/// Vendor's own commission-fee overview: revenue/orders read from the same
/// `GET /api/vendor/orders` envelope the incoming-orders tab already fetches
/// (see `commission_config_provider.dart` — there is no dedicated
/// vendor-facing wallet endpoint), plus the existing warn/pause alert.
class VendorWalletScreen extends ConsumerWidget {
  const VendorWalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(vendorCommissionSnapshotProvider).valueOrNull;
    final wallet = ref.watch(vendorCommissionWalletProvider).valueOrNull;
    final feePerOrder = ref.watch(commissionFeeEgpForCategoryProvider(null));

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.surfaceColor,
        elevation: 0,
        title: Text(context.l10n.navWallet),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(vendorCommissionSnapshotProvider);
          ref.invalidate(vendorCommissionWalletProvider);
          await ref.read(vendorCommissionSnapshotProvider.future);
        },
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            if (wallet != null) VendorCommissionAlertBanner(wallet: wallet),
            if (wallet != null &&
                wallet.alertLevel == VendorCommissionAlertLevel.none)
              const _GoodStandingCard(),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(AppSpacing.xl),
                border: Border.all(color: context.borderColor),
              ),
              child: Row(
                children: [
                  _Stat(
                    value: context.formatCurrency(stats?.totalRevenue ?? 0),
                    label: context.l10n.vendorStatRevenue,
                  ),
                  _Stat(
                    value: '${stats?.totalCount ?? 0}',
                    label: context.l10n.vendorStatTotalOrders,
                  ),
                  _Stat(
                    value: context.formatCurrency(feePerOrder),
                    label: context.l10n.commissionPlatformFee,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.titleMedium.copyWith(
              color: context.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.labelSmall.copyWith(
              color: context.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoodStandingCard extends StatelessWidget {
  const _GoodStandingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.checkCircle2, color: AppColors.success, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              context.l10n.walletGoodStanding,
              style: AppTypography.bodySmall.copyWith(
                color: context.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
