import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationResult {
  const LocationResult({
    required this.latitude,
    required this.longitude,
    this.governorate,
    this.town,
    this.detailAddress,
  });

  final double latitude;
  final double longitude;
  final String? governorate;
  final String? town;
  final String? detailAddress;
}

class LocationService {
  Future<LocationResult> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const XStoreLocationServiceDisabledException();
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const XStoreLocationPermissionDeniedException();
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw const XStoreLocationPermissionPermanentlyDeniedException();
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );

    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return LocationResult(
          latitude: position.latitude,
          longitude: position.longitude,
          governorate: place.administrativeArea ?? place.subAdministrativeArea,
          town: place.locality ?? place.subLocality,
          detailAddress: [place.street, place.subLocality]
              .where((s) => s != null && s.isNotEmpty)
              .cast<String>()
              .join(', '),
        );
      }
    } catch (_) {}

    return LocationResult(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  static String formatCoordinate(double coord) => coord.toStringAsFixed(6);

  static bool isInEgypt(double lat, double lng) {
    return lat >= 22.0 && lat <= 31.7 && lng >= 25.0 && lng <= 37.0;
  }

  static bool isValidLatitude(String value) {
    final d = double.tryParse(value);
    return d != null && d >= -90 && d <= 90;
  }

  static bool isValidLongitude(String value) {
    final d = double.tryParse(value);
    return d != null && d >= -180 && d <= 180;
  }
}

class XStoreLocationServiceDisabledException implements Exception {
  const XStoreLocationServiceDisabledException();
}

class XStoreLocationPermissionDeniedException implements Exception {
  const XStoreLocationPermissionDeniedException();
}

class XStoreLocationPermissionPermanentlyDeniedException implements Exception {
  const XStoreLocationPermissionPermanentlyDeniedException();
}

