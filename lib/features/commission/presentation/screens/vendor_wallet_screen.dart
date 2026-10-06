import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/orbit_background.dart';
import '../../../../shared/widgets/route_reentry_refresh.dart';
import '../../../../shared/widgets/xstore_button.dart';
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

  // Clears the floating dock on this shell tab.
  static const double _dockClearance = 124;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(vendorCommissionSnapshotProvider).valueOrNull;
    final wallet = ref.watch(vendorCommissionWalletProvider).valueOrNull;
    final feePerOrder = ref.watch(commissionFeeEgpForCategoryProvider(null));

    return RouteReentryRefresh(
      isTarget: (location) => location == AppRoutes.vendorWallet,
      onReentry: (ref) {
        ref.invalidate(vendorCommissionSnapshotProvider);
        ref.invalidate(vendorCommissionWalletProvider);
      },
      child: Material(
        type: MaterialType.transparency,
        child: OrbitBackground(
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    AppSpacing.xl,
                    AppSpacing.lg,
                    AppSpacing.xl,
                    AppSpacing.lg,
                  ),
                  child: Text(
                    context.l10n.navWallet,
                    style: AppTypography.headlineSmall.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    color: context.linkColor,
                    onRefresh: () async {
                      ref.invalidate(vendorCommissionSnapshotProvider);
                      ref.invalidate(vendorCommissionWalletProvider);
                      await ref.read(vendorCommissionSnapshotProvider.future);
                    },
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        AppSpacing.xl,
                        0,
                        AppSpacing.xl,
                        _dockClearance,
                      ),
                      children: [
                        if (wallet != null)
                          VendorCommissionAlertBanner(wallet: wallet),
                        if (wallet != null &&
                            wallet.alertLevel ==
                                VendorCommissionAlertLevel.none)
                          const _GoodStandingCard(),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: context.glassColor,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: context.borderColor),
                          ),
                          child: Row(
                            children: [
                              _Stat(
                                value: context.formatCurrency(
                                  stats?.totalRevenue ?? 0,
                                ),
                                label: context.l10n.vendorStatRevenue,
                                valueColor: context.amberColor,
                              ),
                              _Stat(
                                value: '${stats?.totalCount ?? 0}',
                                label: context.l10n.vendorStatTotalOrders,
                              ),
                              _Stat(
                                value: context.formatCurrency(feePerOrder),
                                label: context.l10n.commissionPlatformFee,
                                valueColor: context.amberColor,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        XstoreButton(
                          label: context.l10n.walletPayFees,
                          onPressed: () =>
                              context.push(AppRoutes.commissionPayment),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, this.valueColor});

  final String value;
  final String label;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              style: AppTypography.mono.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: valueColor ?? context.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.labelSmall.copyWith(color: context.labelColor),
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
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            LucideIcons.checkCircle2,
            color: AppColors.success,
            size: 20,
          ),
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
