# Prompt for Cursor: Remaining Firebase integration hardening

Copy everything below into Cursor's chat/agent at the repo root.

---

## Context

A prior pass wired Firebase-authenticated social/phone logins through to the backend (`lib/features/auth/data/repositories/auth_repository_impl.dart`) and fixed a mock-mode regression where `_requireFirebaseIdToken()` broke every social/phone login under the app's default `MOCK=true` config. That's done and covered by `test/auth_repository_impl_test.dart`. Three items remain from the original Firebase integration review. Treat them as independent — implement each as its own small, targeted change, don't mix them into one commit-sized diff, and don't touch unrelated code.

Key files:
- `.github/workflows/ci.yml`
- `lib/core/mock/mock_config.dart`
- `lib/features/auth/data/datasources/social_auth_datasource.dart`
- `lib/features/auth/data/datasources/phone_auth_datasource.dart`
- `ios/Runner/Info.plist`
- `ios/Runner/GoogleService-Info.plist`
- `android/app/src/main/res/values/strings.xml`
- `lib/main.dart`
- `pubspec.yaml`

## 1. Add a CI job that exercises real Firebase code paths (`MOCK=false`)

Right now every CI job and the release APK workflow build/test with `MOCK=true` (or the default, which is also `true` — see `lib/core/mock/mock_config.dart`), so the actual Firebase-backed code in `social_auth_datasource.dart` / `phone_auth_datasource.dart` / the token-exchange logic in `auth_repository_impl.dart` is never exercised by CI. That's exactly how the mock-mode regression slipped in unnoticed until manual review.

- In `.github/workflows/ci.yml`, add a test job (or a step in the existing Flutter test job) that runs `flutter test --dart-define=MOCK=false`, so the tests in `test/auth_repository_impl_test.dart` currently skipped with `skip: MockConfig.useMock ? 'Requires MOCK=false' : false` actually run.
- This job doesn't need real Firebase network access — those tests already inject fake `FirebaseAuth`/`SocialAuthDatasource`/`PhoneAuthDatasource`/`AuthRemoteDataSource` implementations, so `MOCK=false` just forces the code down the "real" branch inside `AuthRepositoryImpl` while everything below it stays faked. Confirm this is true by reading `test/auth_repository_impl_test.dart` before wiring the job — don't add a job that requires live Firebase credentials in CI.
- Keep the existing `MOCK=true` (default) test run as-is; add the `MOCK=false` run alongside it, not instead of it, so both code paths get coverage on every PR.

## 2. Fill in real Facebook + Google iOS config

These are currently placeholder strings and will fail at runtime:
- `ios/Runner/Info.plist`: the `CFBundleURLSchemes` entry `REPLACE_WITH_GOOGLE_REVERSED_IOS_CLIENT_ID` should be the `REVERSED_CLIENT_ID` value already present in `ios/Runner/GoogleService-Info.plist` — read it from that file and substitute it in, no external lookup needed. Also replace `fbREPLACE_WITH_FACEBOOK_APP_ID`, `FacebookAppID`, and `FacebookClientToken` with the real values from the Meta developer console for this app.
- `android/app/src/main/res/values/strings.xml`: replace `facebook_app_id`, `facebook_client_token`, and `fb_login_protocol_scheme` (`fb` + numeric app id) the same way.

Important: you cannot obtain the real Facebook App ID/Client Token from this repo — those live in the Meta developer console. Don't fabricate plausible-looking values. If you don't have them:
- Fix the Google reversed client ID substitution now (that value is derivable from `GoogleService-Info.plist`, already in the repo).
- Leave the Facebook placeholders in place, but add a `// TODO` comment at each site linking them together (Info.plist + strings.xml + AndroidManifest.xml's `com.facebook.sdk.ApplicationId`/`ClientToken` meta-data) so whoever has console access can find every spot that needs updating, and say so explicitly in your final summary.

## 3. Add Firebase App Check

`google-services.json`, `GoogleService-Info.plist`, and `firebase_options.dart` are committed with live (non-secret-by-design, but still exposed) API keys, and nothing currently stops those exposed configs from being reused by an unauthorized client.

- Add `firebase_app_check` to `pubspec.yaml` (pin to a version compatible with the existing `firebase_core: ^3.3.0` / `firebase_auth: ^5.1.4`).
- In `lib/main.dart`'s `bootstrap()`, right after `await Firebase.initializeApp(options: DefaultFirebaseOptions.forFlavor(flavor));`, initialize App Check:
  ```dart
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
    appleProvider: AppleProvider.appAttest,
  );
  ```
  Use `AndroidProvider.debug` / `AppleProvider.debug` when `flavor.isDev` (check how `AppFlavor` exposes that — see `lib/core/config/app_flavor.dart`) so local/dev builds don't require a real Play Integrity / App Attest attestation.
- This is a client-side change only. Note explicitly in your summary that Play Integrity and App Attest must also be **enabled for this app in the Firebase console** (Project Settings → App Check) — that's a console-side step you can't do from the repo, and until it's done, App Check runs in a permissive/unenforced mode.

---

## Output expectations

- Three separate, small diffs — one per numbered item.
- Don't fabricate Facebook credentials, Firebase console settings, or CI secrets. Where a step needs something only available outside the repo (Meta console values, Firebase console App Check enrollment), implement everything that can be done from the repo and call out what's left in your final summary.
- Run `flutter test` (both with and without `--dart-define=MOCK=false`) after each change and report the result.
