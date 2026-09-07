import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'location_service.dart';
import 'gps_point_filter.dart';
import 'route_aggregator.dart';
import 'actual_cadence_calculator.dart';
import '../../core/providers/cadence_provider.dart';

class GpsSessionState {
  final bool isTracking;
  final double distanceKm;
  final double currentSpeedKmH;
  final double actualCadenceSpm;
  final List<LatLng> routePoints;
  final double? lastRawAccuracy;
  final bool hasReceivedAnyFix;
  final String? errorMessage;

  const GpsSessionState({
    required this.isTracking,
    required this.distanceKm,
    required this.currentSpeedKmH,
    required this.actualCadenceSpm,
    required this.routePoints,
    this.lastRawAccuracy,
    this.hasReceivedAnyFix = false,
    this.errorMessage,
  });

  GpsSessionState copyWith({
    bool? isTracking,
    double? distanceKm,
    double? currentSpeedKmH,
    double? actualCadenceSpm,
    List<LatLng>? routePoints,
    double? lastRawAccuracy,
    bool? hasReceivedAnyFix,
    String? errorMessage,
  }) {
    return GpsSessionState(
      isTracking: isTracking ?? this.isTracking,
      distanceKm: distanceKm ?? this.distanceKm,
      currentSpeedKmH: currentSpeedKmH ?? this.currentSpeedKmH,
      actualCadenceSpm: actualCadenceSpm ?? this.actualCadenceSpm,
      routePoints: routePoints ?? this.routePoints,
      lastRawAccuracy: lastRawAccuracy ?? this.lastRawAccuracy,
      hasReceivedAnyFix: hasReceivedAnyFix ?? this.hasReceivedAnyFix,
      errorMessage: errorMessage,
    );
  }
}

final locationServiceProvider = Provider<LocationService>((ref) {
  return GeolocatorLocationService();
});

class GpsController extends Notifier<GpsSessionState> {
  StreamSubscription<PositionData>? _positionSubscription;
  final GpsPointFilter _filter = GpsPointFilter();
  final RouteAggregator _aggregator = RouteAggregator();

  @override
  GpsSessionState build() {
    return const GpsSessionState(
      isTracking: false,
      distanceKm: 0.0,
      currentSpeedKmH: 0.0,
      actualCadenceSpm: 0.0,
      routePoints: [],
    );
  }

  Future<void> startTracking() async {
    final locationService = ref.read(locationServiceProvider);
    final hasPermission = await locationService.checkAndRequestPermission();
    if (!hasPermission) {
      state = state.copyWith(errorMessage: 'Location permission denied or GPS disabled.');
      return;
    }

    _filter.reset();
    _aggregator.reset();

    state = state.copyWith(
      isTracking: true,
      distanceKm: 0.0,
      currentSpeedKmH: 0.0,
      actualCadenceSpm: 0.0,
      routePoints: [],
      errorMessage: null,
    );

    _positionSubscription = locationService.getPositionStream().listen((pos) {
      final filtered = _filter.filter(
        latitude: pos.latitude,
        longitude: pos.longitude,
        accuracyMeters: pos.accuracy,
        timestamp: pos.timestamp,
        speed: pos.speed,
      );

      if (filtered != null) {
        _aggregator.addPoint(filtered);
        
        double stride = 1.10;
        try {
          stride = ref.read(cadenceProvider).strideLengthMeters;
        } catch (_) {}

        final actualCadence = ActualCadenceCalculator.calculate(
          speedKmH: _aggregator.currentSpeedKmH,
          strideLengthMeters: stride,
        );

        state = state.copyWith(
          distanceKm: _aggregator.totalDistanceKm,
          currentSpeedKmH: _aggregator.currentSpeedKmH,
          actualCadenceSpm: actualCadence,
          routePoints: _aggregator.points,
          lastRawAccuracy: pos.accuracy,
          hasReceivedAnyFix: true,
        );
      } else {
        state = state.copyWith(
          lastRawAccuracy: pos.accuracy,
          hasReceivedAnyFix: true,
        );
      }
    }, onError: (e) {
      state = state.copyWith(errorMessage: e.toString());
    });
  }

  void stopTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    state = state.copyWith(isTracking: false);
  }
}

final gpsControllerProvider = NotifierProvider<GpsController, GpsSessionState>(
  GpsController.new,
);
