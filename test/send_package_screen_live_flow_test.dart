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
import 'package:xstore/core/localization/localized_text.dart';
import 'package:xstore/core/mock/mock_config.dart';
import 'package:xstore/core/network/delivery_api_endpoints.dart';
import 'package:xstore/core/router/app_routes.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/cities/domain/entities/city_entity.dart';
import 'package:xstore/features/cities/presentation/providers/city_dependencies.dart';
import 'package:xstore/features/delivery/data/delivery_dio_provider.dart';
import 'package:xstore/features/delivery/presentation/screens/send_package_screen.dart';
import 'package:xstore/features/governments/domain/entities/government_entity.dart';
import 'package:xstore/features/governments/presentation/providers/government_dependencies.dart';

import 'helpers/fake_async_auth_notifier.dart';

const _cairoGov = GovernmentEntity(id: 16, name: LocalizedText(en: 'Cairo', ar: 'القاهرة'));
const _maadiCity = CityEntity(
  id: 1,
  name: LocalizedText(en: 'Maadi', ar: 'المعادي'),
  governorateId: 16,
);

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
          // Pickup/dropoff location is a LocationCascadeField picker now,
          // not a free-text city field — its underlying providers hit the
          // real (unmocked) dioProvider without this override, whose
          // secure-storage-read .timeout() guard creates a genuine 5s
          // Timer that outlives the test's widget tree.
          allGovernmentsProvider.overrideWith((ref) async => const [_cairoGov]),
          allCitiesProvider.overrideWith((ref) async => const [_maadiCity]),
        ]),
      );
      await _settle(tester);

      // Both PhoneInputField and every other TextFormField on this form
      // are addressed by position: [senderName, senderPhone, pickupStreet,
      // recipientName, recipientPhone, dropoffStreet, note]. Pickup/dropoff
      // city+governorate are picked via the two LocationCascadeField
      // pickers instead (same widget twice, so byKey finds two — .at(0)
      // is pickup, .at(1) is dropoff, matching document order).
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Test Buyer');
      await tester.enterText(fields.at(1), '01012345678');
      await tester.enterText(fields.at(2), 'Street 1');
      await tester.pump();

      await tester.tap(find.byKey(const ValueKey('locationCascadeField')).at(0));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cairo'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Maadi'));
      await tester.pumpAndSettle();

      await tester.enterText(fields.at(3), 'Test Recipient');
      await tester.enterText(fields.at(4), '01098765432');
      await tester.enterText(fields.at(5), 'Street 2');
      await tester.pump();

      // The dropoff cascade sits below the fold of this long form.
      final dropoffCascade =
          find.byKey(const ValueKey('locationCascadeField')).at(1);
      await tester.ensureVisible(dropoffCascade);
      await tester.pump();
      await tester.tap(dropoffCascade);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cairo'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Maadi'));
      await tester.pumpAndSettle();

      await tester.enterText(fields.at(6), 'A small box');
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
