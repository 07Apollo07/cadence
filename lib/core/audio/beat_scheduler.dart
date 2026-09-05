import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class BeatScheduler {
  Timer? _timer;
  int _targetCadence = 180; // steps per minute
  bool _isRunning = false;
  int _beatCount = 0;
  
  final AudioPlayer _audioPlayer;
  bool _isAudioInitialized = false;

  VoidCallback? onBeat;

  bool get isRunning => _isRunning;
  int get targetCadence => _targetCadence;
  int get beatCount => _beatCount;

  BeatScheduler({AudioPlayer? audioPlayer, bool initAudio = true}) : _audioPlayer = audioPlayer ?? AudioPlayer() {
    if (audioPlayer == null && initAudio) {
      _initAudio();
    }
  }

  Future<void> _initAudio() async {
    try {
      if (!kIsWeb) {
        await _audioPlayer.setAsset('assets/audio/click_normal.mp3');
        _isAudioInitialized = true;
      }
    } catch (e) {
      debugPrint('Error loading click asset: $e');
      _isAudioInitialized = false;
    }
  }

  void setCadence(int cadence) {
    _targetCadence = cadence.clamp(60, 240);
    if (_isRunning) {
      _restartTimer();
    }
  }

  void start() {
    if (_isRunning) return;
    _isRunning = true;
    _beatCount = 0;
    _restartTimer();
  }

  void stop() {
    _isRunning = false;
    _timer?.cancel();
    _timer = null;
    _audioPlayer.stop();
  }

  void _restartTimer() {
    _timer?.cancel();
    if (!_isRunning || _targetCadence <= 0) return;

    final int intervalMs = (60000 / _targetCadence).round();
    
    _timer = Timer.periodic(Duration(milliseconds: intervalMs), (timer) {
      _beatCount++;
      _playClick();
      onBeat?.call();
    });
  }

  Future<void> _playClick() async {
    if (_isAudioInitialized) {
      try {
        await _audioPlayer.seek(Duration.zero);
        await _audioPlayer.play();
      } catch (e) {
        // Fallback or handle playback error silently
      }
    }
  }

  void dispose() {
    stop();
    try {
      _audioPlayer.dispose();
    } catch (_) {}
  }
}
