import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/audio/beat_scheduler.dart';
import '../../core/providers/cadence_provider.dart';

final beatSchedulerProvider = Provider<BeatScheduler>((ref) {
  // Initialize with initial audio files from cadenceProvider
  final cadenceState = ref.read(cadenceProvider);
  final scheduler = BeatScheduler(
    normalPath: 'assets/audio/${cadenceState.normalAudio}',
    accentedPath: 'assets/audio/${cadenceState.accentedAudio}',
  );

  // Reactively listen for audio selection changes in settings and hot-swap audio instantly
  ref.listen<(String, String)>(
    cadenceProvider.select((s) => (s.normalAudio, s.accentedAudio)),
    (previous, next) {
      if (previous != next) {
        scheduler.setAudioFiles(
          'assets/audio/${next.$1}',
          'assets/audio/${next.$2}',
        );
      }
    },
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
