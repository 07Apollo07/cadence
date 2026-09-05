import 'package:flutter_test/flutter_test.dart';
import 'package:cadence/core/formulas/pace_formulas.dart';

void main() {
  group('PaceFormulas Tests', () {
    test('cadenceAndStrideToSpeedKmH calculates correctly', () {
      // 180 spm, 0.75m stride -> (180 * 0.75 * 60) / 1000 = 8.1 km/h
      final speed = PaceFormulas.cadenceAndStrideToSpeedKmH(180, 0.75);
      expect(speed, closeTo(8.1, 0.01));
    });

    test('speedKmHToPace calculates correctly', () {
      // 12 km/h -> 60 / 12 = 5 min/km = 300 seconds
      final pace = PaceFormulas.speedKmHToPace(12.0);
      expect(pace.inSeconds, 300);
    });

    test('speedAndStrideToCadence calculates correctly', () {
      // 8.1 km/h, 0.75m stride -> (8.1 * 1000) / (0.75 * 60) = 180 spm
      final cadence = PaceFormulas.speedAndStrideToCadence(8.1, 0.75);
      expect(cadence, closeTo(180.0, 0.1));
    });

    test('estimateStrideLengthFromHeight works', () {
      final stride = PaceFormulas.estimateStrideLengthFromHeight(180.0);
      expect(stride, closeTo(180 * 0.414 / 100.0, 0.001));
    });
  });
}
