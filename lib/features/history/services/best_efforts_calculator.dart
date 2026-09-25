import '../models/gps_track_point.dart';

class BestEffortBucket {
  final String label;
  final double targetKm;

  const BestEffortBucket(this.label, this.targetKm);

  static const List<BestEffortBucket> standardBuckets = [
    BestEffortBucket('400m', 0.4),
    BestEffortBucket('1/2 mile', 0.804672),
    BestEffortBucket('1K', 1.0),
    BestEffortBucket('1 mile', 1.609344),
    BestEffortBucket('2 mile', 3.218688),
    BestEffortBucket('5K', 5.0),
    BestEffortBucket('10K', 10.0),
    BestEffortBucket('15K', 15.0),
    BestEffortBucket('10 mile', 16.09344),
    BestEffortBucket('20K', 20.0),
    BestEffortBucket('Half Marathon', 21.0975),
    BestEffortBucket('30K', 30.0),
    BestEffortBucket('Marathon', 42.195),
    BestEffortBucket('50K', 50.0),
  ];
}

class BestEffortsCalculator {
  /// Computes the best (minimum) duration in seconds for a given [targetDistanceKm]
  /// using a sliding-window search over the session's GPS track points.
  /// Returns null if the run never covered [targetDistanceKm].
  static Duration? computeBestEffort(
    List<GpsTrackPoint> points,
    double targetDistanceKm,
  ) {
    if (points.length < 2 || targetDistanceKm <= 0) return null;

    // Build distance (km) and elapsed seconds pairs from start
    final startTime = points.first.timestamp;
    final curve = <_DistanceTimePoint>[];
    
    for (final p in points) {
      final elapsedSecs = p.timestamp.difference(startTime).inMilliseconds / 1000.0;
      curve.add(_DistanceTimePoint(p.distanceFromStartKm, elapsedSecs));
    }

    // Ensure sorted by distance
    curve.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

    final totalDistance = curve.last.distanceKm;
    if (totalDistance < targetDistanceKm) return null;

    double? minDurationSecs;

    // For each point as a potential start of the window
    for (int i = 0; i < curve.length; i++) {
      final startDist = curve[i].distanceKm;
      final startTimeSecs = curve[i].timeSeconds;
      final targetEndDist = startDist + targetDistanceKm;

      if (targetEndDist > totalDistance) {
        // Can't cover target distance from this start point
        break;
      }

      // Find the end time when distance reaches targetEndDist by interpolating
      final endTimeSecs = _interpolateTimeAtDistance(curve, targetEndDist, i);
      if (endTimeSecs != null) {
        final duration = endTimeSecs - startTimeSecs;
        if (duration > 0) {
          if (minDurationSecs == null || duration < minDurationSecs) {
            minDurationSecs = duration;
          }
        }
      }
    }

    if (minDurationSecs == null || minDurationSecs <= 0) return null;
    return Duration(milliseconds: (minDurationSecs * 1000).round());
  }

  static double? _interpolateTimeAtDistance(
    List<_DistanceTimePoint> curve,
    double targetDist,
    int startIndex,
  ) {
    // Find segment [k, k+1] where curve[k].distanceKm <= targetDist <= curve[k+1].distanceKm
    for (int k = startIndex; k < curve.length - 1; k++) {
      final p1 = curve[k];
      final p2 = curve[k + 1];

      if (p1.distanceKm <= targetDist && p2.distanceKm >= targetDist) {
        if (p2.distanceKm == p1.distanceKm) {
          return p1.timeSeconds;
        }
        final fraction = (targetDist - p1.distanceKm) / (p2.distanceKm - p1.distanceKm);
        return p1.timeSeconds + fraction * (p2.timeSeconds - p1.timeSeconds);
      }
    }
    return null;
  }
}

class _DistanceTimePoint {
  final double distanceKm;
  final double timeSeconds;

  const _DistanceTimePoint(this.distanceKm, this.timeSeconds);
}
