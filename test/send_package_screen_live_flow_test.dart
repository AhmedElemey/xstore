// Screen-level, LIVE-mode test of the real SendPackageScreen — a real
// consumer requesting a courier pickup, not fixture data. Matches
// test/edit_profile_screen_live_flow_test.dart's established pattern:
// real screen + real DeliveryRequestRepositoryImpl ->
// DeliveryRequestRemoteDataSource chain, only the Dio HTTP transport is
// scripted.
//
// Delivery uses its OWN Dio client (`deliveryDioProvider`, a different
// host/auth scheme from the marketplace `dioProvider` — see
// delivery_dio_provider.dart's doc comment), so the scripted Dio is wired
// there instead. The mock/live split for this feature isn't a MockConfig
// branch inside one datasource class (like every other screen this
// session) — it's a DIFFERENT datasource class picked by
// delivery_request_dependencies.dart's own `MockConfig.useMock` check
// (DeliveryRequestMockDataSource vs DeliveryRequestRemoteDataSource), so
// this test still needs `skip: MockConfig.useMock` to only run against
// the real one.
//
// Run with: flutter test test/send_package_screen_live_flow_test.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/core/mock/mock_config.dart';
import 'package:xstore/core/network/delivery_api_endpoints.dart';
import 'package:xstore/core/router/app_routes.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/delivery/data/delivery_dio_provider.dart';
import 'package:xstore/features/delivery/presentation/screens/send_package_screen.dart';

import 'helpers/fake_async_auth_notifier.dart';

/// Routes each request by (method, path) to a scripted response — same
/// technique as edit_profile_screen_live_flow_test.dart's
/// `_RoutedInterceptor`.
class _RoutedInterceptor extends Interceptor {
  _RoutedInterceptor(this._routes);

  final Map<String, Object? Function(RequestOptions options)> _routes;

  String _key(RequestOptions o) => '${o.method} ${o.path}';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final route = _routes[_key(options)];
    if (route == null) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: StateError('unscripted request: ${_key(options)}'),
        ),
      );
      return;
    }
    final result = route(options);
    if (result is DioException) {
      handler.reject(result);
    } else {
      handler.resolve(
        Response(requestOptions: options, statusCode: 200, data: result),
      );
    }
  }
}

Dio _fakeDio(Map<String, Object? Function(RequestOptions)> routes) {
  final d = Dio(BaseOptions(baseUrl: DeliveryApiEndpoints.baseUrl));
  d.interceptors.add(_RoutedInterceptor(routes));
  return d;
}

UserEntity _consumer() => const UserEntity(
  id: 'consumer_1',
  name: 'Test Buyer',
  email: 'buyer@test.com',
  phoneNumber: '01012345678',
);

Widget _routedHarness(List<Override> overrides) {
  final router = GoRouter(
    initialLocation: AppRoutes.sendPackage,
    routes: [
      GoRoute(
        path: AppRoutes.sendPackage,
        builder: (_, __) => const SendPackageScreen(),
      ),
      GoRoute(
        path: AppRoutes.myPackages,
        builder: (_, __) => const Scaffold(body: Text('My Packages Screen')),
      ),
    ],
  );
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
}

/// Bounded frame pump instead of `pumpAndSettle()` — matches the
/// established convention from edit_profile_screen_live_flow_test.dart.
Future<void> _settle(
  WidgetTester tester, {
  int times = 15,
  Duration step = const Duration(milliseconds: 100),
}) async {
  for (var i = 0; i < times; i++) {
    await tester.pump(step);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  testWidgets(
    'consumer submits a live package pickup request',
    // The mock/live split here is a whole different datasource class
    // (DeliveryRequestMockDataSource vs ...RemoteDataSource), not a
    // MockConfig branch inside one — this test only exercises the real
    // remote datasource.
    skip: MockConfig.useMock,
    (tester) async {
      final dio = _fakeDio({
        'POST ${DeliveryApiEndpoints.deliveryRequests}': (_) => {
          'id': 'req_1',
          'consumerId': 'consumer_1',
          'consumerName': 'Test Buyer',
          'consumerPhone': '01012345678',
          'status': 'submitted',
        },
      });

      await tester.pumpWidget(
        _routedHarness([
          authProvider.overrideWith(() => FakeAuth(_consumer())),
          deliveryDioProvider.overrideWithValue(dio),
        ]),
      );
      await _settle(tester);

      // Both PhoneInputField and every other field on this form render as
      // a TextFormField, so every field — including the two phone ones —
      // is addressed by position in this single list: [senderName,
      // senderPhone, pickupStreet, pickupCity, recipientName,
      // recipientPhone, dropoffStreet, dropoffCity, note].
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Test Buyer');
      await tester.enterText(fields.at(1), '01012345678');
      await tester.enterText(fields.at(2), 'Street 1');
      await tester.enterText(fields.at(3), 'Cairo');
      await tester.enterText(fields.at(4), 'Test Recipient');
      await tester.enterText(fields.at(5), '01098765432');
      await tester.enterText(fields.at(6), 'Street 2');
      await tester.enterText(fields.at(7), 'Giza');
      await tester.enterText(fields.at(8), 'A small box');
      await tester.pump();

      // The submit button sits below the fold of this long form.
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -600),
      );
      await tester.pump();

      await tester.tap(find.text('Request delivery'));
      await _settle(tester);

      expect(
        find.text("Request sent — we'll send you the price shortly"),
        findsOneWidget,
      );
      expect(find.text('My Packages Screen'), findsOneWidget);
    },
  );
}
