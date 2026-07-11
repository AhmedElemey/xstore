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

    test('consumer is blocked from every vendor-only route', () {
      for (final loc in [
        AppRoutes.listingAdd,
        AppRoutes.listingMy,
        AppRoutes.vendorOrders,
        '${AppRoutes.vendorOrders}/ord_1',
        AppRoutes.incomingOrders,
        AppRoutes.storeHours,
        AppRoutes.earnings,
        AppRoutes.analytics,
      ]) {
        expect(
          computeXStoreAuthRedirect(
            auth: AsyncValue.data(_consumer()),
            needsRoleSelection: false,
            matchedLocation: loc,
          ),
          AppRoutes.home,
          reason: 'consumer should be redirected from $loc',
        );
      }
    });

    test('vendor is blocked from every consumer-only route', () {
      for (final loc in [
        AppRoutes.cart,
        AppRoutes.checkout,
        AppRoutes.wishlist,
        AppRoutes.orders,
      ]) {
        expect(
          computeXStoreAuthRedirect(
            auth: AsyncValue.data(_vendor()),
            needsRoleSelection: false,
            matchedLocation: loc,
          ),
          AppRoutes.home,
          reason: 'vendor should be redirected from $loc',
        );
      }
    });

    test('guest may browse marketplace routes', () {
      for (final loc in [
        AppRoutes.home,
        AppRoutes.explore,
        '${AppRoutes.product}/lst_1',
        '${AppRoutes.product}/lst_1/reviews',
        '${AppRoutes.sellerProfile}/v99',
        AppRoutes.help,
        AppRoutes.login, // guest can always go sign in for real
      ]) {
        expect(
          computeXStoreAuthRedirect(
            auth: const AsyncValue.data(null),
            needsRoleSelection: false,
            matchedLocation: loc,
            isGuest: true,
          ),
          isNull,
          reason: 'guest should be allowed at $loc',
        );
      }
    });

    test('guest is sent to login from account-bound routes', () {
      for (final loc in [
        AppRoutes.cart,
        AppRoutes.checkout,
        AppRoutes.wishlist,
        AppRoutes.orders,
        AppRoutes.profile,
        AppRoutes.notifications,
        AppRoutes.listingAdd,
        AppRoutes.vendorOrders,
      ]) {
        expect(
          computeXStoreAuthRedirect(
            auth: const AsyncValue.data(null),
            needsRoleSelection: false,
            matchedLocation: loc,
            isGuest: true,
          ),
          AppRoutes.login,
          reason: 'guest should be redirected to login from $loc',
        );
      }
    });

    test('non-guest unauthenticated user still lands on login', () {
      expect(
        computeXStoreAuthRedirect(
          auth: const AsyncValue.data(null),
          needsRoleSelection: false,
          matchedLocation: AppRoutes.home,
          isGuest: false,
        ),
        AppRoutes.login,
      );
    });

    test('each role passes its own areas and shared routes', () {
      for (final (user, loc) in [
        (_vendor(), AppRoutes.listingAdd),
        (_vendor(), AppRoutes.storeHours),
        (_vendor(), AppRoutes.incomingOrders),
        // Vendors open consumer order detail via incoming orders.
        (_vendor(), AppRoutes.orderPath('ord_1')),
        (_consumer(), AppRoutes.cart),
        (_consumer(), AppRoutes.checkout),
        (_consumer(), AppRoutes.orderPath('ord_1')),
        (_consumer(), AppRoutes.profile),
        (_vendor(), AppRoutes.profile),
      ]) {
        expect(
          computeXStoreAuthRedirect(
            auth: AsyncValue.data(user),
            needsRoleSelection: false,
            matchedLocation: loc,
          ),
          isNull,
          reason: '${user.role} should be allowed at $loc',
        );
      }
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
              registerConsumerResult: Left(Failure.server('signup failed')),
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
        fullNameAr: 'جين دو',
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
