import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../domain/entities/delivery_request.dart';
import '../providers/delivery_requests_provider.dart';

/// Consumer list of package delivery requests, newest first.
///
/// The COD-at-pickup flow surfaces here: a `submitted` request waits for the
/// admin's price, a `priced` one shows the fee with a "pay in cash at
/// pickup" confirmation, and confirmed/pickedUp/delivered mirror the courier
/// run.
class MyPackageRequestsScreen extends ConsumerStatefulWidget {
  const MyPackageRequestsScreen({super.key});

  @override
  ConsumerState<MyPackageRequestsScreen> createState() =>
      _MyPackageRequestsScreenState();
}

class _MyPackageRequestsScreenState
    extends ConsumerState<MyPackageRequestsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(deliveryRequestsProvider.notifier).fetchRequests(),
    );
  }

  Future<void> _confirmPriced(DeliveryRequestEntity request) async {
    final price = request.price;
    if (price == null) return;
    final priceText = context.formatCurrency(price);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.l10n.packageConfirmDialogTitle),
        content: Text(
          dialogContext.l10n.packageConfirmDialogBody(priceText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(dialogContext.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(dialogContext.l10n.packageConfirmAction),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final ok = await ref
        .read(deliveryRequestsProvider.notifier)
        .confirmRequest(request.id);
    if (!mounted) return;
    if (ok) {
      AppSnackbar.success(context, context.l10n.packageConfirmedSnack);
    } else {
      final error = ref.read(deliveryRequestsProvider).error;
      AppSnackbar.error(context, error ?? context.l10n.errorGeneric);
    }
  }

  Future<void> _cancelRequest(DeliveryRequestEntity request) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.l10n.packageCancelDialogTitle),
        content: Text(dialogContext.l10n.packageCancelDialogBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(dialogContext.l10n.packageCancelDialogKeep),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(dialogContext.l10n.packageCancelAction),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final ok = await ref
        .read(deliveryRequestsProvider.notifier)
        .cancelRequest(request.id, context.l10n.packageCancelledBySender);
    if (!mounted) return;
    if (!ok) {
      final error = ref.read(deliveryRequestsProvider).error;
      AppSnackbar.error(context, error ?? context.l10n.errorGeneric);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(deliveryRequestsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.myPackagesTitle),
        actions: [
          IconButton(
            tooltip: context.l10n.sendPackageTitle,
            icon: const Icon(LucideIcons.packagePlus),
            onPressed: () => context.push(AppRoutes.sendPackage),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(deliveryRequestsProvider.notifier).refreshRequests(),
        child: state.isLoading && state.requests.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  if (state.error != null)
                    SliverToBoxAdapter(
                      child: _InlineError(
                        message: state.error!,
                        onRetry: () => ref
                            .read(deliveryRequestsProvider.notifier)
                            .fetchRequests(),
                      ),
                    ),
                  if (state.requests.isEmpty && state.error == null)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyStateWidget(
                        title: context.l10n.myPackagesEmptyTitle,
                        subtitle: context.l10n.myPackagesEmptyBody,
                        action: FilledButton(
                          onPressed: () =>
                              context.push(AppRoutes.sendPackage),
                          child: Text(context.l10n.sendPackageTitle),
                        ),
                      ),
                    ),
                  SliverPadding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    sliver: SliverList.separated(
                      itemCount: state.requests.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final request = state.requests[index];
                        return _PackageRequestCard(
                          request: request,
                          onConfirm: () => _confirmPriced(request),
                          onCancel: () => _cancelRequest(request),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _PackageRequestCard extends StatelessWidget {
  const _PackageRequestCard({
    required this.request,
    required this.onConfirm,
    required this.onCancel,
  });

  final DeliveryRequestEntity request;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final pickup = request.pickup;
    final dropoff = request.dropoff;
    final routeSummary = '${pickup.street}, ${pickup.city} '
        '${context.arrowForward} ${dropoff.street}, ${dropoff.city}';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppSpacing.md),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  routeSummary,
                  style: AppTypography.bodyMedium.copyWith(
                    color: context.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _PackageStatusBadge(status: request.status),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            context.formatDate(request.createdAt),
            style: AppTypography.labelSmall.copyWith(
              color: context.textSecondary,
            ),
          ),
          if (request.packageNote.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              request.packageNote,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySmall.copyWith(
                color: context.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          ..._statusSection(context),
        ],
      ),
    );
  }

  List<Widget> _statusSection(BuildContext context) {
    switch (request.status) {
      case DeliveryRequestStatus.submitted:
        return [
          _hintRow(
            context,
            icon: LucideIcons.clock3,
            color: AppColors.warning,
            text: context.l10n.packageWaitingPricing,
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: _cancelButton(context),
          ),
        ];
      case DeliveryRequestStatus.priced:
        final price = request.price;
        return [
          if (price != null) ...[
            Text(
              context.formatCurrency(price),
              style: AppTypography.titleLarge.copyWith(
                color: context.primaryColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              context.l10n
                  .packagePayCashAtPickup(context.formatCurrency(price)),
              style: AppTypography.bodySmall.copyWith(
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: onConfirm,
                  child: Text(
                    context.l10n.packageConfirmAction,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _cancelButton(context),
            ],
          ),
        ];
      case DeliveryRequestStatus.confirmed:
        return [
          _hintRow(
            context,
            icon: LucideIcons.truck,
            color: context.primaryColor,
            text: context.l10n.packageConfirmedHint,
          ),
          if (request.price != null) ...[
            const SizedBox(height: AppSpacing.xs),
            _priceLine(context, request.price!),
          ],
        ];
      case DeliveryRequestStatus.pickedUp:
      case DeliveryRequestStatus.delivered:
        return [
          if (request.price != null) _priceLine(context, request.price!),
        ];
      case DeliveryRequestStatus.cancelled:
        final reason = request.cancelReason;
        return [
          if (reason != null && reason.isNotEmpty)
            Text(
              context.l10n.packageCancelReasonLine(reason),
              style: AppTypography.bodySmall.copyWith(
                color: context.textSecondary,
              ),
            ),
        ];
    }
  }

  Widget _priceLine(BuildContext context, double price) {
    return Text(
      context.l10n.packagePayCashAtPickup(context.formatCurrency(price)),
      style: AppTypography.bodySmall.copyWith(color: context.textSecondary),
    );
  }

  Widget _hintRow(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodySmall.copyWith(color: color),
          ),
        ),
      ],
    );
  }

  Widget _cancelButton(BuildContext context) {
    return TextButton(
      onPressed: onCancel,
      style: TextButton.styleFrom(foregroundColor: AppColors.error),
      child: Text(context.l10n.packageCancelAction),
    );
  }
}

class _PackageStatusBadge extends StatelessWidget {
  const _PackageStatusBadge({required this.status});

  final DeliveryRequestStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      DeliveryRequestStatus.submitted => AppColors.orderStatusPending,
      DeliveryRequestStatus.priced => AppColors.orderStatusConfirmed,
      DeliveryRequestStatus.confirmed => AppColors.orderStatusProcessing,
      DeliveryRequestStatus.pickedUp => AppColors.orderStatusShipped,
      DeliveryRequestStatus.delivered => AppColors.orderStatusDelivered,
      DeliveryRequestStatus.cancelled => AppColors.orderStatusCancelled,
    };
    final label = switch (status) {
      DeliveryRequestStatus.submitted =>
        context.l10n.packageStatusSubmitted,
      DeliveryRequestStatus.priced => context.l10n.packageStatusPriced,
      DeliveryRequestStatus.confirmed =>
        context.l10n.packageStatusConfirmed,
      DeliveryRequestStatus.pickedUp =>
        context.l10n.packageStatusPickedUp,
      DeliveryRequestStatus.delivered =>
        context.l10n.packageStatusDelivered,
      DeliveryRequestStatus.cancelled =>
        context.l10n.packageStatusCancelled,
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppSpacing.x4l),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w600,
        ),
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
              style: AppTypography.bodySmall.copyWith(
                color: context.textSecondary,
              ),
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
