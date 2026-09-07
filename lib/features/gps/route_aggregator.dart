import 'package:latlong2/latlong.dart';
import 'gps_point_filter.dart';

class RouteAggregator {
  final List<LatLng> _points = [];
  double _totalDistanceMeters = 0.0;
  DateTime? _startTime;
  DateTime? _lastTime;
  double _currentSpeedKmH = 0.0;

  List<LatLng> get points => List.unmodifiable(_points);
  double get totalDistanceKm => _totalDistanceMeters / 1000.0;
  double get currentSpeedKmH => _currentSpeedKmH;
  Duration get elapsedTime {
    if (_startTime == null || _lastTime == null) return Duration.zero;
    return _lastTime!.difference(_startTime!);
  }

  void reset() {
    _points.clear();
    _totalDistanceMeters = 0.0;
    _startTime = null;
    _lastTime = null;
    _currentSpeedKmH = 0.0;
  }

  /// Adds a filtered point to the route aggregation.
  void addPoint(FilteredPoint point) {
    _startTime ??= point.timestamp;
    _lastTime = point.timestamp;

    if (_points.isNotEmpty) {
      const Distance distance = Distance();
      final segmentMeters = distance.as(LengthUnit.Meter, _points.last, point.position);
      _totalDistanceMeters += segmentMeters;

      if (point.speed != null && point.speed! >= 0) {
        // Convert m/s from GPS to km/h if point.speed is in m/s (geolocator speed is m/s)
        _currentSpeedKmH = point.speed! * 3.6;
      } else {
        // Fallback: distance / time delta
        final timeDelta = point.timestamp.difference(_lastTime ?? point.timestamp);
        if (timeDelta.inSeconds > 0) {
          final hours = timeDelta.inMilliseconds / 3600000.0;
          _currentSpeedKmH = (segmentMeters / 1000.0) / hours;
        }
      }
    }

    _points.add(point.position);
  }
}
