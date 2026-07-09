import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/config/app_flavor.dart';
import 'core/firebase/firebase_options.dart';

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
