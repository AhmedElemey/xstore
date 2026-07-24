# xStore

Cross-platform Flutter marketplace application (consumer and vendor flows: catalog, listings, cart, checkout, orders, store hours, and social/email/phone authentication).

## Project overview

- **Architecture:** Feature-first layering (`data` / `domain` / `presentation`) with Riverpod for state and `go_router` for navigation.
- **Networking:** Dio client with Bearer tokens from secure storage (`lib/core/network/dio_provider.dart`). A `401` response clears persisted auth tokens and invalidates session state so redirects send the user to login.
- **Localization:** Generated `AppLocalizations` (`lib/core/localization/`); templates live in `lib/l10n/`. Run code generation after editing ARB files (see below).
- **Mock vs live data:** Controlled with compile-time `--dart-define` keys (see tables below). Offline-friendly UI work can keep `MOCK=true` in debug; integration and release builds should use real APIs (`MOCK=false`) and a valid `API_BASE_URL`.

---

## Compile-time configuration (`dart-define`)

These values are baked in at **compile time** (not `.env` at runtime unless you wrap Flutter with a loader yourself).

### Required for production

| Define | Meaning |
| ------ | ------- |
| `API_BASE_URL` | Origin of your HTTP API (**no trailing slash**), e.g. `https://api.example.com`. **Release builds assert** if this is missing or blank. Debug/profile defaults to `http://localhost:8080` when unset. |

Examples:

```bash
flutter run --dart-define=API_BASE_URL=https://192.168.1.50:8443 --dart-define=MOCK=false
flutter build ipa --dart-define=API_BASE_URL=https://api.example.com --dart-define=MOCK=false
```

### Optional

| Define | Meaning |
| ------ | ------- |
| `MOCK` | `'true'` / `'false'`. **`MOCK=true` is honoured only outside release** (`!kReleaseMode`), per `MockConfig.useMock`. Use it for local UX with bundled/offline mocks. Omit or pass `MOCK=false` when exercising real backends. |

---

## Running the app

**Debug against a LAN API**

```bash
flutter run --dart-define=API_BASE_URL=https://192.168.1.10:8443 --dart-define=MOCK=false
```

**Debug with mock-friendly behaviour** (catalog and other mock paths guarded by `MockConfig`)

```bash
flutter run --dart-define=MOCK=true
```

After changing **`lib/l10n/*.arb`**:

```bash
flutter gen-l10n
```

When you edit Riverpod/Freezed‑annotated code:

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## Tests

```bash
flutter test          # Full suite
flutter analyze       # Static analysis (run before merges)
```

Key areas covered by automated tests:

- Shared form validators (`test/validators_test.dart`)
- Router redirect helpers (`computeXStoreAuthRedirect` in `test/auth_redirect_and_providers_test.dart`)
- Cart totals and coupon math (`test/cart_totals_test.dart`)
- Store hours schedule validation helpers (`test/store_hours_validator_test.dart`)
- Representative auth/cart/order provider failure paths (`test/auth_redirect_and_providers_test.dart`)

---

## Building and releasing

### Android (go-task)

[go-task](https://taskfile.dev) wraps flavor-specific release APK builds. Install Task (`brew install go-task` on macOS), then from the project root:

```bash
task build:dev    # dev APK  → build/app/outputs/flutter-apk/app-dev-release.apk
task build:prod   # prod APK → build/app/outputs/flutter-apk/app-prod-release.apk
task build:all    # both, in sequence
task clean        # flutter clean && flutter pub get
```

Default API origins are set in **`Taskfile.yml`** (`vars.API_BASE_URL_DEV` / `API_BASE_URL_PROD`). No real URLs are committed to the repo — replace the `CHANGE_ME` placeholders in that file, or override at call time:

```bash
API_BASE_URL_DEV=https://staging-api.example.com task build:dev
API_BASE_URL_PROD=https://api.example.com task build:prod
```

Release builds need **`android/key.properties`** and a local release keystore (see [Android deployment](https://docs.flutter.dev/deployment/android#signing-the-app)). CI uses GitHub Actions secrets instead.

Equivalent raw Flutter commands:

```bash
flutter build apk --release --flavor dev -t lib/main_dev.dart \
  --dart-define=API_BASE_URL=https://your.api.host --dart-define=MOCK=false

flutter build apk --release --flavor prod -t lib/main_prod.dart \
  --dart-define=API_BASE_URL=https://your.api.host --dart-define=MOCK=false
```

### Android (manual)

Debug APK:

```bash
flutter build apk --dart-define=API_BASE_URL=https://your.api.host --dart-define=MOCK=false
```

Google Play bundle:

```bash
flutter build appbundle --dart-define=API_BASE_URL=https://your.api.host --dart-define=MOCK=false
```

Configure signing keys in **`android/key.properties`** and matching `build.gradle.kts` / keystore references as documented in the Flutter [Android deployment](https://docs.flutter.dev/deployment/android) guide.

### iOS

Requires Xcode + CocoaPods. From the project root:

```bash
cd ios && pod install && cd ..
flutter build ipa --dart-define=API_BASE_URL=https://your.api.host --dart-define=MOCK=false
```

Use Xcode Organizer or `xcrun altool`/Transporter for App Store uploads. Maintain **distinct** provisioning profiles per environment (`dev`, `staging`, `prod`).

---

## Social authentication setup (Google, Apple, Facebook)

The app bundles:

- **`google_sign_in`**
- **`sign_in_with_apple`**
- **`flutter_facebook_auth`**
- **Firebase Auth** (`firebase_core`, `firebase_auth`)

Concrete steps vary by Firebase/Meta/Google Cloud projects; at minimum you must:

### Google Sign-In

1. Register iOS/Android OAuth client IDs for your Firebase (or GCP) project.
2. Android: add **both** the debug keystore SHA-1/256 (used by `flutter run`) **and** every **release** keystore SHA-1/256 (local `android/key.properties` + the CI `KEYSTORE_BASE64` secret — they may be different keys) in Firebase, then download/commit `google-services.json` under `android/app/` and `android/app/src/dev/`. Run `task signing:report` to print fingerprints. **Rebuild the release APK** after updating the file — the config is baked in at build time.
3. iOS: add the reversed client ID URL scheme from `GoogleService-Info.plist` under **URL Types** (`ios/Runner/Info.plist`).
4. Ensure **`CFBundleURLSchemes`** lists your OAuth scheme (see Flutter [Google Sign-In integration](https://pub.dev/packages/google_sign_in)).

### Sign in with Apple

1. Enable the **Sign in with Apple** capability for the Xcode target (`Runner`).
2. Add the Service ID / redirect domains in the Apple Developer portal if you federate Apple with Firebase/backends.

### Facebook Login

1. Create a Meta app with Facebook Login and copy **App ID** and **Client Token**.
2. Android: populate `facebook_app_id` / `facebook_client_token` in `android/app/src/main/res/values/strings.xml` and ensure `AndroidManifest.xml` merges the LoginActivity metadata as required by `flutter_facebook_auth`.
3. iOS: add `FacebookAppID`, `FacebookClientToken`, CFBundle URL schemes (`fb<APP_ID>`), and **`LSApplicationQueriesSchemes`** for `fbauth2`/`fbapi` as documented by Meta.

Keep **`dev/staging/prod`** bundle IDs / package names and OAuth redirect URIs isolated so tokens never cross environments.
