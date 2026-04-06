/*
 FIREBASE SETUP — COMPLETE THESE STEPS FIRST:

 1. Go to https://console.firebase.google.com
 2. Create a new project: "xStore"
 3. Add Android app:
      Package name: com.xstore.app
      Download google-services.json
      Place in: android/app/google-services.json
 4. Add iOS app:
      Bundle ID: com.xstore.app
      Download GoogleService-Info.plist
      Place in: ios/Runner/GoogleService-Info.plist
 5. Enable Authentication in Firebase Console:
      Authentication → Sign-in method → Enable:
        ✅ Google
        ✅ Apple
        ✅ Facebook
 6. Run FlutterFire CLI:
      dart pub global activate flutterfire_cli
      flutterfire configure --project=xstore-app
    This auto-generates firebase_options.dart
 7. For Facebook:
      Go to https://developers.facebook.com
      Create app → add Facebook Login product
      Get App ID and App Secret
      Add to Firebase: Facebook App ID + Secret
 8. For Apple (iOS only):
      Requires Apple Developer account ($99/year)
      Enable Sign In with Apple capability in Xcode
*/

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web Firebase options are not configured yet.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError('Firebase options are not configured for macOS.');
      default:
        throw UnsupportedError('Firebase options are not supported on this platform.');
    }
  }

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDHwoekaMb6AEBK9nPZlmwz_DPE6b1_Dow',
    appId: '1:304127266125:ios:d68839a848e5a0e6f93b04',
    messagingSenderId: '304127266125',
    projectId: 'xstore-22e2f',
    storageBucket: 'xstore-22e2f.firebasestorage.app',
    iosClientId: '304127266125-4m1278jhlu9o4qq0gmbb82jlkialtldi.apps.googleusercontent.com',
    iosBundleId: 'com.xstore.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAw2L1su_CuWpOvwUX6uThx4oPhy4lAbvw',
    appId: '1:304127266125:android:7bf82fecabeed953f93b04',
    messagingSenderId: '304127266125',
    projectId: 'xstore-22e2f',
    storageBucket: 'xstore-22e2f.firebasestorage.app',
  );

}