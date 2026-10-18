import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:xstore/core/constants/prefs_keys.dart';
import 'package:xstore/core/localization/localization_provider.dart';
import 'package:xstore/core/mock/mock_config.dart';
import 'package:xstore/core/network/api_endpoints.dart';
import 'package:xstore/core/network/dio_provider.dart';
import 'package:xstore/core/network/server_error_provider.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';
import 'package:xstore/features/auth/presentation/providers/auth_provider.dart';
import 'package:xstore/features/auth/presentation/providers/language_sync_provider.dart';
import 'package:xstore/shared/providers/shared_providers.dart';

const _user = UserEntity(
  id: 'u1',
  name: 'Test',
  email: 't@test.com',
  phoneNumber: '01012345678',
  role: UserRole.consumer,
);

class _Adapter implements HttpClientAdapter {
  _Adapter(this.handler);
  final Future<ResponseBody> Function(RequestOptions o) handler;
  final requests = <RequestOptions>[];

  List<RequestOptions> get puts =>
      requests.where((r) => r.method == 'PUT').toList();

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

ResponseBody _ok() => _json({'isSuccess': true});

/// Auth whose session is whatever the test says; [signIn] is what
/// `adoptSession` does to the state (signed-out -> signed-in).
class _Auth extends Auth {
  _Auth(this._initial);
  final UserEntity? _initial;

  @override
  Future<UserEntity?> build() async => _initial;

