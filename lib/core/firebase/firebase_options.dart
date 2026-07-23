/*
 FIREBASE APPS — this project (xstore-22e2f) should have FOUR apps, one per
 platform × flavor. Status:

   1. Android prod  com.xstore.app       appId ...android:7bf82f...   ✅ registered
   2. Android dev   com.xstore.app.dev   appId ...android:1071a4...   ✅ registered
   3. iOS prod      com.xstore.app       appId ...ios:d68839...       ✅ registered
   4. iOS dev       com.xstore.app.dev   appId (none yet)             ❌ MISSING

 TO ADD THE MISSING 4th APP (iOS dev) — requires the Firebase console/CLI:
   dart pub global activate flutterfire_cli
   flutterfire configure \
     --project=xstore-22e2f \
     --platforms=ios \
     --ios-bundle-id=com.xstore.app.dev \
     --out=lib/core/firebase/firebase_options_dev.dart
   Then paste the generated iOS dev values into `iosDev` below and switch the
   iOS branch of `forFlavor` to `flavor.isDev ? iosDev : ios`.
   NOTE: iOS also needs dev/prod Xcode schemes + build configs before a dev
   bundle id can actually be built — Android has flavors, iOS does not yet.

 Auth providers (Google / Apple / Facebook) are enabled in the Firebase console.
*/

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

import '../config/app_flavor.dart';

class DefaultFirebaseOptions {
  /// OAuth 2.0 Web client ID (client_type 3 in `google-services.json`). Pass
  /// this as [GoogleSignIn.serverClientId] so the returned Google ID token's
  /// `aud` matches what the xStore backend verifies — without it the token is
  /// minted for the Android/iOS client and `/api/auth/google/*/login` 401s.
  static const googleWebClientId =
      '304127266125-agfonsmqpsub3tgocn3g4a0hs55tcrg0.apps.googleusercontent.com';

  /// Flavor-blind accessor (kept for backward compatibility). Returns the
  /// PROD app for the current platform. Prefer [forFlavor].
  static FirebaseOptions get currentPlatform => _forPlatform(isDev: false);

  /// Flavor-aware options — picks the correct Firebase app for the running
  /// flavor so the dev build reports to the dev app, not prod.
  static FirebaseOptions forFlavor(AppFlavor flavor) =>
      _forPlatform(isDev: flavor.isDev);

  static FirebaseOptions _forPlatform({required bool isDev}) {
    if (kIsWeb) {
      throw UnsupportedError('Web Firebase options are not configured yet.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return isDev ? androidDev : android;
      case TargetPlatform.iOS:
        // Only the prod iOS app (com.xstore.app) exists. The iOS dev app
        // (com.xstore.app.dev) — the missing 4th app — is not registered yet,
        // and iOS has no dev flavor/scheme, so dev falls back to prod here.
        // Once registered, add `iosDev` and use: `isDev ? iosDev : ios`.
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError('Firebase options are not configured for macOS.');
      default:
        throw UnsupportedError('Firebase options are not supported on this platform.');
    }
  }

  // --- iOS prod (com.xstore.app) ---
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDHwoekaMb6AEBK9nPZlmwz_DPE6b1_Dow',
    appId: '1:304127266125:ios:d68839a848e5a0e6f93b04',
    messagingSenderId: '304127266125',
    projectId: 'xstore-22e2f',
    storageBucket: 'xstore-22e2f.firebasestorage.app',
    iosClientId: '304127266125-4m1278jhlu9o4qq0gmbb82jlkialtldi.apps.googleusercontent.com',
    iosBundleId: 'com.xstore.app',
  );

  // --- iOS dev (com.xstore.app.dev) — MISSING 4th app. Register it, then fill
  //     these values in and enable the dev branch in `_forPlatform`.
  // static const FirebaseOptions iosDev = FirebaseOptions(
  //   apiKey: '<from flutterfire configure>',
  //   appId: '1:304127266125:ios:<dev-suffix>',
  //   messagingSenderId: '304127266125',
  //   projectId: 'xstore-22e2f',
  //   storageBucket: 'xstore-22e2f.firebasestorage.app',
  //   iosClientId: '<dev ios client id>',
  //   iosBundleId: 'com.xstore.app.dev',
  // );

  // --- Android prod (com.xstore.app) ---
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAw2L1su_CuWpOvwUX6uThx4oPhy4lAbvw',
    appId: '1:304127266125:android:7bf82fecabeed953f93b04',
    messagingSenderId: '304127266125',
    projectId: 'xstore-22e2f',
    storageBucket: 'xstore-22e2f.firebasestorage.app',
  );

  // --- Android dev (com.xstore.app.dev) ---
  static const FirebaseOptions androidDev = FirebaseOptions(
    apiKey: 'AIzaSyAw2L1su_CuWpOvwUX6uThx4oPhy4lAbvw',
    appId: '1:304127266125:android:1071a43571f0b0e0f93b04',
    messagingSenderId: '304127266125',
    projectId: 'xstore-22e2f',
    storageBucket: 'xstore-22e2f.firebasestorage.app',
  );
}
