import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/network/dio_error_mapper.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/error_state_widget.dart';
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
    final snapshot = ref.watch(vendorCommissionSnapshotProvider);
    final stats = snapshot.valueOrNull;
    final wallet = ref.watch(vendorCommissionWalletProvider).valueOrNull;
    final feePerOrder = ref.watch(commissionFeeEgpForCategoryProvider(null));
    final balance = wallet?.outstandingBalanceEgp;

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
                  child: snapshot.hasError && !snapshot.hasValue
                      // First load failed: zero totals and "fees up to date"
                      // would read as a good state.
                      ? ErrorStateWidget(
                          message: userErrorMessage(snapshot.error!),
                          onRetry: () {
                            ref.invalidate(vendorCommissionSnapshotProvider);
                            ref.invalidate(vendorCommissionWalletProvider);
                          },
                        )
                      : RefreshIndicator(
                          color: context.linkColor,
                          onRefresh: () async {
                            ref.invalidate(vendorCommissionSnapshotProvider);
                            ref.invalidate(vendorCommissionWalletProvider);
                            // A failed refresh shows via the error state / stale
                            // data; don't let it escape the indicator.
                            await ref
                                .read(vendorCommissionSnapshotProvider.future)
                                .then((_) {}, onError: (_) {});
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
                              if (wallet != null && balance != null)
                                _BalanceCard(
                                  wallet: wallet,
                                  balance: balance,
                                  feePerOrder: feePerOrder,
                                )
                              else if (wallet != null &&
                                  wallet.alertLevel ==
                                      VendorCommissionAlertLevel.none)
                                const _GoodStandingCard(),
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.lg),
                                decoration: BoxDecoration(
                                  color: context.glassColor,
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: context.borderColor,
                                  ),
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
                                      value: context.formatInt(
                                        stats?.totalCount ?? 0,
                                      ),
                                      label: context.l10n.vendorStatTotalOrders,
                                    ),
                                    _Stat(
                                      value: context.formatCurrency(
                                        feePerOrder,
                                      ),
                                      label: context.l10n.commissionPlatformFee,
                                      valueColor: context.amberColor,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              XstoreButton(
                                label: context.l10n.walletPayFees,
                                // Nothing owed → nothing to pay. Unknown
                                // (null) stays enabled.
                                onPressed: balance == 0
                                    ? null
                                    : () => context.push(
                                        AppRoutes.commissionPayment,
                                      ),
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

/// Owed platform fees with a bar from 0 to the pause limit and a tick at
/// the warn limit. Warn/pause state always comes from the server flags
/// ([VendorCommissionWallet.alertLevel]), never from comparing amounts.
class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.wallet,
    required this.balance,
    required this.feePerOrder,
  });

  final VendorCommissionWallet wallet;
  final double balance;
  final double feePerOrder;

  @override
  Widget build(BuildContext context) {
    final level = wallet.alertLevel;
    final accent = switch (level) {
      VendorCommissionAlertLevel.none => AppColors.success,
      VendorCommissionAlertLevel.warn => AppColors.warning,
      VendorCommissionAlertLevel.paused => AppColors.error,
    };
    final warn = wallet.warnThresholdEgp;
    final pause = wallet.pauseThresholdEgp;
    final ordersUntilWarn = feePerOrder > 0
        ? ((warn - balance) / feePerOrder).ceil()
        : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.glassColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.commissionWalletOutstandingTitle,
            style: AppTypography.labelSmall.copyWith(color: context.labelColor),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              context.formatCurrency(balance),
              maxLines: 1,
              style: AppTypography.mono.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: accent,
              ),
            ),
          ),
          if (pause > 0) ...[
            const SizedBox(height: AppSpacing.md),
            _LimitBar(
              value: balance / pause,
              warnAt: warn / pause,
              color: accent,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Text(
                    context.l10n.commissionWalletWarnAt(
                      context.formatCurrency(warn),
                    ),
                    style: AppTypography.labelSmall.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    context.l10n.commissionWalletPauseAt(
                      context.formatCurrency(pause),
                    ),
                    textAlign: TextAlign.end,
                    style: AppTypography.labelSmall.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
          // Warn/pause vendors already get the banner's explanation above.
          if (level == VendorCommissionAlertLevel.none) ...[
            const SizedBox(height: AppSpacing.md),
            if (balance == 0)
              Row(
                children: [
                  const Icon(
                    LucideIcons.checkCircle2,
                    color: AppColors.success,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.l10n.walletGoodStanding,
                      style: AppTypography.bodySmall.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                  ),
                ],
              )
            else if (ordersUntilWarn > 0)
              Text(
                context.l10n.commissionWalletOrdersUntilWarn(
                  ordersUntilWarn,
                  context.formatInt(ordersUntilWarn),
                ),
                style: AppTypography.bodySmall.copyWith(
                  color: context.textSecondary,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

/// Progress bar with a thin tick marking the warn limit. Both values are
/// fractions of the pause limit; mirrors automatically in RTL.
class _LimitBar extends StatelessWidget {
  const _LimitBar({
    required this.value,
    required this.warnAt,
    required this.color,
  });

  final double value;
  final double warnAt;
  final Color color;

  static const double _height = 8;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return SizedBox(
          height: _height,
          child: Stack(
            children: [
              Positioned.fill(
                child: LinearProgressIndicator(
                  value: value.clamp(0.0, 1.0),
                  minHeight: _height,
                  color: color,
                  backgroundColor: context.borderColor,
                  borderRadius: BorderRadius.circular(_height / 2),
                ),
              ),
              if (warnAt > 0 && warnAt < 1)
                PositionedDirectional(
                  start: (width * warnAt - 1).clamp(0.0, width - 2),
                  top: 0,
                  bottom: 0,
                  child: Container(width: 2, color: context.textSecondary),
                ),
            ],
          ),
        );
      },
    );
  }
}
