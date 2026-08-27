import 'dart:async';
import 'dart:convert';
import 'dart:math' show min;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/domain/entities/user_entity.dart';
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

/// Batches user-journey events locally and POSTs them to
/// `POST /api/analytics/events` — see
/// `docs_business/backend/03_ANALYTICS_EVENTS_HANDOFF.md`.
///
/// Deliberately uses its own [Dio] client rather than the shared `dio`
/// provider: the shared client's error interceptor flips the whole app to
/// the full-screen server-error state on any 5xx, which is correct for
/// user-facing API calls but wrong for a background telemetry POST — a
/// flaky analytics endpoint must never take over the UI. Same reason this
/// client must not share [TokenRefreshInterceptor]: a 401 from telemetry
/// must back off, not log the user out.
///
/// The collector is session-gated: [_flush] POSTs only while a signed-in
/// user (non-empty id + `X-Auth-Token`) is present. Guest events stay in
/// the local queue until login. Session identity is pushed in via
/// [bindSession] from the auth notifier — this provider must not
/// `read`/`listen` to `authProvider`, or Auth's own
/// `ref.read(analyticsServiceProvider)` becomes a Riverpod circular
/// dependency in debug. This dedicated Dio does not inherit
/// `dio_provider`'s token interceptor, so the token is attached per POST.
class AnalyticsService {
  AnalyticsService(
    this._ref, {
    Dio? client,
    Future<String?> Function()? readAuthToken,
  }) : _readAuthToken = readAuthToken {
    _client = client ??
        Dio(
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
    if (kDebugMode && client == null) {
      _client.interceptors.add(LoggingInterceptor());
    }
    _initFuture = _init();
  }

  static const int _maxQueueSize = 500;
  static const int _batchSize = 20;
  static const Duration _flushInterval = Duration(seconds: 20);

  final Ref _ref;
  final Future<String?> Function()? _readAuthToken;
  late final Dio _client;
  late final Future<void> _initFuture;
  late final String _sessionId;
  String _deviceId = '';
  String? _userId;
  String? _userRole;
  String? _currentScreenName;

  final List<AnalyticsEvent> _queue = [];
  final List<(String, Map<String, Object?>)> _pending = [];
  bool _ready = false;
  Future<void>? _inFlightFlush;
  int _consecutiveFailures = 0;
  DateTime? _backoffUntil;

  Timer? _flushTimer;
  VoidCallback? _detachRouterListener;

  /// Completes when the persisted queue has loaded and listeners are bound.
  @visibleForTesting
  Future<void> get ready => _initFuture;

  @visibleForTesting
  Future<void> flushNow() => _flush();

  @visibleForTesting
  List<String> get queuedEventNames =>
      [for (final event in _queue) event.name];

  bool get _isSignedIn => _userId != null && _userId!.isNotEmpty;

  void _bindUser(UserEntity? user) {
    _userId = user?.id;
    _userRole = user?.role.name;
  }

  /// Pushed from the auth notifier on restore / login / logout. Must not be
  /// wired via `ref.listen(authProvider)` — that makes this provider depend
  /// on auth, and Auth reading this provider then circular-asserts in debug.
  void bindSession(UserEntity? user) {
    final wasSignedIn = _isSignedIn;
    _bindUser(user);
    if (_ready && !wasSignedIn && _isSignedIn) unawaited(_flush());
  }

  Future<void> _init() async {
    _sessionId = generateEventId();
    final prefs = await _ref.read(sharedPreferencesProvider.future);
    _deviceId = prefs.getString(PrefsKeys.analyticsDeviceId) ?? generateEventId();
    await prefs.setString(PrefsKeys.analyticsDeviceId, _deviceId);
    _loadPersistedQueue(prefs);

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

  Future<String?> _sessionToken() async {
    final readToken = _readAuthToken;
    if (readToken != null) return readToken();
    return const FlutterSecureStorage().read(key: PrefsKeys.authToken);
  }

  Future<void> _flush() async {
    final inFlight = _inFlightFlush;
    if (inFlight != null) return inFlight;
    final done = _runFlush();
    _inFlightFlush = done;
    try {
      await done;
    } finally {
      if (identical(_inFlightFlush, done)) _inFlightFlush = null;
    }
  }

  Future<void> _runFlush() async {
    if (_queue.isEmpty || !_ready) return;
    if (!_isSignedIn) return;
    final until = _backoffUntil;
    if (until != null && DateTime.now().isBefore(until)) return;
    if (!_ref.read(isOnlineProvider)) return;

    try {
      final token = await _sessionToken();
      if (!_isSignedIn || token == null || token.isEmpty) return;

      final batch = _queue.take(_batchSize).toList();
      // Backend ingest DTO is `{ "events": [ ... ] }`, not a bare array
      // and not a single event object (Postman: POST Ingest Events).
      final body = <String, dynamic>{
        'events': [for (final event in batch) event.toJson()],
      };
      final response = await _client.post<dynamic>(
        ApiEndpoints.analyticsEvents,
        data: body,
        options: LegacyRouteOptions.allowNotFound().copyWith(
          headers: {'X-Auth-Token': token},
        ),
      );
      if (LegacyRouteOptions.isNotFound(response)) {
        _registerFailure();
        return;
      }
      // 200 / any other 2xx: this batch was accepted — drop it. 404 and
      // thrown non-2xx leave the queue intact for retry.
      _queue.removeRange(0, batch.length);
      _consecutiveFailures = 0;
      _backoffUntil = null;
      await _withPrefs(_persistQueue);
    } catch (_) {
      _registerFailure();
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
