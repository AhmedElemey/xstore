// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'language_sync_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$languageSyncHash() => r'6f712c62472363b08b5279bdc118afd25f5ec76b';

/// Keeps the server's `preferredLanguage` in step with the app language
/// (`PUT /api/auth/language`). Fire-and-forget: the UI switches instantly and
/// a failure is never shown.
///
/// - A user-initiated change while signed in is sent after a short debounce;
///   a newer value cancels the older one (last wins). Signed out: local only.
/// - After an explicit login (auth goes signed-out -> signed-in, which is
///   what `Auth.adoptSession` does; a cold session restore is a different
///   transition) the current language is sent once.
/// - A failed send sets [PrefsKeys.pendingLanguageSync]; the next launch
///   retries once when a session is restored. No retry loop within a session.
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
