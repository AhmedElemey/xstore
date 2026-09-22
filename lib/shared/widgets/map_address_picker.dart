import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/app_location_cache.dart';
import '../../core/utils/extensions/context_extensions.dart';
import '../../core/utils/location_service.dart';

/// Result of [showMapAddressPicker]: the pinned coordinate, plus a
/// best-effort reverse-geocoded label for display (never authoritative —
/// the coordinate is what actually reaches the backend).
class MapPickResult {
  const MapPickResult({
    required this.latitude,
    required this.longitude,
    this.addressLine,
  });

  final double latitude;
  final double longitude;
  final String? addressLine;
}

/// Camera creation / tile-load jitter is not a user pick. ~33m; a real
/// drag is larger, a plugin settle is typically far smaller.
bool mapCameraMovedFromStart(LatLng from, LatLng to) {
  const delta = 0.0003;
  return (from.latitude - to.latitude).abs() > delta ||
      (from.longitude - to.longitude).abs() > delta;
}

/// Full-screen "drop a pin" address picker. The pin stays fixed at the
/// screen center — the map moves under it, the standard pattern for precise
/// pin placement — and camera-idle triggers a best-effort reverse geocode.
/// No pin is shown and Confirm stays disabled until the vendor actually
/// moves the map or taps "use my location" — the map still centers
/// somewhere reasonable (the last-known fix, or Cairo) so there's a
/// starting point to look at, but that starting point was never chosen by
/// anyone and must not be confirmable as-is (unless [initialLatitude]/
/// [initialLongitude] are given, e.g. re-opening an already-picked spot to
/// adjust it). Confirm is also disabled outside Egypt, matching the
/// backend's own "Coordinates must be within Egypt bounds" rule (see
/// [AppLocationCache.isInEgypt]).
Future<MapPickResult?> showMapAddressPicker(
  BuildContext context, {
  double? initialLatitude,
  double? initialLongitude,
}) {
  return Navigator.of(context).push<MapPickResult>(
    MaterialPageRoute(
      builder: (_) => _MapAddressPickerScreen(
        initialLatitude: initialLatitude,
        initialLongitude: initialLongitude,
      ),
    ),
  );
}

class _MapAddressPickerScreen extends StatefulWidget {
  const _MapAddressPickerScreen({this.initialLatitude, this.initialLongitude});

  final double? initialLatitude;
  final double? initialLongitude;

  @override
  State<_MapAddressPickerScreen> createState() =>
      _MapAddressPickerScreenState();
}

class _MapAddressPickerScreenState extends State<_MapAddressPickerScreen> {
  late LatLng _start;
  late LatLng _picked;
  GoogleMapController? _mapController;
  String? _addressLine;
  bool _resolvingAddress = false;
  bool _locating = false;
  Timer? _debounce;

  // True once the vendor has actually chosen a spot (dragged the map a
  // meaningful distance, or tapped "use my location") — false on a fresh
  // pick, even though [_picked] itself is never null (it starts at the
  // device's last-known fix, or the Cairo fallback, purely so the map has
  // somewhere to center on). The plugin fires onCameraMove/onCameraIdle
  // when that starting camera is created; those are not a pick. Gates the
  // pin overlay, reverse-geocode, and Confirm.
  late bool _hasPicked;

  @override
  void initState() {
    super.initState();
    _hasPicked = widget.initialLatitude != null && widget.initialLongitude != null;
    _start = LatLng(
      widget.initialLatitude ?? AppLocationCache.latitude,
      widget.initialLongitude ?? AppLocationCache.longitude,
    );
    _picked = _start;
    if (_hasPicked) {
      unawaited(_resolveAddress(_picked));
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  void _onCameraMove(CameraPosition position) {
    _picked = position.target;
    if (_hasPicked || !mapCameraMovedFromStart(_start, position.target)) {
      return;
    }
    setState(() => _hasPicked = true);
  }

  void _onCameraIdle() {
    if (!_hasPicked) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) unawaited(_resolveAddress(_picked));
    });
  }

  Future<void> _resolveAddress(LatLng target) async {
    setState(() => _resolvingAddress = true);
    String? line;
    try {
      final placemarks = await placemarkFromCoordinates(
        target.latitude,
        target.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        line = [place.street, place.subLocality, place.locality]
            .where((s) => s != null && s.trim().isNotEmpty)
            .cast<String>()
            .join(', ');
        if (line.isEmpty) line = null;
      }
    } catch (_) {
      // Best-effort label only — the pinned coordinate is unaffected.
    }
    if (!mounted) return;
    setState(() {
      _addressLine = line;
      _resolvingAddress = false;
    });
  }

  Future<void> _useMyLocation() async {
    setState(() => _locating = true);
    try {
      final result = await LocationService().getCurrentLocation();
      if (!mounted) return;
      final target = LatLng(result.latitude, result.longitude);
      setState(() {
        _picked = target;
        _hasPicked = true;
      });
      await _mapController?.animateCamera(CameraUpdate.newLatLng(target));
      await _resolveAddress(target);
    } catch (_) {
      // GPS failed or was denied — the manual pin drag still works.
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  bool get _inEgypt =>
      AppLocationCache.isInEgypt(_picked.latitude, _picked.longitude);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.checkoutPickOnMap)),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _picked, zoom: 16),
            onMapCreated: (c) => _mapController = c,
            onCameraMove: _onCameraMove,
            onCameraIdle: _onCameraIdle,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),
          if (_hasPicked)
            const IgnorePointer(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 36),
                  child: Icon(
                    Icons.location_pin,
                    size: 44,
                    color: AppColors.error,
                  ),
                ),
              ),
            ),
          Positioned(
            right: AppSpacing.lg,
            bottom: 172,
            child: FloatingActionButton.small(
              heroTag: 'mapAddressPickerMyLocation',
              onPressed: _locating ? null : _useMyLocation,
              child: _locating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Material(
              color: context.surfaceColor,
              child: Padding(
                padding: EdgeInsets.only(
                  left: AppSpacing.lg,
                  right: AppSpacing.lg,
                  top: AppSpacing.lg,
                  bottom: AppSpacing.lg + MediaQuery.paddingOf(context).bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_resolvingAddress)
                          const Padding(
                            padding: EdgeInsets.only(
                              right: AppSpacing.sm,
                              top: 2,
                            ),
                            child: SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        Expanded(
                          child: Text(
                            _addressLine ?? l10n.checkoutMapPinDropped,
                            style: AppTypography.bodyMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (!_inEgypt) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        l10n.checkoutMapOutsideEgypt,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    FilledButton(
                      onPressed: _hasPicked && _inEgypt
                          ? () => Navigator.of(context).pop(
                              MapPickResult(
                                latitude: _picked.latitude,
                                longitude: _picked.longitude,
                                addressLine: _addressLine,
                              ),
                            )
                          : null,
                      child: Text(l10n.checkoutConfirmLocation),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
