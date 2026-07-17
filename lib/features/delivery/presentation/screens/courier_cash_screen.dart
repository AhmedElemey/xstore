import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../domain/courier_order_flow.dart';
import '../providers/courier_cash_wallet_provider.dart';

/// Cash tab: what the courier is holding from COD collections and which
/// delivered orders make up that amount, until it's handed over to xStore.
class CourierCashScreen extends ConsumerWidget {
  const CourierCashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletAsync = ref.watch(courierCashWalletProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.courierCashScreenTitle)),
      body: walletAsync.when(
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
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: context.primaryColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(AppSpacing.lg),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              LucideIcons.wallet,
                              color: context.primaryColor,
                              size: 32,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              context.l10n.courierCashInHand,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              context.formatCurrency(wallet.cashInHandEgp),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: context.primaryColor,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (wallet.handoverDue) ...[
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.12),
                            borderRadius:
                                BorderRadius.circular(AppSpacing.md),
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
                          context.l10n.courierCollectedListTitle,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
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
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        border:
            Border.all(color: context.borderColor.withValues(alpha: 0.45)),
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
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
