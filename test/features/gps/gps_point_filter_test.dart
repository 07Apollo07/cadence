import 'package:flutter_test/flutter_test.dart';
import 'package:cadence/features/gps/gps_point_filter.dart';
import 'synthetic_gps_tracks.dart';

void main() {
  group('GpsPointFilter Tests', () {
    test('filters out bad accuracy and stationary jitter', () {
      final filter = GpsPointFilter();
      final fixes = SyntheticGpsTracks.stationaryWithJitter();

      // 1st fix: accepted (first point)
      final p1 = filter.filter(
        latitude: fixes[0].latitude,
        longitude: fixes[0].longitude,
        accuracyMeters: fixes[0].accuracyMeters,
        timestamp: fixes[0].timestamp,
      );
      expect(p1, isNotNull);

      // 2nd fix: jitter < 2m -> discarded
      final p2 = filter.filter(
        latitude: fixes[1].latitude,
        longitude: fixes[1].longitude,
        accuracyMeters: fixes[1].accuracyMeters,
        timestamp: fixes[1].timestamp,
      );
      expect(p2, isNull);

      // 3rd fix: bad accuracy (> 20m) -> discarded
      final p3 = filter.filter(
        latitude: fixes[2].latitude,
        longitude: fixes[2].longitude,
        accuracyMeters: fixes[2].accuracyMeters,
        timestamp: fixes[2].timestamp,
      );
      expect(p3, isNull);

      // 4th fix: movement >= 2m -> accepted
      final p4 = filter.filter(
        latitude: fixes[3].latitude,
        longitude: fixes[3].longitude,
        accuracyMeters: fixes[3].accuracyMeters,
        timestamp: fixes[3].timestamp,
      );
      expect(p4, isNotNull);
    });
  });
}
