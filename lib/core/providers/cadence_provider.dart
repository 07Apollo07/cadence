import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../formulas/pace_formulas.dart';

enum MovementMode { walking, jogging, running }

class MetricPoint {
  final double timeSeconds;
  final double absoluteTimestamp;
  final double cadence;
  final double speed;
  final double stride;
  final MovementMode mode;

  const MetricPoint({
    required this.timeSeconds,
    required this.absoluteTimestamp,
    required this.cadence,
    required this.speed,
    required this.stride,
    required this.mode,
  });
}

class CadenceHistoryState {
  final List<MetricPoint> history;
  final double sessionStartTimeSeconds;

  const CadenceHistoryState({
    required this.history,
    required this.sessionStartTimeSeconds,
  });

  CadenceHistoryState copyWith({
    List<MetricPoint>? history,
    double? sessionStartTimeSeconds,
  }) {
    return CadenceHistoryState(
      history: history ?? this.history,
      sessionStartTimeSeconds: sessionStartTimeSeconds ?? this.sessionStartTimeSeconds,
    );
  }
}

class CadenceHistoryNotifier extends Notifier<CadenceHistoryState> {
  @override
  CadenceHistoryState build() {
    final nowEpoch = DateTime.now().millisecondsSinceEpoch / 1000.0;
    const defaultJog = 1.10;
    return CadenceHistoryState(
      history: [
        MetricPoint(
          timeSeconds: 0,
          absoluteTimestamp: nowEpoch,
          cadence: 180,
          speed: PaceFormulas.cadenceAndStrideToSpeedKmH(180, defaultJog),
          stride: defaultJog,
          mode: MovementMode.jogging,
        )
      ],
      sessionStartTimeSeconds: nowEpoch,
    );
  }

  void addPoint(MetricPoint point) {
    final updated = List<MetricPoint>.from(state.history)..add(point);
    if (updated.length > 3600) {
      updated.removeAt(0);
    }
    state = state.copyWith(history: updated);
  }

  void reset(double nowEpoch, double cadence, double stride, MovementMode mode) {
    state = CadenceHistoryState(
      sessionStartTimeSeconds: nowEpoch,
      history: [
        MetricPoint(
          timeSeconds: 0,
          absoluteTimestamp: nowEpoch,
          cadence: cadence,
          speed: PaceFormulas.cadenceAndStrideToSpeedKmH(cadence, stride),
          stride: stride,
          mode: mode,
        )
      ],
    );
  }

  void setStartTime(double startTime) {
    state = state.copyWith(sessionStartTimeSeconds: startTime);
  }
}

final cadenceHistoryProvider = NotifierProvider<CadenceHistoryNotifier, CadenceHistoryState>(CadenceHistoryNotifier.new);

class CadenceState {
  final int targetCadence;
  final MovementMode movementMode;
  final double walkStride;
  final double jogStride;
  final double runStride;
  final Color walkColor;
  final Color jogColor;
  final Color runColor;
  final double userHeightCm;
  final bool isRunning;

  final String normalAudio;
  final String accentedAudio;

  const CadenceState({
    required this.targetCadence,
    required this.movementMode,
    required this.walkStride,
    required this.jogStride,
    required this.runStride,
    required this.walkColor,
    required this.jogColor,
    required this.runColor,
    required this.userHeightCm,
    required this.isRunning,
    required this.normalAudio,
    required this.accentedAudio,
  });

  double get strideLengthMeters {
    switch (movementMode) {
      case MovementMode.walking:
        return walkStride;
      case MovementMode.jogging:
        return jogStride;
      case MovementMode.running:
        return runStride;
    }
  }

  Color colorForMode(MovementMode m) {
    switch (m) {
      case MovementMode.walking:
        return walkColor;
      case MovementMode.jogging:
        return jogColor;
      case MovementMode.running:
        return runColor;
    }
  }

  Color get activeColor {
    switch (movementMode) {
      case MovementMode.walking:
        return walkColor;
      case MovementMode.jogging:
        return jogColor;
      case MovementMode.running:
        return runColor;
    }
  }

