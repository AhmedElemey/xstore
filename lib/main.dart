import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/config/app_flavor.dart';
import 'core/firebase/fcm_push_setup.dart';
import 'core/firebase/fcm_token.dart';
import 'core/firebase/firebase_options.dart';
import 'core/utils/app_location_cache.dart';

/// Shared startup used by all flavor entry points.
Future<void> bootstrap(AppFlavor flavor) async {
  AppConfig.init(flavor);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.forFlavor(flavor),
  );
  await FirebaseAppCheck.instance.activate(
    androidProvider:
        flavor.isDev ? AndroidProvider.debug : AndroidProvider.playIntegrity,
    appleProvider:
        flavor.isDev ? AppleProvider.debug : AppleProvider.appAttest,
  );
  await configureFirebaseCloudMessaging();
  // App open: show the native "Allow Notifications" prompt (once — the OS
  // remembers the user's answer on later launches) for every user, logged
  // in or not, then fetch + persist the token. Fire-and-forget so a slow or
  // undecided permission dialog never blocks startup.
  unawaited(() async {
    await requestFcmNotificationPermission();
    await refreshAndStoreFcmToken();
  }());
  // Every API request needs X-Latitude/X-Longitude (see AppLocationCache) —
  // prime from the OS's last-known fix so the very first request already
  // has a real location instead of the Cairo fallback, when available.
  unawaited(AppLocationCache.primeFromLastKnown());
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
  runApp(const ProviderScope(child: XstoreApp()));
}

/// Default entry point for local `flutter run` (no `-t` / `--flavor`).
Future<void> main() async {
  await bootstrap(AppFlavor.dev);
}
