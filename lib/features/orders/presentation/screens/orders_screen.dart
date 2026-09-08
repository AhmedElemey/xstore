import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/route_reentry_refresh.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/orders_provider.dart';
import '../widgets/consumer_orders_view.dart';
import '../widgets/vendor_orders_view.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(
      authProvider.select((a) => a.valueOrNull?.role ?? UserRole.consumer),
    );
    return RouteReentryRefresh(
      isTarget: (location) =>
          location == AppRoutes.orders || location == AppRoutes.incomingOrders,
      onReentry: (ref) => ref.read(ordersNotifierProvider.notifier).fetchOrders(),
      child: role == UserRole.vendor
          ? const VendorOrdersView()
          : const ConsumerOrdersView(),
    );
  }
}
