import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class PositionData {
  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime timestamp;
  final double? speed;

  const PositionData({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.timestamp,
    this.speed,
  });
}

abstract class LocationService {
  Future<bool> checkAndRequestPermission();
  Stream<PositionData> getPositionStream({bool isTracking = false});
}

class GeolocatorLocationService implements LocationService {
  @override
  Future<bool> checkAndRequestPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  @override
  Stream<PositionData> getPositionStream({bool isTracking = false}) {
    final LocationSettings locationSettings;
    final int distanceFilter = isTracking ? 1 : 5;
    final Duration intervalDuration = isTracking
        ? const Duration(seconds: 1)
        : const Duration(seconds: 5);
    final LocationAccuracy accuracy = LocationAccuracy.high;

    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
        intervalDuration: intervalDuration,
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: "Cadence Location Service",
          notificationText:
              "Location tracking active for background run measurement",
          enableWifiLock: true,
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      locationSettings = AppleSettings(
        accuracy: accuracy,
        activityType: ActivityType.fitness,
        distanceFilter: distanceFilter,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
      );
    } else {
      locationSettings = LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
      );
    }

    return Geolocator.getPositionStream(locationSettings: locationSettings).map(
      (Position pos) {
        return PositionData(
          latitude: pos.latitude,
          longitude: pos.longitude,
          accuracy: pos.accuracy,
          timestamp: pos.timestamp,
          speed: pos.speed,
        );
      },
    );
  }
}

class FakeLocationService implements LocationService {
  final List<PositionData> _mockFixes;

  FakeLocationService(this._mockFixes);

  @override
  Future<bool> checkAndRequestPermission() async => true;

  @override
  Stream<PositionData> getPositionStream({bool isTracking = false}) async* {
    for (final fix in _mockFixes) {
      await Future.delayed(const Duration(milliseconds: 100));
      yield fix;
    }
  }
}
