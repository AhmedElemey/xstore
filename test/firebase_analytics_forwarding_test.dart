import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xstore/core/analytics/analytics_service.dart';
import 'package:xstore/core/analytics/event_names.dart';
import 'package:xstore/features/auth/domain/entities/user_entity.dart';

/// Drives [AnalyticsService] through the REAL `firebase_analytics` plugin
/// (default `FirebaseAnalytics.instance`, not a fake) and captures what it
/// sends over the native bridge. This runs the plugin's own name/parameter
/// validation, which a hand-written fake skips, and checks every catalog
/// event against GA4's limits the native SDK enforces silently.
const _hostApi =
    'dev.flutter.pigeon.firebase_analytics_platform_interface.FirebaseAnalyticsHostApi';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();

  final loggedEvents = <Map<Object?, Object?>>[];
  final userIds = <Object?>[];
  final userProperties = <Object?, Object?>{};

  setUpAll(() async {
    await Firebase.initializeApp();
    const codec = StandardMessageCodec();
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    void handle(String method, void Function(List<Object?> args) record) {
      messenger.setMockMessageHandler('$_hostApi.$method', (message) async {
        record(codec.decodeMessage(message)! as List<Object?>);
        return codec.encodeMessage(<Object?>[null]);
      });
    }

    handle('logEvent', (a) => loggedEvents.add(a.first! as Map));
    handle('setUserId', (a) => userIds.add(a.first));
    handle('setUserProperty', (a) => userProperties[a[0]] = a[1]);
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    loggedEvents.clear();
    userIds.clear();
    userProperties.clear();
  });

  Future<AnalyticsService> startService() async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final service = container.read(analyticsServiceProvider);
    await service.ready;
    return service;
  }

  Map<Object?, Object?> paramsOf(String name) =>
      loggedEvents.firstWhere((e) => e['eventName'] == name)['parameters']!
          as Map<Object?, Object?>;

  test('every catalog event reaches GA4 within GA4 limits', () async {
    // Read the catalog from source so a newly added event is covered too.
    final catalog = RegExp(r"static const String \w+ = '(\w+)';")
        .allMatches(
          File('lib/core/analytics/event_names.dart')
              .readAsStringSync()
              .split('abstract final class AnalyticsProps')
              .first,
        )
        .map((m) => m.group(1)!)
        .toList();
    expect(catalog, hasLength(greaterThan(30))); // parse sanity check

    final service = await startService();
    service.debugRouteChanged('/home');
    for (final name in catalog) {
      if (name == AnalyticsEvents.screenView) continue; // route-driven
      service.track(name, properties: {
        AnalyticsProps.itemId: 'p1',
        AnalyticsProps.guest: true,
        AnalyticsProps.quantity: 2,
        AnalyticsProps.query: 'x' * 150,
        AnalyticsProps.reason: null,
      });
    }
    await pumpEventQueue();

    final sent = loggedEvents.map((e) => e['eventName']).toSet();
    expect(sent, containsAll(catalog));
    final validName = RegExp(r'^[A-Za-z][A-Za-z0-9_]{0,39}$');
    for (final event in loggedEvents) {
      final name = event['eventName']! as String;
      final params = event['parameters']! as Map<Object?, Object?>;
      expect(name, matches(validName));
      expect(name, isNot(startsWith('firebase_')));
      expect(params.length, lessThanOrEqualTo(25), reason: name);
      params.forEach((key, value) {
        expect(key as String, matches(validName), reason: name);
        expect(value, anyOf(isA<String>(), isA<num>()), reason: '$name.$key');
        if (value is String) {
          expect(value.length, lessThanOrEqualTo(100), reason: '$name.$key');
        }
      });
    }
  });

  test('screen_view, purchase revenue and identity arrive as GA4 expects',
      () async {
    final service = await startService();
    service.debugRouteChanged('/cart', referrer: '/home');
    service.track(AnalyticsEvents.purchase, properties: {
      AnalyticsProps.orderId: '123',
      AnalyticsProps.valueEgp: 499.5,
      AnalyticsProps.currency: 'EGP',
      AnalyticsProps.paymentType: 'cod',
    });
    service.bindSession(const UserEntity(
      id: '42',
      name: 'Buyer',
      email: 'buyer@test.com',
      phoneNumber: '01011111111',
    ));
    await pumpEventQueue();

    expect(paramsOf('screen_view'),
        {'screen_name': '/cart', 'referrer': '/home'});
    expect(paramsOf('purchase'), containsPair('value', 499.5));
    expect(paramsOf('purchase'), containsPair('currency', 'EGP'));
    expect(paramsOf('purchase'), containsPair('transaction_id', '123'));
    expect(userIds.last, '42');
    expect(userProperties['role'], 'consumer');

    service.bindSession(null);
    await pumpEventQueue();
    expect(userIds.last, isNull);
  });
}
