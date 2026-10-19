import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
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
  final requests = <RequestOptions>[];

  Completer<Object?> get latest => calls.last;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final completer = Completer<Object?>();
    calls.add(completer);
    requests.add(options);
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

/// Settings whose clock the test moves, to exercise the resume throttle.
DateTime _clock = DateTime(2026, 10, 18, 12);

class _ClockedSettings extends GeneralSettings {
  @override
  DateTime now() => _clock;
}

/// Simulates the app going to the background and coming back.
void _backgroundAndResume() {
  final binding = TestWidgetsFlutterBinding.instance;
  binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
  binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
  binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
  binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
  binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
  binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
}

Future<String?> _cachedInstapay() async {
  final prefs = await SharedPreferences.getInstance();
  return AppSettings.tryFromJson(
    prefs.getString(PrefsKeys.generalSettings),
  )?.raw('instapay_handle');
}

Future<void> _tick() => Future<void>.delayed(const Duration(milliseconds: 20));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final skip = MockConfig.useMock
      ? 'MOCK=true answers settings from fixtures without a request'
      : null;

  late _ControlledInterceptor net;

  ProviderContainer makeContainer({List<Override> overrides = const []}) {
    final dio = Dio()..interceptors.add(net);
    final c = ProviderContainer(
      overrides: [dioProvider.overrideWithValue(dio), ...overrides],
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

  group('empty or unusable answers', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({
        PrefsKeys.generalSettings: _settings('cached@instapay').toJson(),
      });
    });

    test('an empty fetch never replaces a non-empty cache', () async {
      final c = makeContainer();
      c.listen(generalSettingsProvider, (_, __) {});
      await c.read(generalSettingsProvider.future);
      await _until(() => net.calls.isNotEmpty);

      net.latest.complete({'items': [], 'totalPages': 1});
      await _tick();

      expect(
        c.read(generalSettingsProvider).requireValue.raw('instapay_handle'),
        'cached@instapay',
      );
      expect(await _cachedInstapay(), 'cached@instapay');
    }, skip: skip);

    test('garbage rows keep the cache (malformed, not empty)', () async {
      final c = makeContainer();
      c.listen(generalSettingsProvider, (_, __) {});
      await c.read(generalSettingsProvider.future);
      await _until(() => net.calls.isNotEmpty);

      net.latest.complete({
        'items': [1, 'x', null],
        'totalPages': 1,
      });
      await _tick();

      expect(await _cachedInstapay(), 'cached@instapay');
      expect(
        c.read(generalSettingsProvider).requireValue.raw('instapay_handle'),
        'cached@instapay',
      );
    }, skip: skip);

    test('first launch: an empty answer is valid and is cached', () async {
      SharedPreferences.setMockInitialValues({});
      final c = makeContainer();
      c.listen(generalSettingsProvider, (_, __) {});
      await _until(() => net.calls.isNotEmpty);

      net.latest.complete({'items': [], 'totalPages': 1});
      final s = await c.read(generalSettingsProvider.future);

      expect(s.isEmpty, isTrue);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(PrefsKeys.generalSettings), '[]');
    }, skip: skip);

    test('an unexpected error type is logged in debug, cache kept', () async {
      final logs = <String>[];
      final original = debugPrint;
      debugPrint = (message, {wrapWidth}) => logs.add(message ?? '');
      addTearDown(() => debugPrint = original);
      final c = makeContainer();
      c.listen(generalSettingsProvider, (_, __) {});
      await c.read(generalSettingsProvider.future);
      await _until(() => net.calls.isNotEmpty);

      // `totalPages` of the wrong type makes the parser throw a TypeError.
      net.latest.complete({
        'items': [
          {'key': 'a', 'value': 'b'},
        ],
        'totalPages': 'many',
      });
      await _tick();

      expect(logs.join(), contains('General settings refresh failed'));
      expect(await _cachedInstapay(), 'cached@instapay');
    }, skip: skip);
  });

  group('stale in-flight results', () {
    test(
      'an old refresh finishing last cannot overwrite newer state',
      () async {
        SharedPreferences.setMockInitialValues({
          PrefsKeys.generalSettings: _settings('cached@instapay').toJson(),
        });
        final c = makeContainer();
        c.listen(generalSettingsProvider, (_, __) {});
        await c.read(generalSettingsProvider.future);
        await _until(() => net.calls.length == 1);

        c.invalidate(generalSettingsProvider);
        await _until(() => net.calls.length == 2);
        net.calls[1].complete(_body('new@instapay'));
        await _tick();
        net.calls[0].complete(_body('stale@instapay'));
        await _tick();

        expect(
          c.read(generalSettingsProvider).requireValue.raw('instapay_handle'),
          'new@instapay',
        );
        expect(await _cachedInstapay(), 'new@instapay');
        expect(net.requests[0].cancelToken!.isCancelled, isTrue);
      },
      skip: skip,
    );

    test(
      'Retry while the first fetch is in flight: the old answer is dropped',
      () async {
        final c = makeContainer();
        c.listen(generalSettingsProvider, (_, __) {});
        await _until(() => net.calls.length == 1);

        c.invalidate(generalSettingsProvider);
        await _until(() => net.calls.length == 2);
        net.calls[1].complete(_body('new@instapay'));
        await c.read(generalSettingsProvider.future);
        net.calls[0].complete(_body('stale@instapay'));
        await _tick();

        expect(
          c.read(generalSettingsProvider).requireValue.raw('instapay_handle'),
          'new@instapay',
        );
        expect(await _cachedInstapay(), 'new@instapay');
      },
      skip: skip,
    );
  });

  group('request cancellation', () {
    testWidgets('the 10 s cap cancels the Dio request', (tester) async {
      final c = makeContainer();
      c.listen(generalSettingsProvider, (_, __) {});
      await tester.pump(const Duration(seconds: 1));
      expect(net.requests.single.cancelToken!.isCancelled, isFalse);

      await tester.pump(const Duration(seconds: 10));

      expect(c.read(generalSettingsProvider).hasError, isTrue);
      expect(net.requests.single.cancelToken!.isCancelled, isTrue);
    }, skip: MockConfig.useMock);

    test('disposing the container cancels the in-flight request', () async {
      final c = makeContainer();
      c.listen(generalSettingsProvider, (_, __) {});
      await _until(() => net.calls.isNotEmpty);

      c.dispose();

      expect(net.requests.single.cancelToken!.isCancelled, isTrue);
    }, skip: skip);
  });

  group('refresh on app resume', () {
    setUp(() {
      _clock = DateTime(2026, 10, 18, 12);
      SharedPreferences.setMockInitialValues({
        PrefsKeys.generalSettings: _settings('cached@instapay').toJson(),
      });
    });

    /// Cold start with a cache; the startup refresh answers "unchanged".
    Future<ProviderContainer> coldStart() async {
      final c = makeContainer(
        overrides: [generalSettingsProvider.overrideWith(_ClockedSettings.new)],
      );
      c.listen(generalSettingsProvider, (_, __) {});
      await c.read(generalSettingsProvider.future);
      await _until(() => net.calls.length == 1);
      net.latest.complete(_body('cached@instapay'));
      await _tick();
      return c;
    }

    test('after 60 s a resume fetches and updates state and cache', () async {
      final c = await coldStart();

      _clock = _clock.add(const Duration(seconds: 61));
      _backgroundAndResume();
      await _until(() => net.calls.length == 2);
      expect(net.calls, hasLength(2));
      net.latest.complete(_body('moved@instapay'));
      await _tick();

      expect(
        c.read(generalSettingsProvider).requireValue.raw('instapay_handle'),
        'moved@instapay',
      );
      expect(await _cachedInstapay(), 'moved@instapay');
    }, skip: skip);

    test('a resume within 60 s of the last attempt does nothing', () async {
      await coldStart();

      _clock = _clock.add(const Duration(seconds: 59));
      _backgroundAndResume();
      await _tick();

      expect(net.calls, hasLength(1));
    }, skip: skip);

    test('a resume while a fetch is in flight adds no duplicate', () async {
      SharedPreferences.setMockInitialValues({
        PrefsKeys.generalSettings: _settings('cached@instapay').toJson(),
      });
      final c = makeContainer(
        overrides: [generalSettingsProvider.overrideWith(_ClockedSettings.new)],
      );
      c.listen(generalSettingsProvider, (_, __) {});
      await c.read(generalSettingsProvider.future);
      await _until(() => net.calls.length == 1); // startup refresh pending

      _clock = _clock.add(const Duration(minutes: 5));
      _backgroundAndResume();
      await _tick();

      expect(net.calls, hasLength(1));
    }, skip: skip);

    test('a failed resume refresh is silent and keeps the cache', () async {
      final c = await coldStart();

      _clock = _clock.add(const Duration(seconds: 61));
      _backgroundAndResume();
      await _until(() => net.calls.length == 2);
      net.latest.completeError('offline');
      await _tick();

      final state = c.read(generalSettingsProvider);
      expect(state.hasError, isFalse);
      expect(state.requireValue.raw('instapay_handle'), 'cached@instapay');
    }, skip: skip);

    test(
      'no value yet (first launch failed): a resume retries, throttled',
      () async {
        SharedPreferences.setMockInitialValues({});
        final c = makeContainer(
          overrides: [
            generalSettingsProvider.overrideWith(_ClockedSettings.new),
          ],
        );
        c.listen(generalSettingsProvider, (_, __) {});
        await _until(() => net.calls.length == 1);
        net.latest.completeError('offline');
        await _tick();
        expect(c.read(generalSettingsProvider).hasError, isTrue);

        _clock = _clock.add(const Duration(seconds: 30));
        _backgroundAndResume();
        await _tick();
        expect(net.calls, hasLength(1), reason: 'within the throttle');

        _clock = _clock.add(const Duration(seconds: 31));
        _backgroundAndResume();
        await _until(() => net.calls.length == 2);
        expect(net.calls, hasLength(2));

        // A second resume (or a splash Retry race) while it is in flight.
        _clock = _clock.add(const Duration(minutes: 5));
        _backgroundAndResume();
        await _tick();
        expect(net.calls, hasLength(2));

        net.latest.complete(_body('back@instapay'));
        final s = await c.read(generalSettingsProvider.future);
        expect(s.raw('instapay_handle'), 'back@instapay');
      },
      skip: skip,
    );

    test('the lifecycle listener is removed on dispose', () async {
      final c = await coldStart();
      c.dispose();

      _clock = _clock.add(const Duration(minutes: 5));
      _backgroundAndResume();
      await _tick();

      expect(net.calls, hasLength(1));
    }, skip: skip);
  });
}
