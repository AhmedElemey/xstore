import 'package:flutter/material.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/orbit_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/route_reentry_refresh.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../domain/courier_order_flow.dart';
import '../providers/courier_cash_wallet_provider.dart';
import '../../../../shared/widgets/space_background.dart';

/// Cash tab: what the courier is holding from COD collections and which
/// delivered orders make up that amount, until it's handed over to xStore.
class CourierCashScreen extends ConsumerWidget {
  const CourierCashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletAsync = ref.watch(courierCashWalletProvider);

    return RouteReentryRefresh(
      isTarget: (location) => location == AppRoutes.courierCash,
      onReentry: (ref) => ref.invalidate(courierCashWalletProvider),
      child: Scaffold(
      appBar: AppBar(title: Text(context.l10n.courierCashScreenTitle)),
      body: SpaceBackground(child: walletAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorStateWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(courierCashWalletProvider),
        ),
        data: (wallet) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(courierCashWalletProvider),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _CashRing(
                        amount: context.formatCurrency(wallet.cashInHandEgp),
                        progress: wallet.handoverThresholdEgp <= 0
                            ? 0
                            : wallet.cashInHandEgp /
                                wallet.handoverThresholdEgp,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (wallet.handoverDue) ...[
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: context.cashColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: context.cashColor.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                LucideIcons.alertTriangle,
                                color: AppColors.warning,
                                size: 18,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  context.l10n.courierHandoverDueBanner,
                                  style:
                                      Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                      Text(
                        context.l10n.courierCashExplainer(
                          context
                              .formatCurrency(wallet.handoverThresholdEgp),
                        ),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: context.textSecondary),
                      ),
                      if (wallet.deliveredCodOrders.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          context.l10n.courierCollectedListTitle.toUpperCase(),
                          style: AppTypography.labelSmall.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (wallet.deliveredCodOrders.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: Text(
                      context.l10n.courierCashEmpty,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: context.textSecondary),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  sliver: SliverList.separated(
                    itemCount: wallet.deliveredCodOrders.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.xs),
                    itemBuilder: (context, index) => _CollectedOrderTile(
                      order: wallet.deliveredCodOrders[index],
                    ),
                  ),
                ),
              const SliverPadding(
                padding: EdgeInsets.only(bottom: AppSpacing.xl),
              ),
            ],
          ),
        ),
      )),
      ),
    );
  }
}

/// Amber ring showing how close the cash in hand is to the hand-over
/// limit, with the amount beside it.
class _CashRing extends StatelessWidget {
  const _CashRing({required this.amount, required this.progress});

  final String amount;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final warm = context.cashColor;
    return GlassCard(
      radius: 24,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            height: 96,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  strokeWidth: 9,
                  color: warm,
                  backgroundColor: context.borderColor,
                ),
                Center(
                  child: Icon(LucideIcons.wallet, color: warm, size: 28),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  amount,
                  style: AppTypography.titleLarge.copyWith(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: context.textPrimary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                Text(
                  context.l10n.courierCashInHand,
                  style: AppTypography.bodySmall.copyWith(
                    color: context.textSecondary,
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

class _CollectedOrderTile extends StatelessWidget {
  const _CollectedOrderTile({required this.order});

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    final deliveredOn = order.deliveredAt ?? order.updatedAt;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: glassFill(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.banknote, color: AppColors.success, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.formattedOrderId,
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  context.formatDate(deliveredOn),
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: context.textSecondary),
                ),
              ],
            ),
          ),
          Text(
            context.formatCurrency(codAmountToCollect(order)),
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: context.cashColor,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
