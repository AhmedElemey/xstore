import 'dart:async';

/// Shared 60s resend-cooldown countdown used by every OTP send/verify flow
/// in the app (login OTP, forgot-password reset, profile email/phone
/// verification) — previously duplicated as near-identical `Timer.periodic`
/// blocks in each notifier/screen.
class OtpResendCooldown {
  OtpResendCooldown({this.seconds = 60});

  final int seconds;
  Timer? _timer;

  /// Starts the countdown, calling [onTick] once immediately and then every
  /// second with the remaining seconds (0 means done — resend is allowed).
  /// [isMounted] is checked before each tick so a disposed owner never gets
  /// a late callback.
  void start(void Function(int remaining) onTick, {required bool Function() isMounted}) {
    cancel();
    var remaining = seconds;
    onTick(remaining);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isMounted()) {
        timer.cancel();
        return;
      }
      remaining -= 1;
      if (remaining <= 0) {
        timer.cancel();
        onTick(0);
      } else {
        onTick(remaining);
      }
    });
  }

  void cancel() => _timer?.cancel();
}
