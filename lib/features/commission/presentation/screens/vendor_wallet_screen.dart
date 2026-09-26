import 'package:flutter/material.dart';
import '../../../../shared/widgets/orbit_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/route_reentry_refresh.dart';
import '../../domain/entities/vendor_commission_wallet.dart';
import '../providers/commission_config_provider.dart';
import '../providers/vendor_commission_wallet_provider.dart';
import '../widgets/vendor_commission_alert_banner.dart';
import '../../../../shared/widgets/space_background.dart';

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

    return RouteReentryRefresh(
      isTarget: (location) => location == AppRoutes.vendorWallet,
      onReentry: (ref) {
        ref.invalidate(vendorCommissionSnapshotProvider);
        ref.invalidate(vendorCommissionWalletProvider);
      },
      child: Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(title: Text(context.l10n.navWallet)),
      body: SpaceBackground(child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(vendorCommissionSnapshotProvider);
          ref.invalidate(vendorCommissionWalletProvider);
          await ref.read(vendorCommissionSnapshotProvider.future);
        },
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            _FeeHero(
              feePerOrder: context.formatCurrency(feePerOrder),
              pauseLimit: wallet == null
                  ? null
                  : context.formatCurrency(wallet.pauseThresholdEgp),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                _Stat(
                  value: '${stats?.totalCount ?? 0}',
                  label: context.l10n.vendorStatTotalOrders,
                ),
                const SizedBox(width: 10),
                _Stat(
                  value: context.formatCurrency(stats?.totalRevenue ?? 0),
                  label: context.l10n.vendorStatRevenue,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (wallet != null) VendorCommissionAlertBanner(wallet: wallet),
            if (wallet != null &&
                wallet.alertLevel == VendorCommissionAlertLevel.none)
              const _GoodStandingCard(),
          ],
        ),
      )),
      ),
    );
  }
}

/// Gradient hero: the flat platform fee per order and the unpaid-fee limit
/// at which new listings pause. (The owed balance itself is admin-only and
/// never reaches the vendor app.)
class _FeeHero extends StatelessWidget {
  const _FeeHero({required this.feePerOrder, required this.pauseLimit});

  final String feePerOrder;
  final String? pauseLimit;

  @override
  Widget build(BuildContext context) {
    final warm = context.cashColor;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.nova.withValues(alpha: 0.22),
            warm.withValues(alpha: 0.14),
          ],
        ),
        border: Border.all(color: warm.withValues(alpha: 0.4)),
      ),
      child: Stack(
        children: [
          PositionedDirectional(
            top: -50,
            end: -50,
            child: Opacity(
              opacity: 0.35,
              child: Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: orbitOrbGradient(3),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.walletFeePerOrder.toUpperCase(),
                  style: AppTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: warm,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  feePerOrder,
                  style: AppTypography.titleLarge.copyWith(
                    fontSize: 38,
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                if (pauseLimit != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    context.l10n.walletPauseLimit(pauseLimit!),
                    style: AppTypography.bodySmall.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
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
      child: GlassCard(
        radius: 18,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w800,
                color: context.textPrimary,
              ),
            ),
          ],
        ),
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
        borderRadius: BorderRadius.circular(18),
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
