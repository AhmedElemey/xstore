import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:math' show min;

import 'package:amplitude_flutter/amplitude.dart';
import 'package:amplitude_flutter/autocapture/autocapture.dart';
import 'package:amplitude_flutter/configuration.dart';
import 'package:amplitude_flutter/events/base_event.dart';
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/domain/entities/user_entity.dart';
import '../../shared/providers/shared_providers.dart';
import '../config/app_config.dart';
import '../constants/prefs_keys.dart';
import '../network/api_auth_headers.dart';
import '../network/api_endpoints.dart';
import '../network/connectivity_provider.dart';
import '../network/legacy_route_options.dart';
import '../network/logging_interceptor.dart';
import '../router/app_routes.dart';
import 'analytics_event.dart';
import 'analytics_ids.dart';
import 'event_names.dart';

part 'analytics_service.g.dart';

/// Batches user-journey events locally and POSTs them to
/// `POST /api/analytics/events` — see
/// `docs_business/backend/03_ANALYTICS_EVENTS_HANDOFF.md`. The same events
/// are independently forwarded to Amplitude via the official
/// `amplitude_flutter` SDK. The API key comes from
/// `--dart-define=AMPLITUDE_API_KEY=...` when set, otherwise the flavor
/// default on [AppConfig] (dev → xStore-Dev, prod → xStore-Prod) so a
/// plain `flutter run --flavor` / VS Code launch still reports. See
/// `docs_business/backend/08_AMPLITUDE_INTEGRATION.md`.
///
/// Deliberately uses its own [Dio] client rather than the shared `dio`
/// provider: the shared client's error interceptor flips the whole app to
/// the full-screen server-error state on any 5xx, which is correct for
/// user-facing API calls but wrong for a background telemetry POST — a
/// flaky analytics endpoint must never take over the UI. Same reason this
/// client must not share [TokenRefreshInterceptor]: a 401 from telemetry
/// must back off, not log the user out.
///
/// The xStore collector is session-gated: [_flush] POSTs only while a
/// signed-in user (non-empty id + `X-Auth-Token`) is present. Guest events
/// stay in the local queue until login. Session identity is pushed in via
/// [bindSession] from the auth notifier — this provider must not
/// `read`/`listen` to `authProvider`, or Auth's own
/// `ref.read(analyticsServiceProvider)` becomes a Riverpod circular
/// dependency in debug. This dedicated Dio does not inherit
/// `dio_provider`'s token interceptor, so the token is attached per POST.
///
/// The Amplitude forwarder is intentionally NOT session-gated the same
/// way — it sends every tracked event (guest and signed-in alike) so the
/// full browse→purchase journey is visible in Amplitude, using
/// [_deviceId] as Amplitude's anonymous identity and [_userId] once
/// signed in (both passed per-event, since [AnalyticsEvent] already
/// snapshots them at enqueue time — no separate `setUserId`/`setDeviceId`
/// call is needed). Autocapture is disabled entirely
/// ([AutocaptureDisabled]) so every Amplitude event comes from an explicit
/// `track()` call here, never an SDK-generated session/lifecycle event —
/// this keeps the event catalog in
/// `docs_business/backend/03_ANALYTICS_EVENTS_HANDOFF.md` authoritative.
/// The SDK owns its own local queue, batching, and retry (see
/// `Configuration.flushQueueSize`/`flushIntervalMillis`/`flushMaxRetries`),
/// so this class does no queueing of its own for Amplitude — only [_queue]
/// (the xStore collector's queue) is ours to manage. Amplitude fails
/// independently of the xStore collector: an Amplitude outage never
/// affects [_flush] or vice versa.
///
/// Google Analytics (GA4 via `firebase_analytics`) is a third sink fed from
/// the same [_enqueue] choke point, so all three receive the identical event
/// catalog. Like Amplitude it is not session-gated and keeps its own queue;
/// identity is set on every [bindSession] via [_bindUser] (GA has no
/// per-event user id). Every call is fire-and-forget with errors swallowed:
/// an unhandled async error here would reach Crashlytics as a fatal. See
/// `docs_business/backend/09_GOOGLE_ANALYTICS_INTEGRATION.md`.
class AnalyticsService {
  AnalyticsService(
    this._ref, {
    Dio? client,
    Amplitude? amplitudeClient,
    String? amplitudeApiKey,
    FirebaseAnalytics? firebaseAnalytics,
    Future<String?> Function()? readAuthToken,
  })  : _readAuthToken = readAuthToken,
        _firebaseAnalytics = firebaseAnalytics ?? _defaultFirebaseAnalytics() {
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
    final apiKey = _resolveAmplitudeApiKey(amplitudeApiKey);
    _amplitude = amplitudeClient ??
        (apiKey.isEmpty ? null : Amplitude(amplitudeConfiguration(apiKey)));
    _initFuture = _init();
  }

