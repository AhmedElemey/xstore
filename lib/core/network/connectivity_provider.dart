import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// App-wide online/offline flag driven by [connectivity_plus].
///
/// Uses platform connectivity (Wi‑Fi / mobile / ethernet / none), not a ping
/// to the API — good enough for immediate “you’re offline” feedback.
final isOnlineProvider = StateNotifierProvider<IsOnlineNotifier, bool>(
  (ref) => IsOnlineNotifier(),
);

class IsOnlineNotifier extends StateNotifier<bool> {
  IsOnlineNotifier() : super(true) {
    unawaited(_init());
  }

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _pluginAvailable = true;

  Future<void> _init() async {
    final List<ConnectivityResult> initial;
    try {
      initial = await Connectivity().checkConnectivity();
    } on MissingPluginException {
      _disablePlugin();
      return;
    }

    _apply(initial);

    try {
      _subscription = Connectivity().onConnectivityChanged.listen(_apply);
    } on MissingPluginException {
      _disablePlugin();
    }
  }

  void _apply(List<ConnectivityResult> results) {
    state = results.any((r) => r != ConnectivityResult.none);
  }

  void _disablePlugin() {
    if (!_pluginAvailable) return;
    _pluginAvailable = false;
    unawaited(_safeCancelSubscription());
    assert(() {
      debugPrint(
        'connectivity_plus unavailable; assuming online until next launch.',
      );
      return true;
    }());
  }

  Future<void> _safeCancelSubscription() async {
    final sub = _subscription;
    _subscription = null;
    if (sub == null) return;

    try {
      await sub.cancel();
    } on MissingPluginException {
      // Native side was never registered; nothing to tear down.
    }
  }

  @override
  void dispose() {
    unawaited(_safeCancelSubscription());
    super.dispose();
  }
}

/// Stored on cart/checkout state when a network action is blocked offline.
const kOfflineErrorCode = '__offline__';

bool isOfflineError(String? error) => error == kOfflineErrorCode;
