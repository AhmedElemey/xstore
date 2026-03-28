// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_detail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$orderDetailNotifierHash() =>
    r'e8a564fb821378d2d3dc012e14b4e04b21a3615e';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$OrderDetailNotifier
    extends BuildlessAutoDisposeNotifier<OrderDetailState> {
  late final String orderId;

  OrderDetailState build(
    String orderId,
  );
}

/// See also [OrderDetailNotifier].
@ProviderFor(OrderDetailNotifier)
const orderDetailNotifierProvider = OrderDetailNotifierFamily();

/// See also [OrderDetailNotifier].
class OrderDetailNotifierFamily extends Family<OrderDetailState> {
  /// See also [OrderDetailNotifier].
  const OrderDetailNotifierFamily();

  /// See also [OrderDetailNotifier].
  OrderDetailNotifierProvider call(
    String orderId,
  ) {
    return OrderDetailNotifierProvider(
      orderId,
    );
  }

  @override
  OrderDetailNotifierProvider getProviderOverride(
    covariant OrderDetailNotifierProvider provider,
  ) {
    return call(
      provider.orderId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'orderDetailNotifierProvider';
}

/// See also [OrderDetailNotifier].
class OrderDetailNotifierProvider extends AutoDisposeNotifierProviderImpl<
    OrderDetailNotifier, OrderDetailState> {
  /// See also [OrderDetailNotifier].
  OrderDetailNotifierProvider(
    String orderId,
  ) : this._internal(
          () => OrderDetailNotifier()..orderId = orderId,
          from: orderDetailNotifierProvider,
          name: r'orderDetailNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$orderDetailNotifierHash,
          dependencies: OrderDetailNotifierFamily._dependencies,
          allTransitiveDependencies:
              OrderDetailNotifierFamily._allTransitiveDependencies,
          orderId: orderId,
        );

  OrderDetailNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.orderId,
  }) : super.internal();

  final String orderId;

  @override
  OrderDetailState runNotifierBuild(
    covariant OrderDetailNotifier notifier,
  ) {
    return notifier.build(
      orderId,
    );
  }

  @override
  Override overrideWith(OrderDetailNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: OrderDetailNotifierProvider._internal(
        () => create()..orderId = orderId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        orderId: orderId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<OrderDetailNotifier, OrderDetailState>
      createElement() {
    return _OrderDetailNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is OrderDetailNotifierProvider && other.orderId == orderId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, orderId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin OrderDetailNotifierRef
    on AutoDisposeNotifierProviderRef<OrderDetailState> {
  /// The parameter `orderId` of this provider.
  String get orderId;
}

class _OrderDetailNotifierProviderElement
    extends AutoDisposeNotifierProviderElement<OrderDetailNotifier,
        OrderDetailState> with OrderDetailNotifierRef {
  _OrderDetailNotifierProviderElement(super.provider);

  @override
  String get orderId => (origin as OrderDetailNotifierProvider).orderId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
