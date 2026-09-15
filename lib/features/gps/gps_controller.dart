import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'location_service.dart';
import 'gps_point_filter.dart';
import 'route_aggregator.dart';
import 'actual_cadence_calculator.dart';
import '../../core/providers/cadence_provider.dart';
import '../../core/services/notification_service.dart';
import '../../core/storage/app_database.dart';
import '../history/models/gps_track_point.dart';
import '../history/models/km_split.dart';
import '../history/repositories/gps_session_repository.dart';

enum GpsStatus { idle, tracking, paused }

class GpsSessionState {
  final GpsStatus status;
  final int? activeSessionId;
  final double distanceKm;
  final double currentSpeedKmH;
  final double actualCadenceSpm;
  final List<LatLng> routePoints;
  final LatLng? latestPosition;
  final Duration movingDuration;
  final Duration idleDuration;
  final Duration pauseDuration;
  final Duration elapsedDuration;
  final double? lastRawAccuracy;
  final bool hasReceivedAnyFix;
  final bool isGpsEnabled;
  final bool isGpsDropped;
  final String? errorMessage;
  final WorkoutSession? recentResumableSession;

  const GpsSessionState({
    required this.status,
    this.activeSessionId,
    required this.distanceKm,
    required this.currentSpeedKmH,
    required this.actualCadenceSpm,
    required this.routePoints,
    this.latestPosition,
    this.movingDuration = Duration.zero,
    this.idleDuration = Duration.zero,
    this.pauseDuration = Duration.zero,
    this.elapsedDuration = Duration.zero,
    this.lastRawAccuracy,
    this.hasReceivedAnyFix = false,
    this.isGpsEnabled = true,
    this.isGpsDropped = false,
    this.errorMessage,
    this.recentResumableSession,
  });

  bool get isTracking => status == GpsStatus.tracking;
  bool get isPaused => status == GpsStatus.paused;
  bool get isIdle => status == GpsStatus.idle;
  bool get isSessionActive => status != GpsStatus.idle;
  Duration get totalDuration => elapsedDuration > Duration.zero
      ? elapsedDuration
      : (movingDuration + idleDuration + pauseDuration);

  GpsSessionState copyWith({
    GpsStatus? status,
    int? activeSessionId,
    double? distanceKm,
    double? currentSpeedKmH,
    double? actualCadenceSpm,
    List<LatLng>? routePoints,
    LatLng? latestPosition,
    Duration? movingDuration,
    Duration? idleDuration,
    Duration? pauseDuration,
    Duration? elapsedDuration,
    double? lastRawAccuracy,
    bool? hasReceivedAnyFix,
    bool? isGpsEnabled,
    bool? isGpsDropped,
    String? errorMessage,
    WorkoutSession? recentResumableSession,
    bool clearResumableSession = false,
  }) {
    return GpsSessionState(
      status: status ?? this.status,
      activeSessionId: activeSessionId ?? this.activeSessionId,
      distanceKm: distanceKm ?? this.distanceKm,
      currentSpeedKmH: currentSpeedKmH ?? this.currentSpeedKmH,
      actualCadenceSpm: actualCadenceSpm ?? this.actualCadenceSpm,
      routePoints: routePoints ?? this.routePoints,
      latestPosition: latestPosition ?? this.latestPosition,
      movingDuration: movingDuration ?? this.movingDuration,
      idleDuration: idleDuration ?? this.idleDuration,
      pauseDuration: pauseDuration ?? this.pauseDuration,
      elapsedDuration: elapsedDuration ?? this.elapsedDuration,
      lastRawAccuracy: lastRawAccuracy ?? this.lastRawAccuracy,
      hasReceivedAnyFix: hasReceivedAnyFix ?? this.hasReceivedAnyFix,
      isGpsEnabled: isGpsEnabled ?? this.isGpsEnabled,
      isGpsDropped: isGpsDropped ?? this.isGpsDropped,
      errorMessage: errorMessage,
      recentResumableSession: clearResumableSession
          ? null
          : (recentResumableSession ?? this.recentResumableSession),
    );
  }
}

final locationServiceProvider = Provider<LocationService>((ref) {
  return GeolocatorLocationService();
});

class GpsController extends Notifier<GpsSessionState> {
  StreamSubscription<PositionData>? _positionSubscription;
  StreamSubscription<ServiceStatus>? _serviceStatusSubscription;
  Timer? _uiTicker;
  final GpsPointFilter _filter = GpsPointFilter();
  final RouteAggregator _aggregator = RouteAggregator();

