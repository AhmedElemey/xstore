import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../providers/order_detail_provider.dart';
import '../widgets/order_action_buttons.dart';
import '../../domain/entities/order_entity.dart';
import '../widgets/order_detail_scroll_content.dart';
import '../widgets/order_status_badge.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_snackbar.dart';
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
      ref.read(orderDetailNotifierProvider(widget.orderId).notifier).fetchOrder();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderDetailNotifierProvider(widget.orderId));
    final order = state.order;

    ref.listen(orderDetailNotifierProvider(widget.orderId), (p, n) {
      final err = n.error;
      if (err != null && err != p?.error && context.mounted) {
        AppSnackbar.error(context, err);
        ref.read(orderDetailNotifierProvider(widget.orderId).notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: order == null && state.isLoading
          ? const OrderDetailSkeleton()
          : order == null
              ? Center(child: Text(state.error ?? context.l10n.errorGeneric))
              : Column(
                  children: [
                    Expanded(
                      child: CustomScrollView(
                        slivers: [
                          SliverAppBar(
                            pinned: true,
                            elevation: 0,
                            backgroundColor: context.surfaceColor,
                            title: Text(
                              '${context.l10n.orderHashPrefix}${order.formattedOrderId}',
                              style: AppTypography.titleMedium,
                            ),
                            actions: [
                              IconButton(
                                icon: const Icon(Icons.ios_share_rounded),
                                onPressed: () {
                                  Share.share(
                                    '${context.l10n.ordersShareSummary}\n${context.l10n.orderHashPrefix}${order.formattedOrderId}\n${orderStatusLabel(context, order.status)}\n${order.total} ${context.l10n.currencyDzd}',
                                  );
                                },
                              ),
                            ],
                          ),
                          OrderDetailScrollContent(order: order),
                        ],
                      ),
                    ),
                    SafeArea(
                      top: false,
                      child: Material(
                        elevation: 8,
                        color: context.surfaceColor,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.lg,
                            AppSpacing.md,
                            AppSpacing.lg,
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
    );
  }
}
