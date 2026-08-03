// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_error_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$serverErrorHash() => r'5c0433954458d5a47ab1167d06bc462e1663d68d';

/// Set when any API response comes back with an HTTP 5xx status, or when
/// several 404s land in a short burst (see the error interceptor in
/// `dio_provider.dart` — a lone 404 is normal app behavior, e.g. OTP for an
/// unregistered phone, and must not trigger this). While true, the router
/// redirects every route to [AppRoutes.serverError] instead of letting the
/// failing screen render its own inline error, and clears when the user
/// retries from that screen.
///
/// Copied from [ServerError].
@ProviderFor(ServerError)
final serverErrorProvider = NotifierProvider<ServerError, bool>.internal(
  ServerError.new,
  name: r'serverErrorProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$serverErrorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ServerError = Notifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
