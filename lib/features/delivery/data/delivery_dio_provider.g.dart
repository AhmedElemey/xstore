// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_dio_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$deliveryDioHash() => r'dc0b5ed66fc08a5b8969d692b72199799b54f2d8';

/// Dio client for the standalone delivery-backend service. Separate from
/// [dioProvider]: different host, and `Authorization: Bearer <token>` auth
/// (delivery-backend's own JWT — see [bridgeLoginToDeliveryBackend]) instead
/// of the marketplace's `X-Auth-Token` + Basic-license scheme.
///
/// Copied from [deliveryDio].
@ProviderFor(deliveryDio)
final deliveryDioProvider = Provider<Dio>.internal(
  deliveryDio,
  name: r'deliveryDioProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$deliveryDioHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DeliveryDioRef = ProviderRef<Dio>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
