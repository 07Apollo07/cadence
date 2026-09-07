import 'package:flutter_test/flutter_test.dart';
import 'package:cadence/features/gps/actual_cadence_calculator.dart';
import 'package:cadence/core/formulas/pace_formulas.dart';

void main() {
  group('ActualCadenceCalculator Tests', () {
    test('calculates actual cadence correctly', () {
      // 8.1 km/h with 0.75m stride -> 180 spm
      final cadence = ActualCadenceCalculator.calculate(
        speedKmH: 8.1,
        strideLengthMeters: 0.75,
      );
      expect(cadence, closeTo(180.0, 0.1));
    });

    test('inverse-correctness test against PaceFormulas', () {
      final strides = [0.6, 0.75, 0.85, 1.0];
      final cadences = [150.0, 165.0, 180.0, 195.0];

      for (final stride in strides) {
        for (final originalCadence in cadences) {
          final speed = PaceFormulas.cadenceAndStrideToSpeedKmH(originalCadence, stride);
          final derivedCadence = ActualCadenceCalculator.calculate(
            speedKmH: speed,
            strideLengthMeters: stride,
          );
          expect(derivedCadence, closeTo(originalCadence, 0.001));
        }
      }
    });
  });
}
