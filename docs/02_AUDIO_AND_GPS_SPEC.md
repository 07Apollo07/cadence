# Audio and GPS spec

This is the core technical piece of the app — two independent problems, each
genuinely worth doing properly: keeping a beat perfectly steady over a long
session, and turning noisy real-world GPS into a trustworthy cadence number.

## Part 1 — the metronome beat scheduler

### Why this is harder than "play a sound every N milliseconds"

A naive implementation uses `Timer.periodic(Duration(milliseconds: interval),
playClick)`. This drifts. Dart's event loop isn't real-time — garbage
collection pauses, frame rendering, and other work on the same isolate delay
timer callbacks unpredictably. Over a 30-minute run at 170 spm (352ms between
clicks), even a few milliseconds of average drift per tick accumulates into
audibly wrong timing well before the session ends. This is the same category
of problem professional audio software solves with **look-ahead scheduling**
— schedule sounds slightly ahead of when they're needed, using precise time
math rather than trusting the timer's callback to fire exactly on time.

### The algorithm (`beat_scheduler.dart`)

```
state: nextBeatTimeMs (absolute, based on a monotonic clock — NOT wall clock),
       intervalMs (60000 / targetCadenceSpm),
       isRunning

# A fast, cheap "scheduler tick" runs frequently (every ~25ms) via a plain
# Timer.periodic — its ONLY job is to check whether it's time to queue the
# NEXT beat, not to play the beat itself late.

on scheduler tick (currentTimeMs):
    if not isRunning: return
    LOOKAHEAD_MS = 100  # how far ahead we're willing to pre-schedule
    while nextBeatTimeMs < currentTimeMs + LOOKAHEAD_MS:
        scheduleClickAt(nextBeatTimeMs)   # see audio playback note below
        nextBeatTimeMs += intervalMs

on target cadence changed (while running):
    intervalMs = 60000 / newCadenceSpm
    # do NOT reset nextBeatTimeMs — let the next beat land wherever it was
    # already scheduled, then apply the new interval from there. Snapping
    # immediately to a new phase makes cadence changes feel like a stutter
    # instead of a smooth tempo change.
```

**Audio playback mechanism**: `just_audio` doesn't give sample-accurate
future scheduling the way native platform audio APIs do, so the practical
approach is: pre-load the click sound once, and on each `scheduleClickAt`
call within the lookahead window, play it immediately (since the lookahead
window is short, 100ms, the remaining Dart-side timing error is small enough
to be inaudible) — the key win over the naive approach is that `nextBeatTimeMs`
is computed from **accumulated interval math on a monotonic clock**, never by
re-deriving from "now" on every tick, which is what actually prevents drift.
If testing on real hardware shows this still isn't tight enough, the fallback
is a native `AudioTrack`-based scheduler via platform channel — note this as
a fallback plan in the handoff, not something to build speculatively upfront.

**Use a monotonic clock**, not `DateTime.now()`, for all interval math —
`Stopwatch` in Dart gives monotonic elapsed time immune to wall-clock
adjustments (NTP sync, timezone changes) that would otherwise cause a sudden
jump in the schedule.

### Testing this (see `05_TESTING_STRATEGY.md` for details)

Run the scheduler against a fake/virtual clock for a simulated multi-minute
session and assert the actual beat times stay within a tight tolerance (e.g.
±5ms) of the ideal `n × intervalMs` sequence — this is what proves "no drift"
without needing a human to listen to 30 minutes of clicks.

## Part 2 — universal media control (not tied to Spotify)

Android's headphone remote buttons work by dispatching `KEYCODE_MEDIA_PLAY_
PAUSE`, `KEYCODE_MEDIA_NEXT`, `KEYCODE_MEDIA_PREVIOUS` media key events, which
the OS routes to whichever app currently holds audio focus — Spotify,
YouTube Music, a podcast app, anything. This app's media transport row should
do exactly the same thing, which means it needs a small native bridge:

- **`MethodChannel`** (`media_key_channel.dart` on the Dart side, a matching
  Kotlin handler on the Android side) that calls
  `AudioManager.dispatchMediaKeyEvent()` with the appropriate `KeyEvent` for
  play/pause, next, and previous.
- This requires **no permissions beyond what a normal app has** — it's the
  same mechanism a Bluetooth headset uses, just triggered from an in-app
  button instead of a physical one.
- **Do not** attempt a Spotify Web API / App Remote SDK integration — that
  would tie the button to one specific service, which is explicitly what
  "universal" means to avoid here.

## Part 3 — GPS jitter filtering (`gps_point_filter.dart`)

Raw GPS positions wander even when stationary — typically several meters of
noise depending on device and environment (indoors near windows, urban
canyons between buildings, etc. — worse). Feed every raw fix straight into
distance accumulation and the app will report you moved when you didn't.

```
state: lastAcceptedPosition (nullable)

for each new raw GPS position (lat, lng, accuracyMeters, timestamp, speed):
    if accuracyMeters > MAX_ACCEPTABLE_ACCURACY_M:   # start at 20
        discard  # GPS fix too imprecise to trust
        continue
    if lastAcceptedPosition is null:
        accept as first point
        continue
    distanceFromLast = haversineDistance(lastAcceptedPosition, newPosition)
    if distanceFromLast < MIN_DISTANCE_FILTER_M:      # start at 2
        discard  # sub-threshold movement is noise, not real motion
        continue
    accept newPosition
    lastAcceptedPosition = newPosition
```

Both thresholds are named constants in `gps_constants.dart`, not magic
numbers inline — they will likely need tuning against real recorded runs
(urban vs open areas behave differently), same caveat as the earlier
project's smoothing/prominence constants.

**Speed**: prefer the GPS chip's own reported `position.speed` (Doppler-
derived, generally more accurate than differencing two noisy points) over
manually computing `distance / time` between filtered points, when available
and the position's `speedAccuracy` is reasonable. Fall back to distance-over-
time only if speed isn't reported.

## Part 4 — the bidirectional cadence formula

This is the conceptual core of why the GPS tab isn't a separate feature with
separate math — it's the *same* relationship as the metronome tab, solved in
the opposite direction, using the *same* calibrated stride length.

**Metronome tab (forward direction — cadence is the known input):**

```dart
double speedKmh(double cadenceSpm, double strideLengthM) =>
    (cadenceSpm * strideLengthM * 60) / 1000;
```

**GPS tab (reverse direction — speed is the known input, cadence is derived):**

```dart
double actualCadenceSpm(double speedKmh, double strideLengthM) =>
    (speedKmh * 1000) / (60 * strideLengthM);
```

These two functions are algebraic inverses of each other — implement
`actual_cadence_calculator.dart`'s function by literally solving the forward
formula for cadence, don't derive it independently, and unit test that
`actualCadenceSpm(speedKmh(x, s), s) == x` for a range of values (see
`05_TESTING_STRATEGY.md`) as a correctness check that the two really are
inverses.

**Target vs actual delta**: simply `actualCadenceSpm - targetCadenceSpm`,
displayed with a direction indicator (above/below target) in
`target_actual_panel.dart`. No new math needed beyond the two formulas above.

**Pace and distance in GPS mode** come directly from the filtered GPS data
(`RouteAggregator`), not from the cadence formulas at all — GPS-measured
distance is ground truth here, unlike the metronome tab where distance is
necessarily an estimate. Don't accidentally compute GPS-mode distance via the
cadence-based formula; that would be strictly worse than the real GPS data
already available.
