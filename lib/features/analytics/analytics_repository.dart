import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/app_database.dart';
import '../../features/history/repositories/gps_session_repository.dart';
import '../history/models/gps_track_point.dart';
import '../history/services/best_efforts_calculator.dart';

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return AnalyticsRepository(db);
});

class BestEffortRow {
  final String distanceBucket;
  final int bestDurationSeconds;
  final int sessionId;
  final DateTime computedAt;

  BestEffortRow({
    required this.distanceBucket,
    required this.bestDurationSeconds,
    required this.sessionId,
    required this.computedAt,
  });
}

class AnalyticsSummary {
  final double totalDistanceKm;
  final int totalMovingDurationSeconds;
  final int totalActivities;
  final double avgPaceMinPerKm;

  AnalyticsSummary({
    required this.totalDistanceKm,
    required this.totalMovingDurationSeconds,
    required this.totalActivities,
    required this.avgPaceMinPerKm,
  });
}

class AnalyticsRepository {
  final AppDatabase _db;

  AnalyticsRepository(this._db);

  /// Gets all-time personal records (PRs) for each distance bucket.
  Future<List<BestEffortRow>> getAllTimePrs() async {
    // Using custom select:
    final result = await _db.customSelect(
      '''
      SELECT distance_bucket, MIN(best_duration_seconds) as best_duration_seconds, session_id, computed_at
      FROM analytics_best_efforts
      WHERE distance_bucket != 'none'
      GROUP BY distance_bucket
      ORDER BY best_duration_seconds ASC
      ''',
    ).get();

    return result.map((row) {
      return BestEffortRow(
        distanceBucket: row.read<String>('distance_bucket'),
        bestDurationSeconds: row.read<int>('best_duration_seconds'),
        sessionId: row.read<int>('session_id'),
        computedAt: row.read<DateTime>('computed_at'),
      );
    }).toList();
  }

  /// Gets personal records (PRs) for each distance bucket within [start] and [end].
  Future<List<BestEffortRow>> getPrsInRange(DateTime start, DateTime end) async {
    final result = await _db.customSelect(
      '''
      SELECT e.distance_bucket, MIN(e.best_duration_seconds) as best_duration_seconds, e.session_id, e.computed_at
      FROM analytics_best_efforts e
      JOIN workout_sessions s ON e.session_id = s.id
      WHERE e.distance_bucket != 'none'
        AND s.start_time >= ? AND s.start_time <= ?
      GROUP BY e.distance_bucket
      ORDER BY best_duration_seconds ASC
      ''',
      variables: [Variable.withDateTime(start), Variable.withDateTime(end)],
    ).get();

    return result.map((row) {
      return BestEffortRow(
        distanceBucket: row.read<String>('distance_bucket'),
        bestDurationSeconds: row.read<int>('best_duration_seconds'),
        sessionId: row.read<int>('session_id'),
        computedAt: row.read<DateTime>('computed_at'),
      );
    }).toList();
  }

  /// Gets summary stats for GPS sessions between [start] and [end].
  Future<AnalyticsSummary> getSummaryInRange(DateTime start, DateTime end) async {
    final query = _db.select(_db.workoutSessions)
      ..where((tbl) => tbl.mode.equals('gps') & 
                       tbl.startTime.isBiggerOrEqualValue(start) & 
                       tbl.startTime.isSmallerOrEqualValue(end));
    
    final sessions = await query.get();

    double totalDist = 0;
    int totalTime = 0;
    double totalPaceWeighted = 0;

    for (final s in sessions) {
      totalDist += s.distanceKm;
      totalTime += s.movingDurationSeconds;
      if (s.avgPaceMinPerKm != null && s.distanceKm > 0) {
        totalPaceWeighted += s.avgPaceMinPerKm! * s.distanceKm;
      }
    }

    final avgPace = totalDist > 0 ? totalPaceWeighted / totalDist : 0.0;

    return AnalyticsSummary(
      totalDistanceKm: totalDist,
      totalMovingDurationSeconds: totalTime,
      totalActivities: sessions.length,
      avgPaceMinPerKm: avgPace,
    );
  }

