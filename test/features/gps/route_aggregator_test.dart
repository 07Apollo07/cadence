import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:cadence/features/gps/route_aggregator.dart';
import 'package:cadence/features/gps/gps_point_filter.dart';

void main() {
  group('RouteAggregator Tests', () {
    test('aggregates points and computes distance', () {
      final aggregator = RouteAggregator();
      final baseTime = DateTime(2026, 9, 7, 10, 0, 0);

      expect(aggregator.totalDistanceKm, 0.0);
      expect(aggregator.points, isEmpty);

      aggregator.addPoint(FilteredPoint(
        position: const LatLng(37.7749, -122.4194),
        accuracyMeters: 5.0,
        timestamp: baseTime,
      ));

      aggregator.addPoint(FilteredPoint(
        position: const LatLng(37.7758, -122.4194), // approx 100 meters north
        accuracyMeters: 5.0,
        timestamp: baseTime.add(const Duration(seconds: 30)),
        speed: 3.33,
      ));

      expect(aggregator.points.length, 2);
      expect(aggregator.totalDistanceKm, greaterThan(0.08));
      expect(aggregator.totalDistanceKm, lessThan(0.15));
      expect(aggregator.currentSpeedKmH, closeTo(3.33 * 3.6, 0.1));
    });
  });
}
