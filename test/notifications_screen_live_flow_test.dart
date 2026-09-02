// Screen-level, LIVE-mode test of the real NotificationsScreen — a real
// user opening their notifications, not fixture data. Matches
// test/orders_screen_live_flow_test.dart's established pattern: real
// screen + real NotificationsRepositoryImpl -> NotificationsRemoteDataSourceImpl
// chain, only the Dio HTTP transport is scripted.
//
// Unlike every other screen tested this session, NotificationsRemoteDataSourceImpl
// has NO `MockConfig.useMock` branch anywhere — notifications always hit
// the real backend regardless of the MOCK build define — so these tests
// run (and must pass) under both `flutter test` and
// `flutter test --dart-define=MOCK=true`, with no `skip:` needed.
//
// Run with: flutter test test/notifications_screen_live_flow_test.dart
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/core/network/api_endpoints.dart';
import 'package:xstore/core/network/dio_provider.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:xstore/features/notifications/presentation/screens/notifications_screen.dart';

/// Routes each request by (method, path) to a scripted response — same
/// technique as orders_screen_live_flow_test.dart's `_RoutedInterceptor`.
class _RoutedInterceptor extends Interceptor {
  _RoutedInterceptor(this._routes);

  final Map<String, Object? Function(RequestOptions options)> _routes;
  final List<RequestOptions> requests = [];

  String _key(RequestOptions o) => '${o.method} ${o.path}';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    requests.add(options);
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

Map<String, dynamic> _notificationJson({
  String id = 'notif_1',
  String title = 'Order Shipped',
  String body = 'Your order #501 is on its way.',
  bool isRead = false,
}) => {
  'id': id,
  'type': 'orderShipped',
  'priority': 'normal',
  'title': title,
  'body': body,
  'isRead': isRead,
  'createdAt': '2026-09-02T00:00:00.000Z',
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
    // NotificationsScreen renders its own Scaffold, so no extra Material
    // wrapper is needed here.
    home: NotificationsScreen(),
  ),
);

/// Pumps the screen, then explicitly (re-)fetches once `authProvider` has
/// actually resolved. `NotificationsNotifier` only fetches reactively via
/// `ref.listen(authProvider, ...)` registered in `build()` — that listener
/// fires on the NEXT transition, not the value already present at
/// registration time, so a fresh `_FakeAuth` override needs an explicit
/// re-trigger, matching orders_screen_live_flow_test.dart's `_pumpReady`.
Future<ProviderContainer> _pumpReady(
  WidgetTester tester,
  List<Override> overrides,
) async {
  await tester.pumpWidget(_harness(overrides));
  await tester.pump();
  final container = ProviderScope.containerOf(
    tester.element(find.byType(NotificationsScreen)),
    listen: false,
  );
  await container.read(authProvider.future);
  // Deliberately not awaited — see the FakeAsync-zone note in
  // orders_screen_live_flow_test.dart's `_pumpReady`.
  unawaited(
    container.read(notificationsProvider.notifier).fetchNotifications(),
  );
  return container;
}

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
    'consumer views their live notifications feed with the unread summary banner',
    (tester) async {
      final dio = _fakeDio({
        'GET ${ApiEndpoints.notifications}': (_) => {
          'items': [_notificationJson()],
          'totalCount': 1,
          'page': 1,
          'pageSize': 20,
          'totalPages': 1,
        },
        'GET ${ApiEndpoints.notificationsUnreadCount}': (_) => 1,
      });

      await _pumpReady(tester, [
        authProvider.overrideWith(() => _FakeAuth(_consumer())),
        dioProvider.overrideWithValue(dio),
      ]);
      await _settle(tester);

      expect(find.text('Order Shipped'), findsOneWidget);
      expect(
        find.text('Your order #501 is on its way.'),
        findsOneWidget,
      );
      expect(
        find.text('🔔 You have 1 unread notifications'),
        findsOneWidget,
      );
      expect(find.text('Mark all read'), findsOneWidget);
    },
  );

  testWidgets(
    'consumer swipes to delete a notification and the live DELETE wire call fires after the undo window',
    (tester) async {
      RequestOptions? deleteRequest;
      final dio = _fakeDio({
        'GET ${ApiEndpoints.notifications}': (_) => {
          'items': [_notificationJson()],
          'totalCount': 1,
          'page': 1,
          'pageSize': 20,
          'totalPages': 1,
        },
        'GET ${ApiEndpoints.notificationsUnreadCount}': (_) => 1,
        'DELETE ${ApiEndpoints.notificationById('notif_1')}': (options) {
          deleteRequest = options;
          return null;
        },
      });

      await _pumpReady(tester, [
        authProvider.overrideWith(() => _FakeAuth(_consumer())),
        dioProvider.overrideWithValue(dio),
      ]);
      await _settle(tester);

      expect(find.text('Order Shipped'), findsOneWidget);

      // Swipe right-to-left (endToStart) to trigger the delete gesture —
      // a read notification also supports swiping the other way to mark
      // read, so the direction matters.
      await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
      await _settle(tester);

      expect(
        find.text('Order Shipped'),
        findsNothing,
        reason: 'deleting removes the notification from the list '
            'immediately (optimistic), before the undo window expires',
      );
      expect(
        find.text('Undo'),
        findsOneWidget,
        reason: 'a 5s undo window is offered before the delete is '
            'actually sent to the backend',
      );
      expect(
        deleteRequest,
        isNull,
        reason: 'the real DELETE call is deferred until the undo window '
            'expires',
      );

      // Advance the fake clock past onDeleteConfirmed's 5-second undo
      // Timer — matches the established OtpResendCooldown-style live-Timer
      // handling for a real (not debounce-only) Timer.
      await tester.pump(const Duration(seconds: 5));
      await _settle(tester);

      expect(deleteRequest, isNotNull);
    },
  );
}
