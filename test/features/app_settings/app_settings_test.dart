import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/error/exceptions.dart';
import 'package:xstore/core/localization/app_localizations.dart';
import 'package:xstore/core/mock/mock_config.dart';
import 'package:xstore/core/network/api_endpoints.dart';
import 'package:xstore/features/app_settings/data/app_settings_remote_datasource.dart';
import 'package:xstore/features/app_settings/domain/app_settings.dart';
import 'package:xstore/features/app_settings/presentation/app_settings_providers.dart';
import 'package:xstore/features/app_settings/presentation/app_update_gate.dart';

class _Adapter implements HttpClientAdapter {
  _Adapter(this.body, {this.status = 200});

  final Object body;
  final int status;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    expect(options.path, ApiEndpoints.appSettings);
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

AppSettingsRemoteDataSource _dataSource(Object body, {int status = 200}) =>
    AppSettingsRemoteDataSource(
      Dio(BaseOptions(baseUrl: 'https://example.test'))
        ..httpClientAdapter = _Adapter(body, status: status),
    );

AppSettings _settings({String? minimum, bool? force, bool? soft}) =>
    AppSettings({
      if (minimum != null) AppSettingKeys.minimumAppVersion: minimum,
      if (force != null) AppSettingKeys.forceUpdateRequired: force,
      if (soft != null) AppSettingKeys.softUpdateRequired: soft,
    });

/// Counts how often the app below the gate is (re)mounted.
class _MountCounter extends StatefulWidget {
  const _MountCounter();

  static int mounts = 0;

  @override
  State<_MountCounter> createState() => _MountCounterState();
}

class _MountCounterState extends State<_MountCounter> {
  @override
  void initState() {
    super.initState();
    _MountCounter.mounts++;
  }

