import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:xstore/core/constants/prefs_keys.dart';
import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/core/mock/mock_config.dart';
import 'package:xstore/core/network/dio_provider.dart';
import 'package:xstore/core/network/server_error_provider.dart';
import 'package:xstore/core/router/app_router.dart';
import 'package:xstore/core/router/app_routes.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/auth/presentation/widgets/auth_header.dart';
import 'package:xstore/features/general_settings/domain/entities/app_settings.dart';
import 'package:xstore/features/general_settings/presentation/providers/general_settings_provider.dart';
import 'package:xstore/features/notifications/presentation/providers/fcm_device_token_sync_provider.dart';
import 'package:xstore/features/notifications/presentation/providers/fcm_push_handling_provider.dart';

import '../../helpers/fake_async_auth_notifier.dart';
import '../../helpers/fake_general_settings.dart';

/// Real `dioProvider` (real headers + interceptors) over a fake transport.
class _Adapter implements HttpClientAdapter {
  _Adapter(this.handler);
  final Future<ResponseBody> Function(RequestOptions o) handler;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    requests.add(options);
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(Object body, {int status = 200}) => ResponseBody.fromString(
  jsonEncode(body),
  status,
  headers: {
    Headers.contentTypeHeader: ['application/json; charset=utf-8'],
  },
);

ResponseBody _ok() => _json(generalSettingsSampleBody);
ResponseBody _boom() => _json({'message': 'boom'}, status: 500);

const _enError =
    "Couldn't load app settings. Check your connection and try again.";

const _delegates = [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

ProviderContainer _container(_Adapter adapter) {
  final c = ProviderContainer(
    overrides: [
      authProvider.overrideWith(() => FakeAuth(null)),
      fcmDeviceTokenSyncProvider.overrideWith((ref) {}),
      fcmPushHandlingProvider.overrideWith((ref) {}),
    ],
  );
  addTearDown(c.dispose);
  c.read(dioProvider).httpClientAdapter = adapter;
  return c;
}

Future<void> _pumpApp(WidgetTester t, ProviderContainer c) async {
  await t.pumpWidget(
    UncontrolledProviderScope(
      container: c,
      child: Consumer(
        builder: (context, ref, _) {
          final router = ref.watch(goRouterProvider);
          return MaterialApp.router(
            key: ObjectKey(router),
            routerConfig: router,
            localizationsDelegates: _delegates,
            supportedLocales: AppLocalizations.supportedLocales,
          );
        },
      ),
    ),
  );
  await t.pump();
}

Future<void> _pumpFor(WidgetTester t, Duration d) async {
  for (
    var left = d;
    left > Duration.zero;
    left -= const Duration(milliseconds: 100)
  ) {
    await t.pump(const Duration(milliseconds: 100));
  }
}

String _location(ProviderContainer c) =>
    c.read(goRouterProvider).routeInformationProvider.value.uri.toString();

Future<void> _teardown(WidgetTester t, ProviderContainer c) async {
  await t.pumpWidget(const SizedBox());
  c.dispose();
  await t.pump(const Duration(seconds: 1));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final skip = MockConfig.useMock
      ? 'MOCK=true answers settings from fixtures without a request'
      : null;

  setUp(() {
    SharedPreferences.setMockInitialValues({
      PrefsKeys.locationPermissionRationaleShown: true,
    });
    FlutterSecureStorage.setMockInitialValues({});
  });

  group('the settings request stays out of the session and the app shell', () {
    test('a 5xx does not raise the global server-error flag', () async {
      final adapter = _Adapter((_) async => _boom());
      final c = _container(adapter);

      await expectLater(
        c.read(generalSettingsProvider.future),
        throwsA(anything),
      );

      expect(adapter.requests, hasLength(1));
      expect(c.read(serverErrorProvider), isFalse);
    }, skip: skip);

    test('control: any other request with a 5xx still raises it', () async {
      final adapter = _Adapter((_) async => _boom());
      final c = _container(adapter);

      await expectLater(
        c.read(dioProvider).get<dynamic>('/api/anything'),
        throwsA(isA<DioException>()),
      );

      expect(c.read(serverErrorProvider), isTrue);
    });

    test(
      'no session token is sent and a 401 leaves the session alone',
      () async {
        FlutterSecureStorage.setMockInitialValues({
          PrefsKeys.authToken: 'stale',
          PrefsKeys.authRefreshToken: 'stale-refresh',
        });
        final adapter = _Adapter(
          (_) async => _json({'message': 'no'}, status: 401),
        );
        final c = _container(adapter);

        await expectLater(
          c.read(generalSettingsProvider.future),
          throwsA(anything),
        );

        expect(
          adapter.requests,
          hasLength(1),
          reason: 'no refresh call, no retry',
        );
        expect(
          adapter.requests.single.headers.containsKey('X-Auth-Token'),
          isFalse,
        );
        const storage = FlutterSecureStorage();
        expect(await storage.read(key: PrefsKeys.authToken), 'stale');
        expect(
          await storage.read(key: PrefsKeys.authRefreshToken),
          'stale-refresh',
        );
      },
      skip: skip,
    );
  });

  group('full router', () {
    testWidgets(
      'first launch + 500: splash error and Retry, no server-error page',
      (t) async {
        var healthy = false;
        final adapter = _Adapter((_) async => healthy ? _ok() : _boom());
        final c = _container(adapter);
        await _pumpApp(t, c);
        await _pumpFor(t, const Duration(seconds: 4));

        expect(_location(c), AppRoutes.splash);
        expect(c.read(serverErrorProvider), isFalse);
        expect(find.text(_enError), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
        expect(find.text('Go home'), findsNothing);

        healthy = true;
        await t.tap(find.text('Retry'));
        await _pumpFor(t, const Duration(seconds: 4));

        expect(_location(c), isNot(AppRoutes.splash));
        expect(c.read(generalSettingsProvider).hasValue, isTrue);
        await _teardown(t, c);
      },
      skip: MockConfig.useMock,
    );

    testWidgets(
      'later launch + 500 on the background refresh stays silent',
      (t) async {
        final cache = AppSettings.fromItems(const [
          {'key': 'instapay_handle', 'value': 'cached'},
        ]);
        SharedPreferences.setMockInitialValues({
          PrefsKeys.locationPermissionRationaleShown: true,
          PrefsKeys.generalSettings: cache.toJson(),
        });
        final adapter = _Adapter((_) async => _boom());
        final c = _container(adapter);
        await _pumpApp(t, c);
        await _pumpFor(t, const Duration(seconds: 4));

        expect(adapter.requests, hasLength(1));
        expect(c.read(serverErrorProvider), isFalse);
        expect(_location(c), isNot(AppRoutes.serverError));
        expect(_location(c), isNot(AppRoutes.splash));
        expect(c.read(generalSettingsProvider).requireValue, cache);
        final prefs = await SharedPreferences.getInstance();
        expect(
          AppSettings.tryFromJson(prefs.getString(PrefsKeys.generalSettings)),
          cache,
        );
        await _teardown(t, c);
      },
      skip: MockConfig.useMock,
    );

    testWidgets(
      'the splash does not shift when the error replaces the progress line',
      (t) async {
        final gate = Completer<ResponseBody>();
        final adapter = _Adapter((_) => gate.future);
        final c = _container(adapter);
        await _pumpApp(t, c);
        await _pumpFor(t, const Duration(seconds: 1));
        final loading = t.getTopLeft(find.byType(AuthWordmark));
        expect(find.text('Retry'), findsNothing);

        gate.complete(_boom());
        await _pumpFor(t, const Duration(seconds: 1));

        expect(find.text('Retry'), findsOneWidget);
        expect(t.getTopLeft(find.byType(AuthWordmark)), loading);
        await _teardown(t, c);
      },
      skip: MockConfig.useMock,
    );
  });
}
