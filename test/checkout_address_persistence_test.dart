// Tests for Checkout's local address-book persistence (checkout_provider
// .dart). There is no backend address book — order placement only ever
// takes GPS coordinates (see checkout_order_flow_test.dart's header) — so
// saved delivery addresses are kept in SharedPreferences, scoped per
// signed-in consumer, instead of being seeded with sample data and thrown
// away when the checkout screen is popped.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:xstore/core/analytics/analytics_service.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/cart/presentation/providers/cart_provider.dart';
import 'package:xstore/features/cart/presentation/providers/cart_state.dart';
import 'package:xstore/features/cart/presentation/providers/checkout_provider.dart';
import 'package:xstore/features/orders/domain/entities/order_entity.dart';

UserEntity _user(String id) => UserEntity(
      id: id,
      name: 'Test Buyer',
      email: 'buyer@test.com',
      phoneNumber: '01012345678',
    );

OrderAddress _address({
  String fullName = 'Jane Doe',
  bool isDefault = false,
}) =>
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

/// Cart's real `build()` schedules a live `fetchCart()` network call once
/// auth resolves — irrelevant to address persistence and unsafe to let run
/// against a real (unmocked) Dio in a unit test, so it's replaced with an
/// inert stand-in here.
class _InertCart extends Cart {
  @override
  CartState build() => const CartState();
}

/// Mirrors checkout_order_flow_test.dart's `_buildContainer`: waits for
/// AnalyticsService's async init to finish registering its own listener
/// before returning. Without this, `_init()` can still be mid-flight when
/// the test body returns and `addTearDown` disposes the container, so it
/// resumes on an already-disposed container and throws into whichever
/// test happens to run next.
Future<ProviderContainer> _buildContainer(String consumerId) async {
  final container = ProviderContainer(
    overrides: [
      authProvider.overrideWith(() => _FakeAuth(_user(consumerId))),
      cartProvider.overrideWith(() => _InertCart()),
    ],
  );
  addTearDown(container.dispose);
  container.listen(checkoutProvider, (_, __) {});
  await container.read(analyticsServiceProvider).ready;
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('starts with no saved addresses instead of a fake seeded one',
      () async {
    final container = await _buildContainer('consumer_1');

    expect(container.read(checkoutProvider).savedAddresses, isEmpty);
    expect(container.read(checkoutProvider).selectedAddressIndex, isNull);
  });

  test('addAddress survives a rebuild of the notifier (persists locally)',
      () async {
    final container = await _buildContainer('consumer_1');
    container
        .read(checkoutProvider.notifier)
        .addAddress(_address(fullName: 'Jane Doe'));
    expect(container.read(checkoutProvider).savedAddresses, hasLength(1));
    // Let the fire-and-forget SharedPreferences write complete.
    await Future<void>.delayed(Duration.zero);

    // A fresh notifier instance (e.g. reopening checkout) must load the
    // same address back from local storage instead of starting empty.
    final reopened = await _buildContainer('consumer_1');
    await Future<void>.delayed(Duration.zero);

    expect(reopened.read(checkoutProvider).savedAddresses, hasLength(1));
    expect(
      reopened.read(checkoutProvider).savedAddresses.single.fullName,
      'Jane Doe',
    );
    expect(reopened.read(checkoutProvider).selectedAddressIndex, 0);
  });

  test("one consumer's saved addresses are never shown to another",
      () async {
    final first = await _buildContainer('consumer_1');
    first.read(checkoutProvider.notifier).addAddress(_address(fullName: 'Jane Doe'));
    await Future<void>.delayed(Duration.zero);

    final second = await _buildContainer('consumer_2');
    await Future<void>.delayed(Duration.zero);

    expect(second.read(checkoutProvider).savedAddresses, isEmpty);
  });

  test('updateAddress replaces the entry in place and keeps it selected',
      () async {
    final container = await _buildContainer('consumer_1');
    final notifier = container.read(checkoutProvider.notifier);
    notifier.addAddress(_address(fullName: 'Jane Doe'));
    notifier.updateAddress(0, _address(fullName: 'Jane Updated'));

    final state = container.read(checkoutProvider);
    expect(state.savedAddresses, hasLength(1));
    expect(state.savedAddresses.single.fullName, 'Jane Updated');
    expect(state.selectedAddressIndex, 0);
  });

  test('marking a new address default clears the previous default', () async {
    final container = await _buildContainer('consumer_1');
    final notifier = container.read(checkoutProvider.notifier);
    notifier.addAddress(_address(fullName: 'Home', isDefault: true));
    notifier.addAddress(_address(fullName: 'Work', isDefault: true));

    final addresses = container.read(checkoutProvider).savedAddresses;
    expect(addresses.where((a) => a.isDefault), hasLength(1));
    expect(addresses.firstWhere((a) => a.isDefault).fullName, 'Work');
  });

  test('removeAddress drops the entry and re-selects sensibly', () async {
    final container = await _buildContainer('consumer_1');
    final notifier = container.read(checkoutProvider.notifier);
    notifier.addAddress(_address(fullName: 'Home'));
    notifier.addAddress(_address(fullName: 'Work'));
    notifier.selectAddress(1);

    notifier.removeAddress(1);

    final state = container.read(checkoutProvider);
    expect(state.savedAddresses, hasLength(1));
    expect(state.savedAddresses.single.fullName, 'Home');
    expect(state.selectedAddressIndex, 0);
  });

  test('removing the last address leaves the list honestly empty, not reseeded',
      () async {
    final container = await _buildContainer('consumer_1');
    final notifier = container.read(checkoutProvider.notifier);
    notifier.addAddress(_address());

    notifier.removeAddress(0);

    final state = container.read(checkoutProvider);
    expect(state.savedAddresses, isEmpty);
    expect(state.selectedAddressIndex, isNull);
  });
}