  @override
  Widget build(BuildContext context) => const Text('home');
}

final _requirement = StateProvider((ref) => AppUpdateRequirement.none);

void main() {
  group('compareVersions', () {
    test('compares numerically, not as text', () {
      expect(compareVersions('2.0.10', '2.0.4'), 1);
      expect(compareVersions('1.9', '2.0.0'), -1);
      expect(compareVersions('2.0', '2.0.0'), 0);
    });

    test('ignores build and pre-release suffixes', () {
      expect(compareVersions('1.0.0+68', '1.0.0'), 0);
      expect(compareVersions('1.0.0-beta', '1.0.1'), -1);
    });
  });

  group('AppSettings.updateRequirement', () {
    test('never prompts at or above the minimum version', () {
      final s = _settings(minimum: '2.0.4', force: true, soft: true);
      expect(s.updateRequirement('2.0.4'), AppUpdateRequirement.none);
      expect(s.updateRequirement('2.1.0'), AppUpdateRequirement.none);
    });

    test('blocks below the minimum when force_update_required is on', () {
      final s = _settings(minimum: '2.0.4', force: true, soft: true);
      expect(s.updateRequirement('2.0.3'), AppUpdateRequirement.required);
    });

    test('asks below the minimum when only soft_update_required is on', () {
      final s = _settings(minimum: '2.0.4', force: false, soft: true);
      expect(s.updateRequirement('1.0.0'), AppUpdateRequirement.optional);
    });

    test('does nothing when no flag is on or no minimum is set', () {
      expect(
        _settings(minimum: '2.0.4').updateRequirement('1.0.0'),
        AppUpdateRequirement.none,
      );
      expect(
        _settings(force: true).updateRequirement('1.0.0'),
        AppUpdateRequirement.none,
      );
      expect(
        AppSettings.empty.updateRequirement('1.0.0'),
        AppUpdateRequirement.none,
      );
    });

    test('falls back when an admin stores a key with the wrong type', () {
      final s = AppSettings(const {
        AppSettingKeys.minimumAppVersion: 204,
        AppSettingKeys.forceUpdateRequired: 'true',
      });
      expect(s.valueOf(AppSettingKeys.forceUpdateRequired, false), isFalse);
      expect(s.updateRequirement('1.0.0'), AppUpdateRequirement.none);
    });
  });

  group('AppSettingsRemoteDataSource', () {
    test('unwraps the Result envelope into typed values', () async {
      final values = await _dataSource({
        'isSuccess': true,
        'data': {
          'force_update_required': true,
          'listing-title-max-character': 170,
          'home_sections': ['banners', 'hot_deals'],
        },
        'errorEn': null,
        'statusCode': 200,
      }).fetchAll();

      final s = AppSettings(values);
      expect(s.valueOf('force_update_required', false), isTrue);
      expect(s.valueOf('listing-title-max-character', 0), 170);
      expect(s.valueOf<List<dynamic>>('home_sections', const []), [
        'banners',
        'hot_deals',
      ]);
    });

    test('accepts a bare map', () async {
      final values = await _dataSource({
        'minimum_app_version': '2.0.4',
      }).fetchAll();
      expect(values['minimum_app_version'], '2.0.4');
    });

    test(
      'throws an AppException for a non-map body or an HTTP error',
      () async {
        await expectLater(
          _dataSource([1, 2]).fetchAll(),
          throwsA(isA<AppException>()),
        );
        await expectLater(
          _dataSource({'errorEn': 'x'}, status: 404).fetchAll(),
          throwsA(isA<AppException>()),
        );
      },
    );
  });

  group('appSettingsProvider', () {
    test('falls back to empty settings when the API is unavailable', () async {
      final container = ProviderContainer(
        overrides: [
          appSettingsRemoteDataSourceProvider.overrideWithValue(
            _dataSource({'errorEn': 'Not found'}, status: 404),
          ),
        ],
      );
      addTearDown(container.dispose);

      final s = await container.read(appSettingsProvider.future);
      expect(s.valueOf(AppSettingKeys.forceUpdateRequired, false), isFalse);
    });

    test(
      'combines settings with the installed version',
      () async {
        final container = ProviderContainer(
          overrides: [
            appSettingsRemoteDataSourceProvider.overrideWithValue(
              _dataSource({
                'data': {
                  'minimum_app_version': '2.0.0',
                  'force_update_required': true,
                },
              }),
            ),
            appVersionProvider.overrideWith((ref) async => '1.0.0'),
          ],
        );
        addTearDown(container.dispose);

        await container.read(appSettingsProvider.future);
        await container.read(appVersionProvider.future);
        expect(
          container.read(appUpdateRequirementProvider),
          AppUpdateRequirement.required,
        );
      },
      skip: MockConfig.useMock ? 'mock mode never fetches settings' : null,
    );
  });

  group('AppUpdateGate', () {
    Future<void> pump(WidgetTester tester, AppUpdateRequirement r) {
      return tester.pumpWidget(
        ProviderScope(
          overrides: [appUpdateRequirementProvider.overrideWithValue(r)],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => AppUpdateGate(child: child!),
            home: const Scaffold(body: Text('home')),
          ),
        ),
      );
    }

    testWidgets('shows nothing extra when no update is needed', (tester) async {
      await pump(tester, AppUpdateRequirement.none);
      expect(find.text('home'), findsOneWidget);
      expect(find.text('Update now'), findsNothing);
    });

    testWidgets('blocks the app with no way to dismiss when required', (
      tester,
    ) async {
      await pump(tester, AppUpdateRequirement.required);
      expect(find.text('Update required'), findsOneWidget);
      expect(find.text('Update now'), findsOneWidget);
      expect(find.text('Later'), findsNothing);
      await tester.tap(find.text('home'), warnIfMissed: false);
      // The full-screen view covers the app, so its content isn't hit-testable.
      expect(find.text('home').hitTestable(), findsNothing);
    });

    testWidgets('never remounts the app below when the prompt changes', (
      tester,
    ) async {
      _MountCounter.mounts = 0;
      final container = ProviderContainer(
        overrides: [
          appUpdateRequirementProvider.overrideWith(
            (ref) => ref.watch(_requirement),
          ),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => AppUpdateGate(child: child!),
            home: const Scaffold(body: _MountCounter()),
          ),
        ),
      );

      for (final r in [
        AppUpdateRequirement.optional,
        AppUpdateRequirement.required,
        AppUpdateRequirement.none,
      ]) {
        container.read(_requirement.notifier).state = r;
        await tester.pump();
      }
      expect(_MountCounter.mounts, 1);
    });

    testWidgets('lets the user dismiss an optional update', (tester) async {
      await pump(tester, AppUpdateRequirement.optional);
      expect(find.text('A new version is available'), findsOneWidget);

      await tester.tap(find.text('Later'));
      await tester.pump();
      expect(find.text('A new version is available'), findsNothing);
      expect(find.text('home'), findsOneWidget);
    });
  });
}
