import 'gps_constants.dart';
import 'package:latlong2/latlong.dart';

class FilteredPoint {
  final LatLng position;
  final double accuracyMeters;
  final DateTime timestamp;
  final double? speed;
  final double? altitude;
  final double? altitudeAccuracy;
  final double? speedAccuracy;
  final double? heading;
  final double? headingAccuracy;

  const FilteredPoint({
    required this.position,
    required this.accuracyMeters,
    required this.timestamp,
    this.speed,
    this.altitude,
    this.altitudeAccuracy,
    this.speedAccuracy,
    this.heading,
    this.headingAccuracy,
  });
}

class GpsPointFilter {
  LatLng? _lastAcceptedPosition;

  LatLng? get lastAcceptedPosition => _lastAcceptedPosition;

  /// Resets the filter state (e.g. on new session start).
  void reset() {
    _lastAcceptedPosition = null;
  }

  /// Filters a raw GPS fix. Returns the [FilteredPoint] if accepted, or null if discarded.
  FilteredPoint? filter({
    required double latitude,
    required double longitude,
    required double accuracyMeters,
    required DateTime timestamp,
    double? speed,
    double? altitude,
    double? altitudeAccuracy,
    double? speedAccuracy,
    double? heading,
    double? headingAccuracy,
  }) {
    // 1. Check accuracy threshold
    if (accuracyMeters > GpsConstants.maxAcceptableAccuracyM) {
      return null;
    }

    final newPos = LatLng(latitude, longitude);

    // 2. If first point, accept immediately
    if (_lastAcceptedPosition == null) {
      _lastAcceptedPosition = newPos;
      return FilteredPoint(
        position: newPos,
        accuracyMeters: accuracyMeters,
        timestamp: timestamp,
        speed: speed,
        altitude: altitude,
        altitudeAccuracy: altitudeAccuracy,
        speedAccuracy: speedAccuracy,
        heading: heading,
        headingAccuracy: headingAccuracy,
      );
    }

    // 3. Check distance from last accepted position (jitter filter)
    final distance = _calculateHaversineDistance(_lastAcceptedPosition!, newPos);
    if (distance < GpsConstants.minDistanceFilterM) {
      return null;
    }

    _lastAcceptedPosition = newPos;
    return FilteredPoint(
      position: newPos,
      accuracyMeters: accuracyMeters,
      timestamp: timestamp,
      speed: speed,
      altitude: altitude,
      altitudeAccuracy: altitudeAccuracy,
      speedAccuracy: speedAccuracy,
      heading: heading,
      headingAccuracy: headingAccuracy,
    );
  }

  double _calculateHaversineDistance(LatLng p1, LatLng p2) {
    const Distance distance = Distance();
    return distance.as(LengthUnit.Meter, p1, p2);
  }
}
