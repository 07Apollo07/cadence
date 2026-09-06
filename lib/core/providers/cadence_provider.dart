import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../storage/preferences_provider.dart';
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
      sessionStartTimeSeconds:
          sessionStartTimeSeconds ?? this.sessionStartTimeSeconds,
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
        ),
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

  void reset(
    double nowEpoch,
    double cadence,
    double stride,
    MovementMode mode,
  ) {
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
        ),
      ],
    );
  }

  void setStartTime(double startTime) {
    state = state.copyWith(sessionStartTimeSeconds: startTime);
  }
}

final cadenceHistoryProvider =
    NotifierProvider<CadenceHistoryNotifier, CadenceHistoryState>(
      CadenceHistoryNotifier.new,
    );

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
  static const _kTargetCadence = 'cadence_target_cadence';
  static const _kMovementMode = 'cadence_movement_mode';
  static const _kWalkStride = 'cadence_walk_stride';
  static const _kJogStride = 'cadence_jog_stride';
  static const _kRunStride = 'cadence_run_stride';
  static const _kWalkColor = 'cadence_walk_color';
  static const _kJogColor = 'cadence_jog_color';
  static const _kRunColor = 'cadence_run_color';
  static const _kUserHeight = 'cadence_user_height';
  static const _kNormalAudio = 'cadence_normal_audio';
  static const _kAccentedAudio = 'cadence_accented_audio';

  SharedPreferences? get _prefs {
    try {
      return ref.read(sharedPreferencesProvider);
    } catch (_) {
      return null;
    }
  }

  @override
  CadenceState build() {
    final prefs = _prefs;

    final targetCadence = prefs?.getInt(_kTargetCadence) ?? 180;

    final modeName = prefs?.getString(_kMovementMode);
    final movementMode = MovementMode.values.firstWhere(
      (m) => m.name == modeName,
      orElse: () => MovementMode.jogging,
    );

    final walkStride = prefs?.getDouble(_kWalkStride) ?? 0.75;
    final jogStride = prefs?.getDouble(_kJogStride) ?? 1.10;
    final runStride = prefs?.getDouble(_kRunStride) ?? 1.30;

    final walkColorVal = prefs?.getInt(_kWalkColor);
    final jogColorVal = prefs?.getInt(_kJogColor);
    final runColorVal = prefs?.getInt(_kRunColor);

    final walkColor = walkColorVal != null ? Color(walkColorVal) : Colors.green;
    final jogColor = jogColorVal != null ? Color(jogColorVal) : Colors.amber;
    final runColor = runColorVal != null
        ? Color(runColorVal)
        : Colors.deepOrange;

    final userHeight = prefs?.getDouble(_kUserHeight) ?? 175.0;

    final normalAudio = prefs?.getString(_kNormalAudio) ?? 'claves44_wav.wav';
    final accentedAudio =
        prefs?.getString(_kAccentedAudio) ?? 'woodblock_high44_wav.wav';

    return CadenceState(
      targetCadence: targetCadence,
      movementMode: movementMode,
      walkStride: walkStride,
      jogStride: jogStride,
      runStride: runStride,
      walkColor: walkColor,
      jogColor: jogColor,
      runColor: runColor,
      userHeightCm: userHeight,
      isRunning: false,
      normalAudio: normalAudio,
      accentedAudio: accentedAudio,
    );
  }

  void setMovementMode(MovementMode mode) {
    if (state.movementMode == mode) return;
    state = state.copyWith(movementMode: mode);
    _prefs?.setString(_kMovementMode, mode.name);
    if (!state.isRunning) return;

    final historyState = ref.read(cadenceHistoryProvider);
    final nowEpoch = DateTime.now().millisecondsSinceEpoch / 1000.0;
    final relTime = nowEpoch - historyState.sessionStartTimeSeconds;
    final newStride = mode == MovementMode.walking
        ? state.walkStride
        : mode == MovementMode.jogging
        ? state.jogStride
        : state.runStride;
    final speed = PaceFormulas.cadenceAndStrideToSpeedKmH(
      state.targetCadence.toDouble(),
      newStride,
    );

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
    _prefs?.setInt(_kTargetCadence, clamped);
    if (!state.isRunning) return;

    final historyState = ref.read(cadenceHistoryProvider);
    final nowEpoch = DateTime.now().millisecondsSinceEpoch / 1000.0;
    final relTime = nowEpoch - historyState.sessionStartTimeSeconds;
    final speed = PaceFormulas.cadenceAndStrideToSpeedKmH(
      clamped.toDouble(),
      state.strideLengthMeters,
    );

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

    if (mode == MovementMode.walking) {
      walk = clamped;
      _prefs?.setDouble(_kWalkStride, clamped);
    } else if (mode == MovementMode.jogging) {
      jog = clamped;
      _prefs?.setDouble(_kJogStride, clamped);
    } else if (mode == MovementMode.running) {
      run = clamped;
      _prefs?.setDouble(_kRunStride, clamped);
    }

    state = state.copyWith(walkStride: walk, jogStride: jog, runStride: run);
    if (!state.isRunning) return;

    final activeStride = mode == state.movementMode
        ? clamped
        : state.strideLengthMeters;

    final historyState = ref.read(cadenceHistoryProvider);
    final nowEpoch = DateTime.now().millisecondsSinceEpoch / 1000.0;
    final relTime = nowEpoch - historyState.sessionStartTimeSeconds;
    final speed = PaceFormulas.cadenceAndStrideToSpeedKmH(
      state.targetCadence.toDouble(),
      activeStride,
    );

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
      _prefs?.setInt(_kWalkColor, color.toARGB32());
    } else if (mode == MovementMode.jogging) {
      state = state.copyWith(jogColor: color);
      _prefs?.setInt(_kJogColor, color.toARGB32());
    } else if (mode == MovementMode.running) {
      state = state.copyWith(runColor: color);
      _prefs?.setInt(_kRunColor, color.toARGB32());
    }
  }

  void setAudioSelection(String normal, String accented) {
    state = state.copyWith(normalAudio: normal, accentedAudio: accented);
    _prefs?.setString(_kNormalAudio, normal);
    _prefs?.setString(_kAccentedAudio, accented);
  }

  void setUserHeight(double heightCm) {
    state = state.copyWith(userHeightCm: heightCm);
    _prefs?.setDouble(_kUserHeight, heightCm);
  }

  void prefillStridesFromHeight(double heightCm) {
    final w = double.parse(
      (heightCm * 0.415 / 100).toStringAsFixed(2),
    ).clamp(0.4, 2.5);
    final j = double.parse(
      (heightCm * 0.55 / 100).toStringAsFixed(2),
    ).clamp(0.4, 2.5);
    final r = double.parse(
      (heightCm * 0.65 / 100).toStringAsFixed(2),
    ).clamp(0.4, 2.5);

    state = state.copyWith(
      userHeightCm: heightCm,
      walkStride: w,
      jogStride: j,
      runStride: r,
    );
    _prefs?.setDouble(_kUserHeight, heightCm);
    _prefs?.setDouble(_kWalkStride, w);
    _prefs?.setDouble(_kJogStride, j);
    _prefs?.setDouble(_kRunStride, r);
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
          ref
              .read(cadenceHistoryProvider.notifier)
              .reset(
                nowEpoch,
                state.targetCadence.toDouble(),
                state.strideLengthMeters,
                state.movementMode,
              );
        } else {
          // Resumed within 30 minutes -> keep history intact (gap shown as blank)
        }
      } else {
        ref
            .read(cadenceHistoryProvider.notifier)
            .reset(
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
    final speed = PaceFormulas.cadenceAndStrideToSpeedKmH(
      state.targetCadence.toDouble(),
      state.strideLengthMeters,
    );

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
    ref
        .read(cadenceHistoryProvider.notifier)
        .reset(
          nowEpoch,
          state.targetCadence.toDouble(),
          state.strideLengthMeters,
          state.movementMode,
        );
  }

  void resetHeight() {
    state = state.copyWith(userHeightCm: 175.0);
    _prefs?.setDouble(_kUserHeight, 175.0);
  }

  void resetStridesAndColors() {
    const w = 0.75;
    const j = 1.10;
    const r = 1.30;
    final wc = Colors.green;
    final jc = Colors.amber;
    final rc = Colors.deepOrange;

    state = state.copyWith(
      walkStride: w,
      jogStride: j,
      runStride: r,
      walkColor: wc,
      jogColor: jc,
      runColor: rc,
    );

    _prefs?.setDouble(_kWalkStride, w);
    _prefs?.setDouble(_kJogStride, j);
    _prefs?.setDouble(_kRunStride, r);
    _prefs?.setInt(_kWalkColor, wc.toARGB32());
    _prefs?.setInt(_kJogColor, jc.toARGB32());
    _prefs?.setInt(_kRunColor, rc.toARGB32());
  }

  void resetAudio() {
    const normal = 'claves44_wav.wav';
    const accented = 'woodblock_high44_wav.wav';

    state = state.copyWith(normalAudio: normal, accentedAudio: accented);
    _prefs?.setString(_kNormalAudio, normal);
    _prefs?.setString(_kAccentedAudio, accented);
  }
}

final cadenceProvider = NotifierProvider<CadenceNotifier, CadenceState>(
  CadenceNotifier.new,
);
