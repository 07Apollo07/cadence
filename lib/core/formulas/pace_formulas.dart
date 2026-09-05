import '../constants/cadence_constants.dart';

class PaceFormulas {
  /// Converts cadence (spm) and stride length (meters) to speed in km/h.
  /// Formula: Speed (km/h) = (Cadence * StrideLength * 60) / 1000
  static double cadenceAndStrideToSpeedKmH(double cadence, double strideLengthMeters) {
    if (cadence <= 0 || strideLengthMeters <= 0) return 0.0;
    return (cadence * strideLengthMeters * 60.0) / 1000.0;
  }

  /// Converts speed (km/h) to pace in minutes per kilometer (min/km).
  static Duration speedKmHToPace(double speedKmH) {
    if (speedKmH <= 0) return Duration.zero;
    final double minutesPerKm = 60.0 / speedKmH;
    final int totalSeconds = (minutesPerKm * 60).round();
    return Duration(seconds: totalSeconds);
  }

  /// Derives actual cadence (spm) from speed (km/h) and stride length (meters).
  static double speedAndStrideToCadence(double speedKmH, double strideLengthMeters) {
    if (speedKmH <= 0 || strideLengthMeters <= 0) return 0.0;
    return (speedKmH * 1000.0) / (strideLengthMeters * 60.0);
  }

  /// Estimates stride length (meters) based on height in centimeters.
  static double estimateStrideLengthFromHeight(double heightCm) {
    if (heightCm <= 0) return CadenceConstants.defaultStrideLengthMeters;
    return heightCm * 0.414 / 100.0;
  }
}
