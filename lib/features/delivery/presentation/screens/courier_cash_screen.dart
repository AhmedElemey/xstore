import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/orbit_background.dart';
import '../../../../shared/widgets/route_reentry_refresh.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../domain/courier_order_flow.dart';
import '../providers/courier_cash_wallet_provider.dart';
import '../widgets/courier_card_sections.dart';
import '../../../../core/network/dio_error_mapper.dart';

/// Cash tab: what the courier is holding from COD collections and which
/// delivered orders make up that amount, until it's handed over to xStore.
class CourierCashScreen extends ConsumerWidget {
  const CourierCashScreen({super.key});

  // Clears the floating dock on this shell tab.
  static const double _dockClearance = 124;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletAsync = ref.watch(courierCashWalletProvider);

    return RouteReentryRefresh(
      isTarget: (location) => location == AppRoutes.courierCash,
      onReentry: (ref) => ref.invalidate(courierCashWalletProvider),
      child: Scaffold(
        backgroundColor: AppColors.transparent,
        body: OrbitBackground(
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
                    context.l10n.courierCashScreenTitle,
                    style: AppTypography.headlineSmall.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Expanded(
                  child: walletAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => ErrorStateWidget(
                      message: userErrorMessage(e),
                      onRetry: () => ref.invalidate(courierCashWalletProvider),
                    ),
                    data: (wallet) => RefreshIndicator(
                      color: context.amberColor,
                      onRefresh: () async =>
                          ref.invalidate(courierCashWalletProvider),
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xl,
                            ),
                            sliver: SliverList.list(
                              children: [
                                _CashHero(amountEgp: wallet.cashInHandEgp),
                                const SizedBox(height: AppSpacing.md),
                                if (wallet.handoverDue) ...[
                                  const CourierHandoverBanner(),
                                  const SizedBox(height: AppSpacing.md),
                                ],
                                Text(
                                  context.l10n.courierCashExplainer(
                                    context.formatCurrency(
                                      wallet.handoverThresholdEgp,
                                    ),
                                  ),
                                  style: AppTypography.bodySmall.copyWith(
                                    color: context.textSecondary,
                                  ),
                                ),
                                if (wallet.deliveredCodOrders.isNotEmpty) ...[
                                  const SizedBox(height: AppSpacing.xl),
                                  Text(
                                    context.l10n.courierCollectedListTitle
                                        .toUpperCase(),
                                    style: AppTypography.fieldLabel.copyWith(
                                      color: context.labelColor,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                ],
                              ],
                            ),
                          ),
                          if (wallet.deliveredCodOrders.isEmpty)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  AppSpacing.xl,
                                  AppSpacing.lg,
                                  AppSpacing.xl,
                                  0,
                                ),
                                child: Text(
                                  context.l10n.courierCashEmpty,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: context.textSecondary,
                                  ),
                                ),
                              ),
                            )
                          else
                            SliverPadding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xl,
                              ),
                              sliver: SliverList.separated(
                                itemCount: wallet.deliveredCodOrders.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: AppSpacing.sm),
                                itemBuilder: (context, index) =>
                                    _CollectedOrderTile(
                                      order: wallet.deliveredCodOrders[index],
                                    ),
                              ),
                            ),
                          const SliverPadding(
                            padding: EdgeInsets.only(bottom: _dockClearance),
                          ),
                        ],
                      ),
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

/// Cash-in-hand hero: a big amber mono amount on a glass card.
class _CashHero extends StatelessWidget {
  const _CashHero({required this.amountEgp});

  final double amountEgp;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: context.glassColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: AppColors.courierGradient),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.courierGradient.first.withValues(
                    alpha: 0.35,
                  ),
                  blurRadius: 24,
                ),
              ],
            ),
            child: const Icon(
              LucideIcons.wallet,
              color: AppColors.onCourier,
              size: 24,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            context.l10n.courierCashInHand.toUpperCase(),
            style: AppTypography.fieldLabel.copyWith(color: context.labelColor),
          ),
          const SizedBox(height: AppSpacing.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              context.formatCurrency(amountEgp),
              maxLines: 1,
              style: AppTypography.mono.copyWith(
                fontSize: 40,
                fontWeight: FontWeight.w700,
                color: context.amberColor,
              ),
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
        color: context.glassColor,
        borderRadius: BorderRadius.circular(22),
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
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  context.formatDate(deliveredOn),
                  style: AppTypography.bodySmall.copyWith(
                    color: context.labelColor,
                  ),
                ),
              ],
            ),
          ),
          Text(
            context.formatCurrency(codAmountToCollect(order)),
            style: AppTypography.mono.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: context.amberColor,
            ),
          ),
        ],
      ),
    );
  }
}
