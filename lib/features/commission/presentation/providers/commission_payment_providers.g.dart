// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commission_payment_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$commissionPaymentRepositoryHash() =>
    r'30731ea413a35cf2a0e2d9f09f35ea5c4dcbe017';

/// See also [commissionPaymentRepository].
@ProviderFor(commissionPaymentRepository)
final commissionPaymentRepositoryProvider =
    Provider<CommissionPaymentRepository>.internal(
  commissionPaymentRepository,
  name: r'commissionPaymentRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$commissionPaymentRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CommissionPaymentRepositoryRef
    = ProviderRef<CommissionPaymentRepository>;
String _$commissionPayToAccountsHash() =>
    r'465693058a372903195ff3e5de3dbe889430ffe0';

/// Pay-to accounts for the payment screens. A failed or missing setting
/// reads as "none configured" — the screen then tells the vendor to contact
/// support rather than blocking on an error state.
///
/// Copied from [commissionPayToAccounts].
@ProviderFor(commissionPayToAccounts)
final commissionPayToAccountsProvider =
    AutoDisposeFutureProvider<Map<CommissionPaymentMethod, String>>.internal(
  commissionPayToAccounts,
  name: r'commissionPayToAccountsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$commissionPayToAccountsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CommissionPayToAccountsRef
    = AutoDisposeFutureProviderRef<Map<CommissionPaymentMethod, String>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
