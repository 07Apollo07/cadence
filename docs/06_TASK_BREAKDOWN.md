# Task breakdown

Work through in order. Each milestone ends with passing tests and a clean
`flutter analyze` before the next begins — same discipline as the
pose-estimation project. GPS is milestone 5 here, built as part of this same
v1, not deferred to a later release.

## Milestone 0 — project scaffold

- [ ] `flutter create`, Android only — no other platform folders.
- [ ] Add dependencies from `00_OVERVIEW.md`'s tech stack table.
- [ ] Folder structure exactly per `01_ARCHITECTURE.md`.
- [ ] Riverpod `ProviderScope` in `main.dart`.
- [ ] Drift database class + empty table schema per `03_DATA_MODEL_AND_STORAGE.md`.
- [ ] Clean `flutter analyze` on the empty scaffold.

## Milestone 1 — beat scheduler core (no UI, no audio hardware, virtual clock only)

- [ ] `beat_scheduler.dart` with an injectable clock abstraction.
- [ ] `beat_scheduler_test.dart` — the full-session drift test is the gate
      here. Do not proceed until beats stay within tolerance across a
      simulated 30-minute run.
- [ ] `pace_formulas.dart` + tests.
- [ ] `stride_length_calculator.dart` + tests.

## Milestone 2 — data layer

- [ ] Freezed entities: `SessionSummary`, `CadenceSample`, `GpsPoint`,
      `UserCalibration`.
- [ ] `SessionRepository` + `CalibrationRepository`, backed by Drift.
- [ ] `session_aggregator.dart` + tests.
- [ ] In-memory fakes of both repositories for later tests.

## Milestone 3 — calibration + shared cadence target (first vertical slice)

- [ ] `CadenceTargetController` — the single shared target-cadence state.
- [ ] Calibration screen, wired to `CalibrationRepository`.
- [ ] `knurled_wheel.dart` + `wheel_physics.dart` — build and test the wheel
      as a standalone reusable widget here, against the shared target
      controller, before it's needed by either tab. Cover the full
      interaction spec from `04_UI_DESIGN_SPEC.md`: drag, momentum, detent
      snap, haptics, bounds resistance, and the non-gesture accessible
      fallback control.
- [ ] Widget tests per `05_TESTING_STRATEGY.md`.

## Milestone 4 — metronome tab (first full tab)

- [ ] Real `just_audio`-backed click playback wired to `beat_scheduler.dart`.
- [ ] `MetronomeController` state machine (idle/running/paused/ended).
- [ ] `StatCarousel` (5 cards) + `GlassReadout` + `MetronomeToggleButton`
      per the design spec.
- [ ] `media_key_channel.dart` (Dart side) + Android Kotlin handler +
      `MediaTransportRow` widget — build and manually verify this actually
      controls a real backgrounded music app on-device (this is the one
      piece automated tests can't fully cover — flag it explicitly at
      handoff, per `07_MCP_AND_AGENT_WORKFLOW.md`).
- [ ] `metronome_session_flow_test.dart` integration test.
- [ ] Session save/end wiring through the shared `SessionRepository`.

## Milestone 5 — GPS tab

- [ ] `location_service.dart` wrapping `geolocator`, including the Android
      foreground-service setup needed for background-tracking during a run
      (manifest permissions + service declaration).
- [ ] Fake `LocationService` implementation, feeding from
      `synthetic_gps_tracks.dart`, usable as a drop-in swap (mirrors the
      pose-estimation project's fake landmark stream pattern).
- [ ] `gps_point_filter.dart` + `route_aggregator.dart` +
      `actual_cadence_calculator.dart`, with the full unit test suite from
      `05_TESTING_STRATEGY.md` — including the inverse-correctness test
      against `pace_formulas.dart`.
- [ ] `RouteMap` widget (`flutter_map` + OSM tiles + gradient polyline +
      attribution) and `TargetActualPanel`.
- [ ] `GpsController` wiring everything together, sharing
      `CadenceTargetController` with the metronome tab.
- [ ] Handle GPS signal loss and permission-denial states explicitly, per
      the design spec — not silent failures.
- [ ] `gps_session_flow_test.dart` integration test using the fake location
      service.

## Milestone 6 — history

- [ ] `HistoryScreen` with route-thumbnail vs cadence-sparkline
      differentiation by session mode.
- [ ] `SessionDetailScreen`.
- [ ] Empty state + widget tests.

## Milestone 7 — polish and hardening

- [ ] Full accessibility pass per `04_UI_DESIGN_SPEC.md`.
- [ ] Verify: app survives backgrounding mid-GPS-session (tracking
      continues via foreground service), audio focus loss mid-metronome
      (e.g. an incoming call — beat should pause and the app should make
      that state visible, not silently stop with no indication), GPS
      permission revoked mid-session, orientation locked to portrait (an
      explicit decision, not an unhandled rotation crash).
- [ ] Full `flutter test` + `flutter analyze` clean run.
- [ ] Manual on-device pass: real metronome session (listen for drift over a
      real 20+ minute run, not just the simulated test), real outdoor GPS
      session (sanity-check distance/route against a known route), real
      media-control test against an actual backgrounded music app.

## What happens after Milestone 7

Hand back to the human. Flag explicitly: the wheel's pixels-per-step
sensitivity, the GPS filter's accuracy/distance thresholds, and the beat
scheduler's lookahead window are all starting values from the specs — they
will likely need real-world tuning that no amount of synthetic testing can
fully substitute for.
