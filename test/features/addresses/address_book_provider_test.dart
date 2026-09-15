// Tests for AddressBook (address_book_provider.dart) — the shared local
// address book behind both the Profile "My Addresses" screen and
// checkout's address step. There is no backend address book yet (see
// checkout_address_persistence_test.dart's header for the fuller context),
// so these addresses are kept in SharedPreferences, scoped per signed-in
// consumer, under the same storage key checkout used before this provider
// existed.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:xstore/features/addresses/presentation/providers/address_book_provider.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/orders/domain/entities/order_entity.dart';

UserEntity _user(String id) => UserEntity(
  id: id,
  name: 'Test Buyer',
  email: 'buyer@test.com',
  phoneNumber: '01012345678',
);

OrderAddress _address({String fullName = 'Jane Doe', bool isDefault = false}) =>
    OrderAddress(
      fullName: fullName,
      phone: '01012345678',
      street: '1 Test Street',
      city: 'Cairo',
      wilaya: 'Cairo',
      isDefault: isDefault,
    );

class _FakeAuth extends Auth {
  _FakeAuth(this._user);
  final UserEntity? _user;
  @override
  Future<UserEntity?> build() async => _user;
}

/// Mirrors checkout_address_persistence_test.dart's `_buildContainer`:
/// awaiting auth's own resolution before returning means every test starts
/// from a container whose AddressBook has already had its initial
/// loading→data auth transition settle, instead of racing it.
Future<ProviderContainer> _buildContainer(String consumerId) async {
  final container = ProviderContainer(
    overrides: [authProvider.overrideWith(() => _FakeAuth(_user(consumerId)))],
  );
  addTearDown(container.dispose);
  container.listen(addressBookProvider, (_, __) {});
  await container.read(authProvider.future);
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('starts empty for a fresh consumer', () async {
    final container = await _buildContainer('consumer_1');
    expect(container.read(addressBookProvider), isEmpty);
  });

  test('the first address added becomes main even if not requested', () async {
    final container = await _buildContainer('consumer_1');
    container.read(addressBookProvider.notifier).addAddress(_address());

    final list = container.read(addressBookProvider);
    expect(list, hasLength(1));
    expect(list.single.isDefault, isTrue);
  });

  test('marking a new address main clears the previous one', () async {
    final container = await _buildContainer('consumer_1');
    final notifier = container.read(addressBookProvider.notifier);
    notifier.addAddress(_address(fullName: 'Home', isDefault: true));
    notifier.addAddress(_address(fullName: 'Work', isDefault: true));

    final list = container.read(addressBookProvider);
    expect(list.where((a) => a.isDefault), hasLength(1));
    expect(list.firstWhere((a) => a.isDefault).fullName, 'Work');
  });

  test('setMainAddress moves the main flag without adding or removing entries', () async {
    final container = await _buildContainer('consumer_1');
    final notifier = container.read(addressBookProvider.notifier);
    notifier.addAddress(_address(fullName: 'Home'));
    notifier.addAddress(_address(fullName: 'Work'));

    notifier.setMainAddress(1);

    final list = container.read(addressBookProvider);
    expect(list, hasLength(2));
    expect(list[0].isDefault, isFalse);
    expect(list[1].isDefault, isTrue);
  });

  test('removing the main address promotes another one instead of leaving none', () async {
    final container = await _buildContainer('consumer_1');
    final notifier = container.read(addressBookProvider.notifier);
    notifier.addAddress(_address(fullName: 'Home', isDefault: true));
    notifier.addAddress(_address(fullName: 'Work'));

    notifier.removeAddress(0);

    final list = container.read(addressBookProvider);
    expect(list, hasLength(1));
    expect(list.single.fullName, 'Work');
    expect(list.single.isDefault, isTrue);
  });

  test('removing the only address leaves the book honestly empty', () async {
    final container = await _buildContainer('consumer_1');
    final notifier = container.read(addressBookProvider.notifier);
    notifier.addAddress(_address());

    notifier.removeAddress(0);

    expect(container.read(addressBookProvider), isEmpty);
  });

  test('addAddress refuses a 6th address and leaves the book at 5', () async {
    final container = await _buildContainer('consumer_1');
    final notifier = container.read(addressBookProvider.notifier);
    for (var i = 0; i < AddressBook.maxAddresses; i++) {
      final added = notifier.addAddress(_address(fullName: 'Addr $i'));
      expect(added, isTrue);
    }
    expect(container.read(addressBookProvider), hasLength(5));

    final added = notifier.addAddress(_address(fullName: 'One too many'));

    expect(added, isFalse);
    expect(container.read(addressBookProvider), hasLength(5));
    expect(
      container.read(addressBookProvider).any((a) => a.fullName == 'One too many'),
      isFalse,
    );
  });

  test('addAddress persists locally and a fresh notifier loads it back', () async {
    final container = await _buildContainer('consumer_1');
    container.read(addressBookProvider.notifier).addAddress(_address());
    // Let the fire-and-forget SharedPreferences write complete.
    await Future<void>.delayed(Duration.zero);

    final reopened = await _buildContainer('consumer_1');
    await Future<void>.delayed(Duration.zero);

    expect(reopened.read(addressBookProvider), hasLength(1));
    expect(reopened.read(addressBookProvider).single.fullName, 'Jane Doe');
  });

  test("one consumer's addresses are never shown to another", () async {
    final first = await _buildContainer('consumer_1');
    first.read(addressBookProvider.notifier).addAddress(_address());
    await Future<void>.delayed(Duration.zero);

    final second = await _buildContainer('consumer_2');
    await Future<void>.delayed(Duration.zero);

    expect(second.read(addressBookProvider), isEmpty);
  });
}
