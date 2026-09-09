// Screen-level, LIVE-mode (MOCK=false) test of the real StoreHoursScreen —
// a real vendor viewing and toggling their store hours, not fixture data.
// Matches test/vendor_orders_screen_live_flow_test.dart's established
// pattern: real screen + real StoreHoursRepositoryImpl ->
// StoreHoursDataSourceImpl chain, only the Dio HTTP transport is scripted.
//
// StoreHoursDataSourceImpl's GET/PUT/PATCH calls use
// LegacyRouteOptions.allowNotFound() (this module isn't on the confirmed
// `/api` contract yet — the hosted backend 404s until it ships, and a 404
// there is treated as "no data yet", not an error). The scripted
// interceptor always resolves with statusCode 200, so every scripted
// route here takes the normal (non-404-fallback) path.
//
// StoreHoursScreen's initState fires fetchStoreHours() via a
// postFrameCallback with no await on authProvider — the same race every
// other screen in this session works around with `_pumpReady`.
//
// Run with: flutter test test/store_hours_screen_live_flow_test.dart
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
import 'package:xstore/core/network/api_endpoints.dart';
import 'package:xstore/core/network/dio_provider.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/store/presentation/providers/store_hours_provider.dart';
import 'package:xstore/features/store/presentation/screens/store_hours_screen.dart';

/// Routes each request by (method, path) to a scripted response — same
/// technique as vendor_orders_screen_live_flow_test.dart's
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
  final d = Dio(BaseOptions(baseUrl: ApiEndpoints.baseUrl));
  d.interceptors.add(_RoutedInterceptor(routes));
  return d;
}

class _FakeAuth extends Auth {
  _FakeAuth(this._user);
  final UserEntity? _user;
  @override
  Future<UserEntity?> build() async => _user;
}

UserEntity _vendor() => const UserEntity(
  id: 'vendor_1',
  name: 'Test Vendor',
  email: 'vendor@test.com',
  phoneNumber: '01012345678',
  role: UserRole.vendor,
);

const _days = [
  'saturday',
  'sunday',
  'monday',
  'tuesday',
  'wednesday',
  'thursday',
  'friday',
];

Map<String, dynamic> _storeHoursJson({
  String vendorId = 'vendor_1',
  bool isStoreOpen = true,
}) => {
  'vendorId': vendorId,
  'isStoreOpen': isStoreOpen,
  'temporaryMessage': null,
  'updatedAt': DateTime(2026, 9, 1).toIso8601String(),
  'schedule': _days
      .map(
        (day) => {
          'day': day,
          'isOpen': day != 'friday',
          'openTime': '09:00',
          'closeTime': '18:00',
          'is24Hours': false,
          'isClosed': day == 'friday',
        },
      )
      .toList(),
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
    // StoreHoursScreen renders its own Scaffold, and neither test below
    // pops it, so no extra Navigator scaffolding is needed here.
    home: StoreHoursScreen(),
  ),
);

/// Bounded frame pump instead of `pumpAndSettle()` — matches the
/// established convention from vendor_orders_screen_live_flow_test.dart.
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
/// actually resolved — same race every other screen in this session
/// works around via `_pumpReady`.
Future<ProviderContainer> _pumpReady(
  WidgetTester tester,
  List<Override> overrides,
) async {
  await tester.pumpWidget(_harness(overrides));
  await tester.pump();
  final container = ProviderScope.containerOf(
    tester.element(find.byType(StoreHoursScreen)),
    listen: false,
  );
  await container.read(authProvider.future);
  // Deliberately not awaited — see the FakeAsync-zone note in
  // orders_screen_live_flow_test.dart's `_pumpReady`.
  unawaited(
    container.read(storeHoursNotifierProvider.notifier).fetchStoreHours(),
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
    'vendor views their live weekly store hours',
    // Exercises StoreHoursDataSourceImpl's LIVE (non-mock) branch.
    skip: MockConfig.useMock,
    (tester) async {
      final dio = _fakeDio({
        'GET ${ApiEndpoints.vendorStoreHours('vendor_1')}': (_) =>
            _storeHoursJson(),
      });

      await _pumpReady(tester, [
        authProvider.overrideWith(() => _FakeAuth(_vendor())),
        dioProvider.overrideWithValue(dio),
      ]);
      await _settle(tester);

      expect(find.text('Weekly Schedule'), findsOneWidget);
      expect(find.text('Your store is currently OPEN'), findsOneWidget);
    },
  );

  testWidgets(
    'vendor closes their store and the live PATCH wire call updates the banner',
    skip: MockConfig.useMock,
    (tester) async {
      var isOpen = true;
      final dio = _fakeDio({
        'GET ${ApiEndpoints.vendorStoreHours('vendor_1')}': (_) =>
            _storeHoursJson(isStoreOpen: isOpen),
        'PATCH ${ApiEndpoints.vendorStoreStatus('vendor_1')}': (options) {
          isOpen = (options.data as Map)['isStoreOpen'] as bool;
          return null;
        },
      });

      await _pumpReady(tester, [
        authProvider.overrideWith(() => _FakeAuth(_vendor())),
        dioProvider.overrideWithValue(dio),
      ]);
      await _settle(tester);

      expect(find.text('Your store is currently OPEN'), findsOneWidget);

      await tester.tap(find.text('Close Store Now'));
      await _settle(tester);

      expect(find.text('Your store is currently CLOSED'), findsOneWidget);
      expect(find.text('Store is now Closed 🔴'), findsOneWidget);
    },
  );
}