  CadenceState copyWith({
    int? targetCadence,
    MovementMode? movementMode,
    double? walkStride,
    double? jogStride,
    double? runStride,
    Color? walkColor,
    Color? jogColor,
    Color? runColor,
    double? userHeightCm,
    bool? isRunning,
    String? normalAudio,
    String? accentedAudio,
  }) {
    return CadenceState(
      targetCadence: targetCadence ?? this.targetCadence,
      movementMode: movementMode ?? this.movementMode,
      walkStride: walkStride ?? this.walkStride,
      jogStride: jogStride ?? this.jogStride,
      runStride: runStride ?? this.runStride,
      walkColor: walkColor ?? this.walkColor,
      jogColor: jogColor ?? this.jogColor,
      runColor: runColor ?? this.runColor,
      userHeightCm: userHeightCm ?? this.userHeightCm,
      isRunning: isRunning ?? this.isRunning,
      normalAudio: normalAudio ?? this.normalAudio,
      accentedAudio: accentedAudio ?? this.accentedAudio,
    );
  }
}

class CadenceNotifier extends Notifier<CadenceState> {
  @override
  CadenceState build() {
    const defaultWalk = 0.75;
    const defaultJog = 1.10;
    const defaultRun = 1.30;
    return CadenceState(
      targetCadence: 180,
      movementMode: MovementMode.jogging,
      walkStride: defaultWalk,
      jogStride: defaultJog,
      runStride: defaultRun,
      walkColor: Colors.green,
      jogColor: Colors.amber,
      runColor: Colors.deepOrange,
      userHeightCm: 175.0,
      isRunning: false,
      normalAudio: 'claves44_wav.wav',
      accentedAudio: 'woodblock_high44_wav.wav',
    );
  }

  void setMovementMode(MovementMode mode) {
    if (state.movementMode == mode) return;
    state = state.copyWith(movementMode: mode);
    if (!state.isRunning) return;

    final historyState = ref.read(cadenceHistoryProvider);
    final nowEpoch = DateTime.now().millisecondsSinceEpoch / 1000.0;
    final relTime = nowEpoch - historyState.sessionStartTimeSeconds;
    final newStride = mode == MovementMode.walking
        ? state.walkStride
        : mode == MovementMode.jogging
            ? state.jogStride
            : state.runStride;
    final speed = PaceFormulas.cadenceAndStrideToSpeedKmH(state.targetCadence.toDouble(), newStride);

    final newPoint = MetricPoint(
      timeSeconds: relTime < 0 ? 0 : relTime,
      absoluteTimestamp: nowEpoch,
      cadence: state.targetCadence.toDouble(),
      speed: speed,
      stride: newStride,
      mode: mode,
    );

    ref.read(cadenceHistoryProvider.notifier).addPoint(newPoint);
  }

  void setTargetCadence(int cadence) {
    final clamped = cadence.clamp(60, 240);
    state = state.copyWith(targetCadence: clamped);
    if (!state.isRunning) return;

    final historyState = ref.read(cadenceHistoryProvider);
    final nowEpoch = DateTime.now().millisecondsSinceEpoch / 1000.0;
    final relTime = nowEpoch - historyState.sessionStartTimeSeconds;
    final speed = PaceFormulas.cadenceAndStrideToSpeedKmH(clamped.toDouble(), state.strideLengthMeters);
    
    final newPoint = MetricPoint(
      timeSeconds: relTime < 0 ? 0 : relTime,
      absoluteTimestamp: nowEpoch,
      cadence: clamped.toDouble(),
      speed: speed,
      stride: state.strideLengthMeters,
      mode: state.movementMode,
    );

    ref.read(cadenceHistoryProvider.notifier).addPoint(newPoint);
  }

  void setStrideLength(double stride) {
    setModeStride(state.movementMode, stride);
  }

