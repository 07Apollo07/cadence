import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:metronome/metronome.dart';
import '../services/notification_service.dart';

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
      NotificationService().updateMetronomeNotification(
        isRunning: true,
        cadence: _targetCadence,
      );
    }
  }

  Future<void> start() async {
    if (isRunningNotifier.value) return;
    isRunningNotifier.value = true;
    beatCountNotifier.value = 0;
    _metronomePlugin.play();
    NotificationService().updateMetronomeNotification(
      isRunning: true,
      cadence: _targetCadence,
    );

    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
      await session.setActive(true);
    } catch (e) {
      debugPrint('AudioSession configuration failed: $e');
    }
  }

  Future<void> stop() async {
    isRunningNotifier.value = false;
    _metronomePlugin.stop();
    NotificationService().updateMetronomeNotification(
      isRunning: false,
      cadence: _targetCadence,
    );
    try {
      final session = await AudioSession.instance;
      await session.setActive(false);
    } catch (e) {
      debugPrint('AudioSession deactivate failed: $e');
    }
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
