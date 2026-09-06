import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/audio/beat_scheduler.dart';
import '../../core/providers/cadence_provider.dart';

final beatSchedulerProvider = Provider<BeatScheduler>((ref) {
  final scheduler = BeatScheduler();
  
  // Initialize with initial audio files from cadenceProvider
  final cadenceState = ref.read(cadenceProvider);
  scheduler.setAudioFiles(
    'assets/audio/${cadenceState.normalAudio}',
    'assets/audio/${cadenceState.accentedAudio}',
  );

  scheduler.beatCountNotifier.addListener(() {
    if (scheduler.isRunning) {
      ref.read(cadenceProvider.notifier).addTickPoint();
    }
  });

  ref.onDispose(() {
    scheduler.dispose();
  });

  return scheduler;
});
