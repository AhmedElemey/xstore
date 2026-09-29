// QA suite (2026-09-24): geo-header fallback. The whole catalog 400s if
// these headers aren't valid in-Egypt coordinates, so the fallback must
// itself always be inside the backend's Egypt bounds.
import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/utils/app_location_cache.dart';

void main() {
  setUp(AppLocationCache.debugReset);

  test('default (no fix) returns the in-Egypt Cairo fallback', () {
    expect(
      AppLocationCache.isInEgypt(
          AppLocationCache.latitude, AppLocationCache.longitude),
      isTrue,
    );
    expect(AppLocationCache.latitude, AppLocationCache.fallbackLatitude);
  });

  test('an out-of-Egypt fix is rejected and never stored', () {
    AppLocationCache.set(37.33, -122.03); // Cupertino
    expect(AppLocationCache.latitude, AppLocationCache.fallbackLatitude);
  });

  test('an in-Egypt fix is used verbatim', () {
    AppLocationCache.set(31.2001, 29.9187); // Alexandria
    expect(AppLocationCache.latitude, closeTo(31.2001, 1e-6));
    expect(AppLocationCache.longitude, closeTo(29.9187, 1e-6));
  });

  test('isInEgypt covers major cities and excludes neighbours', () {
    expect(AppLocationCache.isInEgypt(30.0444, 31.2357), isTrue); // Cairo
    expect(AppLocationCache.isInEgypt(31.2001, 29.9187), isTrue); // Alexandria
    expect(AppLocationCache.isInEgypt(24.0889, 32.8998), isTrue); // Aswan
    expect(AppLocationCache.isInEgypt(27.9158, 34.3299), isTrue); // Sharm
    expect(AppLocationCache.isInEgypt(31.7683, 35.2137), isFalse); // Jerusalem
    expect(AppLocationCache.isInEgypt(0, 0), isFalse); // null island
  });
}
