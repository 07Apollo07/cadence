import 'package:latlong2/latlong.dart';

class GpsTrackPoint {
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double speedKmH;
  final double cadenceSpm;
  final double distanceFromStartKm;
  final bool isPausePoint;

  const GpsTrackPoint({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.speedKmH,
    required this.cadenceSpm,
    required this.distanceFromStartKm,
    this.isPausePoint = false,
  });

  LatLng get latLng => LatLng(latitude, longitude);

  Map<String, dynamic> toJson() => {
    'lat': latitude,
    'lng': longitude,
    'time': timestamp.toIso8601String(),
    'speed': speedKmH,
    'cadence': cadenceSpm,
    'dist': distanceFromStartKm,
    'pause': isPausePoint,
  };

  factory GpsTrackPoint.fromJson(Map<String, dynamic> json) => GpsTrackPoint(
    latitude: (json['lat'] as num).toDouble(),
    longitude: (json['lng'] as num).toDouble(),
    timestamp: DateTime.parse(json['time'] as String),
    speedKmH: (json['speed'] as num?)?.toDouble() ?? 0.0,
    cadenceSpm: (json['cadence'] as num?)?.toDouble() ?? 0.0,
    distanceFromStartKm: (json['dist'] as num?)?.toDouble() ?? 0.0,
    isPausePoint: json['pause'] as bool? ?? false,
  );
}