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
    r'260ff4ec91e7fabc65efe25adc9b03b126d49f79';

/// Pay-to accounts for the payment screens, derived from the cached General
/// Settings. Blank handles are left out ("not set up"). With a cache this is
/// always data; the error state is a failed first-launch fetch (Retry
/// re-runs [generalSettingsProvider]).
///
/// Copied from [commissionPayToAccounts].
@ProviderFor(commissionPayToAccounts)
final commissionPayToAccountsProvider = AutoDisposeProvider<
    AsyncValue<Map<CommissionPaymentMethod, String>>>.internal(
  commissionPayToAccounts,
  name: r'commissionPayToAccountsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$commissionPayToAccountsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CommissionPayToAccountsRef
    = AutoDisposeProviderRef<AsyncValue<Map<CommissionPaymentMethod, String>>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