  /// Gets GPS sessions in date range.
  Future<List<WorkoutSession>> getSessionsInRange(DateTime start, DateTime end) async {
    return (_db.select(_db.workoutSessions)
          ..where((tbl) => tbl.mode.equals('gps') &
                           tbl.startTime.isBiggerOrEqualValue(start) &
                           tbl.startTime.isSmallerOrEqualValue(end))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.startTime)]))
        .get();
  }

  /// Checks how many GPS sessions in range lack analytics best efforts.
  Future<int> getMissingAnalyticsCount(DateTime start, DateTime end) async {
    final result = await _db.customSelect(
      '''
      SELECT COUNT(*) as cnt
      FROM workout_sessions s
      WHERE s.mode = 'gps'
        AND s.route_points_json IS NOT NULL
        AND s.route_points_json != '[]'
        AND s.start_time >= ? AND s.start_time <= ?
        AND NOT EXISTS (
          SELECT 1 FROM analytics_best_efforts e WHERE e.session_id = s.id
        )
      ''',
      variables: [Variable.withDateTime(start), Variable.withDateTime(end)],
    ).getSingle();
    return result.read<int>('cnt');
  }

  /// Backfills missing analytics best efforts for all GPS sessions in range.
  Future<void> backfillMissingAnalytics(
    DateTime start,
    DateTime end, {
    void Function(int processed, int total)? onProgress,
  }) async {
    try {
      final sessions = await (_db.select(_db.workoutSessions)
            ..where((tbl) => tbl.mode.equals('gps') &
                             tbl.routePointsJson.isNotNull() &
                             tbl.startTime.isBiggerOrEqualValue(start) &
                             tbl.startTime.isSmallerOrEqualValue(end)))
          .get();

      final List<WorkoutSession> sessionsToBackfill = [];
      for (final session in sessions) {
        final existing = await (_db.select(_db.analyticsBestEfforts)
              ..where((tbl) => tbl.sessionId.equals(session.id)))
            .get();

        if (existing.isEmpty && session.routePointsJson != null) {
          sessionsToBackfill.add(session);
        }
      }

      final total = sessionsToBackfill.length;
      if (total == 0) {
        onProgress?.call(0, 0);
        return;
      }

      int processed = 0;
      onProgress?.call(processed, total);

      for (final session in sessionsToBackfill) {
        try {
          final list = jsonDecode(session.routePointsJson!) as List;
          final points = list
              .map((e) => GpsTrackPoint.fromJson(e as Map<String, dynamic>))
              .toList();
          await _saveBestEfforts(session.id, points);
        } catch (_) {
          await _saveBestEfforts(session.id, []);
        }
        processed++;
        onProgress?.call(processed, total);
      }
    } catch (_) {}
  }

  Future<void> _saveBestEfforts(int sessionId, List<GpsTrackPoint> points) async {
    await (_db.delete(_db.analyticsBestEfforts)..where((tbl) => tbl.sessionId.equals(sessionId))).go();

    int insertedCount = 0;
    for (final bucket in BestEffortBucket.standardBuckets) {
      final duration = BestEffortsCalculator.computeBestEffort(points, bucket.targetKm);
      if (duration != null) {
        await _db.into(_db.analyticsBestEfforts).insert(
          AnalyticsBestEffortsCompanion.insert(
            sessionId: sessionId,
            distanceBucket: bucket.label,
            bestDurationSeconds: duration.inSeconds,
            computedAt: DateTime.now(),
          ),
        );
        insertedCount++;
      }
    }

    if (insertedCount == 0) {
      await _db.into(_db.analyticsBestEfforts).insert(
        AnalyticsBestEffortsCompanion.insert(
          sessionId: sessionId,
          distanceBucket: 'none',
          bestDurationSeconds: 0,
          computedAt: DateTime.now(),
        ),
      );
    }
  }
}
