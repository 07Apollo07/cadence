# Project: Cadence — metronome + GPS run tracker

## What this app does

A single-user, Android app with two ways of working with running cadence,
built around one shared formula layer:

1. **Metronome tab** — you set a target cadence with a physical-feeling scroll
   wheel, the app clicks a beat at that rate, you match your steps to it.
   Speed/pace/distance are calculated *forward* from the target cadence.
2. **GPS tab** — you set the same target cadence, but this time the app
   records your real route via GPS while you run outdoors, and derives your
   *actual* cadence backward from your real measured speed. You see target vs
   actual side by side.

Both tabs share one running clock (elapsed time, independent of everything
else) and one History screen listing past sessions from either mode.

**Explicitly not building**: a phone-accelerometer pedometer. Cadence is
either a value you set (metronome) or a value derived from real GPS speed
(GPS mode) — never estimated from shaking the phone in your pocket. That path
was considered and rejected as unreliable and redundant with the other two.

## Hard constraints

- **Android only.** No iOS/web/desktop targets or platform folders.
- **No paid APIs required.** Map tiles via OpenStreetMap (free, attribution
  required, no API key). GPS via the device's own hardware through
  `geolocator` (free, no key). Do not introduce Google Maps or Mapbox — they
  require billing setup this project doesn't need.
- **Local-first storage.** All sessions, routes, and calibration data live in
  a local SQLite DB via Drift. No accounts, no cloud sync, no analytics.
- **"Universal" media controls** — the media transport row (separate from the
  metronome beat) must control *whatever* app currently holds Android's audio
  focus (Spotify, YouTube Music, a podcast app, anything), not be tied to one
  music service's SDK. See `02_AUDIO_AND_GPS_SPEC.md` for how.
- **This is a real technical project, not a form-and-list app.** Two pieces
  deserve real engineering attention, not shortcuts:
  - The metronome's beat scheduler must be tight and drift-free — a metronome
    that slowly drifts off-tempo over a 30-minute run defeats its purpose.
  - GPS jitter filtering must be real, not skipped — raw GPS wanders even
    standing still, and naive distance summing will happily report you ran
    further than you did.

## Core user flow

1. **Calibrate once**: same as before — stride length, measured or estimated
   from height.
2. **Metronome tab**: scroll either wheel to set target cadence (both wheels
   always move together, driving one shared value). Swipe the central
   carousel between Cadence / Speed / Pace / Distance / Time — the wheels
   always adjust cadence regardless of which card is showing; the other cards
   are just that formula layer evaluated live. Tap the metronome button to
   start/stop the beat. Independently, the media row controls whatever's
   playing in the background.
3. **GPS tab**: same wheels set a target cadence. Start a session, go run
   outside. The map draws your route live, colored along a calm-to-hot
   gradient by effort. Below the map: Target cadence vs Actual cadence (from
   GPS), with a delta indicator, plus pace/distance/elapsed from real GPS
   data.
4. **End session**: saved to history, tagged by mode (indoor/metronome vs
   GPS).
5. **History**: session list — GPS sessions show a small route thumbnail,
   metronome sessions show a small cadence sparkline instead.

## Tech stack

| Concern | Choice | Why |
|---|---|---|
| State management | `flutter_riverpod` | Same rationale as before — testable, no BuildContext coupling |
| Immutable models | `freezed` + `json_serializable` | DRY value objects |
| Local storage | `drift` (SQLite) | Handles session → many-samples / many-GPS-points cleanly |
| Metronome audio | `just_audio` | Low-latency looping/seek playback, needed for the look-ahead scheduler in `02_AUDIO_AND_GPS_SPEC.md` |
| Universal media control | Custom `MethodChannel` to Android's `AudioManager.dispatchMediaKeyEvent` | The same mechanism wired headphone buttons use to control whatever app holds audio focus — no vendor SDK, no Spotify-specific integration |
| GPS | `geolocator` | Free, no API key, direct device GPS access |
| Map | `flutter_map` + OpenStreetMap raster tiles | Free, no API key, attribution required (a small credit line, same as most fitness apps show) |
| Distance/geo math | `latlong2` | Pairs with flutter_map, has haversine distance built in |
| Wheel physics | `package:flutter/physics.dart` (`SpringSimulation`, `FrictionSimulation`) | Built into Flutter, no extra dependency — gives the wheel real momentum/overshoot |
| Testing | `flutter_test`, `mocktail`, `integration_test` | Standard |

Resolve current stable versions at implementation time rather than pinning
versions written here.

## What "done" looks like for v1 (both milestones included)

- Calibration screen works and persists stride length.
- Metronome tab: wheels drive target cadence with real weighted/3D scroll
  feel and haptic detents; carousel swipes between five derived stat cards;
  metronome beat is audibly steady over a full 30+ minute session (see drift
  tolerance in `05_TESTING_STRATEGY.md`); media row independently controls
  background audio via the platform channel.
- GPS tab (2nd milestone, built in this same v1 — not deferred to a future
  release): live map with route drawn, GPS jitter filtered, target-vs-actual
  cadence comparison, pace/distance/elapsed all correct.
- Sessions from both modes save and appear correctly in History, visually
  distinguished by mode.
- Unit tests pass for the full formula layer (both directions), the beat
  scheduler's timing accuracy, and the GPS filtering logic.
- `flutter analyze` clean.
- Graceful handling of: microphone/location permission denial, GPS signal
  loss mid-session, backgrounding during a GPS session (must keep recording
  via foreground service), audio focus loss (e.g. a phone call interrupts the
  metronome beat).

## Read these next, in order

1. `01_ARCHITECTURE.md` — folder structure, layers, module boundaries
2. `02_AUDIO_AND_GPS_SPEC.md` — the two real technical cores: the metronome
   beat scheduler, and GPS filtering + the bidirectional cadence formula
3. `03_DATA_MODEL_AND_STORAGE.md` — entities, schema, repositories
4. `04_UI_DESIGN_SPEC.md` — design tokens, the three screens, wheel/carousel
   interaction spec
5. `05_TESTING_STRATEGY.md` — what to test and how
6. `06_TASK_BREAKDOWN.md` — ordered implementation milestones
7. `07_MCP_AND_AGENT_WORKFLOW.md` — using the Dart/Flutter MCP server to
   build, run, and self-debug this