  @override
  GpsSessionState build() {
    ref.onDispose(() {
      _positionSubscription?.cancel();
      _serviceStatusSubscription?.cancel();
      _uiTicker?.cancel();
    });
    final locationService = ref.read(locationServiceProvider);

    _serviceStatusSubscription = locationService
        .getServiceStatusStream()
        .listen((status) {
          if (status == ServiceStatus.disabled) {
            state = state.copyWith(
              isGpsEnabled: false,
              isGpsDropped: state.isTracking,
              errorMessage: 'GPS service was turned off.',
            );
          } else if (status == ServiceStatus.enabled) {
            state = state.copyWith(
              isGpsEnabled: true,
              isGpsDropped: false,
              errorMessage: null,
            );
          }
        });

    Future.microtask(() async {
      final enabled = await locationService.isLocationServiceEnabled();
      if (!enabled) {
        state = state.copyWith(
          isGpsEnabled: false,
          errorMessage: 'GPS is disabled.',
        );
      }
      await checkResumableSession();
      _startListening(locationService);
    });
    return const GpsSessionState(
      status: GpsStatus.idle,
      distanceKm: 0.0,
      currentSpeedKmH: 0.0,
      actualCadenceSpm: 0.0,
      routePoints: [],
    );
  }

  Future<void> checkAndRetryGps() async {
    final locationService = ref.read(locationServiceProvider);
    final serviceEnabled = await locationService.isLocationServiceEnabled();
    if (!serviceEnabled) {
      state = state.copyWith(
        isGpsEnabled: false,
        errorMessage:
            'Location services are still disabled. Please turn on GPS.',
      );
      return;
    }

    final hasPermission = await locationService.checkAndRequestPermission();
    if (!hasPermission) {
      state = state.copyWith(
        isGpsEnabled: true,
        errorMessage: 'Location permission denied or GPS disabled.',
      );
      return;
    }

    state = state.copyWith(
      isGpsEnabled: true,
      isGpsDropped: false,
      errorMessage: null,
    );

    _startListening(locationService);
  }

  Future<void> checkResumableSession() async {
    try {
      final repo = ref.read(gpsSessionRepositoryProvider);
      final recent = await repo.getRecentSessionWithin(
        const Duration(hours: 1, minutes: 30),
      );
      if (recent != null && state.isIdle) {
        state = state.copyWith(recentResumableSession: recent);
      }
    } catch (_) {}
  }

  void dismissResumableBanner() {
    state = state.copyWith(clearResumableSession: true);
  }

  Future<void> startTracking() async {
    final locationService = ref.read(locationServiceProvider);
    final serviceEnabled = await locationService.isLocationServiceEnabled();
    if (!serviceEnabled) {
      state = state.copyWith(
        isGpsEnabled: false,
        errorMessage: 'Location services are disabled. Please enable GPS.',
      );
      return;
    }

    final hasPermission = await locationService.checkAndRequestPermission();
    if (!hasPermission) {
      state = state.copyWith(
        isGpsEnabled: true,
        errorMessage: 'Location permission denied or GPS disabled.',
      );
      return;
    }

    _filter.reset();
    _aggregator.reset();
    _aggregator.startSession();

    state = state.copyWith(
      status: GpsStatus.tracking,
      activeSessionId: null,
      distanceKm: 0.0,
      currentSpeedKmH: 0.0,
      actualCadenceSpm: 0.0,
      routePoints: [],
      movingDuration: Duration.zero,
      idleDuration: Duration.zero,
      pauseDuration: Duration.zero,
      elapsedDuration: Duration.zero,
      isGpsEnabled: true,
      isGpsDropped: false,
      errorMessage: null,
      clearResumableSession: true,
    );

    _startListening(locationService);
    _startTicker();
    _syncNotification();
  }