  /// `minIdLength: 1` — backend user ids are short integers ("42"), and
  /// Amplitude rejects any user_id under 5 characters by default (400
  /// "Invalid id length"), which silently dropped every signed-in event.
  @visibleForTesting
  static Configuration amplitudeConfiguration(String apiKey) => Configuration(
        apiKey: apiKey,
        autocapture: const AutocaptureDisabled(),
        minIdLength: 1,
      );

  static const int _maxQueueSize = 500;
  static const int _batchSize = 20;
  static const Duration _flushInterval = Duration(seconds: 20);

  /// Constructor [amplitudeApiKey] wins (tests). Else dart-define. Else
  /// the flavor default so local `flutter run` is not silently off.
  static String _resolveAmplitudeApiKey(String? override) {
    if (override != null) return override;
    const fromEnv = String.fromEnvironment('AMPLITUDE_API_KEY');
    if (fromEnv.isNotEmpty) return fromEnv;
    return AppConfig.maybeFlavor?.amplitudeApiKey ?? '';
  }

  /// Null when Firebase was never initialized (unit tests, or a bootstrap
  /// that failed before `Firebase.initializeApp`) — GA is then just off.
  static FirebaseAnalytics? _defaultFirebaseAnalytics() {
    try {
      return Firebase.apps.isEmpty ? null : FirebaseAnalytics.instance;
    } catch (_) {
      return null;
    }
  }

  final Ref _ref;
  final Future<String?> Function()? _readAuthToken;
  late final Dio _client;
  late final Amplitude? _amplitude;
  final FirebaseAnalytics? _firebaseAnalytics;
  late final Future<void> _initFuture;
  late final String _sessionId;
  late final int _sessionStartMs;
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
  Future<void> flushNow() =>
      Future.wait([_flush(), _amplitude?.flush() ?? Future<void>.value()]);

  @visibleForTesting
  List<String> get queuedEventNames =>
      [for (final event in _queue) event.name];

  bool get _isSignedIn => _userId != null && _userId!.isNotEmpty;

  void _bindUser(UserEntity? user) {
    _userId = user?.id;
    _userRole = user?.role.name;
    // Unconditional: GA persists the user id natively across launches, so a
    // cold start that restores no session must still clear it.
    _toFirebase((ga) async {
      await ga.setUserId(id: _userId);
      await ga.setUserProperty(name: AnalyticsProps.role, value: _userRole);
    });
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
    _sessionStartMs = DateTime.now().millisecondsSinceEpoch;
    final prefs = await _ref.read(sharedPreferencesProvider.future);
    _deviceId = prefs.getString(PrefsKeys.analyticsDeviceId) ?? generateEventId();
    await prefs.setString(PrefsKeys.analyticsDeviceId, _deviceId);
    _loadPersistedQueue(prefs);
    // The SDK dispatches 'init' over its platform channel here — awaited so
    // no track() call races construction (matches the SDK's own documented
    // `await amplitude.isBuilt;` usage).
    await _amplitude?.isBuilt;

    _ref.listen<bool>(isOnlineProvider, (prev, next) {
      if (next && prev == false) {
        unawaited(_flush());
        unawaited(_amplitude?.flush());
      }
    });

    _ready = true;
    if (kDebugMode) {
      debugPrint(
        _amplitude != null
            ? 'Amplitude: forwarding events'
            : 'Amplitude: disabled (no API key)',
      );
    }
    for (final p in _pending) {
      _enqueue(p.$1, p.$2);
    }
    _pending.clear();
    // Fires exactly once per process start — this service is a keepAlive
    // provider created once for the app's lifetime, so _init() runs once.
    // Does not cover foreground-resume from background (no
    // WidgetsBindingObserver wired for that yet); cold start covers the
    // large majority of "app opened" sessions.
    track(AnalyticsEvents.appOpen);

    _flushTimer = Timer.periodic(_flushInterval, (_) {
      unawaited(_flush());
      unawaited(_amplitude?.flush());
    });
    unawaited(_flush());
    unawaited(_amplitude?.flush());
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

    // Not queued on our side — the SDK owns its own local queue/batching/
    // retry (Configuration.flushQueueSize/flushIntervalMillis/
    // flushMaxRetries), so a single track() call here is the whole job.
    final amplitude = _amplitude;
    if (amplitude != null) {
      unawaited(amplitude.track(_amplitudeBaseEvent(event)));
    }
    _toFirebase((ga) => _logToFirebase(ga, event));
  }

