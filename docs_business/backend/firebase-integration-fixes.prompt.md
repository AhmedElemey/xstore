# Prompt for Cursor: Fix Firebase Auth integration in xStore

Copy everything below into Cursor's chat/agent (Cmd+K or Composer) at the repo root.

---

## Context

This is a Flutter app (xStore) that uses `firebase_auth` + `firebase_core` for phone/OTP and social (Google/Apple/Facebook) sign-in, alongside a separate custom REST backend (via Dio) used for email/password login/register (`POST /auth/login`, `POST /auth/register`). A review of the Firebase integration surfaced several real gaps. Fix them in priority order below. Don't refactor unrelated code, don't add abstractions beyond what's needed, and keep existing code style/patterns (Riverpod providers, `fpdart` `Either<Failure, T>`, freezed entities).

Key files:
- `lib/core/firebase/firebase_options.dart`
- `lib/core/network/dio_provider.dart`
- `lib/core/network/api_endpoints.dart`
- `lib/features/auth/data/datasources/social_auth_datasource.dart`
- `lib/features/auth/data/datasources/phone_auth_datasource.dart`
- `lib/features/auth/data/datasources/auth_remote_datasource.dart`
- `lib/features/auth/data/repositories/auth_repository_impl.dart`
- `lib/features/auth/domain/entities/social_auth_result.dart`
- `ios/Runner/Info.plist`
- `android/app/src/main/res/values/strings.xml`
- `lib/core/mock/mock_config.dart`

## 1. (Critical) Bridge Firebase-authenticated users into the app's own backend session

Right now `signInWithGoogle` / `signInWithApple` / `signInWithFacebook` in `social_auth_datasource.dart`, and `verifyOtp` in `phone_auth_datasource.dart`, authenticate the user against Firebase only and return a `SocialAuthResult` / `UserEntity` straight to the UI. `AuthRepositoryImpl` never calls `_remote` for these flows, so the backend never issues a session token, and `persistSessionUser` in `auth_repository_impl.dart` ends up persisting a user with `token: null`. Since `dio_provider.dart`'s request interceptor only attaches `Authorization: Bearer <token>` when a token exists in secure storage, every authenticated API call after a social/phone login goes out unauthenticated.

Fix:
- Add a new backend endpoint constant in `api_endpoints.dart`, e.g. `static const String socialLogin = '/auth/social';` and `static const String phoneLogin = '/auth/phone';` (confirm actual route names with backend team if they differ — flag with a `// TODO(backend):` comment if you have to guess).
- Add methods to `AuthRemoteDataSource` (interface + impl in `auth_remote_datasource.dart`), e.g.:
  ```dart
  Future<UserModel> loginWithSocialToken({required String provider, required String idToken});
  Future<UserModel> loginWithPhoneToken({required String firebaseIdToken, required String phoneNumber});
  ```
  These should POST the Firebase ID token (get it via `await FirebaseAuth.instance.currentUser?.getIdToken()` right after `signInWithCredential` succeeds) to the backend, which is expected to verify it server-side (via Firebase Admin SDK) and return a `UserModel` including a backend-issued `token`, matching the shape already returned by `login`/`register`.
- Wire `AuthRepositoryImpl.signInWithGoogle/Apple/Facebook` and `verifyOtp` to call the new remote methods after the Firebase step succeeds, then `_persistUser(model)` exactly like `login`/`register` already do, so the resulting session has a real bearer token.
- Respect `MockConfig.useMock` in the new remote methods the same way `login`/`register` already do (return a mock `UserModel` with a fake token).
- Keep `SocialAuthResult`/`UserEntity` shapes as-is; just make sure the final persisted user carries a non-null `token` for every login path, not just email/password.

If you're not sure what the real backend contract is, implement the client side against the pattern above and leave a clearly marked `// TODO(backend): confirm endpoint + payload shape` rather than guessing silently.

## 2. (High) Fill in real Facebook + Google iOS config

