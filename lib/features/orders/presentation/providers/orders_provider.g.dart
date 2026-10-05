// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'orders_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$ordersNotifierHash() => r'41eb16134b5eac21305605904d937ca358de7ce6';

/// The consumer's My Orders list. Vendors never reach /orders (they use
/// VendorOrdersScreen and `vendorOrdersProvider`).
///
/// Copied from [OrdersNotifier].
@ProviderFor(OrdersNotifier)
final ordersNotifierProvider =
    NotifierProvider<OrdersNotifier, OrdersState>.internal(
  OrdersNotifier.new,
  name: r'ordersNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$ordersNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$OrdersNotifier = Notifier<OrdersState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