  /// Runs [call] against GA when it is configured, fire-and-forget. Errors
  /// (sync or async) are swallowed — GA must never fail a `track()` caller
  /// or surface as an uncaught zone error.
  void _toFirebase(Future<void> Function(FirebaseAnalytics ga) call) {
    final ga = _firebaseAnalytics;
    if (ga == null) return;
    unawaited(
      Future.sync(() => call(ga)).catchError((Object e) {
        if (kDebugMode) debugPrint('Google Analytics: $e');
      }),
    );
  }

  /// GA4 limits: string values up to 100 chars, only String/num values
  /// (no bool/null), and `screen_view` is reserved — it must go through
  /// [FirebaseAnalytics.logScreenView]. Every catalog name is already a
  /// valid GA4 name (snake_case, under 40 chars, no reserved prefix).
  /// `purchase` gets GA's `value` + `transaction_id` (`currency` is already
  /// sent as `EGP`) so it lands in GA revenue reports, mirroring Amplitude's
  /// `revenue`.
  Future<void> _logToFirebase(FirebaseAnalytics ga, AnalyticsEvent event) {
    final parameters = <String, Object>{};
    void put(String key, Object? value) {
      switch (value) {
        case null:
          return;
        case num n:
          parameters[key] = n;
        case bool b:
          parameters[key] = b ? 'true' : 'false';
        default:
          final text = value.toString();
          parameters[key] = text.length > 100 ? text.substring(0, 100) : text;
      }
    }

    put(AnalyticsProps.screenName, event.screenName);
    event.properties.forEach(put);
    final revenue = _revenueOf(event);
    if (revenue != null) {
      put('value', revenue);
      put('transaction_id', event.properties[AnalyticsProps.orderId]);
    }

    if (event.name == AnalyticsEvents.screenView) {
      final screenName = parameters.remove(AnalyticsProps.screenName);
      return ga.logScreenView(
        screenName: screenName as String?,
        parameters: parameters,
      );
    }
    return ga.logEvent(name: event.name, parameters: parameters);
  }

  /// Wires automatic `screen_view` tracking off go_router's route-change
  /// notifications — avoids touching every one of the ~60 `GoRoute`
  /// definitions in `app_router.dart` to name each page. Idempotent: safe
  /// to call again when the router is rebuilt (role switch recreates
  /// [GoRouter] in `app_router.dart`).
  ///
  /// `referrer` (the previous route) is how a product view is attributed to
  /// home / explore / wishlist / store without instrumenting every product
  /// link with a `select_item` event.
  void attachRouter(GoRouter router) {
    _detachRouterListener?.call();
    final provider = router.routeInformationProvider;
    String? last;
    void onChange() {
      final uri = provider.value.uri.toString();
      if (uri == last) return;
      final referrer = last;
      last = uri;
      _onRouteChanged(uri, referrer: referrer);
    }

    provider.addListener(onChange);
    _detachRouterListener = () => provider.removeListener(onChange);
    onChange();
  }

  void _onRouteChanged(String uri, {String? referrer}) {
    _currentScreenName = uri;
    track(AnalyticsEvents.screenView, properties: {
      AnalyticsProps.screenName: uri,
      if (referrer != null) AnalyticsProps.referrer: referrer,
    });
    // A couple of funnel-critical routes also get a named event alongside
    // the generic screen_view, so a funnel chart doesn't need a
    // screen_name filter step — mirrors how begin_checkout/purchase are
    // already named events rather than relying on screen_view alone.
    if (uri == AppRoutes.cart) {
      track(AnalyticsEvents.cartViewed);
    }
  }

