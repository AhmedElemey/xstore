// Screen-level, LIVE-mode (MOCK=false) test of the real VendorStoreScreen
// — a real consumer visiting another vendor's public storefront, not
// fixture data. Matches test/orders_screen_live_flow_test.dart's
// established pattern: real screen + real ProfileRepositoryImpl ->
// ProfileRemoteDataSourceImpl chain, only the Dio HTTP transport is
// scripted.
//
// Unlike most screens tested this session, `_bootstrap()` already awaits
// `authProvider.future` directly when auth hasn't resolved yet
// (`authUser = await ref.read(authProvider.future);`), so this screen has
// no initState-postFrameCallback-vs-auth race to work around — a plain
// `pumpWidget` + settle is enough.
//
// Run with: flutter test test/vendor_store_screen_live_flow_test.dart
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
import 'package:xstore/features/profile/presentation/screens/vendor_store_screen.dart';

/// Routes each request by (method, path) to a scripted response — same
/// technique as orders_screen_live_flow_test.dart's `_RoutedInterceptor`.
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

UserEntity _consumer() => const UserEntity(
  id: 'consumer_1',
  name: 'Test Buyer',
  email: 'buyer@test.com',
  phoneNumber: '01012345678',
);

/// A live GET /api/listings row, filtered client-side by `userId` to
/// assemble a public storefront (CONFIRMED: `/users/{id}/store` doesn't
/// exist on the live API).
Map<String, dynamic> _listingJson({
  String id = '9001',
  String title = 'Wireless Earbuds',
  String userId = 'vendor_1',
  String storeName = 'Ahmed Store',
}) => {
  'id': id,
  'title': title,
  'price': 50000,
  'status': 2,
  'userId': userId,
  'storeName': storeName,
  'userName': 'Ahmed',
};

Widget _harness(List<Override> overrides, String sellerId) => ProviderScope(
  overrides: overrides,
  child: MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    // VendorStoreScreen renders its own Scaffold, so no extra Material
    // wrapper is needed here.
    home: VendorStoreScreen(sellerId: sellerId),
  ),
);

/// Bounded frame pump instead of `pumpAndSettle()` — matches the
/// established convention from orders_screen_live_flow_test.dart.
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
    'consumer visits another vendor\'s live storefront and sees their listings',
    // Exercises ProfileRemoteDataSourceImpl's LIVE (non-mock) branch.
    skip: MockConfig.useMock,
    (tester) async {
      final dio = _fakeDio({
        'GET ${ApiEndpoints.apiListings}': (_) => [_listingJson()],
      });

      await tester.pumpWidget(
        _harness([
          authProvider.overrideWith(() => _FakeAuth(_consumer())),
          dioProvider.overrideWithValue(dio),
        ], 'vendor_1'),
      );
      await _settle(tester);

      expect(find.text('Ahmed Store'), findsWidgets);
      expect(find.text('Wireless Earbuds'), findsOneWidget);
    },
  );
}