  Future<void> resumePreviousSession(WorkoutSession session) async {
    final locationService = ref.read(locationServiceProvider);
    final serviceEnabled = await locationService.isLocationServiceEnabled();
    if (!serviceEnabled) {
      state = state.copyWith(
        isGpsEnabled: false,
        errorMessage: 'Location services are disabled. Please enable GPS.',
      );
      return;
    }

    final hasPermission = await locationService.checkAndRequestPermission();
    if (!hasPermission) {
      state = state.copyWith(
        isGpsEnabled: true,
        errorMessage: 'Location permission denied or GPS disabled.',
      );
      return;
    }

    _filter.reset();

    List<GpsTrackPoint> points = [];
    if (session.routePointsJson != null &&
        session.routePointsJson!.isNotEmpty) {
      try {
        final list = jsonDecode(session.routePointsJson!) as List;
        points = list
            .map((item) => GpsTrackPoint.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }

    List<KmSplit> splits = [];
    if (session.splitsJson != null && session.splitsJson!.isNotEmpty) {
      try {
        final list = jsonDecode(session.splitsJson!) as List;
        splits = list
            .map((item) => KmSplit.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }

    _aggregator.restoreFromSession(
      startTime: session.startTime,
      movingDuration: Duration(seconds: session.movingDurationSeconds),
      pauseDuration: Duration(seconds: session.pauseDurationSeconds),
      distanceKm: session.distanceKm,
      points: points,
      splits: splits,
    );

    state = state.copyWith(
      status: GpsStatus.tracking,
      activeSessionId: session.id,
      distanceKm: _aggregator.totalDistanceKm,
      currentSpeedKmH: _aggregator.currentSpeedKmH,
      actualCadenceSpm: _aggregator.avgCadence,
      routePoints: _aggregator.points,
      movingDuration: _aggregator.movingDuration,
      idleDuration: _aggregator.idleDuration,
      pauseDuration: _aggregator.pauseDuration,
      elapsedDuration: _aggregator.elapsedDuration,
      errorMessage: null,
      clearResumableSession: true,
    );

    _startListening(locationService);
    _startTicker();
    _syncNotification();
  }

  Future<void> resumeTracking() async {
    if (state.status != GpsStatus.paused) return;

    final locationService = ref.read(locationServiceProvider);
    final serviceEnabled = await locationService.isLocationServiceEnabled();
    if (!serviceEnabled) {
      state = state.copyWith(
        isGpsEnabled: false,
        errorMessage: 'Location services are disabled. Please enable GPS.',
      );
      return;
    }

    final hasPermission = await locationService.checkAndRequestPermission();
    if (!hasPermission) {
      state = state.copyWith(
        isGpsEnabled: true,
        errorMessage: 'Location permission denied or GPS disabled.',
      );
      return;
    }

    _aggregator.onResume();

    state = state.copyWith(
      status: GpsStatus.tracking,
      movingDuration: _aggregator.movingDuration,
      idleDuration: _aggregator.idleDuration,
      pauseDuration: _aggregator.pauseDuration,
      elapsedDuration: _aggregator.elapsedDuration,
      isGpsEnabled: true,
      isGpsDropped: false,
      errorMessage: null,
    );

    _startListening(locationService);
    _startTicker();
    _syncNotification();
  }

  void _startTicker() {
    _uiTicker?.cancel();
    _uiTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.isSessionActive) {
        state = state.copyWith(
          movingDuration: _aggregator.movingDuration,
          idleDuration: _aggregator.idleDuration,
          pauseDuration: _aggregator.pauseDuration,
          elapsedDuration: _aggregator.elapsedDuration,
        );
      }
    });
  }

  void _startListening(LocationService locationService) {
    _positionSubscription?.cancel();
    _positionSubscription = locationService
        .getPositionStream(isTracking: state.isTracking)
        .listen(
          (pos) {
            state = state.copyWith(
              isGpsEnabled: true,
              isGpsDropped: false,
              errorMessage: null,
            );
            final loc = LatLng(pos.latitude, pos.longitude);
            if (state.isIdle || state.isPaused) {
              state = state.copyWith(
                latestPosition: loc,
                lastRawAccuracy: pos.accuracy,
                hasReceivedAnyFix: true,
              );
            } else if (state.isTracking) {
              final filtered = _filter.filter(
                latitude: pos.latitude,
                longitude: pos.longitude,
                accuracyMeters: pos.accuracy,
                timestamp: pos.timestamp,
                speed: pos.speed,
              );

              if (filtered != null) {
                double stride = 1.10;
                MovementMode mode = MovementMode.jogging;
                try {
                  final cadenceState = ref.read(cadenceProvider);
                  stride = cadenceState.strideLengthMeters;
                  mode = cadenceState.movementMode;
                } catch (_) {}

                final actualCadence = ActualCadenceCalculator.calculate(
                  speedKmH: (pos.speed != null && pos.speed! >= 0)
                      ? pos.speed! * 3.6
                      : _aggregator.currentSpeedKmH,
                  strideLengthMeters: stride,
                );

                _aggregator.addPoint(
                  filtered,
                  cadenceSpm: actualCadence,
                  movementMode: mode,
                  strideLengthMeters: stride,
                );

                state = state.copyWith(
                  distanceKm: _aggregator.totalDistanceKm,
                  currentSpeedKmH: _aggregator.currentSpeedKmH,
                  actualCadenceSpm: actualCadence,
                  routePoints: _aggregator.points,
                  latestPosition: loc,
                  movingDuration: _aggregator.movingDuration,
                  idleDuration: _aggregator.idleDuration,
                  pauseDuration: _aggregator.pauseDuration,
                  elapsedDuration: _aggregator.elapsedDuration,
                  lastRawAccuracy: pos.accuracy,
                  hasReceivedAnyFix: true,
                );
              } else {
                state = state.copyWith(
                  latestPosition: loc,
                  lastRawAccuracy: pos.accuracy,
                  hasReceivedAnyFix: true,
                );
              }
              _syncNotification();
            }
          },
          onError: (e) {
            state = state.copyWith(errorMessage: e.toString());
            _syncNotification();
          },
        );
  }

  void pauseTracking() {
    _aggregator.onPause();
    state = state.copyWith(
      status: GpsStatus.paused,
      movingDuration: _aggregator.movingDuration,
      idleDuration: _aggregator.idleDuration,
      pauseDuration: _aggregator.pauseDuration,
      elapsedDuration: _aggregator.elapsedDuration,
    );
    _syncNotification();
  }

  Future<void> stopTracking() async {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _uiTicker?.cancel();

    // Persist GPS run to SQLite if there is distance or points recorded
    if (_aggregator.points.isNotEmpty || _aggregator.totalDistanceKm > 0.01) {
      try {
        final repo = ref.read(gpsSessionRepositoryProvider);
        double stride = 1.10;
        try {
          stride = ref.read(cadenceProvider).strideLengthMeters;
        } catch (_) {}

        final startTime = _aggregator.startTime ?? DateTime.now();
        final endTime = DateTime.now();
        final durationSeconds = _aggregator.totalDuration.inSeconds;
        final movingDurationSeconds = _aggregator.movingDuration.inSeconds;
        final pauseDurationSeconds = _aggregator.pauseDuration.inSeconds;
        final targetCadence = ref
            .read(cadenceProvider)
            .targetCadence
            .toDouble();
        final avgCadence = _aggregator.avgCadence;
        final maxCadence = _aggregator.maxCadence;
        final distanceKm = _aggregator.totalDistanceKm;
        final avgPace = _aggregator.avgPaceMinPerKm;
        final bestPace = _aggregator.bestPaceMinPerKm;
        final estimatedCalories = _aggregator.estimatedCalories;
        final estimatedSteps = _aggregator.estimatedSteps(stride);
        final points = _aggregator.detailedPoints;
        final splits = _aggregator.splits;

        if (state.activeSessionId != null) {
          await repo.updateGpsSession(
            id: state.activeSessionId!,
            startTime: startTime,
            endTime: endTime,
            targetCadence: targetCadence,
            avgCadence: avgCadence,
            maxCadence: maxCadence,
            distanceKm: distanceKm,
            durationSeconds: durationSeconds,
            movingDurationSeconds: movingDurationSeconds,
            pauseDurationSeconds: pauseDurationSeconds,
            avgPaceMinPerKm: avgPace,
            bestPaceMinPerKm: bestPace,
            estimatedCalories: estimatedCalories,
            estimatedSteps: estimatedSteps,
            points: points,
            splits: splits,
          );
        } else {
          await repo.insertGpsSession(
            startTime: startTime,
            endTime: endTime,
            targetCadence: targetCadence,
            avgCadence: avgCadence,
            maxCadence: maxCadence,
            distanceKm: distanceKm,
            durationSeconds: durationSeconds,
            movingDurationSeconds: movingDurationSeconds,
            pauseDurationSeconds: pauseDurationSeconds,
            avgPaceMinPerKm: avgPace,
            bestPaceMinPerKm: bestPace,
            estimatedCalories: estimatedCalories,
            estimatedSteps: estimatedSteps,
            points: points,
            splits: splits,
          );
        }
      } catch (e) {
        // Log or handle error gracefully
      }
    }

    state = state.copyWith(
      status: GpsStatus.idle,
      activeSessionId: null,
      distanceKm: 0.0,
      currentSpeedKmH: 0.0,
      actualCadenceSpm: 0.0,
      routePoints: [],
      movingDuration: Duration.zero,
      idleDuration: Duration.zero,
      pauseDuration: Duration.zero,
      elapsedDuration: Duration.zero,
      errorMessage: null,
      recentResumableSession: null,
    );
    _syncNotification();
    _startListening(ref.read(locationServiceProvider));
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