  /// Exercises the exact route-change logic [attachRouter] wires to
  /// go_router, without needing a real [GoRouter] instance in tests.
  @visibleForTesting
  void debugRouteChanged(String uri, {String? referrer}) =>
      _onRouteChanged(uri, referrer: referrer);

  /// Sends the xStore collector queue while the session token is still
  /// valid — called from `Auth.logout` before the remote logout revokes it,
  /// so `logout` (and anything else pending) is not stranded until the next
  /// login. Amplitude needs no token, so its SDK queue is left to itself.
  /// Bounded so a slow network never holds up signing out.
  Future<void> flushBeforeSignOut() async {
    Future<void> drain() async {
      // A flush already in flight may have started before `logout` was
      // queued; let it finish so the loop below starts a fresh one.
      await _inFlightFlush;
      while (_queue.isNotEmpty) {
        final before = _queue.length;
        await _flush();
        if (_queue.length >= before) return; // offline, backoff or failed
      }
    }

    await drain().timeout(const Duration(seconds: 3), onTimeout: () {});
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

      // Events stamped for a different account (left over from a previous
      // login on this device) would be attributed to this session's token —
      // drop them. Guest events (null userId) stay: the session identity is
      // stamped onto them below, stitching the pre-login journey.
      _queue.removeWhere((e) => e.userId != null && e.userId != _userId);
      if (_queue.isEmpty) return;
      final batch = _queue.take(_batchSize).toList();
      // Backend ingest DTO is `{ "events": [ ... ] }`, not a bare array
      // and not a single event object (Postman: POST Ingest Events).
      final body = <String, dynamic>{
        'events': [
          for (final event in batch)
            event.toJson(
              fallbackUserId: _userId,
              fallbackUserRole: _userRole,
              fallbackScreenName: _currentScreenName,
            ),
        ],
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

  String get _amplitudePlatform {
    try {
      return Platform.isIOS ? 'iOS' : (Platform.isAndroid ? 'Android' : 'Other');
    } catch (_) {
      return 'Other';
    }
  }

  /// Amplitude's revenue dashboards read the top-level `revenue` field, not
  /// an `event_properties` entry — only `purchase` carries a numeric
  /// `value_egp`, so this is the one event that populates it.
  num? _revenueOf(AnalyticsEvent event) {
    if (event.name != AnalyticsEvents.purchase) return null;
    final value = event.properties[AnalyticsProps.valueEgp];
    if (value is num) return value;
    if (value is String) return num.tryParse(value);
    return null;
  }

  /// Builds the SDK event for [event]. [BaseEvent] takes `userId`/`deviceId`/
  /// `sessionId`/`insertId`/`revenue`/`revenueType`/`userProperties` directly
  /// as constructor fields — no separate `Identify`/`Revenue` call needed,
  /// mirroring exactly what the old hand-built JSON payload sent.
  BaseEvent _amplitudeBaseEvent(AnalyticsEvent event) {
    final screenName = event.screenName;
    final revenue = _revenueOf(event);
    return BaseEvent(
      event.name,
      userId: event.userId,
      deviceId: event.deviceId,
      timestamp: event.occurredAt.millisecondsSinceEpoch,
      insertId: event.eventId, // dedupe key — safe for the SDK to retry
      sessionId: _sessionStartMs,
      platform: _amplitudePlatform,
      revenue: revenue?.toDouble(),
      revenueType: revenue != null ? 'purchase' : null,
      eventProperties: {
        if (screenName != null) 'screen_name': screenName,
        ...event.properties,
      },
      userProperties: event.userRole != null ? {'role': event.userRole} : null,
    );
  }

  void dispose() {
    _flushTimer?.cancel();
    _detachRouterListener?.call();
    _client.close();
    // Amplitude has no dispose()/close() — it's a thin MethodChannel proxy
    // with no Dart-side resources; the native SDK flushes on app close
    // itself (see Amplitude.track's doc comment).
  }
}

@Riverpod(keepAlive: true)
AnalyticsService analyticsService(AnalyticsServiceRef ref) {
  final service = AnalyticsService(ref);
  ref.onDispose(service.dispose);
  return service;
}
