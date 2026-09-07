import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'location_service.dart';
import 'gps_point_filter.dart';
import 'route_aggregator.dart';
import 'actual_cadence_calculator.dart';
import '../../core/providers/cadence_provider.dart';
import '../../core/services/notification_service.dart';

enum GpsStatus {
  idle,
  tracking,
  paused,
}

class GpsSessionState {
  final GpsStatus status;
  final double distanceKm;
  final double currentSpeedKmH;
  final double actualCadenceSpm;
  final List<LatLng> routePoints;
  final double? lastRawAccuracy;
  final bool hasReceivedAnyFix;
  final String? errorMessage;

  const GpsSessionState({
    required this.status,
    required this.distanceKm,
    required this.currentSpeedKmH,
    required this.actualCadenceSpm,
    required this.routePoints,
    this.lastRawAccuracy,
    this.hasReceivedAnyFix = false,
    this.errorMessage,
  });

  bool get isTracking => status == GpsStatus.tracking;
  bool get isPaused => status == GpsStatus.paused;
  bool get isIdle => status == GpsStatus.idle;
  bool get isSessionActive => status != GpsStatus.idle;

  GpsSessionState copyWith({
    GpsStatus? status,
    double? distanceKm,
    double? currentSpeedKmH,
    double? actualCadenceSpm,
    List<LatLng>? routePoints,
    double? lastRawAccuracy,
    bool? hasReceivedAnyFix,
    String? errorMessage,
  }) {
    return GpsSessionState(
      status: status ?? this.status,
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
      status: GpsStatus.idle,
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
      status: GpsStatus.tracking,
      distanceKm: 0.0,
      currentSpeedKmH: 0.0,
      actualCadenceSpm: 0.0,
      routePoints: [],
      errorMessage: null,
    );

    _startListening(locationService);
    _syncNotification();
  }

  Future<void> resumeTracking() async {
    if (state.status != GpsStatus.paused) return;

    final locationService = ref.read(locationServiceProvider);
    final hasPermission = await locationService.checkAndRequestPermission();
    if (!hasPermission) {
      state = state.copyWith(errorMessage: 'Location permission denied or GPS disabled.');
      return;
    }

    state = state.copyWith(
      status: GpsStatus.tracking,
      errorMessage: null,
    );

    _startListening(locationService);
    _syncNotification();
  }

  void _startListening(LocationService locationService) {
    _positionSubscription?.cancel();
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
      _syncNotification();
    }, onError: (e) {
      state = state.copyWith(errorMessage: e.toString());
      _syncNotification();
    });
  }

  void pauseTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    state = state.copyWith(status: GpsStatus.paused);
    _syncNotification();
  }

  void stopTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    state = state.copyWith(status: GpsStatus.idle);
    _syncNotification();
  }

  void _syncNotification() {
    NotificationService().updateGpsNotification(
      isTracking: state.isTracking,
      isPaused: state.isPaused,
      distanceKm: state.distanceKm,
      speedKmH: state.currentSpeedKmH,
    );
  }
}

final gpsControllerProvider = NotifierProvider<GpsController, GpsSessionState>(
  GpsController.new,
);
