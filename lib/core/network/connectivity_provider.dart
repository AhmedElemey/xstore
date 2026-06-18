import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
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
    _subscription = Connectivity().onConnectivityChanged.listen(_apply);
    _refresh();
  }

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  Future<void> _refresh() async {
    _apply(await Connectivity().checkConnectivity());
  }

  void _apply(List<ConnectivityResult> results) {
    state = results.any((r) => r != ConnectivityResult.none);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

/// Stored on cart/checkout state when a network action is blocked offline.
const kOfflineErrorCode = '__offline__';

bool isOfflineError(String? error) => error == kOfflineErrorCode;
