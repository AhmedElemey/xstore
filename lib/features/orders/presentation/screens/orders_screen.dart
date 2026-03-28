import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/consumer_orders_view.dart';
import '../widgets/vendor_orders_view.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(authProvider).valueOrNull?.role ?? UserRole.consumer;
    if (role == UserRole.vendor) return const VendorOrdersView();
    return const ConsumerOrdersView();
  }
}
