import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/cadence_constants.dart';
import '../formulas/pace_formulas.dart';

class MetricPoint {
  final double timeSeconds;
  final double absoluteTimestamp;
  final double cadence;
  final double speed;
  final double stride;

  const MetricPoint({
    required this.timeSeconds,
    required this.absoluteTimestamp,
    required this.cadence,
    required this.speed,
    required this.stride,
  });
}

class CadenceState {
  final int targetCadence;
  final double strideLengthMeters;
  final bool isRunning;
  final List<MetricPoint> history;
  final double sessionStartTimeSeconds;

  const CadenceState({
    required this.targetCadence,
    required this.strideLengthMeters,
    required this.isRunning,
    required this.history,
    required this.sessionStartTimeSeconds,
  });

  CadenceState copyWith({
    int? targetCadence,
    double? strideLengthMeters,
    bool? isRunning,
    List<MetricPoint>? history,
    double? sessionStartTimeSeconds,
  }) {
    return CadenceState(
      targetCadence: targetCadence ?? this.targetCadence,
      strideLengthMeters: strideLengthMeters ?? this.strideLengthMeters,
      isRunning: isRunning ?? this.isRunning,
      history: history ?? this.history,
      sessionStartTimeSeconds: sessionStartTimeSeconds ?? this.sessionStartTimeSeconds,
    );
  }
}

class CadenceNotifier extends Notifier<CadenceState> {
  @override
  CadenceState build() {
    final nowEpoch = DateTime.now().millisecondsSinceEpoch / 1000.0;
    return CadenceState(
      targetCadence: 180,
      strideLengthMeters: CadenceConstants.defaultStrideLengthMeters,
      isRunning: false,
      history: [
        MetricPoint(
          timeSeconds: 0,
          absoluteTimestamp: nowEpoch,
          cadence: 180,
          speed: PaceFormulas.cadenceAndStrideToSpeedKmH(180, CadenceConstants.defaultStrideLengthMeters),
          stride: CadenceConstants.defaultStrideLengthMeters,
        )
      ],
      sessionStartTimeSeconds: nowEpoch,
    );
  }

  void setTargetCadence(int cadence) {
    final clamped = cadence.clamp(60, 240);
    final nowEpoch = DateTime.now().millisecondsSinceEpoch / 1000.0;
    final relTime = nowEpoch - state.sessionStartTimeSeconds;
    final speed = PaceFormulas.cadenceAndStrideToSpeedKmH(clamped.toDouble(), state.strideLengthMeters);
    
    final newPoint = MetricPoint(
      timeSeconds: relTime < 0 ? 0 : relTime,
      absoluteTimestamp: nowEpoch,
      cadence: clamped.toDouble(),
      speed: speed,
      stride: state.strideLengthMeters,
    );

    final updatedHistory = List<MetricPoint>.from(state.history)..add(newPoint);
    if (updatedHistory.length > 3600) {
      updatedHistory.removeAt(0);
    }

    state = state.copyWith(
      targetCadence: clamped,
      history: updatedHistory,
    );
  }

  void setStrideLength(double stride) {
    final clamped = stride.clamp(0.4, 2.0);
    final nowEpoch = DateTime.now().millisecondsSinceEpoch / 1000.0;
    final relTime = nowEpoch - state.sessionStartTimeSeconds;
    final speed = PaceFormulas.cadenceAndStrideToSpeedKmH(state.targetCadence.toDouble(), clamped);

    final newPoint = MetricPoint(
      timeSeconds: relTime < 0 ? 0 : relTime,
      absoluteTimestamp: nowEpoch,
      cadence: state.targetCadence.toDouble(),
      speed: speed,
      stride: clamped,
    );

    final updatedHistory = List<MetricPoint>.from(state.history)..add(newPoint);
    if (updatedHistory.length > 3600) {
      updatedHistory.removeAt(0);
    }

    state = state.copyWith(
      strideLengthMeters: clamped,
      history: updatedHistory,
    );
  }

  void setRunning(bool running) {
    final nowEpoch = DateTime.now().millisecondsSinceEpoch / 1000.0;
    if (running && !state.isRunning) {
      if (state.history.isNotEmpty) {
        final lastPoint = state.history.last;
        final gap = nowEpoch - lastPoint.absoluteTimestamp;
        if (gap > 1800) {
          // If paused > 30 minutes, reset history
          state = state.copyWith(
            isRunning: true,
            sessionStartTimeSeconds: nowEpoch,
            history: [
              MetricPoint(
                timeSeconds: 0,
                absoluteTimestamp: nowEpoch,
                cadence: state.targetCadence.toDouble(),
                speed: PaceFormulas.cadenceAndStrideToSpeedKmH(state.targetCadence.toDouble(), state.strideLengthMeters),
                stride: state.strideLengthMeters,
              )
            ],
          );
        } else {
          // Resumed within 30 minutes -> keep history intact (gap shown as blank)
          state = state.copyWith(isRunning: true);
        }
      } else {
        state = state.copyWith(
          isRunning: true,
          sessionStartTimeSeconds: nowEpoch,
          history: [
            MetricPoint(
              timeSeconds: 0,
              absoluteTimestamp: nowEpoch,
              cadence: state.targetCadence.toDouble(),
              speed: PaceFormulas.cadenceAndStrideToSpeedKmH(state.targetCadence.toDouble(), state.strideLengthMeters),
              stride: state.strideLengthMeters,
            )
          ],
        );
      }
    } else {
      state = state.copyWith(isRunning: running);
    }
  }

  void addTickPoint() {
    if (!state.isRunning) return;
    final nowEpoch = DateTime.now().millisecondsSinceEpoch / 1000.0;
    final relTime = nowEpoch - state.sessionStartTimeSeconds;
    final speed = PaceFormulas.cadenceAndStrideToSpeedKmH(state.targetCadence.toDouble(), state.strideLengthMeters);
    
    if (state.history.isNotEmpty && (nowEpoch - state.history.last.absoluteTimestamp) < 0.9) {
      return;
    }

    final newPoint = MetricPoint(
      timeSeconds: relTime < 0 ? 0 : relTime,
      absoluteTimestamp: nowEpoch,
      cadence: state.targetCadence.toDouble(),
      speed: speed,
      stride: state.strideLengthMeters,
    );

    final updatedHistory = List<MetricPoint>.from(state.history)..add(newPoint);
    if (updatedHistory.length > 3600) {
      updatedHistory.removeAt(0);
    }
    state = state.copyWith(history: updatedHistory);
  }

  void resetHistory() {
    final nowEpoch = DateTime.now().millisecondsSinceEpoch / 1000.0;
    state = state.copyWith(
      sessionStartTimeSeconds: nowEpoch,
      history: [
        MetricPoint(
          timeSeconds: 0,
          absoluteTimestamp: nowEpoch,
          cadence: state.targetCadence.toDouble(),
          speed: PaceFormulas.cadenceAndStrideToSpeedKmH(state.targetCadence.toDouble(), state.strideLengthMeters),
          stride: state.strideLengthMeters,
        )
      ],
    );
  }
}

final cadenceProvider = NotifierProvider<CadenceNotifier, CadenceState>(CadenceNotifier.new);

