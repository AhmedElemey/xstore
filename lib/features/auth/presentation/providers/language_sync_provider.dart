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
///   session is restored. No retry loop within a session.
///
/// keepAlive: app-lifetime listener, started from `XstoreApp`.
@Riverpod(keepAlive: true)
void languageSync(LanguageSyncRef ref) {
  var disposed = false;
  Timer? timer;
  CancelToken? inFlight;
  ref.onDispose(() {
    disposed = true;
    timer?.cancel();
    inFlight?.cancel();
  });

  Future<void> send(SharedPreferences prefs, AppLanguage language) async {
    timer?.cancel();
    inFlight?.cancel();
    final token = inFlight = CancelToken();
    // Write-ahead: a kill mid-request still leaves the retry for next launch.
    await prefs.setBool(PrefsKeys.pendingLanguageSync, true);
    if (token.isCancelled || disposed) return;
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
    // Superseded by a newer send (or disposed): that one owns the flag.
    if (token.isCancelled || disposed) return;
    if (ok) {
      await prefs.remove(PrefsKeys.pendingLanguageSync);
    } else {
      await prefs.setBool(PrefsKeys.pendingLanguageSync, true);
    }
  }

  Future<void> start() async {
    final notifier = ref.read(appLocaleProvider.notifier);
    final SharedPreferences prefs;
    try {
      await notifier.loaded;
      prefs = await ref.read(sharedPreferencesProvider.future);
    } catch (_) {
      return;
    }
    if (disposed) return;

    var startupHandled = false;
    ref.listen(authProvider, (previous, next) {
      if (next.valueOrNull == null) return;
      final explicitLogin =
          previous is AsyncData<UserEntity?> && previous.value == null;
      if (explicitLogin) {
        startupHandled = true;
        unawaited(send(prefs, ref.read(appLocaleProvider)));
      } else if (!startupHandled) {
        startupHandled = true;
        if (prefs.getBool(PrefsKeys.pendingLanguageSync) == true) {
          unawaited(send(prefs, ref.read(appLocaleProvider)));
        }
      }
    }, fireImmediately: true);

    ref.listen(appLocaleProvider, (previous, next) {
      if (previous == next || ref.read(authProvider).valueOrNull == null) {
        return;
      }
      timer?.cancel();
      // Marked now so a kill during the debounce still retries next launch.
      unawaited(prefs.setBool(PrefsKeys.pendingLanguageSync, true));
      timer = Timer(_debounce, () {
        // Signed out during the debounce: nothing to send.
        if (ref.read(authProvider).valueOrNull == null) return;
        unawaited(send(prefs, ref.read(appLocaleProvider)));
      });
    });
  }

  unawaited(start());
}
