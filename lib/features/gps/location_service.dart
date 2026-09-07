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
  Stream<PositionData> getPositionStream();
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
  Stream<PositionData> getPositionStream() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 1,
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings).map((Position pos) {
      return PositionData(
        latitude: pos.latitude,
        longitude: pos.longitude,
        accuracy: pos.accuracy,
        timestamp: pos.timestamp,
        speed: pos.speed,
      );
    });
  }
}

class FakeLocationService implements LocationService {
  final List<PositionData> _mockFixes;
  
  FakeLocationService(this._mockFixes);

  @override
  Future<bool> checkAndRequestPermission() async => true;

  @override
  Stream<PositionData> getPositionStream() async* {
    for (final fix in _mockFixes) {
      await Future.delayed(const Duration(milliseconds: 100));
      yield fix;
    }
  }
}
