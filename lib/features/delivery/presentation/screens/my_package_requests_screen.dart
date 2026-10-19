// TODO(phase-2): parked, not routed yet (see app_router.dart); already in the Orbit design.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/auth_back_button.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/orbit_background.dart';
import '../../../../shared/widgets/xstore_button.dart';
import '../../domain/entities/delivery_request.dart';
import '../providers/delivery_requests_provider.dart';
import '../widgets/courier_card_sections.dart';
import 'send_package_screen.dart';

/// Requester's (consumer or vendor) list of package delivery requests,
/// newest first.
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
      AppSnackbar.error(
        context,
        context.localizedError(error ?? context.l10n.errorGeneric),
      );
    }
  }

  Future<void> _cancelRequest(DeliveryRequestEntity request) async {
    final reasonCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.l10n.packageCancelDialogTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dialogContext.l10n.packageCancelDialogBody),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: reasonCtrl,
              decoration: InputDecoration(
                hintText: dialogContext.l10n.packageRejectReasonHint,
              ),
              maxLines: 2,
            ),
          ],
        ),
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
    final reason = reasonCtrl.text.trim();
    reasonCtrl.dispose();
    if (confirmed != true || !mounted) return;
    final ok = await ref.read(deliveryRequestsProvider.notifier).cancelRequest(
          request.id,
          reason.isNotEmpty ? reason : context.l10n.packageCancelledBySender,
        );
    if (!mounted) return;
    if (!ok) {
      final error = ref.read(deliveryRequestsProvider).error;
      AppSnackbar.error(
        context,
        context.localizedError(error ?? context.l10n.errorGeneric),
      );
    }
  }

  void _requestAgain(DeliveryRequestEntity request) {
    context.push(
      AppRoutes.sendPackage,
      extra: SendPackageArgs(
        orderId: request.orderId,
        initialPickup: request.pickup,
        initialDropoff: request.dropoff,
        initialNote: request.packageNote,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(deliveryRequestsProvider);
    final error = state.error;

    return Scaffold(
      body: OrbitBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _Header(
                title: context.l10n.myPackagesTitle,
                action: Material(
                  color: context.glassColor,
                  shape: CircleBorder(
                    side: BorderSide(color: context.borderColor),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: IconButton(
                    tooltip: context.l10n.sendPackageTitle,
                    constraints: const BoxConstraints.tightFor(
                      width: 44,
                      height: 44,
                    ),
                    icon: Icon(
                      LucideIcons.packagePlus,
                      size: 20,
                      color: context.textPrimary,
                    ),
                    onPressed: () => context.push(AppRoutes.sendPackage),
                  ),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => ref
                      .read(deliveryRequestsProvider.notifier)
                      .refreshRequests(),
                  child: state.isLoading && state.requests.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : CustomScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          slivers: [
                            if (error != null && state.requests.isEmpty)
                              SliverFillRemaining(
                                hasScrollBody: false,
                                child: ErrorStateWidget(
                                  message: error,
                                  onRetry: () => ref
                                      .read(deliveryRequestsProvider.notifier)
                                      .fetchRequests(),
                                ),
                              ),
                            if (error != null && state.requests.isNotEmpty)
                              SliverPadding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                  AppSpacing.xl,
                                  0,
                                  AppSpacing.xl,
                                  AppSpacing.md,
                                ),
                                sliver: SliverToBoxAdapter(
                                  child: _InlineError(
                                    message: error,
                                    onRetry: () => ref
                                        .read(deliveryRequestsProvider.notifier)
                                        .fetchRequests(),
                                  ),
                                ),
                              ),
                            if (state.requests.isEmpty && error == null)
                              SliverFillRemaining(
                                hasScrollBody: false,
                                child: EmptyStateWidget(
                                  title: context.l10n.myPackagesEmptyTitle,
                                  subtitle: context.l10n.myPackagesEmptyBody,
                                  action: XstoreButton(
                                    label: context.l10n.sendPackageTitle,
                                    onPressed: () =>
                                        context.push(AppRoutes.sendPackage),
                                  ),
                                ),
                              ),
                            SliverPadding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                AppSpacing.xl,
                                0,
                                AppSpacing.xl,
                                AppSpacing.x3l,
                              ),
                              sliver: SliverList.separated(
                                itemCount: state.requests.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: AppSpacing.md),
                                itemBuilder: (context, index) {
                                  final request = state.requests[index];
                                  return _PackageRequestCard(
                                    request: request,
                                    onConfirm: () => _confirmPriced(request),
                                    onCancel: () => _cancelRequest(request),
                                    onRequestAgain: () =>
                                        _requestAgain(request),
                                  );
                                },
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
    );
  }
}

/// Orbit screen header: frosted back button (only when there is a route to
/// pop), an Unbounded title and an optional action.
class _Header extends StatelessWidget {
  const _Header({required this.title, this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.xl,
        AppSpacing.spacing18,
        AppSpacing.xl,
        AppSpacing.lg,
      ),
      child: Row(
        children: [
          if (Navigator.canPop(context)) ...[
            const AuthBackButton(),
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.headlineSmall.copyWith(
                fontSize: 20,
                color: context.textPrimary,
              ),
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}

class _PackageRequestCard extends StatelessWidget {
  const _PackageRequestCard({
    required this.request,
    required this.onConfirm,
    required this.onCancel,
    required this.onRequestAgain,
  });

  final DeliveryRequestEntity request;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final VoidCallback onRequestAgain;

  @override
  Widget build(BuildContext context) {
    final pickup = request.pickup;
    final dropoff = request.dropoff;

    return CourierCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _PackageStatusBadge(status: request.status),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  context.formatDate(request.createdAt),
                  textAlign: TextAlign.end,
                  style: AppTypography.labelSmall.copyWith(
                    color: context.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _RouteTrail(
            pickup: '${pickup.street}, ${pickup.city}',
            dropoff: '${dropoff.street}, ${dropoff.city}',
          ),
          if (request.packageNote.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              request.packageNote,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySmall.copyWith(
                color: context.textSecondary,
              ),
            ),
          ],
          if (request.orderId != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Icon(LucideIcons.link2, size: 12, color: context.textSecondary),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  context.l10n.packageOrderLinkedLabel,
                  style: AppTypography.labelSmall.copyWith(
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.md),
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
              style: AppTypography.mono.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: context.amberColor,
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
            const SizedBox(height: AppSpacing.md),
          ],
          XstoreButton(
            label: context.l10n.packageConfirmAction,
            onPressed: onConfirm,
          ),
          const SizedBox(height: AppSpacing.xs),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: _cancelButton(context),
          ),
        ];
      case DeliveryRequestStatus.confirmed:
        return [
          _hintRow(
            context,
            icon: LucideIcons.truck,
            color: context.amberColor,
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
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: OutlinedButton(
              onPressed: onRequestAgain,
              child: Text(context.l10n.packageRequestAgainAction),
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

/// Pickup → drop-off as a node-and-trail route (hollow ring, amber trail,
/// filled amber node), like the courier cards.
class _RouteTrail extends StatelessWidget {
  const _RouteTrail({required this.pickup, required this.dropoff});

  final String pickup;
  final String dropoff;

  @override
  Widget build(BuildContext context) {
    final amber = context.amberColor;
    final labelStyle = AppTypography.fieldLabel.copyWith(
      color: context.labelColor,
      fontSize: 11,
    );
    final valueStyle = AppTypography.bodySmall.copyWith(
      color: context.textPrimary,
      fontWeight: FontWeight.w700,
    );

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 18,
            child: Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: amber, width: 2),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    decoration: BoxDecoration(
                      color: amber.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: amber,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: amber.withValues(alpha: 0.35),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.courierPickupLabel.toUpperCase(),
                  style: labelStyle,
                ),
                const SizedBox(height: 2),
                Text(
                  pickup,
                  style: valueStyle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  context.l10n.courierDropoffLabel.toUpperCase(),
                  style: labelStyle,
                ),
                const SizedBox(height: 2),
                Text(
                  dropoff,
                  style: valueStyle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Orbit status pill (same recipe as `OrderStatusBadge`): the status colour
/// at 16% behind its own text, darkened in light mode.
class _PackageStatusBadge extends StatelessWidget {
  const _PackageStatusBadge({required this.status});

  final DeliveryRequestStatus status;

  @override
  Widget build(BuildContext context) {
    final accent = switch (status) {
      DeliveryRequestStatus.submitted => AppColors.orderStatusPending,
      DeliveryRequestStatus.priced => AppColors.orderStatusConfirmed,
      DeliveryRequestStatus.confirmed => AppColors.orderStatusProcessing,
      DeliveryRequestStatus.pickedUp => AppColors.orderStatusShipped,
      DeliveryRequestStatus.delivered => AppColors.orderStatusDelivered,
      DeliveryRequestStatus.cancelled => AppColors.orderStatusCancelled,
    };
    final label = switch (status) {
      DeliveryRequestStatus.submitted => context.l10n.packageStatusSubmitted,
      DeliveryRequestStatus.priced => context.l10n.packageStatusPriced,
      DeliveryRequestStatus.confirmed => context.l10n.packageStatusConfirmed,
      DeliveryRequestStatus.pickedUp => context.l10n.packageStatusPickedUp,
      DeliveryRequestStatus.delivered => context.l10n.packageStatusDelivered,
      DeliveryRequestStatus.cancelled => context.l10n.packageStatusCancelled,
    };
    final fg = context.isDark
        ? accent
        : Color.lerp(accent, AppColors.black, 0.35)!;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: fg,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

/// Compact refresh-failed notice shown above a stale list.
class _InlineError extends StatelessWidget {
  const _InlineError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.lg,
        AppSpacing.xs,
        AppSpacing.xs,
        AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: context.glassColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.alertCircle, color: AppColors.error, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              context.localizedError(message),
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
