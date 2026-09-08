import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/app_database.dart';
import '../../../core/storage/database_connection.dart';
import '../models/gps_track_point.dart';
import '../models/km_split.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = constructDb();
  ref.onDispose(() => db.close());
  return db;
});

final gpsSessionRepositoryProvider = Provider<GpsSessionRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return GpsSessionRepository(db);
});

final allGpsSessionsProvider = StreamProvider<List<WorkoutSession>>((ref) {
  final repo = ref.watch(gpsSessionRepositoryProvider);
  return repo.watchAllGpsSessions();
});

class GpsSessionRepository {
  final AppDatabase _db;

  GpsSessionRepository(this._db);

  Stream<List<WorkoutSession>> watchAllGpsSessions() {
    return (_db.select(_db.workoutSessions)
          ..where((tbl) => tbl.mode.equals('gps'))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.startTime)]))
        .watch();
  }

  Future<WorkoutSession?> getSessionById(int id) async {
    return (_db.select(_db.workoutSessions)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  /// Gets the most recent GPS session completed within [duration] (e.g. 24 hours).
  Future<WorkoutSession?> getRecentSessionWithin(Duration duration) async {
    final cutoff = DateTime.now().subtract(duration);
    return (_db.select(_db.workoutSessions)
          ..where((tbl) => tbl.mode.equals('gps') & tbl.startTime.isBiggerOrEqualValue(cutoff))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.startTime)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<int> insertGpsSession({
    required DateTime startTime,
    DateTime? endTime,
    required double targetCadence,
    required double avgCadence,
    required double maxCadence,
    required double distanceKm,
    required int durationSeconds,
    required int movingDurationSeconds,
    required int pauseDurationSeconds,
    double? avgPaceMinPerKm,
    double? bestPaceMinPerKm,
    required int estimatedCalories,
    required int estimatedSteps,
    required List<GpsTrackPoint> points,
    required List<KmSplit> splits,
  }) async {
    final pointsJson = jsonEncode(points.map((p) => p.toJson()).toList());
    final splitsJson = jsonEncode(splits.map((s) => s.toJson()).toList());

    return _db.into(_db.workoutSessions).insert(
      WorkoutSessionsCompanion.insert(
        startTime: startTime,
        endTime: Value(endTime),
        mode: const Value('gps'),
        targetCadence: Value(targetCadence),
        avgCadence: Value(avgCadence),
        maxCadence: Value(maxCadence),
        distanceKm: Value(distanceKm),
        durationSeconds: Value(durationSeconds),
        movingDurationSeconds: Value(movingDurationSeconds),
        pauseDurationSeconds: Value(pauseDurationSeconds),
        avgPaceMinPerKm: Value(avgPaceMinPerKm),
        bestPaceMinPerKm: Value(bestPaceMinPerKm),
        estimatedCalories: Value(estimatedCalories),
        estimatedSteps: Value(estimatedSteps),
        routePointsJson: Value(pointsJson),
        splitsJson: Value(splitsJson),
      ),
    );
  }

  Future<bool> updateGpsSession({
    required int id,
    required DateTime startTime,
    DateTime? endTime,
    required double targetCadence,
    required double avgCadence,
    required double maxCadence,
    required double distanceKm,
    required int durationSeconds,
    required int movingDurationSeconds,
    required int pauseDurationSeconds,
    double? avgPaceMinPerKm,
    double? bestPaceMinPerKm,
    required int estimatedCalories,
    required int estimatedSteps,
    required List<GpsTrackPoint> points,
    required List<KmSplit> splits,
  }) async {
    final pointsJson = jsonEncode(points.map((p) => p.toJson()).toList());
    final splitsJson = jsonEncode(splits.map((s) => s.toJson()).toList());

    return _db.update(_db.workoutSessions).replace(
      WorkoutSession(
        id: id,
        startTime: startTime,
        endTime: endTime,
        mode: 'gps',
        targetCadence: targetCadence,
        avgCadence: avgCadence,
        maxCadence: maxCadence,
        distanceKm: distanceKm,
        durationSeconds: durationSeconds,
        movingDurationSeconds: movingDurationSeconds,
        pauseDurationSeconds: pauseDurationSeconds,
        avgPaceMinPerKm: avgPaceMinPerKm,
        bestPaceMinPerKm: bestPaceMinPerKm,
        estimatedCalories: estimatedCalories,
        estimatedSteps: estimatedSteps,
        routePointsJson: pointsJson,
        splitsJson: splitsJson,
      ),
    );
  }

  Future<int> deleteSession(int id) {
    return (_db.delete(_db.workoutSessions)..where((tbl) => tbl.id.equals(id))).go();
  }
}