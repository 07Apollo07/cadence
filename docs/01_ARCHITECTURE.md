# Architecture

## Principles

Same as the pose-estimation project's architecture principles — feature-first,
layered within each feature, domain logic free of Flutter imports, Riverpod
as the only presentation-to-domain bridge, no God classes. Repeated here
briefly; don't relax them because this is "just a metronome":

- Domain logic (beat scheduling math, GPS filtering, cadence formulas) is
  plain Dart, unit-testable without a widget tree, an audio engine, or a GPS
  fix.
- One repository per data concern, never duplicated across features.
- Each class describable in one sentence.

## Folder structure

```
lib/
  main.dart
  app.dart

  core/
    theme/
      app_colors.dart              # instrument-panel dark palette (see 04)
      app_typography.dart
      app_theme.dart
    constants/
      cadence_constants.dart        # e.g. MIN_CADENCE_SPM, MAX_CADENCE_SPM
      audio_constants.dart          # scheduler look-ahead window, tick sound asset
      gps_constants.dart            # accuracy threshold, min-distance filter
    errors/
      app_exceptions.dart
    utils/
      result.dart

  features/
    calibration/
      data/
        calibration_repository.dart
      domain/
        stride_length_calculator.dart
        user_calibration.dart
      presentation/
        calibration_screen.dart
        calibration_controller.dart

    cadence_wheel/
      domain/
        cadence_target_controller.dart   # the ONE shared target-cadence value;
                                          # both wheels and both tabs read/write
                                          # this single source of truth
      presentation/
        widgets/
          knurled_wheel.dart             # the reusable 3D scroll wheel widget
          wheel_physics.dart             # spring/friction simulation for momentum

    metronome/
      domain/
        beat_scheduler.dart              # THE core technical piece — see 02
        pace_formulas.dart                # shared with gps_tracking, see note below
      data/
        (uses live_session's shared session repository)
      presentation/
        metronome_screen.dart
        metronome_controller.dart
        widgets/
          stat_carousel.dart              # swipeable Cadence/Speed/Pace/Distance/Time
          glass_readout.dart              # the inset-panel big number widget
          metronome_toggle_button.dart    # the domed beat start/stop button

    gps_tracking/
      domain/
        gps_point_filter.dart             # accuracy + min-distance jitter filter
        route_aggregator.dart             # rolls filtered points into distance/speed
        actual_cadence_calculator.dart    # speed -> cadence, the REVERSE of pace_formulas
      data/
        location_service.dart             # wraps geolocator, foreground service handling
      presentation/
        gps_screen.dart
        gps_controller.dart
        widgets/
          route_map.dart                  # flutter_map wrapper, route polyline w/ gradient
          target_actual_panel.dart        # the two-stat comparison + delta indicator

    media_control/
      data/
        media_key_channel.dart            # MethodChannel to Android AudioManager
      presentation/
        widgets/
          media_transport_row.dart        # skip-back/play/skip-forward, calls media_key_channel

    session/
      domain/
        session_entity.dart               # freezed: SessionSummary (mode: metronome|gps)
        session_aggregator.dart
      data/
        session_repository.dart           # ONE repository, both tabs write through it

    history/
      presentation/
        history_screen.dart
        session_detail_screen.dart
        history_controller.dart
      (reuses session/data/session_repository.dart and session/domain entities
       — do not redefine them here)

  shared/
    database/
      app_database.dart
      tables/
        sessions_table.dart
        cadence_samples_table.dart
        gps_points_table.dart
        calibration_table.dart
    widgets/
      app_scaffold.dart
      segmented_tab_switcher.dart          # the Metronome/GPS pill switcher, shared chrome
      loading_indicator.dart
      empty_state.dart

test/
  unit/
    metronome/
      beat_scheduler_test.dart
      pace_formulas_test.dart
    gps_tracking/
      gps_point_filter_test.dart
      route_aggregator_test.dart
      actual_cadence_calculator_test.dart
    calibration/
      stride_length_calculator_test.dart
    session/
      session_aggregator_test.dart
  widget/
    knurled_wheel_test.dart
    stat_carousel_test.dart
    target_actual_panel_test.dart
    empty_state_test.dart
  fixtures/
    synthetic_gps_tracks.dart              # generates known lat/lng sequences with
                                            # controllable jitter, for filter tests

integration_test/
  metronome_session_flow_test.dart
  gps_session_flow_test.dart               # uses a fake LocationService, see 07
  app_test.dart
```

**Why `pace_formulas.dart` sits under `metronome/domain/` but is described as
shared**: it's written once, imported by both `metronome` and `gps_tracking`
(the GPS feature calls the *inverse* of the same formulas — see
`02_AUDIO_AND_GPS_SPEC.md`). If it turns out cleaner during implementation,
it's fine to promote it to `shared/` instead — the constraint that matters is
**one implementation**, not its exact folder.

## Data flow — metronome tab

```
KnurledWheel (drag gesture + spring physics)
  -> CadenceTargetController (single source of truth for target cadence)
  -> BeatScheduler (look-ahead audio scheduling at that cadence)
  -> PaceFormulas (target cadence -> speed/pace/distance, forward direction)
  -> MetronomeController (Riverpod state: all 5 carousel values + beat on/off)
  -> MetronomeScreen + StatCarousel + GlassReadout (UI)
  -> on "end session": SessionAggregator -> SessionRepository.save()
```

## Data flow — GPS tab

```
KnurledWheel -> CadenceTargetController (SAME shared target as metronome tab)

LocationService (raw GPS positions)
  -> GpsPointFilter (accuracy + min-distance filtering)
  -> RouteAggregator (filtered points -> cumulative distance, current speed)
  -> ActualCadenceCalculator (measured speed -> actual cadence, INVERSE of
     pace_formulas' speed formula, using the same calibrated stride length)
  -> GpsController (Riverpod state: target cadence, actual cadence, distance,
     pace, elapsed, route points for the map)
  -> GpsScreen + RouteMap + TargetActualPanel (UI)
  -> on "end session": SessionAggregator -> SessionRepository.save()
```

Note that `CadenceTargetController` is genuinely shared, not duplicated —
setting the target on one tab and switching to the other must show the same
target value. This is the one piece of state that spans both tabs; everything
else (beat scheduler, GPS filtering) is tab-local.

## State management pattern

Same sealed-state-machine approach as the pose-estimation project:
`idle -> running -> paused -> ended` per session, modeled as a freezed union,
not scattered booleans. `CadenceTargetController` is a simple shared
`StateNotifier<int>` (spm), read by both tab controllers via `ref.watch`.