  void setModeStride(MovementMode mode, double stride) {
    final clamped = stride.clamp(0.4, 2.5);
    double walk = state.walkStride;
    double jog = state.jogStride;
    double run = state.runStride;

    if (mode == MovementMode.walking) walk = clamped;
    if (mode == MovementMode.jogging) jog = clamped;
    if (mode == MovementMode.running) run = clamped;

    state = state.copyWith(
      walkStride: walk,
      jogStride: jog,
      runStride: run,
    );
    if (!state.isRunning) return;

    final activeStride = mode == state.movementMode
        ? clamped
        : state.strideLengthMeters;

    final historyState = ref.read(cadenceHistoryProvider);
    final nowEpoch = DateTime.now().millisecondsSinceEpoch / 1000.0;
    final relTime = nowEpoch - historyState.sessionStartTimeSeconds;
    final speed = PaceFormulas.cadenceAndStrideToSpeedKmH(state.targetCadence.toDouble(), activeStride);

    final newPoint = MetricPoint(
      timeSeconds: relTime < 0 ? 0 : relTime,
      absoluteTimestamp: nowEpoch,
      cadence: state.targetCadence.toDouble(),
      speed: speed,
      stride: activeStride,
      mode: state.movementMode,
    );

    ref.read(cadenceHistoryProvider.notifier).addPoint(newPoint);
  }

  void setModeColor(MovementMode mode, Color color) {
    if (mode == MovementMode.walking) {
      state = state.copyWith(walkColor: color);
    } else if (mode == MovementMode.jogging) {
      state = state.copyWith(jogColor: color);
    } else if (mode == MovementMode.running) {
      state = state.copyWith(runColor: color);
    }
  }

  void setAudioSelection(String normal, String accented) {
    state = state.copyWith(normalAudio: normal, accentedAudio: accented);
  }

  void prefillStridesFromHeight(double heightCm) {
    final w = double.parse((heightCm * 0.415 / 100).toStringAsFixed(2));
    final j = double.parse((heightCm * 0.55 / 100).toStringAsFixed(2));
    final r = double.parse((heightCm * 0.65 / 100).toStringAsFixed(2));

    state = state.copyWith(
      userHeightCm: heightCm,
      walkStride: w.clamp(0.4, 2.5),
      jogStride: j.clamp(0.4, 2.5),
      runStride: r.clamp(0.4, 2.5),
    );
  }

  void setRunning(bool running) {
    final nowEpoch = DateTime.now().millisecondsSinceEpoch / 1000.0;
    if (running && !state.isRunning) {
      final historyState = ref.read(cadenceHistoryProvider);
      if (historyState.history.isNotEmpty) {
        final lastPoint = historyState.history.last;
        final gap = nowEpoch - lastPoint.absoluteTimestamp;
        if (gap > 1800) {
          // If paused > 30 minutes, reset history
          ref.read(cadenceHistoryProvider.notifier).reset(
                nowEpoch,
                state.targetCadence.toDouble(),
                state.strideLengthMeters,
                state.movementMode,
              );
        } else {
          // Resumed within 30 minutes -> keep history intact (gap shown as blank)
        }
      } else {
        ref.read(cadenceHistoryProvider.notifier).reset(
              nowEpoch,
              state.targetCadence.toDouble(),
              state.strideLengthMeters,
              state.movementMode,
            );
      }
      state = state.copyWith(isRunning: true);
    } else {
      state = state.copyWith(isRunning: running);
    }
  }

  void addTickPoint() {
    if (!state.isRunning) return;
    final historyState = ref.read(cadenceHistoryProvider);
    final nowEpoch = DateTime.now().millisecondsSinceEpoch / 1000.0;
    final relTime = nowEpoch - historyState.sessionStartTimeSeconds;
    final speed = PaceFormulas.cadenceAndStrideToSpeedKmH(state.targetCadence.toDouble(), state.strideLengthMeters);
    
    final newPoint = MetricPoint(
      timeSeconds: relTime < 0 ? 0 : relTime,
      absoluteTimestamp: nowEpoch,
      cadence: state.targetCadence.toDouble(),
      speed: speed,
      stride: state.strideLengthMeters,
      mode: state.movementMode,
    );

    ref.read(cadenceHistoryProvider.notifier).addPoint(newPoint);
  }

  void resetHistory() {
    final nowEpoch = DateTime.now().millisecondsSinceEpoch / 1000.0;
    ref.read(cadenceHistoryProvider.notifier).reset(
          nowEpoch,
          state.targetCadence.toDouble(),
          state.strideLengthMeters,
          state.movementMode,
        );
  }
}

final cadenceProvider = NotifierProvider<CadenceNotifier, CadenceState>(CadenceNotifier.new);

