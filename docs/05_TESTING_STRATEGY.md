# Testing strategy

Same philosophy as the pose-estimation project: this is a vibe-coded handoff,
tests are what let the agent (and you) trust the two real engineering pieces
— beat timing and GPS filtering — without a human manually running a
30-minute session or going outside to check every change.

## Unit tests — priority order

### `beat_scheduler_test.dart`

This is the most important test file in the project — a drifting metronome
defeats the entire point of the app.

- Drive the scheduler with a **fake/virtual clock** (inject a clock
  abstraction rather than depending on real wall-clock time, so the test
  runs instantly rather than actually waiting 30 minutes) advancing in fixed
  increments, simulating a session at a fixed cadence (e.g. 170 spm) for a
  simulated 30 minutes.
- Collect every scheduled beat timestamp. Assert each one falls within a
  tight tolerance (e.g. ±5ms) of the ideal `startTime + n × intervalMs`
  sequence, for every `n` across the whole simulated session — not just the
  first few beats. This is what specifically catches cumulative drift, which
  a test that only checks the first 10 beats would miss entirely.
- Test a mid-session cadence change: assert the interval changes immediately
  but the *phase* of the next beat isn't reset (per the spec in
  `02_AUDIO_AND_GPS_SPEC.md` — no stutter on tempo change).
- Test start/stop/restart doesn't leave stale scheduled beats firing after
  stop.

### `pace_formulas_test.dart`

Exact-value tests for the forward direction, same as the pose-estimation
project's formula tests — hardcode expected values computed by hand, don't
just re-implement the formula in the test.

### `actual_cadence_calculator_test.dart`

- Exact-value tests for the reverse formula.
- **Inverse-correctness test**: for a range of cadence values and stride
  lengths, assert `actualCadenceSpm(speedKmh(cadence, stride), stride)`
  returns the original `cadence` (within floating-point tolerance). This is
  the test that specifically catches a reverse formula that was
  independently (and incorrectly) derived rather than solved from the
  forward one.

### `gps_point_filter_test.dart`

Use `fixtures/synthetic_gps_tracks.dart` (build this first, analogous to the
pose-estimation project's synthetic signal fixture) to generate known
lat/lng sequences with controllable injected jitter:

- A stationary point held for many "readings" with small random jitter
  (simulating standing still) → assert filtered output shows near-zero
  accumulated distance, not the sum of every jittery micro-movement.
- A sequence of points with low reported accuracy (worse than the threshold)
  → assert those points are discarded, not accepted.
- A clean sequence of points representing real movement at a known pace →
  assert they're all accepted and the resulting distance matches the known
  ground-truth distance within a small tolerance.

### `route_aggregator_test.dart`

- Given a list of filtered `GpsPoint`s with known coordinates and timestamps,
  assert cumulative distance and current speed calculations are correct
  (verify against hand-computed haversine distances for a couple of test
  cases).

### `stride_length_calculator_test.dart` / `session_aggregator_test.dart`

Same as the pose-estimation project's equivalents — reuse that test
structure, the logic is identical.

## Widget tests

- `knurled_wheel_test.dart`: simulate a drag gesture, assert the bound
  cadence value changes by the expected amount; assert a fast flick triggers
  continued momentum change after release (don't need to assert exact
  physics values, just that motion continues past pointer-up); assert bounds
  clamping at min/max cadence.
- `stat_carousel_test.dart`: swiping changes the displayed card; the
  underlying cadence value is unaffected by which card is showing.
- `target_actual_panel_test.dart`: renders correct delta direction/value
  given target and actual inputs; renders the "searching…" state when GPS
  accuracy is degraded.
- `empty_state_test.dart`: same pattern as before.

## Integration tests

- `metronome_session_flow_test.dart`: calibrate → set target cadence via
  simulated wheel input → start metronome → (verify beat scheduler is
  running via its exposed state, not by listening for actual audio) → end →
  assert session saved correctly with `mode: metronome`.
- `gps_session_flow_test.dart`: inject a **fake** `LocationService` (feeding
  from `synthetic_gps_tracks.dart`) in place of real `geolocator` calls,
  same pattern as the pose-estimation project's fake landmark stream. Drive
  a full flow and assert a session saves correctly with `mode: gps`, correct
  route points, and correct target-vs-actual numbers.
- `app_test.dart`: boot smoke test.

## What NOT to spend test effort on

- Don't try to assert exact audio latency or record actual sound output —
  test the scheduler's *timing logic* against a virtual clock, not real
  audio hardware behavior.
- Don't unit test `geolocator`, `flutter_map`, or `just_audio` themselves —
  test your code's boundary with them.
- Don't write pixel-exact assertions for the wheel's visual ridge rendering
  — test the interaction/value logic, not the CSS-equivalent styling.

## Definition of done, testing-wise

- `flutter test` passes fully, including the beat scheduler's full-session
  drift test and the GPS filter's synthetic-jitter tests.
- `flutter analyze` clean.
- Both integration_test flows (metronome and GPS) pass using their fake
  service implementations.
