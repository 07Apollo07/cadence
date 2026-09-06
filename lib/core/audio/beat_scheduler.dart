import 'package:flutter/foundation.dart';
import 'package:metronome/metronome.dart';

class BeatScheduler {
  final _metronomePlugin = Metronome();
  int _targetCadence = 180;

  final ValueNotifier<int> beatCountNotifier = ValueNotifier<int>(0);
  final ValueNotifier<bool> isRunningNotifier = ValueNotifier<bool>(false);

  int get beatCount => beatCountNotifier.value;
  bool get isRunning => isRunningNotifier.value;
  int get targetCadence => _targetCadence;

  String? _currentNormalPath;
  String? _currentAccentedPath;

  BeatScheduler({
    String normalPath = 'assets/audio/base44_wav.wav',
    String accentedPath = 'assets/audio/claves44_wav.wav',
  }) {
    _currentNormalPath = normalPath;
    _currentAccentedPath = accentedPath;
    _metronomePlugin.init(
      normalPath,
      accentedPath: accentedPath,
      bpm: _targetCadence,
      volume: 50,
      enableTickCallback: true,
      timeSignature: 4,
    );
    _metronomePlugin.tickStream.listen((int tick) {
      beatCountNotifier.value = tick;
    });
  }

  void dispose() {
    stop();
    _metronomePlugin.destroy();
    beatCountNotifier.dispose();
    isRunningNotifier.dispose();
  }

  void setCadence(int cadence) {
    _targetCadence = cadence.clamp(60, 240);
    if (isRunningNotifier.value) {
      _metronomePlugin.setBPM(_targetCadence);
    }
  }

  void start() {
    if (isRunningNotifier.value) return;
    isRunningNotifier.value = true;
    beatCountNotifier.value = 0;
    _metronomePlugin.play();
  }

  void stop() {
    isRunningNotifier.value = false;
    _metronomePlugin.stop();
  }

  void setAudioFiles(String normalPath, String accentedPath) {
    if (_currentNormalPath == normalPath && _currentAccentedPath == accentedPath) {
      return;
    }
    _currentNormalPath = normalPath;
    _currentAccentedPath = accentedPath;

    _metronomePlugin.setAudioFile(
      mainPath: normalPath,
      accentedPath: accentedPath,
    );
  }
}
