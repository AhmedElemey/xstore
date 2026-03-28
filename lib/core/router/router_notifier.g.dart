// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'router_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$routerNotifierHash() => r'23b4308e42eecac7df5e6226dadc7624cf7f04ac';

/// Bridges auth state to [GoRouter] via [Listenable] for `refreshListenable`.
///
/// Auth-based redirects (including vendor route guard) are centralized in
/// [computeXStoreAuthRedirect] so they live next to this notifier, which
/// [watch]es [authProvider] and notifies the router when session changes.
///
/// Copied from [routerNotifier].
@ProviderFor(routerNotifier)
final routerNotifierProvider = Provider<RouterNotifier>.internal(
  routerNotifier,
  name: r'routerNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$routerNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef RouterNotifierRef = ProviderRef<RouterNotifier>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
