import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/prefs_keys.dart';
import '../../../../core/localization/localization_provider.dart';
import '../../../../shared/providers/shared_providers.dart';
import '../../domain/entities/user_entity.dart';
import 'auth_provider.dart';

part 'language_sync_provider.g.dart';

const _debounce = Duration(milliseconds: 500);

/// Keeps the server's `preferredLanguage` in step with the app language
/// (`PUT /api/auth/language`). Fire-and-forget: the UI switches instantly and
/// a failure is never shown.
///
/// - A user-initiated change while signed in is sent after a short debounce;
///   a newer value cancels the older one (last wins). Signed out: local only.
/// - After an explicit login (auth goes signed-out -> signed-in, which is
///   what `Auth.adoptSession` does; a cold session restore is a different
///   transition) the current language is sent once.
/// - [PrefsKeys.pendingLanguageSync] is set before sending (write-ahead) and
///   cleared only on success, so a failure, or the app being killed during
///   the debounce or the request, is retried once on the next launch when a
///   session is restored. No retry loop within a session. The flag is only
///   cleared by the latest change: an older request succeeding while a newer
///   change is still debouncing or in flight leaves it set.
/// - Storage is best-effort: a failing SharedPreferences read/write is
///   swallowed (debug log) and never stops the request being sent.
///
/// keepAlive: app-lifetime listener, started from `XstoreApp`.
@Riverpod(keepAlive: true)
void languageSync(LanguageSyncRef ref) {
  var disposed = false;
  // Bumped on every locale change and every send; a send may touch the
  // pending flag only while it is still the latest.
  var generation = 0;
  Timer? timer;
  CancelToken? inFlight;
  ref.onDispose(() {
    disposed = true;
    timer?.cancel();
    inFlight?.cancel();
  });

  // Resolved lazily on each use (not once at startup) so a storage failure
  // early in the session doesn't disable sync for the rest of it.
  Future<SharedPreferences?> getPrefs() async {
    try {
      return await ref.read(sharedPreferencesProvider.future);
    } catch (e) {
      if (kDebugMode) debugPrint('Language sync: prefs unavailable: $e');
      if (!disposed) ref.invalidate(sharedPreferencesProvider);
      return null;
    }
  }

  Future<void> setPending(bool value) async {
    try {
      final prefs = await getPrefs();
      if (prefs == null || disposed) return;
      if (value) {
        await prefs.setBool(PrefsKeys.pendingLanguageSync, true);
      } else {
        await prefs.remove(PrefsKeys.pendingLanguageSync);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Language sync: flag write failed: $e');
    }
  }

  Future<void> send(AppLanguage language) async {
    timer?.cancel();
    inFlight?.cancel();
    final token = inFlight = CancelToken();
    final mine = ++generation;
    // Superseded by a newer change/send (or disposed): that one owns the flag.
    bool stale() => token.isCancelled || disposed || mine != generation;
    // Write-ahead: a kill mid-request still leaves the retry for next launch.
    await setPending(true);
    if (stale()) return;
    var ok = false;
    try {
      await ref
          .read(authRemoteDataSourceProvider)
          .updatePreferredLanguage(
            language == AppLanguage.arabic ? 'ar' : 'en',
            cancelToken: token,
          );
      ok = true;
    } catch (e) {
      if (kDebugMode && !token.isCancelled) {
        debugPrint('Language sync failed: $e');
      }
    }
    if (stale()) return;
    // On failure the write-ahead flag simply stays set.
    if (ok) await setPending(false);
  }

  Future<void> sendIfPending() async {
    final prefs = await getPrefs();
    if (disposed || prefs?.getBool(PrefsKeys.pendingLanguageSync) != true) {
      return;
    }
    unawaited(send(ref.read(appLocaleProvider)));
  }

  Future<void> start() async {
    try {
      await ref.read(appLocaleProvider.notifier).loaded;
    } catch (_) {
      // Saved language failed to load: user changes can still be synced.
    }
    if (disposed) return;

    var startupHandled = false;
    ref.listen(authProvider, (previous, next) {
      if (next.valueOrNull == null) return;
      final explicitLogin =
          previous is AsyncData<UserEntity?> && previous.value == null;
      if (explicitLogin) {
        startupHandled = true;
        unawaited(send(ref.read(appLocaleProvider)));
      } else if (!startupHandled) {
        startupHandled = true;
        unawaited(sendIfPending());
      }
    }, fireImmediately: true);

    ref.listen(appLocaleProvider, (previous, next) {
      if (previous == next || ref.read(authProvider).valueOrNull == null) {
        return;
      }
      timer?.cancel();
      generation++;
      // Marked now so a kill during the debounce still retries next launch.
      unawaited(setPending(true));
      timer = Timer(_debounce, () {
        // Signed out during the debounce: nothing to send.
        if (ref.read(authProvider).valueOrNull == null) return;
        unawaited(send(ref.read(appLocaleProvider)));
      });
    });
  }

  unawaited(start());
}
