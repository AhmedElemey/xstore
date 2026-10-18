import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:xstore/core/constants/prefs_keys.dart';
import 'package:xstore/core/mock/mock_config.dart';
import 'package:xstore/core/network/dio_provider.dart';
import 'package:xstore/features/general_settings/domain/entities/app_settings.dart';
import 'package:xstore/features/general_settings/presentation/providers/general_settings_provider.dart';

import '../../helpers/fake_general_settings.dart';

/// Answers each GET from the next completer so a test controls when (and
/// whether) the settings fetch finishes.
class _ControlledInterceptor extends Interceptor {
  final calls = <Completer<Object?>>[];

  Completer<Object?> get latest => calls.last;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final completer = Completer<Object?>();
    calls.add(completer);
    completer.future.then(
      (body) => handler.resolve(
        Response(requestOptions: options, statusCode: 200, data: body),
      ),
      onError: (Object e) =>
          handler.reject(DioException(requestOptions: options, error: e)),
    );
  }
}

Map<String, Object?> _body(String instapay) => {
  'items': [
    {'key': 'instapay_handle', 'value': instapay, 'dataType': 'String'},
  ],
  'totalPages': 1,
};

AppSettings _settings(String instapay) => AppSettings.fromItems([
  {'key': 'instapay_handle', 'value': instapay, 'dataType': 'String'},
]);

/// Waits (real time) for [done], so a slow first SharedPreferences load
/// doesn't make assertions race the provider.
Future<void> _until(bool Function() done) async {
  for (var i = 0; i < 100 && !done(); i++) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

Future<void> _tick() => Future<void>.delayed(const Duration(milliseconds: 20));

void main() {
  final skip = MockConfig.useMock
      ? 'MOCK=true answers settings from fixtures without a request'
      : null;

  late _ControlledInterceptor net;

  ProviderContainer makeContainer() {
    final dio = Dio()..interceptors.add(net);
    final c = ProviderContainer(
      overrides: [dioProvider.overrideWithValue(dio)],
    );
    addTearDown(c.dispose);
    return c;
  }

  setUp(() {
    net = _ControlledInterceptor();
    SharedPreferences.setMockInitialValues({});
  });

  group('first launch (no cache)', () {
    test('waits for the fetch, caches it, then is ready', () async {
      final c = makeContainer();
      c.listen(generalSettingsProvider, (_, __) {});
      await _until(() => net.calls.isNotEmpty);

      expect(c.read(generalSettingsProvider).isLoading, isTrue);
      expect(net.calls, hasLength(1));

      net.latest.complete(generalSettingsSampleBody);
      final s = await c.read(generalSettingsProvider.future);

      expect(s.string('instapay_handle'), '01019816854');
      expect(c.read(generalSettingsProvider).hasValue, isTrue);
      final prefs = await SharedPreferences.getInstance();
      expect(
        AppSettings.tryFromJson(prefs.getString(PrefsKeys.generalSettings)),
        s,
      );
    }, skip: skip);

    test('a failed fetch is an error; Retry re-fetches and succeeds', () async {
      final c = makeContainer();
      c.listen(generalSettingsProvider, (_, __) {});
      await _until(() => net.calls.isNotEmpty);
      net.latest.completeError('offline');
      await _tick();

      expect(c.read(generalSettingsProvider).hasError, isTrue);
      expect(c.read(generalSettingsProvider).hasValue, isFalse);

      c.invalidate(generalSettingsProvider);
      await _until(() => net.calls.length == 2);
      expect(net.calls, hasLength(2));
      net.latest.complete(_body('retry@instapay'));
      final s = await c.read(generalSettingsProvider.future);

      expect(s.raw('instapay_handle'), 'retry@instapay');
    }, skip: skip);

    testWidgets('gives up after the 10 s cap instead of hanging', (
      tester,
    ) async {
      final c = makeContainer();
      c.listen(generalSettingsProvider, (_, __) {});
      await tester.pump(const Duration(seconds: 9));
      expect(c.read(generalSettingsProvider).isLoading, isTrue);

      await tester.pump(const Duration(seconds: 2));
      final state = c.read(generalSettingsProvider);
      expect(state.hasError, isTrue);
      expect(state.error, isA<TimeoutException>());
    }, skip: MockConfig.useMock);
  });

  group('later launch (cache exists)', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({
        PrefsKeys.generalSettings: _settings('cached@instapay').toJson(),
      });
    });

    test('is ready from the cache while the fetch is still pending', () async {
      final c = makeContainer();
      final s = await c.read(generalSettingsProvider.future);

      expect(s.raw('instapay_handle'), 'cached@instapay');
      expect(c.read(generalSettingsProvider).hasValue, isTrue);
    }, skip: skip);

    test('a differing fetch updates the state and the cache', () async {
      final c = makeContainer();
      c.listen(generalSettingsProvider, (_, __) {});
      await c.read(generalSettingsProvider.future);
      await _until(() => net.calls.isNotEmpty);

      net.latest.complete(_body('new@instapay'));
      await _tick();

      expect(
        c.read(generalSettingsProvider).requireValue.raw('instapay_handle'),
        'new@instapay',
      );
      final prefs = await SharedPreferences.getInstance();
      expect(
        AppSettings.tryFromJson(
          prefs.getString(PrefsKeys.generalSettings),
        )!.raw('instapay_handle'),
        'new@instapay',
      );
    }, skip: skip);

    test('an identical fetch leaves the state untouched', () async {
      final c = makeContainer();
      var notifications = 0;
      c.listen(generalSettingsProvider, (_, __) => notifications++);
      await c.read(generalSettingsProvider.future);
      await _until(() => net.calls.isNotEmpty);
      final before = notifications;

      net.latest.complete(_body('cached@instapay'));
      await _tick();

      expect(notifications, before);
    }, skip: skip);

    test('a failed background refresh keeps the cache silently', () async {
      final c = makeContainer();
      c.listen(generalSettingsProvider, (_, __) {});
      await c.read(generalSettingsProvider.future);
      await _until(() => net.calls.isNotEmpty);

      net.latest.completeError('offline');
      await _tick();

      final state = c.read(generalSettingsProvider);
      expect(state.hasError, isFalse);
      expect(state.requireValue.raw('instapay_handle'), 'cached@instapay');
      final prefs = await SharedPreferences.getInstance();
      expect(
        AppSettings.tryFromJson(
          prefs.getString(PrefsKeys.generalSettings),
        )!.raw('instapay_handle'),
        'cached@instapay',
      );
    }, skip: skip);
  });

  test('a corrupt cache is treated as no cache', () async {
    SharedPreferences.setMockInitialValues({
      PrefsKeys.generalSettings: '{not json',
    });
    final c = makeContainer();
    c.listen(generalSettingsProvider, (_, __) {});
    await _until(() => net.calls.isNotEmpty);

    expect(c.read(generalSettingsProvider).isLoading, isTrue);
    expect(net.calls, hasLength(1));
  }, skip: skip);
}
