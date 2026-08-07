import 'dart:async';
import 'dart:convert';
import 'dart:math' show min;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../shared/providers/shared_providers.dart';
import '../constants/prefs_keys.dart';
import '../network/api_auth_headers.dart';
import '../network/api_endpoints.dart';
import '../network/connectivity_provider.dart';
import '../network/legacy_route_options.dart';
import '../network/logging_interceptor.dart';
import 'analytics_event.dart';
import 'analytics_ids.dart';
import 'event_names.dart';

part 'analytics_service.g.dart';

/// Batches user-journey events locally and POSTs them to the (proposed)
/// backend collector — see `docs_business/backend/03_ANALYTICS_EVENTS_HANDOFF.md`.
///
/// Deliberately uses its own [Dio] client rather than the shared `dio`
/// provider: the shared client's error interceptor flips the whole app to
/// the full-screen server-error state on any 5xx, which is correct for
/// user-facing API calls but wrong for a background telemetry POST — a
/// flaky analytics endpoint must never take over the UI.
///
/// Until the backend ships the collector route, POSTs 404 (tolerated via
/// [LegacyRouteOptions.allowNotFound]) and the queue keeps growing/retrying
/// with backoff instead of erroring — same "legacy 404" pattern used
/// elsewhere in this app for undeployed routes.
class AnalyticsService {
  AnalyticsService(this._ref) {
    _client = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Accept': 'application/json',
          'Authorization': ApiAuthHeaders.basicLicenseKey,
        },
      ),
    );
    if (kDebugMode) _client.interceptors.add(LoggingInterceptor());
    unawaited(_init());
  }

  static const int _maxQueueSize = 500;
  static const int _batchSize = 20;
  static const Duration _flushInterval = Duration(seconds: 20);

  final Ref _ref;
  late final Dio _client;
  late final String _sessionId;
  String _deviceId = '';
  String? _userId;
  String? _userRole;
  String? _currentScreenName;

  final List<AnalyticsEvent> _queue = [];
  final List<(String, Map<String, Object?>)> _pending = [];
  bool _ready = false;
  bool _flushing = false;
  int _consecutiveFailures = 0;
  DateTime? _backoffUntil;

  Timer? _flushTimer;
  VoidCallback? _detachRouterListener;

  Future<void> _init() async {
    _sessionId = generateEventId();
    final prefs = await _ref.read(sharedPreferencesProvider.future);
    _deviceId = prefs.getString(PrefsKeys.analyticsDeviceId) ?? generateEventId();
    await prefs.setString(PrefsKeys.analyticsDeviceId, _deviceId);
    _loadPersistedQueue(prefs);

    _ref.listen<AsyncValue<UserEntity?>>(authProvider, (prev, next) {
      if (next.isLoading) return;
      final user = next.valueOrNull;
      _userId = user?.id;
      _userRole = user?.role.name;
    });

    _ref.listen<bool>(isOnlineProvider, (prev, next) {
      if (next && prev == false) unawaited(_flush());
    });

    _ready = true;
    for (final p in _pending) {
      _enqueue(p.$1, p.$2);
    }
    _pending.clear();

    _flushTimer = Timer.periodic(_flushInterval, (_) => unawaited(_flush()));
    unawaited(_flush());
  }

  void _loadPersistedQueue(SharedPreferences prefs) {
    final raw = prefs.getString(PrefsKeys.analyticsQueue);
    if (raw == null || raw.isEmpty) return;
    try {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      for (final json in list) {
        final event = AnalyticsEvent.fromJson(json);
        if (event != null) _queue.add(event);
      }
    } catch (_) {
      // Corrupt persisted payload — start with an empty queue rather than
      // block startup on it.
    }
  }

  Future<void> _persistQueue(SharedPreferences prefs) async {
    final encoded = jsonEncode(_queue.map((e) => e.toJson()).toList());
    await prefs.setString(PrefsKeys.analyticsQueue, encoded);
  }

  Future<void> _withPrefs(Future<void> Function(SharedPreferences) fn) async {
    final prefs = await _ref.read(sharedPreferencesProvider.future);
    await fn(prefs);
  }

  /// Records a user-journey event. Safe to call before startup finishes —
  /// events fired before the queue loads are buffered and flushed through
  /// once [_init] completes.
  void track(String name, {Map<String, Object?> properties = const {}}) {
    if (!_ready) {
      _pending.add((name, properties));
      return;
    }
    _enqueue(name, properties);
  }

  void _enqueue(String name, Map<String, Object?> properties) {
    final event = AnalyticsEvent(
      name: name,
      sessionId: _sessionId,
      deviceId: _deviceId,
      userId: _userId,
      userRole: _userRole,
      screenName: _currentScreenName,
      properties: properties,
    );
    _queue.add(event);
    if (_queue.length > _maxQueueSize) {
      _queue.removeAt(0); // telemetry, not critical data — drop oldest
    }
    unawaited(_withPrefs(_persistQueue));
    if (_queue.length >= _batchSize) {
      unawaited(_flush());
    }
  }

  /// Wires automatic `screen_view` tracking off go_router's route-change
  /// notifications — avoids touching every one of the ~60 `GoRoute`
  /// definitions in `app_router.dart` to name each page. Idempotent: safe
  /// to call again when the router is rebuilt (role switch recreates
  /// [GoRouter] in `app_router.dart`).
  void attachRouter(GoRouter router) {
    _detachRouterListener?.call();
    final provider = router.routeInformationProvider;
    String? last;
    void onChange() {
      final uri = provider.value.uri.toString();
      if (uri == last) return;
      last = uri;
      _currentScreenName = uri;
      track(AnalyticsEvents.screenView, properties: {AnalyticsProps.screenName: uri});
    }

    provider.addListener(onChange);
    _detachRouterListener = () => provider.removeListener(onChange);
    onChange();
  }

  int _backoffSeconds() => min(300, 10 * (1 << _consecutiveFailures.clamp(0, 5)));

  void _registerFailure() {
    _consecutiveFailures++;
    _backoffUntil = DateTime.now().add(Duration(seconds: _backoffSeconds()));
  }

  Future<void> _flush() async {
    if (_flushing || _queue.isEmpty || !_ready) return;
    final until = _backoffUntil;
    if (until != null && DateTime.now().isBefore(until)) return;
    if (!_ref.read(isOnlineProvider)) return;

    _flushing = true;
    try {
      final batch = _queue.take(_batchSize).toList();
      final response = await _client.post<dynamic>(
        ApiEndpoints.analyticsEvents,
        data: {'events': batch.map((e) => e.toJson()).toList()},
        options: LegacyRouteOptions.allowNotFound(),
      );
      if (LegacyRouteOptions.isNotFound(response)) {
        _registerFailure();
        return;
      }
      _queue.removeRange(0, batch.length);
      _consecutiveFailures = 0;
      _backoffUntil = null;
      await _withPrefs(_persistQueue);
    } catch (_) {
      _registerFailure();
    } finally {
      _flushing = false;
    }
  }

  void dispose() {
    _flushTimer?.cancel();
    _detachRouterListener?.call();
    _client.close();
  }
}

@Riverpod(keepAlive: true)
AnalyticsService analyticsService(AnalyticsServiceRef ref) {
  final service = AnalyticsService(ref);
  ref.onDispose(service.dispose);
  return service;
}
