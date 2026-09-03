// Screen-level, LIVE-mode test of the real MyPackageRequestsScreen — a
// real consumer viewing and confirming their package delivery requests,
// not fixture data. Matches test/send_package_screen_live_flow_test.dart's
// established pattern: real screen + real DeliveryRequestRepositoryImpl ->
// DeliveryRequestRemoteDataSource chain, on delivery's own Dio client
// (`deliveryDioProvider`), only the transport is scripted.
//
// Delivery's mock/live split is a whole different datasource class picked
// at the provider level (DeliveryRequestMockDataSource vs
// ...RemoteDataSource) — see the 2026-09-03 lesson in
// flutter-review/SKILL.md — so this needs `skip: MockConfig.useMock` even
// though the remote datasource itself has no MockConfig branch.
//
// initState fires fetchRequests() via a postFrameCallback that reads
// authProvider synchronously (valueOrNull) — the standard auth-race this
// session works around with `_pumpReady`.
//
// Run with: flutter test test/my_package_requests_screen_live_flow_test.dart
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/core/mock/mock_config.dart';
import 'package:xstore/core/network/delivery_api_endpoints.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/delivery/data/delivery_dio_provider.dart';
import 'package:xstore/features/delivery/presentation/providers/delivery_requests_provider.dart';
import 'package:xstore/features/delivery/presentation/screens/my_package_requests_screen.dart';

import 'helpers/fake_async_auth_notifier.dart';

/// Routes each request by (method, path) to a scripted response — same
/// technique as send_package_screen_live_flow_test.dart's
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

Map<String, dynamic> _addressJson({
  String street = 'Street 1',
  String city = 'Cairo',
}) => {
  'fullName': 'Test Buyer',
  'phone': '01012345678',
  'street': street,
  'city': city,
  'wilaya': 'Cairo',
};

Map<String, dynamic> _requestJson({
  String id = 'req_1',
  String status = 'priced',
  double? price = 75.0,
}) => {
  'id': id,
  'consumerId': 'consumer_1',
  'consumerName': 'Test Buyer',
  'consumerPhone': '01012345678',
  'pickup': _addressJson(),
  'dropoff': _addressJson(street: 'Street 2', city: 'Giza'),
  'packageNote': 'A small box',
  'status': status,
  'price': price,
  'createdAt': DateTime(2026, 9, 1).toIso8601String(),
  'updatedAt': DateTime(2026, 9, 1).toIso8601String(),
};

Widget _harness(List<Override> overrides) => ProviderScope(
  overrides: overrides,
  child: const MaterialApp(
    localizationsDelegates: [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    // MyPackageRequestsScreen renders its own Scaffold, and neither test
    // below navigates away from it, so no extra Navigator scaffolding is
    // needed here.
    home: MyPackageRequestsScreen(),
  ),
);

/// Bounded frame pump instead of `pumpAndSettle()` — matches the
/// established convention from send_package_screen_live_flow_test.dart.
Future<void> _settle(
  WidgetTester tester, {
  int times = 15,
  Duration step = const Duration(milliseconds: 100),
}) async {
  for (var i = 0; i < times; i++) {
    await tester.pump(step);
  }
}

/// Pumps the screen, then explicitly (re-)fetches once `authProvider` has
/// actually resolved — `MyPackageRequestsScreen`'s postFrameCallback only
/// calls `fetchRequests()` when `authProvider` is ALREADY resolved at that
/// instant (`_requester`'s synchronous `ref.read`), same race
/// orders_screen_live_flow_test.dart's `_pumpReady` works around.
Future<ProviderContainer> _pumpReady(
  WidgetTester tester,
  List<Override> overrides,
) async {
  await tester.pumpWidget(_harness(overrides));
  await tester.pump();
  final container = ProviderScope.containerOf(
    tester.element(find.byType(MyPackageRequestsScreen)),
    listen: false,
  );
  await container.read(authProvider.future);
  // Deliberately not awaited — see the FakeAsync-zone note in
  // orders_screen_live_flow_test.dart's `_pumpReady`.
  unawaited(
    container.read(deliveryRequestsProvider.notifier).fetchRequests(),
  );
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  testWidgets(
    'consumer views their live package requests',
    skip: MockConfig.useMock,
    (tester) async {
      final dio = _fakeDio({
        'GET ${DeliveryApiEndpoints.deliveryRequestsMine}': (_) => [
          _requestJson(),
        ],
      });

      await _pumpReady(tester, [
        authProvider.overrideWith(() => FakeAuth(_consumer())),
        deliveryDioProvider.overrideWithValue(dio),
      ]);
      await _settle(tester);

      expect(find.text('Price ready'), findsOneWidget);
      expect(find.text('EGP 75'), findsOneWidget);
    },
  );

  testWidgets(
    'consumer confirms a priced request via the live PUT wire call',
    skip: MockConfig.useMock,
    (tester) async {
      var status = 'priced';
      final dio = _fakeDio({
        'GET ${DeliveryApiEndpoints.deliveryRequestsMine}': (_) => [
          _requestJson(status: status),
        ],
        'POST ${DeliveryApiEndpoints.deliveryRequestConfirm('req_1')}': (_) {
          status = 'confirmed';
          return _requestJson(status: status);
        },
      });

      await _pumpReady(tester, [
        authProvider.overrideWith(() => FakeAuth(_consumer())),
        deliveryDioProvider.overrideWithValue(dio),
      ]);
      await _settle(tester);

      expect(find.text('Price ready'), findsOneWidget);

      await tester.tap(find.text('Confirm — pay at pickup'));
      await _settle(tester);

      // The card behind the dialog shares the same button label, so the
      // dialog's own confirm button is the LAST match once it's open.
      await tester.tap(find.text('Confirm — pay at pickup').last);
      await _settle(tester);

      expect(
        find.text('Order placed — a courier is being assigned'),
        findsOneWidget,
      );
      expect(find.text('Confirmed'), findsOneWidget);
    },
  );
}
