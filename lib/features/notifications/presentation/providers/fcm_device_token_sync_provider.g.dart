// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fcm_device_token_sync_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$fcmDeviceTokenSyncHash() =>
    r'66389d874c90c63d6c47b62ceb084ae90259a18f';

/// Subscribes to [FirebaseMessaging.onTokenRefresh] for the app lifetime.
/// Best-effort: devices without Google Play Services (common in the target
/// market) can throw here — that must never take down auth session restore,
/// which reads this provider from `Auth.build()`.
///
/// Copied from [fcmDeviceTokenSync].
@ProviderFor(fcmDeviceTokenSync)
final fcmDeviceTokenSyncProvider = Provider<void>.internal(
  fcmDeviceTokenSync,
  name: r'fcmDeviceTokenSyncProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$fcmDeviceTokenSyncHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FcmDeviceTokenSyncRef = ProviderRef<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
