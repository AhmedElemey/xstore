import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/route_reentry_refresh.dart';
import '../providers/orders_provider.dart';
import '../widgets/consumer_orders_view.dart';

/// The consumer's My Orders tab. Vendors are redirected off /orders and use
/// VendorOrdersScreen.
class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RouteReentryRefresh(
      isTarget: (location) => location == AppRoutes.orders,
      onReentry: (ref) => ref.read(ordersNotifierProvider.notifier).fetchOrders(),
      child: const ConsumerOrdersView(),
    );
  }
}
