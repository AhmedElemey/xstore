// Screen-level, LIVE-mode test of the real CourierCashScreen — a real
// courier viewing their cash-in-hand and the delivered COD orders behind
// it, not fixture data. Matches
// test/courier_deliveries_screen_live_flow_test.dart's established
// pattern: real screen + real OrdersRepositoryImpl ->
// OrdersRemoteDataSourceImpl chain, only the Dio HTTP transport is
// scripted.
//
// Unlike every postFrameCallback-driven screen this session,
// `courierCashWalletProvider` is a plain `@riverpod` FutureProvider that
// `ref.watch(authProvider)`s internally — it naturally stays in its own
// "loading" AsyncValue until auth resolves, then rebuilds, so a bare
// `pumpWidget` + settle is enough; no `_pumpReady`/re-trigger workaround
// is needed here.
//
// GetCourierOrdersUseCase (the same call CourierDeliveriesScreen makes)
// goes through OrdersRemoteDataSourceImpl, which DOES branch on
// MockConfig — this test needs the usual `skip: MockConfig.useMock`.
//
// Run with: flutter test test/courier_cash_screen_live_flow_test.dart
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
import 'package:xstore/features/delivery/presentation/screens/courier_cash_screen.dart';

/// Routes each request by (method, path) to a scripted response — same
/// technique as courier_deliveries_screen_live_flow_test.dart's
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

UserEntity _courier() => const UserEntity(
  id: 'courier_1',
  name: 'Test Courier',
  email: 'courier@test.com',
  phoneNumber: '01012345678',
  role: UserRole.courier,
);

Map<String, dynamic> _orderJson({
  String id = '701',
  String status = 'delivered',
  double total = 300,
}) => {
  'id': id,
  'consumerId': 'consumer_1',
  'consumerName': 'Test Buyer',
  'consumerPhone': '01012345678',
  'vendorId': 'vendor_1',
  'vendorName': 'Ahmed',
  'vendorStoreName': 'Ahmed Store',
  'status': status,
  'listingId': '9001',
  'listingName': 'Wireless Earbuds',
  'quantity': 1,
  'price': total,
  'total': total,
  'courierId': 'courier_1',
  'createdAt': '2026-08-01T00:00:00.000Z',
  'updatedAt': '2026-08-01T00:00:00.000Z',
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
    home: CourierCashScreen(),
  ),
);

/// Bounded frame pump instead of `pumpAndSettle()` — matches the
/// established convention from courier_deliveries_screen_live_flow_test
/// .dart.
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
    'courier views their live cash-in-hand and collected orders',
    skip: MockConfig.useMock,
    (tester) async {
      final dio = _fakeDio({
        'GET ${ApiEndpoints.ordersCourier('courier_1')}': (_) => [
          _orderJson(),
        ],
      });

      await tester.pumpWidget(
        _harness([
          authProvider.overrideWith(() => _FakeAuth(_courier())),
          dioProvider.overrideWithValue(dio),
        ]),
      );
      await _settle(tester);

      // Renders both in the header summary and the collected-order tile's
      // own amount — a legitimate duplicate, not a bug.
      expect(find.text('EGP 300'), findsWidgets);
      expect(find.text('Collected orders'), findsOneWidget);
      expect(find.text('701'), findsOneWidget);
    },
  );

  testWidgets(
    'courier with no delivered COD orders sees the empty cash state',
    skip: MockConfig.useMock,
    (tester) async {
      final dio = _fakeDio({
        'GET ${ApiEndpoints.ordersCourier('courier_1')}': (_) => [],
      });

      await tester.pumpWidget(
        _harness([
          authProvider.overrideWith(() => _FakeAuth(_courier())),
          dioProvider.overrideWithValue(dio),
        ]),
      );
      await _settle(tester);

      expect(find.text('EGP 0'), findsOneWidget);
      expect(
        find.text(
          "You're not holding any cash. Delivered COD orders will appear here.",
        ),
        findsOneWidget,
      );
    },
  );
}
