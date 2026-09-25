import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:xstore/shared/widgets/map_address_picker.dart';

void main() {
  const start = LatLng(30.558, 31.01);

  test('map creation jitter at the starting point is not a pick', () {
    expect(
      mapCameraMovedFromStart(start, const LatLng(30.55801, 31.01001)),
      isFalse,
    );
    expect(mapCameraMovedFromStart(start, start), isFalse);
  });

  test('dragging the camera away from the start counts as a pick', () {
    expect(
      mapCameraMovedFromStart(start, const LatLng(30.56, 31.02)),
      isTrue,
    );
  });
}
