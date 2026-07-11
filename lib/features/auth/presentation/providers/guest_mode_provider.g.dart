// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guest_mode_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$guestModeHash() => r'1543af565a7817f4daeafea64d8c423d2e5ad0ad';

/// Whether the user chose "Continue as Guest" instead of signing in.
///
/// Guests can browse (home, explore, product, seller pages) but every
/// account-bound route or action requires login — enforced centrally in
/// `computeXStoreAuthRedirect` and at action sites via `requireLogin`.
/// The flag persists across launches (same lazy-load pattern as
/// [AppThemeMode]) and is cleared as soon as a real session is adopted.
///
/// Copied from [GuestMode].
@ProviderFor(GuestMode)
final guestModeProvider = NotifierProvider<GuestMode, bool>.internal(
  GuestMode.new,
  name: r'guestModeProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$guestModeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$GuestMode = Notifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