These are currently placeholder strings and will fail at runtime:
- `ios/Runner/Info.plist`: replace `REPLACE_WITH_GOOGLE_REVERSED_IOS_CLIENT_ID` (the `CFBundleURLSchemes` entry under the first `CFBundleURLTypes` dict) with the real reversed iOS OAuth client ID from `GoogleService-Info.plist`'s `REVERSED_CLIENT_ID` key. Also replace `REPLACE_WITH_FACEBOOK_APP_ID` (both `fbREPLACE_WITH_FACEBOOK_APP_ID` URL scheme and `FacebookAppID`) and `REPLACE_WITH_FACEBOOK_CLIENT_TOKEN` with real values from the Meta developer console.
- `android/app/src/main/res/values/strings.xml`: replace `facebook_app_id`, `facebook_client_token`, and `fb_login_protocol_scheme` (`fb` + numeric app id) the same way.

Don't invent values — if you don't have the real Facebook App ID/Client Token or Google reversed client ID, leave the placeholders in place but add a loud `TODO` comment and call it out explicitly in your summary at the end, rather than making up plausible-looking fake IDs.

## 3. (Medium) Register the missing iOS dev Firebase app

`firebase_options.dart` documents that iOS dev (`com.xstore.app.dev`) has no registered Firebase app, so `forFlavor` currently falls back to the **prod** iOS Firebase config for dev builds (see the comment block at the top of the file and the `TargetPlatform.iOS` case in `_forPlatform`). This needs the actual Firebase CLI run, which you (Cursor) can't do without credentials — so:
- Don't fabricate a `iosDev` `FirebaseOptions` block with fake keys.
- Instead, leave a clear runnable checklist in the file (it's mostly already there) and skip this item in code — just confirm the comment accurately reflects that dev iOS intentionally shares the prod project until the 4th app is registered.

## 4. (Medium) Make sure real-Firebase paths get exercised somewhere in CI

Right now `MockConfig.useMock` defaults to `true` and the release APK workflow always builds with `--dart-define=MOCK=true`, so none of the above code ever actually runs against real Firebase in CI.
- Add (or extend) a CI job / test target that builds or runs relevant auth unit/widget tests with `--dart-define=MOCK=false` using fake/test Firebase credentials or mocked `FirebaseAuth` (e.g. via `firebase_auth_mocks` or by injecting a fake `FirebaseAuth` into `PhoneAuthDatasourceImpl`/`SocialAuthDatasourceImpl`, which already accept an optional `FirebaseAuth` in their constructors for exactly this purpose).
- If a full integration test is out of scope, at minimum add unit tests for `AuthRepositoryImpl.signInWithGoogle/Apple/Facebook` and `verifyOtp` that assert a backend token-exchange call happens after the Firebase credential step succeeds (this also acts as a regression test for fix #1).

## 5. (Low) Add Firebase App Check

`google-services.json`, `GoogleService-Info.plist`, and `firebase_options.dart` are committed with live (non-secret-by-design, but still exposed) API keys and no App Check configured. Add the `firebase_app_check` package and initialize it in `main.dart`'s `bootstrap()` right after `Firebase.initializeApp(...)`, using Play Integrity on Android and DeviceCheck/App Attest on iOS. If you can't verify these values are enrolled in App Check on the Firebase console side, add the client-side initialization and note in your summary that console-side enrollment is still needed.

## 6. (Low) Use Android's SMS auto-retrieval callback

In `phone_auth_datasource.dart`, `sendOtp`'s `verificationCompleted: (_) {}` callback is currently a no-op, so Android's automatic SMS-code verification path (where Firebase can sign the user in without them typing the OTP) is silently discarded. Update `verificationCompleted` to complete the `Completer` by signing in with the auto-retrieved `PhoneAuthCredential` directly (mirroring what `verifyOtp` does with a manually-entered code), and make sure the OTP-entry screen handles the case where verification already completed before the user typed anything (e.g. by exposing this via `SendOtpResult` or a callback so the UI can skip straight to success).

---

## Output expectations

- Make the changes as small, targeted diffs per numbered item above.
- Do not touch files/behavior outside of what's described.
- At the end, summarize per-item what was done vs. what needs a human (real Facebook/Google credentials, backend endpoint confirmation, Firebase console App Check enrollment, `flutterfire configure` for iOS dev) — don't silently fabricate credentials or endpoints to make the diff look complete.
