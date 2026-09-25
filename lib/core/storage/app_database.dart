import 'package:drift/drift.dart';

part 'app_database.g.dart';

class WorkoutSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  TextColumn get mode => text().withDefault(const Constant('gps'))();
  RealColumn get targetCadence => real().withDefault(const Constant(0.0))();
  RealColumn get avgCadence => real().withDefault(const Constant(0.0))();
  RealColumn get maxCadence => real().withDefault(const Constant(0.0))();
  RealColumn get distanceKm => real().withDefault(const Constant(0.0))();
  IntColumn get durationSeconds => integer().withDefault(const Constant(0))();
  IntColumn get movingDurationSeconds => integer().withDefault(const Constant(0))();
  IntColumn get pauseDurationSeconds => integer().withDefault(const Constant(0))();
  RealColumn get avgPaceMinPerKm => real().nullable()();
  RealColumn get bestPaceMinPerKm => real().nullable()();
  IntColumn get estimatedCalories => integer().withDefault(const Constant(0))();
  IntColumn get estimatedSteps => integer().withDefault(const Constant(0))();
  TextColumn get routePointsJson => text().nullable()(); // Serialized list of detailed points
  TextColumn get splitsJson => text().nullable()(); // Serialized list of 1km splits
}

class WorkoutSamples extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().references(WorkoutSessions, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get timestamp => dateTime()();
  RealColumn get cadence => real()();
  RealColumn get speedKmH => real()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
}

class AnalyticsBestEfforts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().references(WorkoutSessions, #id, onDelete: KeyAction.cascade)();
  TextColumn get distanceBucket => text()();
  IntColumn get bestDurationSeconds => integer()();
  DateTimeColumn get computedAt => dateTime()();
}

@DriftDatabase(tables: [WorkoutSessions, WorkoutSamples, AnalyticsBestEfforts])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            try { await m.addColumn(workoutSessions, workoutSessions.maxCadence); } catch (_) {}
            try { await m.addColumn(workoutSessions, workoutSessions.movingDurationSeconds); } catch (_) {}
            try { await m.addColumn(workoutSessions, workoutSessions.pauseDurationSeconds); } catch (_) {}
            try { await m.addColumn(workoutSessions, workoutSessions.avgPaceMinPerKm); } catch (_) {}
            try { await m.addColumn(workoutSessions, workoutSessions.bestPaceMinPerKm); } catch (_) {}
            try { await m.addColumn(workoutSessions, workoutSessions.estimatedCalories); } catch (_) {}
            try { await m.addColumn(workoutSessions, workoutSessions.estimatedSteps); } catch (_) {}
            try { await m.addColumn(workoutSessions, workoutSessions.splitsJson); } catch (_) {}
          }
          if (from < 3) {
            await m.createTable(analyticsBestEfforts);
          }
        },
      );
}
