# Prompt for Cursor: Fix mock-mode regression from the Firebase→backend session bridge

Copy everything below into Cursor's chat/agent at the repo root.

---

## Context

A previous change wired Firebase-authenticated social/phone logins through to the backend by adding a Firebase ID token exchange in `lib/features/auth/data/repositories/auth_repository_impl.dart` (`_exchangeSocialToken`, `_requireFirebaseIdToken`, and the phone branch of `verifyOtp`). That change introduced a regression: **every social login (Google/Apple/Facebook) and every phone OTP verification now fails whenever `MockConfig.useMock` is `true`** — which is the app's default (`bool.fromEnvironment('MOCK', defaultValue: true)` in `lib/core/mock/mock_config.dart`), and is also what the release APK CI workflow always builds with.

## Root cause

`_requireFirebaseIdToken()` in `auth_repository_impl.dart` unconditionally does:

```dart
Future<String> _requireFirebaseIdToken() async {
  final token = await _firebaseAuth.currentUser?.getIdToken();
  if (token == null || token.isEmpty) {
    throw const AuthException('Firebase session missing after sign-in');
  }
  return token;
}
```

But `lib/features/auth/data/datasources/social_auth_datasource.dart` and `lib/features/auth/data/datasources/phone_auth_datasource.dart` both short-circuit on `MockConfig.useMock` *before ever calling `FirebaseAuth`* — they return a fake `SocialAuthResult`/`UserEntity` directly, so no real Firebase session exists. `AuthRepositoryImpl` defaults to the real `FirebaseAuth.instance` and has no `MockConfig` import at all, so it always demands a real Firebase ID token, which doesn't exist in mock mode. Result: `signInWithGoogle`/`signInWithApple`/`signInWithFacebook`/`verifyOtp` all throw `AuthException('Firebase session missing after sign-in')` in mock mode instead of succeeding.

The test added alongside that change (`test/auth_repository_impl_test.dart`) didn't catch this because it injects a `_FakeFirebaseAuth` with a non-null current user directly into the repository — it never reproduces the real default wiring where the repository uses `FirebaseAuth.instance` while the datasources independently mock-shortcut.

## Fix

In `lib/features/auth/data/repositories/auth_repository_impl.dart`:

1. Import `MockConfig` (`import '../../../../core/mock/mock_config.dart';` — match the relative path used elsewhere in this file).
2. Update `_requireFirebaseIdToken()` to short-circuit in mock mode, matching the pattern every other datasource in this codebase already uses for `MockConfig.useMock`:
   ```dart
   Future<String> _requireFirebaseIdToken() async {
     if (MockConfig.useMock) return 'mock-firebase-id-token';
     final token = await _firebaseAuth.currentUser?.getIdToken();
     if (token == null || token.isEmpty) {
       throw const AuthException('Firebase session missing after sign-in');
     }
     return token;
   }
   ```
   This is safe because `AuthRemoteDataSourceImpl.loginWithSocialToken` / `loginWithPhoneToken` (in `auth_remote_datasource.dart`) already have their own `MockConfig.useMock` branches that return a mock `UserModel` without inspecting the token value — the placeholder is never sent anywhere real.

## Verify

- Add a test (or extend `test/auth_repository_impl_test.dart`) that specifically covers the *default* wiring — i.e. constructs `AuthRepositoryImpl` without overriding `firebaseAuth` (so it falls back to `FirebaseAuth.instance`) while `MockConfig.useMock` is `true`, and asserts `signInWithGoogle()` / `verifyOtp()` succeed instead of returning a `Failure`. This is the exact scenario the existing tests missed.
- Run the full test suite (`flutter test`) and confirm nothing else regresses.
- Manually sanity-check (or note if you can't run the app) that with default config (no `--dart-define=MOCK=...` passed, so `MOCK` defaults to `true`), tapping each social sign-in button and completing phone OTP entry both still succeed and land the user on the expected screen.

## Scope

Only touch what's needed to fix this regression (the `_requireFirebaseIdToken` guard, its test coverage, and the `MockConfig` import). Don't change the token-exchange logic itself, the new backend endpoints, or unrelated files.