  void signIn(UserEntity user) => state = AsyncData(user);
}

Future<void> _settle([int ms = 700]) =>
    Future<void>.delayed(Duration(milliseconds: ms));

Future<ProviderContainer> _start(
  _Adapter adapter, {
  UserEntity? user = _user,
  List<Override> overrides = const [],
}) async {
  final c = ProviderContainer(
    overrides: [authProvider.overrideWith(() => _Auth(user)), ...overrides],
  );
  addTearDown(c.dispose);
  c.read(dioProvider).httpClientAdapter = adapter;
  await c.read(authProvider.future);
  c.read(languageSyncProvider);
  await c.read(appLocaleProvider.notifier).loaded.catchError((_) {});
  await _settle(50);
  return c;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final skip = MockConfig.useMock
      ? 'Needs the real datasource (no MOCK)'
      : null;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({
      PrefsKeys.authToken: 'user-token',
    });
  });

  Future<bool> pending() async =>
      (await SharedPreferences.getInstance()).getBool(
        PrefsKeys.pendingLanguageSync,
      ) ??
      false;

  test(
    'signed in: toggle sends one PUT with the token, then en on toggle back',
    () async {
      final adapter = _Adapter((_) async => _ok());
      final c = await _start(adapter);
      final locale = c.read(appLocaleProvider.notifier);

      await locale.toggleLanguage();
      await _settle();
      expect(adapter.puts, hasLength(1));
      final put = adapter.puts.single;
      expect(put.path, ApiEndpoints.updateLanguage);
      expect(put.data, {'preferredLanguage': 'ar'});
      expect(put.headers['X-Auth-Token'], 'user-token');

      await locale.toggleLanguage();
      await _settle();
      expect(adapter.puts, hasLength(2));
      expect(adapter.puts.last.data, {'preferredLanguage': 'en'});
      expect(await pending(), isFalse);
    },
    skip: skip,
  );

  test('signed out: language changes locally, no request', () async {
    final adapter = _Adapter((_) async => _ok());
    final c = await _start(adapter, user: null);

    await c.read(appLocaleProvider.notifier).toggleLanguage();
    await _settle();

    expect(c.read(appLocaleProvider), AppLanguage.arabic);
    expect(adapter.requests, isEmpty);
  }, skip: skip);

  test('rapid toggles send only the final language', () async {
    final adapter = _Adapter((_) async => _ok());
    final c = await _start(adapter);
    final locale = c.read(appLocaleProvider.notifier);

    await locale.toggleLanguage(); // ar
    await locale.toggleLanguage(); // en
    await locale.toggleLanguage(); // ar
    await _settle();

    expect(adapter.puts, hasLength(1));
    expect(adapter.puts.single.data, {'preferredLanguage': 'ar'});
  }, skip: skip);

  test('the switch is instant even when the request hangs', () async {
    final adapter = _Adapter((_) => Completer<ResponseBody>().future);
    final c = await _start(adapter);

    await c
        .read(appLocaleProvider.notifier)
        .toggleLanguage()
        .timeout(const Duration(milliseconds: 200));
    expect(c.read(appLocaleProvider), AppLanguage.arabic);
    await _settle();
    expect(adapter.puts, hasLength(1)); // sent, never answered
  }, skip: skip);

  test(
    'failure stores the pending flag; next launch retries once and clears',
    () async {
      final failing = _Adapter(
        (_) async => _json({'message': 'x'}, status: 503),
      );
      final c1 = await _start(failing);
      await c1.read(appLocaleProvider.notifier).toggleLanguage();
      await _settle();
      expect(failing.puts, hasLength(1));
      expect(await pending(), isTrue);
      c1.dispose();

      // New launch: saved language 'arabic' loads, session restored, flag set.
      final ok = _Adapter((_) async => _ok());
      await _start(ok);
      await _settle();
      expect(ok.puts, hasLength(1));
      expect(ok.puts.single.data, {'preferredLanguage': 'ar'});
      expect(await pending(), isFalse);
    },
    skip: skip,
  );

  test('failing again on the retry keeps the flag and does not loop', () async {
    SharedPreferences.setMockInitialValues({
      PrefsKeys.pendingLanguageSync: true,
      'app_language': 'arabic',
    });
    final adapter = _Adapter((_) async => _json({'message': 'x'}, status: 500));
    await _start(adapter);
    await _settle(1500);

    expect(adapter.puts, hasLength(1));
    expect(await pending(), isTrue);
  }, skip: skip);

  test('2xx {isSuccess:false} counts as a failure', () async {
    final adapter = _Adapter(
      (_) async => _json({'isSuccess': false, 'errorEn': 'nope'}),
    );
    final c = await _start(adapter);

    await c.read(appLocaleProvider.notifier).toggleLanguage();
    await _settle();

    expect(adapter.puts, hasLength(1));
    expect(await pending(), isTrue);
  }, skip: skip);

  test('4xx counts as a failure', () async {
    final adapter = _Adapter(
      (_) async => _json({'message': 'bad'}, status: 400),
    );
    final c = await _start(adapter);

    await c.read(appLocaleProvider.notifier).toggleLanguage();
    await _settle();

    expect(await pending(), isTrue);
  }, skip: skip);

  test(
    'a 5xx here never raises the server-error page; others still do',
    () async {
      final adapter = _Adapter(
        (_) async => _json({'message': 'x'}, status: 500),
      );
      final c = await _start(adapter);

      await c.read(appLocaleProvider.notifier).toggleLanguage();
      await _settle();
      expect(adapter.puts, hasLength(1));
      expect(c.read(serverErrorProvider), isFalse);

      await expectLater(
        c.read(dioProvider).get<dynamic>('/api/anything'),
        throwsA(isA<DioException>()),
      );
      expect(c.read(serverErrorProvider), isTrue);
    },
    skip: skip,
  );

  test('after an explicit login the current language is sent once', () async {
    SharedPreferences.setMockInitialValues({'app_language': 'arabic'});
    final adapter = _Adapter((_) async => _ok());
    final c = await _start(adapter, user: null);
    expect(adapter.requests, isEmpty);

    (c.read(authProvider.notifier) as _Auth).signIn(_user);
    await _settle();

    expect(adapter.puts, hasLength(1));
    expect(adapter.puts.single.data, {'preferredLanguage': 'ar'});
    expect(await pending(), isFalse);
  }, skip: skip);

  test('restored session or startup language load sends nothing', () async {
    SharedPreferences.setMockInitialValues({'app_language': 'arabic'});
    final adapter = _Adapter((_) async => _ok());
    final c = await _start(adapter); // signed in at launch
    await _settle();

    expect(c.read(appLocaleProvider), AppLanguage.arabic);
    expect(adapter.requests, isEmpty);
  }, skip: skip);

  test(
    'an older success does not clear the flag while a newer change debounces',
    () async {
      final first = Completer<ResponseBody>();
      var puts = 0;
      final adapter = _Adapter(
        (_) => ++puts == 1 ? first.future : Future.value(_ok()),
      );
      final c = await _start(adapter);
      final locale = c.read(appLocaleProvider.notifier);

      await locale.toggleLanguage(); // A: ar
      await _settle(600); // A is in flight
      expect(adapter.puts, hasLength(1));
      await locale.toggleLanguage(); // B: en, debouncing
      await _settle(50);

      first.complete(_ok()); // A succeeds inside B's debounce window
      await _settle(50);
      expect(adapter.puts, hasLength(1));
      expect(await pending(), isTrue, reason: 'B has not been sent yet');

      await _settle(700);
      expect(adapter.puts, hasLength(2));
      expect(adapter.puts.last.data, {'preferredLanguage': 'en'});
      expect(await pending(), isFalse);
    },
    skip: skip,
  );

  group('storage failures never stop the request', () {
    test('prefs always throwing: the change is still sent', () async {
      final adapter = _Adapter((_) async => _ok());
      final c = await _start(
        adapter,
        overrides: [
          sharedPreferencesProvider.overrideWith(
            (ref) async => throw StateError('storage down'),
          ),
        ],
      );

      // setLanguage still throws on its own prefs write (pre-existing), but
      // the locale has already switched.
      await c
          .read(appLocaleProvider.notifier)
          .toggleLanguage()
          .catchError((_) {});
      await _settle();

      expect(adapter.puts, hasLength(1));
      expect(adapter.puts.single.data, {'preferredLanguage': 'ar'});
    }, skip: skip);

    test('prefs failing at startup recovers for later changes', () async {
      var calls = 0;
      final adapter = _Adapter((_) async => _ok());
      final c = await _start(
        adapter,
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) async {
            if (++calls <= 3) throw StateError('storage down');
            return SharedPreferences.getInstance();
          }),
        ],
      );

      await c
          .read(appLocaleProvider.notifier)
          .toggleLanguage()
          .catchError((_) {});
      await _settle();
      await c
          .read(appLocaleProvider.notifier)
          .toggleLanguage()
          .catchError((_) {});
      await _settle();

      expect(adapter.puts, isNotEmpty);
      expect(adapter.puts.last.data, {'preferredLanguage': 'en'});
      expect(await pending(), isFalse);
    }, skip: skip);
  });
}
