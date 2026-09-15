import 'package:latlong2/latlong.dart';
import 'gps_point_filter.dart';
import '../history/models/gps_track_point.dart';
import '../history/models/km_split.dart';
import '../../core/providers/cadence_provider.dart';

class RouteAggregator {
  final List<LatLng> _points = [];
  final List<GpsTrackPoint> _detailedPoints = [];
  final List<KmSplit> _splits = [];

  double _totalDistanceMeters = 0.0;
  DateTime? _startTime;
  DateTime? _lastPointTime;
  DateTime? _pauseStartTime;
  
  Duration _movingDuration = Duration.zero;
  Duration _pauseDuration = Duration.zero;
  double _currentSpeedKmH = 0.0;
  double _maxCadence = 0.0;

  // Split tracking state
  int _lastSplitKm = 0;
  Duration _lastSplitMovingTime = Duration.zero;
  final List<double> _splitCadences = [];
  final List<double> _splitSpeeds = [];

  List<LatLng> get points => List.unmodifiable(_points);
  List<GpsTrackPoint> get detailedPoints => List.unmodifiable(_detailedPoints);
  List<KmSplit> get splits => List.unmodifiable(_splits);
  double get totalDistanceKm => _totalDistanceMeters / 1000.0;
  double get currentSpeedKmH => _currentSpeedKmH;
  DateTime? get startTime => _startTime;
  Duration get movingDuration => _movingDuration;
  Duration get pauseDuration {
    if (_pauseStartTime != null) {
      return _pauseDuration + DateTime.now().difference(_pauseStartTime!);
    }
    return _pauseDuration;
  }
  Duration get elapsedDuration {
    if (_startTime == null) return _movingDuration + pauseDuration;
    return DateTime.now().difference(_startTime!);
  }
  Duration get idleDuration {
    final elapsed = elapsedDuration;
    final activeAndPaused = _movingDuration + pauseDuration;
    if (elapsed > activeAndPaused) {
      return elapsed - activeAndPaused;
    }
    return Duration.zero;
  }
  Duration get totalDuration => elapsedDuration;

  void startSession([DateTime? startTime]) {
    _startTime ??= startTime ?? DateTime.now();
  }

  void reset() {
    _points.clear();
    _detailedPoints.clear();
    _splits.clear();
    _totalDistanceMeters = 0.0;
    _startTime = null;
    _lastPointTime = null;
    _pauseStartTime = null;
    _movingDuration = Duration.zero;
    _pauseDuration = Duration.zero;
    _currentSpeedKmH = 0.0;
    _maxCadence = 0.0;
    _lastSplitKm = 0;
    _lastSplitMovingTime = Duration.zero;
    _splitCadences.clear();
    _splitSpeeds.clear();
  }

  /// Restore aggregator state from a previous session (e.g. 24h resumption)
  void restoreFromSession({
    required DateTime startTime,
    required Duration movingDuration,
    required Duration pauseDuration,
    required double distanceKm,
    required List<GpsTrackPoint> points,
    required List<KmSplit> splits,
  }) {
    reset();
    _startTime = startTime;
    _movingDuration = movingDuration;
    _pauseDuration = pauseDuration;
    _totalDistanceMeters = distanceKm * 1000.0;
    _detailedPoints.addAll(points);
    _splits.addAll(splits);
    _points.addAll(points.map((p) => p.latLng));
    _lastSplitKm = splits.length;
    _lastSplitMovingTime = movingDuration;
    if (_points.isNotEmpty) {
      _lastPointTime = points.last.timestamp;
    }
  }

  void onPause() {
    _pauseStartTime = DateTime.now();
  }

  void onResume() {
    if (_pauseStartTime != null) {
      _pauseDuration += DateTime.now().difference(_pauseStartTime!);
      _pauseStartTime = null;
    }
  }

