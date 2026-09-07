import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cadence/features/gps/location_service.dart';
import 'package:cadence/features/gps/gps_controller.dart';

void main() {
  group('GPS Session Flow Integration Test', () {
    test('starts tracking, receives filtered fixes, and updates metrics', () async {
      final baseTime = DateTime(2026, 9, 7, 12, 0, 0);
      final mockFixes = [
        PositionData(latitude: 37.7749, longitude: -122.4194, accuracy: 5.0, timestamp: baseTime),
        PositionData(latitude: 37.7758, longitude: -122.4194, accuracy: 5.0, timestamp: baseTime.add(const Duration(seconds: 10)), speed: 3.0),
      ];

      final fakeService = FakeLocationService(mockFixes);
      final container = ProviderContainer(
        overrides: [
          locationServiceProvider.overrideWithValue(fakeService),
        ],
      );
      
      final controller = container.read(gpsControllerProvider.notifier);
      
      expect(controller.state.isTracking, false);

      await controller.startTracking();
      // Give async stream a moment to emit
      await Future.delayed(const Duration(milliseconds: 300));

      expect(controller.state.isTracking, true);
      expect(controller.state.routePoints.length, 2);
      expect(controller.state.distanceKm, greaterThan(0.05));
      expect(controller.state.currentSpeedKmH, greaterThan(0.0));

      controller.stopTracking();
      expect(controller.state.isTracking, false);
      container.dispose();
    });
  });
}
