// Regression test for: tapping a "shop by category" chip on Home navigates
// to Explore correctly, but a SECOND tap (a different category) while the
// Explore tab is already built silently did nothing — it neither searched
// by the new category nor updated the search bar text.
//
// Root cause: the bottom nav's StatefulShellRoute.indexedStack keeps each
// tab's widget (and State) alive across navigations — ExploreScreen's
// `initState`, which used to be the only place reading the `?category=`
// query param, only ever fires the first time the tab is built. A plain
// (non-shell) GoRoute harness wouldn't reproduce this: without an
// IndexedStack keeping the branch alive, Flutter recreates the State on
// every navigation to a new query, masking the bug. This harness mirrors
// the real app_router.dart shape closely enough to reproduce it: a
// StatefulShellRoute.indexedStack with the real ExploreScreen as one
// branch.
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
import 'package:xstore/core/network/api_endpoints.dart';
import 'package:xstore/core/network/dio_provider.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/explore/presentation/screens/explore_screen.dart';

class _RoutedInterceptor extends Interceptor {
  _RoutedInterceptor(this.onRequest_);
  final List<Map<String, String?>> requests = [];
  final Object? Function(RequestOptions options) onRequest_;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    requests.add(options.queryParameters.map((k, v) => MapEntry(k, '$v')));
    final result = onRequest_(options);
    handler.resolve(Response(requestOptions: options, statusCode: 200, data: result));
  }
}

class _FakeAuth extends Auth {
  _FakeAuth(this._user);
  final UserEntity? _user;
  @override
  Future<UserEntity?> build() async => _user;
}

Map<String, dynamic> _listingJson(String id, String title) => {
  'id': id,
  'title': title,
  'price': 100,
  'status': 2,
  'imageUrls': <String>[],
  'userName': 'Ahmed',
  'categoryNameEn': 'Electronics',
  'condition': 1,
};

Future<void> _settle(WidgetTester tester, {int times = 15}) async {
  for (var i = 0; i < times; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  testWidgets(
    'a second "shop by category" tap while Explore is already built still '
    'searches by the new category and updates the search bar',
    skip: MockConfig.useMock,
    (tester) async {
      final interceptor = _RoutedInterceptor(
        (_) => [_listingJson('1', 'Some Item')],
      );
      final dio = Dio(BaseOptions(baseUrl: ApiEndpoints.baseUrl))
        ..interceptors.add(interceptor);

      late GoRouter router;
      router = GoRouter(
        initialLocation: '/home',
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, shell) => Scaffold(body: shell),
            branches: [
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/home',
                    builder: (context, state) => const SizedBox.shrink(),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/explore',
                    builder: (context, state) => const ExploreScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(
              () => _FakeAuth(
                const UserEntity(
                  id: 'consumer_1',
                  name: 'Test Buyer',
                  email: 'buyer@test.com',
                  phoneNumber: '01012345678',
                ),
              ),
            ),
            dioProvider.overrideWithValue(dio),
          ],
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
        ),
      );
      await _settle(tester);

      // First "shop by category" tap — Explore tab is built for the first
      // time, exactly like tapping a chip on a fresh Home screen.
      router.go(
        Uri(path: '/explore', queryParameters: {'category': 'Electronics'})
            .toString(),
      );
      await _settle(tester);

      expect(
        find.widgetWithText(TextField, 'Electronics'),
        findsOneWidget,
        reason: 'the search bar should show the first tapped category',
      );
      expect(interceptor.requests.last['keyword'], 'Electronics');

      // Second "shop by category" tap with a DIFFERENT category — Explore's
      // widget/state is already alive (kept by the IndexedStack), so this
      // is the case that used to be silently dropped.
      router.go(
        Uri(path: '/explore', queryParameters: {'category': 'Books'})
            .toString(),
      );
      await _settle(tester);

      expect(
        find.widgetWithText(TextField, 'Books'),
        findsOneWidget,
        reason:
            'retapping a different category chip must update the search '
            'bar too, not just the first one',
      );
      expect(interceptor.requests.last['keyword'], 'Books');
    },
  );
}
