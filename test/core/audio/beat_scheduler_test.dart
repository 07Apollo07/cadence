import 'package:flutter_test/flutter_test.dart';
import 'package:cadence/core/audio/beat_scheduler.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BeatScheduler Tests', () {
    test('initial state is stopped with default cadence 180', () {
      final scheduler = BeatScheduler(initAudio: false);
      expect(scheduler.isRunning, false);
      expect(scheduler.targetCadence, 180);
      expect(scheduler.beatCount, 0);
    });

    test('start and stop updates isRunning state', () {
      final scheduler = BeatScheduler(initAudio: false);
      scheduler.start();
      expect(scheduler.isRunning, true);
      scheduler.stop();
      expect(scheduler.isRunning, false);
    });

    test('setCadence clamps values between 60 and 240', () {
      final scheduler = BeatScheduler(initAudio: false);
      scheduler.setCadence(40);
      expect(scheduler.targetCadence, 60);

      scheduler.setCadence(300);
      expect(scheduler.targetCadence, 240);

      scheduler.setCadence(175);
      expect(scheduler.targetCadence, 175);
    });
  });
}
