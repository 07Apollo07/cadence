import '../../core/formulas/pace_formulas.dart';

class ActualCadenceCalculator {
  /// Derives actual cadence (spm) from speed (km/h) and stride length (meters).
  /// Algebraically inverse to PaceFormulas.cadenceAndStrideToSpeedKmH.
  static double calculate({
    required double speedKmH,
    required double strideLengthMeters,
  }) {
    return PaceFormulas.speedAndStrideToCadence(speedKmH, strideLengthMeters);
  }

  /// Calculates speed in km/h from distance in meters and elapsed time.
  static double speedFromDistanceAndTime({
    required double distanceMeters,
    required Duration elapsed,
  }) {
    if (elapsed.inMilliseconds <= 0 || distanceMeters <= 0) return 0.0;
    final hours = elapsed.inMilliseconds / 3600000.0;
    final km = distanceMeters / 1000.0;
    return km / hours;
  }
}
