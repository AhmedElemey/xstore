// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address_book_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$addressBookHash() => r'935b17889acbc6d52519f744e87ccdf035987b33';

/// Single source of truth for a consumer's saved delivery addresses,
/// shared by the Profile "My Addresses" screen and checkout's address step
/// (`checkout_provider.dart`) so an edit made from either place is
/// immediately visible from the other without waiting for a fresh app
/// launch. No backend address book exists yet (order placement only ever
/// takes GPS coordinates), so this stays local, persisted to
/// SharedPreferences per signed-in consumer — the exact mechanism checkout
/// used before this provider existed, kept under the same storage key so
/// addresses saved before this feature shipped are not lost.
///
/// Copied from [AddressBook].
@ProviderFor(AddressBook)
final addressBookProvider =
    NotifierProvider<AddressBook, List<OrderAddress>>.internal(
  AddressBook.new,
  name: r'addressBookProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$addressBookHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AddressBook = Notifier<List<OrderAddress>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
