import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../domain/courier_order_flow.dart';
import '../../domain/delivery_request_flow.dart';
import '../../domain/entities/delivery_request.dart';
import '../providers/courier_cash_wallet_provider.dart';
import '../providers/courier_deliveries_provider.dart';
import '../providers/courier_packages_provider.dart';
import '../widgets/delivery_fail_sheet.dart';
import '../widgets/delivery_order_card.dart';
import '../widgets/package_delivery_card.dart';

/// Courier home tab: today's run. Active pick-ups/drop-offs on top,
/// finished tasks below, cash-in-hand summary in the header.
class CourierDeliveriesScreen extends ConsumerStatefulWidget {
  const CourierDeliveriesScreen({super.key});

  @override
  ConsumerState<CourierDeliveriesScreen> createState() =>
      _CourierDeliveriesScreenState();
}

class _CourierDeliveriesScreenState
    extends ConsumerState<CourierDeliveriesScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(courierDeliveriesProvider.notifier).fetchOrders();
      ref.read(courierPackagesProvider.notifier).fetchPackages();
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.extentAfter < 200) {
      ref.read(courierDeliveriesProvider.notifier).loadMore();
    }
  }

  Future<void> _confirmDelivered(OrderEntity order) async {
    final codAmount = codAmountToCollect(order);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.l10n.courierDeliverConfirmTitle),
        content: Text(
          codAmount > 0
              ? dialogContext.l10n.courierDeliverConfirmCod(
                  dialogContext.formatCurrency(codAmount),
                )
              : dialogContext.l10n.courierDeliverConfirmPrepaid,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(dialogContext.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(dialogContext.l10n.courierDeliverAction),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await ref
        .read(courierDeliveriesProvider.notifier)
        .markDelivered(order.id);
  }

  /// Cash changes hands here: confirm the exact amount to collect from the
  /// sender before marking the package as picked up.
  Future<void> _confirmPackagePickedUp(DeliveryRequestEntity request) async {
    final amount = cashToCollectFromSender(request);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.l10n.courierPackagePickupConfirmTitle),
        content: Text(
          dialogContext.l10n.courierPackagePickupConfirmBody(
            dialogContext.formatCurrency(amount),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(dialogContext.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(dialogContext.l10n.courierPackagePickUpAction),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await ref
        .read(courierPackagesProvider.notifier)
        .markPickedUp(request.id);
  }

  void _showFailSheet(OrderEntity order) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => DeliveryFailSheet(
        onConfirm: (reason) => ref
            .read(courierDeliveriesProvider.notifier)
            .markFailed(order.id, reason),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(courierDeliveriesProvider);
    final packagesState = ref.watch(courierPackagesProvider);
    final active = state.activeOrders;
    final finished = state.finishedOrders;
    final activePackages = packagesState.activePackages;
    final finishedPackages = packagesState.finishedPackages;
    final isEmpty = state.orders.isEmpty &&
        packagesState.packages.isEmpty &&
        state.error == null &&
        packagesState.error == null;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.courierDeliveriesTitle)),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(courierCashWalletProvider);
          await Future.wait([
            ref.read(courierDeliveriesProvider.notifier).refreshOrders(),
            ref.read(courierPackagesProvider.notifier).refreshPackages(),
          ]);
        },
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                controller: _scroll,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(child: _CashSummaryHeader()),
                  if (state.error != null)
                    SliverToBoxAdapter(
                      child: _InlineError(
                        message: state.error!,
                        onRetry: () => ref
                            .read(courierDeliveriesProvider.notifier)
                            .fetchOrders(),
                      ),
                    ),
                  if (packagesState.error != null)
                    SliverToBoxAdapter(
                      child: _InlineError(
                        message: packagesState.error!,
                        onRetry: () => ref
                            .read(courierPackagesProvider.notifier)
                            .fetchPackages(),
                      ),
                    ),
                  if (isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyStateWidget(
                        title: context.l10n.courierEmptyTitle,
                        subtitle: context.l10n.courierEmptyBody,
                      ),
                    ),
                  if (activePackages.isNotEmpty) ...[
                    _sectionHeader(
                      context,
                      context.l10n.courierPackagesSection,
                      trailing: context.l10n
                          .courierPackagesCount(activePackages.length),
                    ),
                    _packageList(activePackages, withActions: true),
                  ],
                  if (active.isNotEmpty) ...[
                    _sectionHeader(
                      context,
                      context.l10n.courierActiveSection,
                    ),
                    _orderList(active, withActions: true),
                  ],
                  if (finished.isNotEmpty ||
                      finishedPackages.isNotEmpty) ...[
                    _sectionHeader(
                      context,
                      context.l10n.courierHistorySection,
                    ),
                    if (finished.isNotEmpty)
                      _orderList(finished, withActions: false),
                    if (finished.isNotEmpty && finishedPackages.isNotEmpty)
                      const SliverToBoxAdapter(
                        child: SizedBox(height: AppSpacing.sm),
                      ),
                    if (finishedPackages.isNotEmpty)
                      _packageList(finishedPackages, withActions: false),
                  ],
                  if (state.isLoadingMore)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.md),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ),
                  const SliverPadding(
                    padding: EdgeInsets.only(bottom: AppSpacing.xl),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title,
      {String? trailing}) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            if (trailing != null)
              Text(
                trailing,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: context.textSecondary),
              ),
          ],
        ),
      ),
    );
  }

  Widget _packageList(
    List<DeliveryRequestEntity> packages, {
    required bool withActions,
  }) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      sliver: SliverList.separated(
        itemCount: packages.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          final request = packages[index];
          return PackageDeliveryCard(
            request: request,
            onPickedUp:
                withActions ? () => _confirmPackagePickedUp(request) : null,
            onDelivered: withActions
                ? () => ref
                    .read(courierPackagesProvider.notifier)
                    .markDelivered(request.id)
                : null,
          );
        },
      ),
    );
  }

  Widget _orderList(List<OrderEntity> orders, {required bool withActions}) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      sliver: SliverList.separated(
        itemCount: orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          final order = orders[index];
          return DeliveryOrderCard(
            order: order,
            onPickedUp: withActions
                ? () => ref
                    .read(courierDeliveriesProvider.notifier)
                    .markPickedUp(order.id)
                : null,
            onDelivered: withActions ? () => _confirmDelivered(order) : null,
            onFailed: withActions ? () => _showFailSheet(order) : null,
          );
        },
      ),
    );
  }
}

/// Compact cash-in-hand strip; the Cash tab has the full breakdown.
class _CashSummaryHeader extends ConsumerWidget {
  const _CashSummaryHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(courierCashWalletProvider).valueOrNull;
    if (wallet == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: context.primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppSpacing.md),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.wallet, color: context.primaryColor),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    context.l10n.courierCashInHand,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Text(
                  context.formatCurrency(wallet.cashInHandEgp),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: context.primaryColor,
                      ),
                ),
              ],
            ),
          ),
          if (wallet.handoverDue) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSpacing.md),
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
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          const Icon(LucideIcons.alertCircle, color: AppColors.error, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(onPressed: onRetry, child: Text(context.l10n.retry)),
        ],
      ),
    );
  }
}
