import 'package:flutter_test/flutter_test.dart';
import 'package:cadence/features/history/models/gps_track_point.dart';
import 'package:cadence/features/history/services/best_efforts_calculator.dart';
import 'package:cadence/core/providers/cadence_provider.dart';

void main() {
  group('BestEffortsCalculator', () {
    test('computes best effort correctly for synthetic trace', () {
      final baseTime = DateTime(2026, 9, 16, 10, 0, 0);
      
      // Create synthetic points covering 6 km at a constant speed of 12 km/h (5 min/km = 300 seconds per km)
      final points = <GpsTrackPoint>[];
      for (int i = 0; i <= 60; i++) {
        final distKm = i * 0.1; // 0 to 6 km in 100m steps
        final elapsedSecs = i * 30.0; // 30 seconds per 100m -> 300s per km
        points.add(
          GpsTrackPoint(
            latitude: 37.7749 + (i * 0.001),
            longitude: -122.4194,
            timestamp: baseTime.add(Duration(seconds: elapsedSecs.round())),
            speedKmH: 12.0,
            cadenceSpm: 160.0,
            distanceFromStartKm: distKm,
            isPausePoint: false,
            movementMode: MovementMode.running,
            strideLengthMeters: 1.0,
          ),
        );
      }

      // 1K should take 300 seconds (5 minutes)
      final best1k = BestEffortsCalculator.computeBestEffort(points, 1.0);
      expect(best1k, isNotNull);
      expect(best1k!.inSeconds, 300);

      // 5K should take 1500 seconds (25 minutes)
      final best5k = BestEffortsCalculator.computeBestEffort(points, 5.0);
      expect(best5k, isNotNull);
      expect(best5k!.inSeconds, 1500);

      // 10K should return null because total distance is only 6 km
      final best10k = BestEffortsCalculator.computeBestEffort(points, 10.0);
      expect(best10k, isNull);
    });
  });
}
