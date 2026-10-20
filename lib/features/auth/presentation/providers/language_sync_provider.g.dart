// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'language_sync_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$languageSyncHash() => r'ce0ed737606b7c11e21116d1d3d49ea12cbfbd9a';

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
///
/// Copied from [languageSync].
@ProviderFor(languageSync)
final languageSyncProvider = Provider<void>.internal(
  languageSync,
  name: r'languageSyncProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$languageSyncHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef LanguageSyncRef = ProviderRef<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
