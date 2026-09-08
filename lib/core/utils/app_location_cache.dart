import 'package:flutter/foundation.dart';
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
///
/// CONFIRMED (live, 2026-09-01): the backend also 400s
/// `"Coordinates must be within Egypt bounds"` when those headers are a
/// real GPS fix outside Egypt (iOS Simulator defaults to Cupertino). Only
/// Egypt-bounded coordinates are stored; otherwise the Cairo fallback is
/// sent.
abstract final class AppLocationCache {
  static double? _latitude;
  static double? _longitude;

  /// Cairo — used until a real in-Egypt fix is available, and whenever the
  /// OS last-known / simulator GPS is outside Egypt.
  static const double fallbackLatitude = 30.0444;
  static const double fallbackLongitude = 31.2357;

  static double get latitude {
    final lat = _latitude;
    final lng = _longitude;
    if (lat == null || lng == null || !isInEgypt(lat, lng)) {
      return fallbackLatitude;
    }
    return lat;
  }

  static double get longitude {
    final lat = _latitude;
    final lng = _longitude;
    if (lat == null || lng == null || !isInEgypt(lat, lng)) {
      return fallbackLongitude;
    }
    return lng;
  }

  /// Approximate Egypt bounding box used by the live API (and
  /// [LocationService.isInEgypt]).
  static bool isInEgypt(double lat, double lng) {
    return lat >= 22.0 && lat <= 31.7 && lng >= 25.0 && lng <= 37.0;
  }

  static void set(double latitude, double longitude) {
    if (!isInEgypt(latitude, longitude)) return;
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

  @visibleForTesting
  static void debugReset() {
    _latitude = null;
    _longitude = null;
  }
}
