import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xstore/core/error/failures.dart';
import 'package:xstore/core/localization/app_localizations_en.dart';
import 'package:xstore/core/router/app_routes.dart';
import 'package:xstore/core/router/router_notifier.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/cart/domain/entities/place_order_params.dart';
import 'package:xstore/features/cart/presentation/providers/cart_dependencies.dart';
import 'package:xstore/features/cart/presentation/providers/cart_provider.dart';
import 'package:xstore/features/orders/domain/entities/order_entity.dart';
import 'package:xstore/features/orders/presentation/providers/orders_dependencies.dart';
import 'package:xstore/features/orders/presentation/providers/orders_provider.dart';
import 'helpers/fake_async_auth_notifier.dart';
import 'helpers/stub_auth_repository.dart';
import 'helpers/stub_cart_repository.dart';
import 'helpers/stub_orders_repository.dart';

UserEntity _consumer() => UserEntity(
      id: 'c1',
      name: 'Buyer',
      email: 'buyer@test.com',
      phoneNumber: '01011111111',
    );

UserEntity _vendor() => UserEntity(
      id: 'v99',
      name: 'Ven',
      email: 'v@test.com',
      phoneNumber: '01099999999',
      role: UserRole.vendor,
    );

PlaceOrderParams _dummyCheckout(String consumerId) => PlaceOrderParams(
      consumerId: consumerId,
      items: const [],
      deliveryAddress: const OrderAddress(
        fullName: 'x',
        phone: '010',
        street: '-',
        city: 'city',
        wilaya: 'w',
      ),
      paymentMethod: PaymentMethod.cashOnDelivery,
      subtotal: 0,
      shippingTotal: 0,
      discount: 0,
      total: 0,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('computeXStoreAuthRedirect', () {
    test('unauthenticated routes to login from protected screens', () {
      expect(
        computeXStoreAuthRedirect(
          auth: const AsyncValue.data(null),
          needsRoleSelection: false,
          matchedLocation: AppRoutes.home,
        ),
        AppRoutes.login,
      );
    });

    test('authenticated user leaves login for home', () {
      expect(
        computeXStoreAuthRedirect(
          auth: AsyncValue.data(_consumer()),
          needsRoleSelection: false,
          matchedLocation: AppRoutes.login,
        ),
        AppRoutes.home,
      );
    });

    test('loading leaves redirect deferred', () {
      expect(
        computeXStoreAuthRedirect(
          auth: const AsyncValue.loading(),
          needsRoleSelection: false,
          matchedLocation: AppRoutes.home,
        ),
        isNull,
      );
    });

    test('provider error aligns with logout redirect semantics', () {
      expect(
        computeXStoreAuthRedirect(
          auth: AsyncValue.error('401', StackTrace.empty),
          needsRoleSelection: false,
          matchedLocation: AppRoutes.wishlist,
        ),
        AppRoutes.login,
      );
    });
  });

  group('provider failures', () {
    test('login failure exposes failure string on notifier', () async {
      final l10n = AppLocalizationsEn();
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWith((ref) {
            return StubAuthRepository(
              loginResult: Left(Failure.network('no connection')),
            );
          }),
          authProvider.overrideWith(() => FakeAuth(null)),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authProvider.future);

      container.read(loginNotifierProvider.notifier)
        ..updateEmail('buyer@test.com')
        ..updatePassword('secret12');
      await container.read(loginNotifierProvider.notifier).login(l10n);

      expect(
        container.read(loginNotifierProvider).error,
        Failure.network('no connection').toString(),
      );
    });

    test('register failure after valid wizard leaves error populated', () async {
      final l10n = AppLocalizationsEn();
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWith((ref) {
            return StubAuthRepository(
              restoreUser: null,
              registerResult: Left(Failure.server('signup failed')),
            );
          }),
          authProvider.overrideWith(() => FakeAuth(null)),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authProvider.future);

      final rn = container.read(registerNotifierProvider.notifier)..reset();
      rn.updateRole(UserRole.consumer);
      expect(rn.nextStep(l10n), true);
      rn.updateField(
        fullName: 'Jane Doe',
        email: 'jane@test.com',
        phoneNumber: '01012345678',
        location: 'Cairo',
      );
      expect(rn.nextStep(l10n), true);

      rn.updatePasswordFields('Password1!');
      rn.updateConfirmPassword('Password1!');
      if (!rn.state.agreedToTerms) {
        rn.toggleAgreedToTerms();
      }

      await rn.submitFromCurrentStep(l10n);

      expect(
        container.read(registerNotifierProvider).error,
        Failure.server('signup failed').toString(),
      );
    });

    test('cart addFromListing surfaces repository failure', () async {
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith(() => FakeAuth(_consumer())),
          cartRepositoryProvider.overrideWith((ref) {
            return StubCartRepository(
              addFromListingResult: ({
                required String consumerId,
                required String listingId,
                required int quantity,
              }) =>
                  Left(Failure.network('cart add failed')),
            );
          }),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authProvider.future);

      await container.read(cartProvider.notifier).addFromListing(
            listingId: 'lst1',
            quantity: 1,
          );

      expect(
        container.read(cartProvider).error,
        Failure.network('cart add failed').toString(),
      );
    });

    test('cart placeOrder failure records error without throwing', () async {
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith(() => FakeAuth(_consumer())),
          cartRepositoryProvider.overrideWith((ref) {
            return StubCartRepository(
              placeOrderResult: (_) =>
                  Left(Failure.server('cannot place')),
            );
          }),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authProvider.future);

      await container.read(cartProvider.notifier).placeOrder(
            _dummyCheckout('c1'),
          );

      expect(
        container.read(cartProvider).error,
        Failure.server('cannot place').toString(),
      );
    });

    test('consumer orders fetch failure sets error', () async {
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith(() => FakeAuth(_consumer())),
          ordersRepositoryProvider.overrideWith((ref) {
            return StubOrdersRepository(
              getConsumerOrdersResult: ({
                required String consumerId,
                required int page,
                required int pageSize,
              }) =>
                  Left(Failure.network('orders down')),
            );
          }),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authProvider.future);

      await container.read(ordersNotifierProvider.notifier).fetchOrders();

      expect(
        container.read(ordersNotifierProvider).error,
        Failure.network('orders down').toString(),
      );
    });

    test('vendor confirm order failure stores error', () async {
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith(() => FakeAuth(_vendor())),
          ordersRepositoryProvider.overrideWith((ref) {
            return StubOrdersRepository(
              confirmOrderResult: (_) =>
                  Left(Failure.server('confirm failed')),
            );
          }),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authProvider.future);

      await container
          .read(ordersNotifierProvider.notifier)
          .confirmOrderVendor('order_x');

      expect(
        container.read(ordersNotifierProvider).error,
        Failure.server('confirm failed').toString(),
      );
    });
  });
}
