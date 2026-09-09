import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/utils/app_location_cache.dart';

void main() {
  tearDown(AppLocationCache.debugReset);

  test('defaults to Cairo when no fix has been stored', () {
    expect(AppLocationCache.latitude, AppLocationCache.fallbackLatitude);
    expect(AppLocationCache.longitude, AppLocationCache.fallbackLongitude);
  });

  test('stores an in-Egypt fix', () {
    AppLocationCache.set(30.0444, 31.2357);
    expect(AppLocationCache.latitude, 30.0444);
    expect(AppLocationCache.longitude, 31.2357);
  });

  test('ignores Cupertino / out-of-Egypt coordinates', () {
    AppLocationCache.set(37.3346, -122.0090);
    expect(AppLocationCache.latitude, AppLocationCache.fallbackLatitude);
    expect(AppLocationCache.longitude, AppLocationCache.fallbackLongitude);
  });

  test('keeps the previous Egypt fix if a later set is outside Egypt', () {
    AppLocationCache.set(30.0444, 31.2357);
    AppLocationCache.set(37.3346, -122.0090);
    expect(AppLocationCache.latitude, 30.0444);
    expect(AppLocationCache.longitude, 31.2357);
  });
}
