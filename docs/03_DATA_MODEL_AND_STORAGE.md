# Data model and storage

## Storage choice: Drift (SQLite)

Same rationale as the pose-estimation project — local-first, type-safe,
handles one-to-many relationships (session → many cadence samples, session →
many GPS points) cleanly.

## Tables

### `calibration`

Identical to the pose-estimation project's calibration table — single row,
stride length + method + timestamp. Don't rebuild this differently; the
concept is the same regardless of which app is using it.

### `sessions`

| Column | Type | Notes |
|---|---|---|
| id | int, PK, autoincrement | |
| mode | text | `"metronome"` or `"gps"` — drives which UI/thumbnail history uses |
| startedAt | datetime | |
| endedAt | datetime | |
| durationSeconds | int | from the independent Timer thread |
| targetCadenceSpm | int | the value set via the wheel, always recorded regardless of mode |
| strideLengthMeters | double | snapshot of calibration at session time |
| avgCadenceSpm | double | target cadence average for metronome mode; actual (GPS-derived) average for GPS mode |
| maxCadenceSpm | double | same distinction as above |
| distanceKm | double | calculated-equivalent for metronome mode; real GPS-summed distance for GPS mode |
| avgPaceMinPerKm | double, nullable | |

### `cadence_samples`

Used by **both** modes — for metronome sessions it logs the target cadence
over time (mostly constant unless adjusted mid-run); for GPS sessions it logs
the actual (derived) cadence over time. One table, one meaning per row
(disambiguated by the parent session's `mode`), not two separate tables that
would just duplicate the same shape.

| Column | Type | Notes |
|---|---|---|
| id | int, PK, autoincrement | |
| sessionId | int, FK -> sessions.id | cascade delete |
| offsetMs | int | ms since session start |
| cadenceSpm | double | |
| speedKmh | double | |

### `gps_points`

**GPS-mode sessions only.** Metronome sessions never write rows here.

| Column | Type | Notes |
|---|---|---|
| id | int, PK, autoincrement | |
| sessionId | int, FK -> sessions.id | cascade delete |
| offsetMs | int | ms since session start |
| latitude | double | post-filtering — only accepted points from `GpsPointFilter`, never raw noisy fixes |
| longitude | double | |
| accuracyMeters | double | kept for later debugging/tuning of filter thresholds |

Downsample `cadence_samples` writes to roughly one per 1-2 seconds, same as
the pose-estimation project's guidance — don't persist every scheduler tick
or every raw GPS fix. `gps_points` naturally downsamples itself, since the
`GpsPointFilter` already discards sub-threshold movements.

**No raw/unfiltered GPS data or audio buffers are ever persisted** — same
privacy commitment as the pose-estimation project, write it as a comment in
`location_service.dart` and `gps_point_filter.dart`.

## Entities (domain layer, freezed)

```dart
enum SessionMode { metronome, gps }

@freezed
class SessionSummary with _$SessionSummary {
  const factory SessionSummary({
    required int? id,
    required SessionMode mode,
    required DateTime startedAt,
    DateTime? endedAt,
    required Duration duration,
    required int targetCadenceSpm,
    required double strideLengthMeters,
    required double avgCadenceSpm,
    required double maxCadenceSpm,
    required double distanceKm,
    double? avgPaceMinPerKm,
  }) = _SessionSummary;
}

@freezed
class CadenceSample with _$CadenceSample {
  const factory CadenceSample({
    required Duration offset,
    required double cadenceSpm,
    required double speedKmh,
  }) = _CadenceSample;
}

@freezed
class GpsPoint with _$GpsPoint {
  const factory GpsPoint({
    required Duration offset,
    required double latitude,
    required double longitude,
    required double accuracyMeters,
  }) = _GpsPoint;
}

@freezed
class UserCalibration with _$UserCalibration {
  const factory UserCalibration({
    required double strideLengthMeters,
    required CalibrationMethod method,
    required DateTime calibratedAt,
  }) = _UserCalibration;
}

enum CalibrationMethod { measured, estimatedFromHeight }
```

## Repository contracts

```dart
abstract class SessionRepository {
  Future<void> saveSession(
    SessionSummary summary,
    List<CadenceSample> cadenceSamples,
    List<GpsPoint> gpsPoints, // empty list for metronome-mode sessions
  );
  Future<List<SessionSummary>> getAllSessions();
  Future<SessionSummary?> getSession(int id);
  Future<List<CadenceSample>> getCadenceSamplesForSession(int id);
  Future<List<GpsPoint>> getGpsPointsForSession(int id);
  Future<void> deleteSession(int id);
}

abstract class CalibrationRepository {
  Future<void> saveCalibration(UserCalibration calibration);
  Future<UserCalibration?> getCalibration();
}
```

One `SessionRepository`, used by both `metronome` and `gps_tracking`
features — not two separate repositories. This is the same DRY tripwire
called out in the pose-estimation project's architecture doc: if the agent's
codegen produces two, that's a bug to fix.

Provide in-memory fake implementations of both interfaces for widget and
integration tests, same pattern as before.
