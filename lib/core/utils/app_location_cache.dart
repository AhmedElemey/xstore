import 'package:geolocator/geolocator.dart';

/// Last-known device coordinates, sent as `X-Latitude`/`X-Longitude` headers
/// on every API request.
///
/// CONFIRMED (live probe, 2026-08-14): `GET /api/listings` — and by
/// extension every screen that derives from it (Explore, Home, Similar
/// Products) — 400s with "Location data is required. Please provide
/// X-Latitude and X-Longitude headers." if these are missing. This cache is
/// a best-effort source for them: primed from the OS's last-known fix at
/// startup (no permission prompt — returns null if never granted), and kept
/// current whenever [LocationService.getCurrentLocation] succeeds anywhere
/// in the app (edit-profile GPS detect, register store step, etc).
abstract final class AppLocationCache {
  static double? _latitude;
  static double? _longitude;

  /// Cairo — used only until a real fix (last-known or fresh) is available,
  /// so location-gated endpoints never hard-fail for a user who hasn't
  /// granted location yet.
  static const double _fallbackLatitude = 30.0444;
  static const double _fallbackLongitude = 31.2357;

  static double get latitude => _latitude ?? _fallbackLatitude;
  static double get longitude => _longitude ?? _fallbackLongitude;

  static void set(double latitude, double longitude) {
    _latitude = latitude;
    _longitude = longitude;
  }

  /// Fire-and-forget: reads the OS's cached last-known position, if any,
  /// without requesting permission or a fresh GPS fix.
  static Future<void> primeFromLastKnown() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
      final position = await Geolocator.getLastKnownPosition();
      if (position != null) {
        set(position.latitude, position.longitude);
      }
    } catch (_) {
      // Best-effort only — the request-time fallback covers this.
    }
  }
}