  /// Adds a filtered point to the route aggregation.
  void addPoint(
    FilteredPoint point, {
    double cadenceSpm = 0.0,
    MovementMode movementMode = MovementMode.jogging,
    double strideLengthMeters = 0.75,
  }) {
    final now = point.timestamp;
    _startTime ??= now;

    if (cadenceSpm > _maxCadence) {
      _maxCadence = cadenceSpm;
    }

    if (_points.isNotEmpty && _lastPointTime != null) {
      const Distance distance = Distance();
      final segmentMeters = distance.as(LengthUnit.Meter, _points.last, point.position);
      _totalDistanceMeters += segmentMeters;

      final timeDelta = now.difference(_lastPointTime!);
      if (timeDelta > Duration.zero && timeDelta < const Duration(seconds: 30)) {
        _movingDuration += timeDelta;
      }

      if (point.speed != null && point.speed! >= 0) {
        _currentSpeedKmH = point.speed! * 3.6;
      } else {
        if (timeDelta.inMilliseconds > 0) {
          final hours = timeDelta.inMilliseconds / 3600000.0;
          _currentSpeedKmH = (segmentMeters / 1000.0) / hours;
        }
      }
    }

    _lastPointTime = now;
    _points.add(point.position);

    _detailedPoints.add(
      GpsTrackPoint(
        latitude: point.position.latitude,
        longitude: point.position.longitude,
        timestamp: now,
        speedKmH: _currentSpeedKmH,
        cadenceSpm: cadenceSpm,
        distanceFromStartKm: totalDistanceKm,
        movementMode: movementMode,
        strideLengthMeters: strideLengthMeters,
      ),
    );

    _splitCadences.add(cadenceSpm);
    _splitSpeeds.add(_currentSpeedKmH);

    // Check if a new kilometer split has been completed
    final currentKm = totalDistanceKm.floor();
    if (currentKm > _lastSplitKm && currentKm > 0) {
      final splitTime = _movingDuration - _lastSplitMovingTime;
      final splitSecs = splitTime.inSeconds;

      final avgCadence = _splitCadences.isNotEmpty
          ? _splitCadences.reduce((a, b) => a + b) / _splitCadences.length
          : cadenceSpm;
      final avgSpeed = _splitSpeeds.isNotEmpty
          ? _splitSpeeds.reduce((a, b) => a + b) / _splitSpeeds.length
          : _currentSpeedKmH;

      final paceMinPerKm = avgSpeed > 0.1 ? 60.0 / avgSpeed : (splitSecs / 60.0);

      _splits.add(
        KmSplit(
          kilometer: currentKm,
          durationSeconds: splitSecs,
          avgSpeedKmH: avgSpeed,
          avgPaceMinPerKm: paceMinPerKm,
          avgCadence: avgCadence,
        ),
      );

      _lastSplitKm = currentKm;
      _lastSplitMovingTime = _movingDuration;
      _splitCadences.clear();
      _splitSpeeds.clear();
    }
  }

  double get avgCadence {
    if (_detailedPoints.isEmpty) return 0.0;
    final validPoints = _detailedPoints.where((p) => p.cadenceSpm > 0);
    if (validPoints.isEmpty) return 0.0;
    final sum = validPoints.fold<double>(0.0, (prev, p) => prev + p.cadenceSpm);
    return sum / validPoints.length;
  }

  double get maxCadence => _maxCadence;

  double? get avgPaceMinPerKm {
    if (totalDistanceKm < 0.05 || _movingDuration.inSeconds < 5) return null;
    final pace = (_movingDuration.inSeconds / 60.0) / totalDistanceKm;
    return pace.clamp(2.0, 30.0);
  }

  double? get bestPaceMinPerKm {
    if (_splits.isEmpty) return avgPaceMinPerKm;
    return _splits.map((s) => s.avgPaceMinPerKm).reduce((a, b) => a < b ? a : b);
  }

  int get estimatedCalories => (totalDistanceKm * 65).round();

  int estimatedSteps(double strideLengthMeters) {
    if (strideLengthMeters <= 0) return 0;
    return (_totalDistanceMeters / strideLengthMeters).round();
  }
}
