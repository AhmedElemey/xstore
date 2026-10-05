import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/app_routes.dart';
import '../providers/order_detail_provider.dart';
import '../widgets/order_action_buttons.dart';
import '../../domain/entities/order_entity.dart';
import '../widgets/order_detail_scroll_content.dart';
import '../widgets/order_status_badge.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/auth_back_button.dart';
import '../../../../shared/widgets/orbit_background.dart';
import '../../../../shared/widgets/skeletons/order_detail_skeleton.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(orderDetailNotifierProvider(widget.orderId).notifier)
          .fetchOrder();
    });
  }

  /// Checkout's "Track My Order" (and FCM) uses [GoRouter.go], which
  /// replaces the stack — [SliverAppBar] then hides its implied leading.
  /// Pop when there is a route underneath; otherwise land on Orders.
  void _onBack() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }
    GoRouter.maybeOf(context)?.go(AppRoutes.orders);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderDetailNotifierProvider(widget.orderId));
    final order = state.order;

    ref.listen(orderDetailNotifierProvider(widget.orderId), (p, n) {
      final err = n.error;
      if (err != null && err != p?.error && context.mounted) {
        AppSnackbar.error(context, err);
        ref
            .read(orderDetailNotifierProvider(widget.orderId).notifier)
            .clearError();
      }
    });

    return PopScope(
      canPop: Navigator.of(context).canPop(),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onBack();
      },
      child: Scaffold(
        backgroundColor: context.backgroundColor,
        body: OrbitBackground(
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _Header(order: order, onBack: _onBack),
                Expanded(
                  child: order == null && state.isLoading
                      ? const OrderDetailSkeleton()
                      : order == null
                      ? Center(
                          child: Text(state.error ?? context.l10n.errorGeneric),
                        )
                      : CustomScrollView(
                          slivers: [OrderDetailScrollContent(order: order)],
                        ),
                ),
                if (order != null)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: context.backgroundColor.withValues(alpha: 0.96),
                      border: Border(
                        top: BorderSide(color: context.borderColor),
                      ),
                    ),
                    child: SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                          AppSpacing.xl,
                          AppSpacing.md,
                          AppSpacing.xl,
                          AppSpacing.md,
                        ),
                        child: OrderActionButtons(
                          orderId: widget.orderId,
                          order: order,
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

/// Orbit header: frosted back button, order number in mono, store and date
/// underneath, and the share action on the end.
class _Header extends StatelessWidget {
  const _Header({required this.order, required this.onBack});

  final OrderEntity? order;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final o = order;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          AuthBackButton(onPressed: onBack),
          const SizedBox(width: AppSpacing.md),
          if (o != null) ...[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${context.l10n.orderHashPrefix}${o.formattedOrderId}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.headlineSmall.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${o.vendorStoreName} · ${context.formatMediumDate(o.createdAt)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelMedium.copyWith(
                      color: context.labelColor,
                    ),
                  ),
                ],
              ),
            ),
            Material(
              color: context.glassColor,
              shape: CircleBorder(side: BorderSide(color: context.borderColor)),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  Share.share(
                    '${context.l10n.ordersShareSummary}\n${context.l10n.orderHashPrefix}${o.formattedOrderId}\n${orderStatusLabel(context, o.status)}\n${context.formatCurrency(o.total)}',
                  );
                },
                child: SizedBox.square(
                  dimension: 44,
                  child: Icon(
                    Icons.ios_share_rounded,
                    size: 20,
                    color: context.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
