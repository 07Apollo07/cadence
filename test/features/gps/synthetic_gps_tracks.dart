class SyntheticGpsFix {
  final double latitude;
  final double longitude;
  final double accuracyMeters;
  final DateTime timestamp;
  final double? speed;

  const SyntheticGpsFix({
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
    required this.timestamp,
    this.speed,
  });
}

class SyntheticGpsTracks {
  /// Generates a stationary track with random jitter below/above accuracy and distance thresholds.
  static List<SyntheticGpsFix> stationaryWithJitter() {
    final baseTime = DateTime(2026, 9, 7, 8, 0, 0);
    return [
      SyntheticGpsFix(latitude: 37.7749, longitude: -122.4194, accuracyMeters: 5.0, timestamp: baseTime),
      // Jitter well under 2 meters -> should be filtered out
      SyntheticGpsFix(latitude: 37.774905, longitude: -122.419405, accuracyMeters: 5.0, timestamp: baseTime.add(const Duration(seconds: 1))),
      // Bad accuracy (> 20m) -> should be filtered out
      SyntheticGpsFix(latitude: 37.775000, longitude: -122.419500, accuracyMeters: 25.0, timestamp: baseTime.add(const Duration(seconds: 2))),
      // Movement > 2 meters -> accepted
      SyntheticGpsFix(latitude: 37.7750, longitude: -122.4194, accuracyMeters: 5.0, timestamp: baseTime.add(const Duration(seconds: 3))),
    ];
  }
}
