import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/orders_provider.dart';
import '../widgets/consumer_orders_view.dart';
import '../widgets/vendor_orders_view.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  GoRouterDelegate? _delegate;
  var _onThisRoute = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final router = GoRouter.maybeOf(context);
    final next = router?.routerDelegate;
    if (identical(next, _delegate)) return;
    _delegate?.removeListener(_onRoute);
    _delegate = next;
    _delegate?.addListener(_onRoute);
    // Seed so the first listener tick (already on this path) does not
    // double-fetch with the child view's initState load.
    _onThisRoute = _isThisRoute(router);
  }

  @override
  void dispose() {
    _delegate?.removeListener(_onRoute);
    super.dispose();
  }

  bool _isThisRoute(GoRouter? router) {
    if (router == null) return false;
    final path = router.routerDelegate.currentConfiguration.uri.path;
    return path == AppRoutes.orders || path == AppRoutes.incomingOrders;
  }

  void _onRoute() {
    if (!mounted) return;
    final router = GoRouter.maybeOf(context);
    final now = _isThisRoute(router);
    if (now && !_onThisRoute) {
      ref.read(ordersNotifierProvider.notifier).fetchOrders();
    }
    _onThisRoute = now;
  }

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(
      authProvider.select((a) => a.valueOrNull?.role ?? UserRole.consumer),
    );
    if (role == UserRole.vendor) return const VendorOrdersView();
    return const ConsumerOrdersView();
  }
}
