// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $WorkoutSessionsTable extends WorkoutSessions
    with TableInfo<$WorkoutSessionsTable, WorkoutSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
    'start_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
    'end_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('gps'),
  );
  static const VerificationMeta _targetCadenceMeta = const VerificationMeta(
    'targetCadence',
  );
  @override
  late final GeneratedColumn<double> targetCadence = GeneratedColumn<double>(
    'target_cadence',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _avgCadenceMeta = const VerificationMeta(
    'avgCadence',
  );
  @override
  late final GeneratedColumn<double> avgCadence = GeneratedColumn<double>(
    'avg_cadence',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _maxCadenceMeta = const VerificationMeta(
    'maxCadence',
  );
  @override
  late final GeneratedColumn<double> maxCadence = GeneratedColumn<double>(
    'max_cadence',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _distanceKmMeta = const VerificationMeta(
    'distanceKm',
  );
  @override
  late final GeneratedColumn<double> distanceKm = GeneratedColumn<double>(
    'distance_km',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _movingDurationSecondsMeta =
      const VerificationMeta('movingDurationSeconds');
  @override
  late final GeneratedColumn<int> movingDurationSeconds = GeneratedColumn<int>(
    'moving_duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _pauseDurationSecondsMeta =
      const VerificationMeta('pauseDurationSeconds');
  @override
  late final GeneratedColumn<int> pauseDurationSeconds = GeneratedColumn<int>(
    'pause_duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _avgPaceMinPerKmMeta = const VerificationMeta(
    'avgPaceMinPerKm',
  );
  @override
  late final GeneratedColumn<double> avgPaceMinPerKm = GeneratedColumn<double>(
    'avg_pace_min_per_km',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bestPaceMinPerKmMeta = const VerificationMeta(
    'bestPaceMinPerKm',
  );
  @override
  late final GeneratedColumn<double> bestPaceMinPerKm = GeneratedColumn<double>(
    'best_pace_min_per_km',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _estimatedCaloriesMeta = const VerificationMeta(
    'estimatedCalories',
  );
  @override
  late final GeneratedColumn<int> estimatedCalories = GeneratedColumn<int>(
    'estimated_calories',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _estimatedStepsMeta = const VerificationMeta(
    'estimatedSteps',
  );
  @override
  late final GeneratedColumn<int> estimatedSteps = GeneratedColumn<int>(
    'estimated_steps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _routePointsJsonMeta = const VerificationMeta(
    'routePointsJson',
  );
  @override
  late final GeneratedColumn<String> routePointsJson = GeneratedColumn<String>(
    'route_points_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _splitsJsonMeta = const VerificationMeta(
    'splitsJson',
  );
  @override
  late final GeneratedColumn<String> splitsJson = GeneratedColumn<String>(
    'splits_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    startTime,
    endTime,
    mode,
    targetCadence,
    avgCadence,
    maxCadence,
    distanceKm,
    durationSeconds,
    movingDurationSeconds,
    pauseDurationSeconds,
    avgPaceMinPerKm,
    bestPaceMinPerKm,
    estimatedCalories,
    estimatedSteps,
    routePointsJson,
    splitsJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    }
    if (data.containsKey('target_cadence')) {
      context.handle(
        _targetCadenceMeta,
        targetCadence.isAcceptableOrUnknown(
          data['target_cadence']!,
          _targetCadenceMeta,
        ),
      );
    }
    if (data.containsKey('avg_cadence')) {
      context.handle(
        _avgCadenceMeta,
        avgCadence.isAcceptableOrUnknown(data['avg_cadence']!, _avgCadenceMeta),
      );
    }
    if (data.containsKey('max_cadence')) {
      context.handle(
        _maxCadenceMeta,
        maxCadence.isAcceptableOrUnknown(data['max_cadence']!, _maxCadenceMeta),
      );
    }
    if (data.containsKey('distance_km')) {
      context.handle(
        _distanceKmMeta,
        distanceKm.isAcceptableOrUnknown(data['distance_km']!, _distanceKmMeta),
      );
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('moving_duration_seconds')) {
      context.handle(
        _movingDurationSecondsMeta,
        movingDurationSeconds.isAcceptableOrUnknown(
          data['moving_duration_seconds']!,
          _movingDurationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('pause_duration_seconds')) {
      context.handle(
        _pauseDurationSecondsMeta,
        pauseDurationSeconds.isAcceptableOrUnknown(
          data['pause_duration_seconds']!,
          _pauseDurationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('avg_pace_min_per_km')) {
      context.handle(
        _avgPaceMinPerKmMeta,
        avgPaceMinPerKm.isAcceptableOrUnknown(
          data['avg_pace_min_per_km']!,
          _avgPaceMinPerKmMeta,
        ),
      );
    }
    if (data.containsKey('best_pace_min_per_km')) {
      context.handle(
        _bestPaceMinPerKmMeta,
        bestPaceMinPerKm.isAcceptableOrUnknown(
          data['best_pace_min_per_km']!,
          _bestPaceMinPerKmMeta,
        ),
      );
    }
    if (data.containsKey('estimated_calories')) {
      context.handle(
        _estimatedCaloriesMeta,
        estimatedCalories.isAcceptableOrUnknown(
          data['estimated_calories']!,
          _estimatedCaloriesMeta,
        ),
      );
    }
    if (data.containsKey('estimated_steps')) {
      context.handle(
        _estimatedStepsMeta,
        estimatedSteps.isAcceptableOrUnknown(
          data['estimated_steps']!,
          _estimatedStepsMeta,
        ),
      );
    }
    if (data.containsKey('route_points_json')) {
      context.handle(
        _routePointsJsonMeta,
        routePointsJson.isAcceptableOrUnknown(
          data['route_points_json']!,
          _routePointsJsonMeta,
        ),
      );
    }
    if (data.containsKey('splits_json')) {
      context.handle(
        _splitsJsonMeta,
        splitsJson.isAcceptableOrUnknown(data['splits_json']!, _splitsJsonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_time'],
      )!,
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_time'],
      ),
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      targetCadence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_cadence'],
      )!,
      avgCadence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}avg_cadence'],
      )!,
      maxCadence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}max_cadence'],
      )!,
      distanceKm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance_km'],
      )!,
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      )!,
      movingDurationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}moving_duration_seconds'],
      )!,
      pauseDurationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pause_duration_seconds'],
      )!,
      avgPaceMinPerKm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}avg_pace_min_per_km'],
      ),
      bestPaceMinPerKm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}best_pace_min_per_km'],
      ),
      estimatedCalories: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}estimated_calories'],
      )!,
      estimatedSteps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}estimated_steps'],
      )!,
      routePointsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}route_points_json'],
      ),
      splitsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}splits_json'],
      ),
    );
  }

  @override
  $WorkoutSessionsTable createAlias(String alias) {
    return $WorkoutSessionsTable(attachedDatabase, alias);
  }
}

class WorkoutSession extends DataClass implements Insertable<WorkoutSession> {
  final int id;
  final DateTime startTime;
  final DateTime? endTime;
  final String mode;
  final double targetCadence;
  final double avgCadence;
  final double maxCadence;
  final double distanceKm;
  final int durationSeconds;
  final int movingDurationSeconds;
  final int pauseDurationSeconds;
  final double? avgPaceMinPerKm;
  final double? bestPaceMinPerKm;
  final int estimatedCalories;
  final int estimatedSteps;
  final String? routePointsJson;
  final String? splitsJson;
  const WorkoutSession({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.mode,
    required this.targetCadence,
    required this.avgCadence,
    required this.maxCadence,
    required this.distanceKm,
    required this.durationSeconds,
    required this.movingDurationSeconds,
    required this.pauseDurationSeconds,
    this.avgPaceMinPerKm,
    this.bestPaceMinPerKm,
    required this.estimatedCalories,
    required this.estimatedSteps,
    this.routePointsJson,
    this.splitsJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['start_time'] = Variable<DateTime>(startTime);
    if (!nullToAbsent || endTime != null) {
      map['end_time'] = Variable<DateTime>(endTime);
    }
    map['mode'] = Variable<String>(mode);
    map['target_cadence'] = Variable<double>(targetCadence);
    map['avg_cadence'] = Variable<double>(avgCadence);
    map['max_cadence'] = Variable<double>(maxCadence);
    map['distance_km'] = Variable<double>(distanceKm);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['moving_duration_seconds'] = Variable<int>(movingDurationSeconds);
    map['pause_duration_seconds'] = Variable<int>(pauseDurationSeconds);
    if (!nullToAbsent || avgPaceMinPerKm != null) {
      map['avg_pace_min_per_km'] = Variable<double>(avgPaceMinPerKm);
    }
    if (!nullToAbsent || bestPaceMinPerKm != null) {
      map['best_pace_min_per_km'] = Variable<double>(bestPaceMinPerKm);
    }
    map['estimated_calories'] = Variable<int>(estimatedCalories);
    map['estimated_steps'] = Variable<int>(estimatedSteps);
    if (!nullToAbsent || routePointsJson != null) {
      map['route_points_json'] = Variable<String>(routePointsJson);
    }
    if (!nullToAbsent || splitsJson != null) {
      map['splits_json'] = Variable<String>(splitsJson);
    }
    return map;
  }

  WorkoutSessionsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutSessionsCompanion(
      id: Value(id),
      startTime: Value(startTime),
      endTime: endTime == null && nullToAbsent
          ? const Value.absent()
          : Value(endTime),
      mode: Value(mode),
      targetCadence: Value(targetCadence),
      avgCadence: Value(avgCadence),
      maxCadence: Value(maxCadence),
      distanceKm: Value(distanceKm),
      durationSeconds: Value(durationSeconds),
      movingDurationSeconds: Value(movingDurationSeconds),
      pauseDurationSeconds: Value(pauseDurationSeconds),
      avgPaceMinPerKm: avgPaceMinPerKm == null && nullToAbsent
          ? const Value.absent()
          : Value(avgPaceMinPerKm),
      bestPaceMinPerKm: bestPaceMinPerKm == null && nullToAbsent
          ? const Value.absent()
          : Value(bestPaceMinPerKm),
      estimatedCalories: Value(estimatedCalories),
      estimatedSteps: Value(estimatedSteps),
      routePointsJson: routePointsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(routePointsJson),
      splitsJson: splitsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(splitsJson),
    );
  }

  factory WorkoutSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutSession(
      id: serializer.fromJson<int>(json['id']),
      startTime: serializer.fromJson<DateTime>(json['startTime']),
      endTime: serializer.fromJson<DateTime?>(json['endTime']),
      mode: serializer.fromJson<String>(json['mode']),
      targetCadence: serializer.fromJson<double>(json['targetCadence']),
      avgCadence: serializer.fromJson<double>(json['avgCadence']),
      maxCadence: serializer.fromJson<double>(json['maxCadence']),
      distanceKm: serializer.fromJson<double>(json['distanceKm']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      movingDurationSeconds: serializer.fromJson<int>(
        json['movingDurationSeconds'],
      ),
      pauseDurationSeconds: serializer.fromJson<int>(
        json['pauseDurationSeconds'],
      ),
      avgPaceMinPerKm: serializer.fromJson<double?>(json['avgPaceMinPerKm']),
      bestPaceMinPerKm: serializer.fromJson<double?>(json['bestPaceMinPerKm']),
      estimatedCalories: serializer.fromJson<int>(json['estimatedCalories']),
      estimatedSteps: serializer.fromJson<int>(json['estimatedSteps']),
      routePointsJson: serializer.fromJson<String?>(json['routePointsJson']),
      splitsJson: serializer.fromJson<String?>(json['splitsJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'startTime': serializer.toJson<DateTime>(startTime),
      'endTime': serializer.toJson<DateTime?>(endTime),
      'mode': serializer.toJson<String>(mode),
      'targetCadence': serializer.toJson<double>(targetCadence),
      'avgCadence': serializer.toJson<double>(avgCadence),
      'maxCadence': serializer.toJson<double>(maxCadence),
      'distanceKm': serializer.toJson<double>(distanceKm),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'movingDurationSeconds': serializer.toJson<int>(movingDurationSeconds),
      'pauseDurationSeconds': serializer.toJson<int>(pauseDurationSeconds),
      'avgPaceMinPerKm': serializer.toJson<double?>(avgPaceMinPerKm),
      'bestPaceMinPerKm': serializer.toJson<double?>(bestPaceMinPerKm),
      'estimatedCalories': serializer.toJson<int>(estimatedCalories),
      'estimatedSteps': serializer.toJson<int>(estimatedSteps),
      'routePointsJson': serializer.toJson<String?>(routePointsJson),
      'splitsJson': serializer.toJson<String?>(splitsJson),
    };
  }

  WorkoutSession copyWith({
    int? id,
    DateTime? startTime,
    Value<DateTime?> endTime = const Value.absent(),
    String? mode,
    double? targetCadence,
    double? avgCadence,
    double? maxCadence,
    double? distanceKm,
    int? durationSeconds,
    int? movingDurationSeconds,
    int? pauseDurationSeconds,
    Value<double?> avgPaceMinPerKm = const Value.absent(),
    Value<double?> bestPaceMinPerKm = const Value.absent(),
    int? estimatedCalories,
    int? estimatedSteps,
    Value<String?> routePointsJson = const Value.absent(),
    Value<String?> splitsJson = const Value.absent(),
  }) => WorkoutSession(
    id: id ?? this.id,
    startTime: startTime ?? this.startTime,
    endTime: endTime.present ? endTime.value : this.endTime,
    mode: mode ?? this.mode,
    targetCadence: targetCadence ?? this.targetCadence,
    avgCadence: avgCadence ?? this.avgCadence,
    maxCadence: maxCadence ?? this.maxCadence,
    distanceKm: distanceKm ?? this.distanceKm,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    movingDurationSeconds: movingDurationSeconds ?? this.movingDurationSeconds,
    pauseDurationSeconds: pauseDurationSeconds ?? this.pauseDurationSeconds,
    avgPaceMinPerKm: avgPaceMinPerKm.present
        ? avgPaceMinPerKm.value
        : this.avgPaceMinPerKm,
    bestPaceMinPerKm: bestPaceMinPerKm.present
        ? bestPaceMinPerKm.value
        : this.bestPaceMinPerKm,
    estimatedCalories: estimatedCalories ?? this.estimatedCalories,
    estimatedSteps: estimatedSteps ?? this.estimatedSteps,
    routePointsJson: routePointsJson.present
        ? routePointsJson.value
        : this.routePointsJson,
    splitsJson: splitsJson.present ? splitsJson.value : this.splitsJson,
  );
  WorkoutSession copyWithCompanion(WorkoutSessionsCompanion data) {
    return WorkoutSession(
      id: data.id.present ? data.id.value : this.id,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      mode: data.mode.present ? data.mode.value : this.mode,
      targetCadence: data.targetCadence.present
          ? data.targetCadence.value
          : this.targetCadence,
      avgCadence: data.avgCadence.present
          ? data.avgCadence.value
          : this.avgCadence,
      maxCadence: data.maxCadence.present
          ? data.maxCadence.value
          : this.maxCadence,
      distanceKm: data.distanceKm.present
          ? data.distanceKm.value
          : this.distanceKm,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      movingDurationSeconds: data.movingDurationSeconds.present
          ? data.movingDurationSeconds.value
          : this.movingDurationSeconds,
      pauseDurationSeconds: data.pauseDurationSeconds.present
          ? data.pauseDurationSeconds.value
          : this.pauseDurationSeconds,
      avgPaceMinPerKm: data.avgPaceMinPerKm.present
          ? data.avgPaceMinPerKm.value
          : this.avgPaceMinPerKm,
      bestPaceMinPerKm: data.bestPaceMinPerKm.present
          ? data.bestPaceMinPerKm.value
          : this.bestPaceMinPerKm,
      estimatedCalories: data.estimatedCalories.present
          ? data.estimatedCalories.value
          : this.estimatedCalories,
      estimatedSteps: data.estimatedSteps.present
          ? data.estimatedSteps.value
          : this.estimatedSteps,
      routePointsJson: data.routePointsJson.present
          ? data.routePointsJson.value
          : this.routePointsJson,
      splitsJson: data.splitsJson.present
          ? data.splitsJson.value
          : this.splitsJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSession(')
          ..write('id: $id, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('mode: $mode, ')
          ..write('targetCadence: $targetCadence, ')
          ..write('avgCadence: $avgCadence, ')
          ..write('maxCadence: $maxCadence, ')
          ..write('distanceKm: $distanceKm, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('movingDurationSeconds: $movingDurationSeconds, ')
          ..write('pauseDurationSeconds: $pauseDurationSeconds, ')
          ..write('avgPaceMinPerKm: $avgPaceMinPerKm, ')
          ..write('bestPaceMinPerKm: $bestPaceMinPerKm, ')
          ..write('estimatedCalories: $estimatedCalories, ')
          ..write('estimatedSteps: $estimatedSteps, ')
          ..write('routePointsJson: $routePointsJson, ')
          ..write('splitsJson: $splitsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    startTime,
    endTime,
    mode,
    targetCadence,
    avgCadence,
    maxCadence,
    distanceKm,
    durationSeconds,
    movingDurationSeconds,
    pauseDurationSeconds,
    avgPaceMinPerKm,
    bestPaceMinPerKm,
    estimatedCalories,
    estimatedSteps,
    routePointsJson,
    splitsJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutSession &&
          other.id == this.id &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.mode == this.mode &&
          other.targetCadence == this.targetCadence &&
          other.avgCadence == this.avgCadence &&
          other.maxCadence == this.maxCadence &&
          other.distanceKm == this.distanceKm &&
          other.durationSeconds == this.durationSeconds &&
          other.movingDurationSeconds == this.movingDurationSeconds &&
          other.pauseDurationSeconds == this.pauseDurationSeconds &&
          other.avgPaceMinPerKm == this.avgPaceMinPerKm &&
          other.bestPaceMinPerKm == this.bestPaceMinPerKm &&
          other.estimatedCalories == this.estimatedCalories &&
          other.estimatedSteps == this.estimatedSteps &&
          other.routePointsJson == this.routePointsJson &&
          other.splitsJson == this.splitsJson);
}

class WorkoutSessionsCompanion extends UpdateCompanion<WorkoutSession> {
  final Value<int> id;
  final Value<DateTime> startTime;
  final Value<DateTime?> endTime;
  final Value<String> mode;
  final Value<double> targetCadence;
  final Value<double> avgCadence;
  final Value<double> maxCadence;
  final Value<double> distanceKm;
  final Value<int> durationSeconds;
  final Value<int> movingDurationSeconds;
  final Value<int> pauseDurationSeconds;
  final Value<double?> avgPaceMinPerKm;
  final Value<double?> bestPaceMinPerKm;
  final Value<int> estimatedCalories;
  final Value<int> estimatedSteps;
  final Value<String?> routePointsJson;
  final Value<String?> splitsJson;
  const WorkoutSessionsCompanion({
    this.id = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.mode = const Value.absent(),
    this.targetCadence = const Value.absent(),
    this.avgCadence = const Value.absent(),
    this.maxCadence = const Value.absent(),
    this.distanceKm = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.movingDurationSeconds = const Value.absent(),
    this.pauseDurationSeconds = const Value.absent(),
    this.avgPaceMinPerKm = const Value.absent(),
    this.bestPaceMinPerKm = const Value.absent(),
    this.estimatedCalories = const Value.absent(),
    this.estimatedSteps = const Value.absent(),
    this.routePointsJson = const Value.absent(),
    this.splitsJson = const Value.absent(),
  });
  WorkoutSessionsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime startTime,
    this.endTime = const Value.absent(),
    this.mode = const Value.absent(),
    this.targetCadence = const Value.absent(),
    this.avgCadence = const Value.absent(),
    this.maxCadence = const Value.absent(),
    this.distanceKm = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.movingDurationSeconds = const Value.absent(),
    this.pauseDurationSeconds = const Value.absent(),
    this.avgPaceMinPerKm = const Value.absent(),
    this.bestPaceMinPerKm = const Value.absent(),
    this.estimatedCalories = const Value.absent(),
    this.estimatedSteps = const Value.absent(),
    this.routePointsJson = const Value.absent(),
    this.splitsJson = const Value.absent(),
  }) : startTime = Value(startTime);
  static Insertable<WorkoutSession> custom({
    Expression<int>? id,
    Expression<DateTime>? startTime,
    Expression<DateTime>? endTime,
    Expression<String>? mode,
    Expression<double>? targetCadence,
    Expression<double>? avgCadence,
    Expression<double>? maxCadence,
    Expression<double>? distanceKm,
    Expression<int>? durationSeconds,
    Expression<int>? movingDurationSeconds,
    Expression<int>? pauseDurationSeconds,
    Expression<double>? avgPaceMinPerKm,
    Expression<double>? bestPaceMinPerKm,
    Expression<int>? estimatedCalories,
    Expression<int>? estimatedSteps,
    Expression<String>? routePointsJson,
    Expression<String>? splitsJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (mode != null) 'mode': mode,
      if (targetCadence != null) 'target_cadence': targetCadence,
      if (avgCadence != null) 'avg_cadence': avgCadence,
      if (maxCadence != null) 'max_cadence': maxCadence,
      if (distanceKm != null) 'distance_km': distanceKm,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (movingDurationSeconds != null)
        'moving_duration_seconds': movingDurationSeconds,
      if (pauseDurationSeconds != null)
        'pause_duration_seconds': pauseDurationSeconds,
      if (avgPaceMinPerKm != null) 'avg_pace_min_per_km': avgPaceMinPerKm,
      if (bestPaceMinPerKm != null) 'best_pace_min_per_km': bestPaceMinPerKm,
      if (estimatedCalories != null) 'estimated_calories': estimatedCalories,
      if (estimatedSteps != null) 'estimated_steps': estimatedSteps,
      if (routePointsJson != null) 'route_points_json': routePointsJson,
      if (splitsJson != null) 'splits_json': splitsJson,
    });
  }

  WorkoutSessionsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? startTime,
    Value<DateTime?>? endTime,
    Value<String>? mode,
    Value<double>? targetCadence,
    Value<double>? avgCadence,
    Value<double>? maxCadence,
    Value<double>? distanceKm,
    Value<int>? durationSeconds,
    Value<int>? movingDurationSeconds,
    Value<int>? pauseDurationSeconds,
    Value<double?>? avgPaceMinPerKm,
    Value<double?>? bestPaceMinPerKm,
    Value<int>? estimatedCalories,
    Value<int>? estimatedSteps,
    Value<String?>? routePointsJson,
    Value<String?>? splitsJson,
  }) {
    return WorkoutSessionsCompanion(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      mode: mode ?? this.mode,
      targetCadence: targetCadence ?? this.targetCadence,
      avgCadence: avgCadence ?? this.avgCadence,
      maxCadence: maxCadence ?? this.maxCadence,
      distanceKm: distanceKm ?? this.distanceKm,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      movingDurationSeconds:
          movingDurationSeconds ?? this.movingDurationSeconds,
      pauseDurationSeconds: pauseDurationSeconds ?? this.pauseDurationSeconds,
      avgPaceMinPerKm: avgPaceMinPerKm ?? this.avgPaceMinPerKm,
      bestPaceMinPerKm: bestPaceMinPerKm ?? this.bestPaceMinPerKm,
      estimatedCalories: estimatedCalories ?? this.estimatedCalories,
      estimatedSteps: estimatedSteps ?? this.estimatedSteps,
      routePointsJson: routePointsJson ?? this.routePointsJson,
      splitsJson: splitsJson ?? this.splitsJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<DateTime>(endTime.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (targetCadence.present) {
      map['target_cadence'] = Variable<double>(targetCadence.value);
    }
    if (avgCadence.present) {
      map['avg_cadence'] = Variable<double>(avgCadence.value);
    }
    if (maxCadence.present) {
      map['max_cadence'] = Variable<double>(maxCadence.value);
    }
    if (distanceKm.present) {
      map['distance_km'] = Variable<double>(distanceKm.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (movingDurationSeconds.present) {
      map['moving_duration_seconds'] = Variable<int>(
        movingDurationSeconds.value,
      );
    }
    if (pauseDurationSeconds.present) {
      map['pause_duration_seconds'] = Variable<int>(pauseDurationSeconds.value);
    }
    if (avgPaceMinPerKm.present) {
      map['avg_pace_min_per_km'] = Variable<double>(avgPaceMinPerKm.value);
    }
    if (bestPaceMinPerKm.present) {
      map['best_pace_min_per_km'] = Variable<double>(bestPaceMinPerKm.value);
    }
    if (estimatedCalories.present) {
      map['estimated_calories'] = Variable<int>(estimatedCalories.value);
    }
    if (estimatedSteps.present) {
      map['estimated_steps'] = Variable<int>(estimatedSteps.value);
    }
    if (routePointsJson.present) {
      map['route_points_json'] = Variable<String>(routePointsJson.value);
    }
    if (splitsJson.present) {
      map['splits_json'] = Variable<String>(splitsJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSessionsCompanion(')
          ..write('id: $id, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('mode: $mode, ')
          ..write('targetCadence: $targetCadence, ')
          ..write('avgCadence: $avgCadence, ')
          ..write('maxCadence: $maxCadence, ')
          ..write('distanceKm: $distanceKm, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('movingDurationSeconds: $movingDurationSeconds, ')
          ..write('pauseDurationSeconds: $pauseDurationSeconds, ')
          ..write('avgPaceMinPerKm: $avgPaceMinPerKm, ')
          ..write('bestPaceMinPerKm: $bestPaceMinPerKm, ')
          ..write('estimatedCalories: $estimatedCalories, ')
          ..write('estimatedSteps: $estimatedSteps, ')
          ..write('routePointsJson: $routePointsJson, ')
          ..write('splitsJson: $splitsJson')
          ..write(')'))
        .toString();
  }
}

class $WorkoutSamplesTable extends WorkoutSamples
    with TableInfo<$WorkoutSamplesTable, WorkoutSample> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutSamplesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workout_sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cadenceMeta = const VerificationMeta(
    'cadence',
  );
  @override
  late final GeneratedColumn<double> cadence = GeneratedColumn<double>(
    'cadence',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _speedKmHMeta = const VerificationMeta(
    'speedKmH',
  );
  @override
  late final GeneratedColumn<double> speedKmH = GeneratedColumn<double>(
    'speed_km_h',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    timestamp,
    cadence,
    speedKmH,
    latitude,
    longitude,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_samples';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutSample> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('cadence')) {
      context.handle(
        _cadenceMeta,
        cadence.isAcceptableOrUnknown(data['cadence']!, _cadenceMeta),
      );
    } else if (isInserting) {
      context.missing(_cadenceMeta);
    }
    if (data.containsKey('speed_km_h')) {
      context.handle(
        _speedKmHMeta,
        speedKmH.isAcceptableOrUnknown(data['speed_km_h']!, _speedKmHMeta),
      );
    } else if (isInserting) {
      context.missing(_speedKmHMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutSample map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutSample(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      cadence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cadence'],
      )!,
      speedKmH: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}speed_km_h'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
    );
  }

  @override
  $WorkoutSamplesTable createAlias(String alias) {
    return $WorkoutSamplesTable(attachedDatabase, alias);
  }
}

class WorkoutSample extends DataClass implements Insertable<WorkoutSample> {
  final int id;
  final int sessionId;
  final DateTime timestamp;
  final double cadence;
  final double speedKmH;
  final double? latitude;
  final double? longitude;
  const WorkoutSample({
    required this.id,
    required this.sessionId,
    required this.timestamp,
    required this.cadence,
    required this.speedKmH,
    this.latitude,
    this.longitude,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['cadence'] = Variable<double>(cadence);
    map['speed_km_h'] = Variable<double>(speedKmH);
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    return map;
  }

  WorkoutSamplesCompanion toCompanion(bool nullToAbsent) {
    return WorkoutSamplesCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      timestamp: Value(timestamp),
      cadence: Value(cadence),
      speedKmH: Value(speedKmH),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
    );
  }

  factory WorkoutSample.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutSample(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      cadence: serializer.fromJson<double>(json['cadence']),
      speedKmH: serializer.fromJson<double>(json['speedKmH']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'cadence': serializer.toJson<double>(cadence),
      'speedKmH': serializer.toJson<double>(speedKmH),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
    };
  }

  WorkoutSample copyWith({
    int? id,
    int? sessionId,
    DateTime? timestamp,
    double? cadence,
    double? speedKmH,
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
  }) => WorkoutSample(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    timestamp: timestamp ?? this.timestamp,
    cadence: cadence ?? this.cadence,
    speedKmH: speedKmH ?? this.speedKmH,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
  );
  WorkoutSample copyWithCompanion(WorkoutSamplesCompanion data) {
    return WorkoutSample(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      cadence: data.cadence.present ? data.cadence.value : this.cadence,
      speedKmH: data.speedKmH.present ? data.speedKmH.value : this.speedKmH,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSample(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('timestamp: $timestamp, ')
          ..write('cadence: $cadence, ')
          ..write('speedKmH: $speedKmH, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    timestamp,
    cadence,
    speedKmH,
    latitude,
    longitude,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutSample &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.timestamp == this.timestamp &&
          other.cadence == this.cadence &&
          other.speedKmH == this.speedKmH &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude);
}

class WorkoutSamplesCompanion extends UpdateCompanion<WorkoutSample> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<DateTime> timestamp;
  final Value<double> cadence;
  final Value<double> speedKmH;
  final Value<double?> latitude;
  final Value<double?> longitude;
  const WorkoutSamplesCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.cadence = const Value.absent(),
    this.speedKmH = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
  });
  WorkoutSamplesCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required DateTime timestamp,
    required double cadence,
    required double speedKmH,
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
  }) : sessionId = Value(sessionId),
       timestamp = Value(timestamp),
       cadence = Value(cadence),
       speedKmH = Value(speedKmH);
  static Insertable<WorkoutSample> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<DateTime>? timestamp,
    Expression<double>? cadence,
    Expression<double>? speedKmH,
    Expression<double>? latitude,
    Expression<double>? longitude,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (timestamp != null) 'timestamp': timestamp,
      if (cadence != null) 'cadence': cadence,
      if (speedKmH != null) 'speed_km_h': speedKmH,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    });
  }

  WorkoutSamplesCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<DateTime>? timestamp,
    Value<double>? cadence,
    Value<double>? speedKmH,
    Value<double?>? latitude,
    Value<double?>? longitude,
  }) {
    return WorkoutSamplesCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      timestamp: timestamp ?? this.timestamp,
      cadence: cadence ?? this.cadence,
      speedKmH: speedKmH ?? this.speedKmH,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (cadence.present) {
      map['cadence'] = Variable<double>(cadence.value);
    }
    if (speedKmH.present) {
      map['speed_km_h'] = Variable<double>(speedKmH.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSamplesCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('timestamp: $timestamp, ')
          ..write('cadence: $cadence, ')
          ..write('speedKmH: $speedKmH, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude')
          ..write(')'))
        .toString();
  }
}

class $AnalyticsBestEffortsTable extends AnalyticsBestEfforts
    with TableInfo<$AnalyticsBestEffortsTable, AnalyticsBestEffort> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnalyticsBestEffortsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workout_sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _distanceBucketMeta = const VerificationMeta(
    'distanceBucket',
  );
  @override
  late final GeneratedColumn<String> distanceBucket = GeneratedColumn<String>(
    'distance_bucket',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bestDurationSecondsMeta =
      const VerificationMeta('bestDurationSeconds');
  @override
  late final GeneratedColumn<int> bestDurationSeconds = GeneratedColumn<int>(
    'best_duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _computedAtMeta = const VerificationMeta(
    'computedAt',
  );
  @override
  late final GeneratedColumn<DateTime> computedAt = GeneratedColumn<DateTime>(
    'computed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    distanceBucket,
    bestDurationSeconds,
    computedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'analytics_best_efforts';
  @override
  VerificationContext validateIntegrity(
    Insertable<AnalyticsBestEffort> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('distance_bucket')) {
      context.handle(
        _distanceBucketMeta,
        distanceBucket.isAcceptableOrUnknown(
          data['distance_bucket']!,
          _distanceBucketMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_distanceBucketMeta);
    }
    if (data.containsKey('best_duration_seconds')) {
      context.handle(
        _bestDurationSecondsMeta,
        bestDurationSeconds.isAcceptableOrUnknown(
          data['best_duration_seconds']!,
          _bestDurationSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_bestDurationSecondsMeta);
    }
    if (data.containsKey('computed_at')) {
      context.handle(
        _computedAtMeta,
        computedAt.isAcceptableOrUnknown(data['computed_at']!, _computedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_computedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AnalyticsBestEffort map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AnalyticsBestEffort(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      distanceBucket: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}distance_bucket'],
      )!,
      bestDurationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}best_duration_seconds'],
      )!,
      computedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}computed_at'],
      )!,
    );
  }

  @override
  $AnalyticsBestEffortsTable createAlias(String alias) {
    return $AnalyticsBestEffortsTable(attachedDatabase, alias);
  }
}

class AnalyticsBestEffort extends DataClass
    implements Insertable<AnalyticsBestEffort> {
  final int id;
  final int sessionId;
  final String distanceBucket;
  final int bestDurationSeconds;
  final DateTime computedAt;
  const AnalyticsBestEffort({
    required this.id,
    required this.sessionId,
    required this.distanceBucket,
    required this.bestDurationSeconds,
    required this.computedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['distance_bucket'] = Variable<String>(distanceBucket);
    map['best_duration_seconds'] = Variable<int>(bestDurationSeconds);
    map['computed_at'] = Variable<DateTime>(computedAt);
    return map;
  }

  AnalyticsBestEffortsCompanion toCompanion(bool nullToAbsent) {
    return AnalyticsBestEffortsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      distanceBucket: Value(distanceBucket),
      bestDurationSeconds: Value(bestDurationSeconds),
      computedAt: Value(computedAt),
    );
  }

  factory AnalyticsBestEffort.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AnalyticsBestEffort(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      distanceBucket: serializer.fromJson<String>(json['distanceBucket']),
      bestDurationSeconds: serializer.fromJson<int>(
        json['bestDurationSeconds'],
      ),
      computedAt: serializer.fromJson<DateTime>(json['computedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'distanceBucket': serializer.toJson<String>(distanceBucket),
      'bestDurationSeconds': serializer.toJson<int>(bestDurationSeconds),
      'computedAt': serializer.toJson<DateTime>(computedAt),
    };
  }

  AnalyticsBestEffort copyWith({
    int? id,
    int? sessionId,
    String? distanceBucket,
    int? bestDurationSeconds,
    DateTime? computedAt,
  }) => AnalyticsBestEffort(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    distanceBucket: distanceBucket ?? this.distanceBucket,
    bestDurationSeconds: bestDurationSeconds ?? this.bestDurationSeconds,
    computedAt: computedAt ?? this.computedAt,
  );
  AnalyticsBestEffort copyWithCompanion(AnalyticsBestEffortsCompanion data) {
    return AnalyticsBestEffort(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      distanceBucket: data.distanceBucket.present
          ? data.distanceBucket.value
          : this.distanceBucket,
      bestDurationSeconds: data.bestDurationSeconds.present
          ? data.bestDurationSeconds.value
          : this.bestDurationSeconds,
      computedAt: data.computedAt.present
          ? data.computedAt.value
          : this.computedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AnalyticsBestEffort(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('distanceBucket: $distanceBucket, ')
          ..write('bestDurationSeconds: $bestDurationSeconds, ')
          ..write('computedAt: $computedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    distanceBucket,
    bestDurationSeconds,
    computedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AnalyticsBestEffort &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.distanceBucket == this.distanceBucket &&
          other.bestDurationSeconds == this.bestDurationSeconds &&
          other.computedAt == this.computedAt);
}

class AnalyticsBestEffortsCompanion
    extends UpdateCompanion<AnalyticsBestEffort> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<String> distanceBucket;
  final Value<int> bestDurationSeconds;
  final Value<DateTime> computedAt;
  const AnalyticsBestEffortsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.distanceBucket = const Value.absent(),
    this.bestDurationSeconds = const Value.absent(),
    this.computedAt = const Value.absent(),
  });
  AnalyticsBestEffortsCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required String distanceBucket,
    required int bestDurationSeconds,
    required DateTime computedAt,
  }) : sessionId = Value(sessionId),
       distanceBucket = Value(distanceBucket),
       bestDurationSeconds = Value(bestDurationSeconds),
       computedAt = Value(computedAt);
  static Insertable<AnalyticsBestEffort> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<String>? distanceBucket,
    Expression<int>? bestDurationSeconds,
    Expression<DateTime>? computedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (distanceBucket != null) 'distance_bucket': distanceBucket,
      if (bestDurationSeconds != null)
        'best_duration_seconds': bestDurationSeconds,
      if (computedAt != null) 'computed_at': computedAt,
    });
  }

  AnalyticsBestEffortsCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<String>? distanceBucket,
    Value<int>? bestDurationSeconds,
    Value<DateTime>? computedAt,
  }) {
    return AnalyticsBestEffortsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      distanceBucket: distanceBucket ?? this.distanceBucket,
      bestDurationSeconds: bestDurationSeconds ?? this.bestDurationSeconds,
      computedAt: computedAt ?? this.computedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (distanceBucket.present) {
      map['distance_bucket'] = Variable<String>(distanceBucket.value);
    }
    if (bestDurationSeconds.present) {
      map['best_duration_seconds'] = Variable<int>(bestDurationSeconds.value);
    }
    if (computedAt.present) {
      map['computed_at'] = Variable<DateTime>(computedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnalyticsBestEffortsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('distanceBucket: $distanceBucket, ')
          ..write('bestDurationSeconds: $bestDurationSeconds, ')
          ..write('computedAt: $computedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $WorkoutSessionsTable workoutSessions = $WorkoutSessionsTable(
    this,
  );
  late final $WorkoutSamplesTable workoutSamples = $WorkoutSamplesTable(this);
  late final $AnalyticsBestEffortsTable analyticsBestEfforts =
      $AnalyticsBestEffortsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    workoutSessions,
    workoutSamples,
    analyticsBestEfforts,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'workout_sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('workout_samples', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'workout_sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('analytics_best_efforts', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$WorkoutSessionsTableCreateCompanionBuilder =
    WorkoutSessionsCompanion Function({
      Value<int> id,
      required DateTime startTime,
      Value<DateTime?> endTime,
      Value<String> mode,
      Value<double> targetCadence,
      Value<double> avgCadence,
      Value<double> maxCadence,
      Value<double> distanceKm,
      Value<int> durationSeconds,
      Value<int> movingDurationSeconds,
      Value<int> pauseDurationSeconds,
      Value<double?> avgPaceMinPerKm,
      Value<double?> bestPaceMinPerKm,
      Value<int> estimatedCalories,
      Value<int> estimatedSteps,
      Value<String?> routePointsJson,
      Value<String?> splitsJson,
    });
typedef $$WorkoutSessionsTableUpdateCompanionBuilder =
    WorkoutSessionsCompanion Function({
      Value<int> id,
      Value<DateTime> startTime,
      Value<DateTime?> endTime,
      Value<String> mode,
      Value<double> targetCadence,
      Value<double> avgCadence,
      Value<double> maxCadence,
      Value<double> distanceKm,
      Value<int> durationSeconds,
      Value<int> movingDurationSeconds,
      Value<int> pauseDurationSeconds,
      Value<double?> avgPaceMinPerKm,
      Value<double?> bestPaceMinPerKm,
      Value<int> estimatedCalories,
      Value<int> estimatedSteps,
      Value<String?> routePointsJson,
      Value<String?> splitsJson,
    });

final class $$WorkoutSessionsTableReferences
    extends
        BaseReferences<_$AppDatabase, $WorkoutSessionsTable, WorkoutSession> {
  $$WorkoutSessionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$WorkoutSamplesTable, List<WorkoutSample>>
  _workoutSamplesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.workoutSamples,
    aliasName: 'workout_sessions__id__workout_samples__session_id',
  );

  $$WorkoutSamplesTableProcessedTableManager get workoutSamplesRefs {
    final manager = $$WorkoutSamplesTableTableManager(
      $_db,
      $_db.workoutSamples,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_workoutSamplesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $AnalyticsBestEffortsTable,
    List<AnalyticsBestEffort>
  >
  _analyticsBestEffortsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.analyticsBestEfforts,
        aliasName: 'workout_sessions__id__analytics_best_efforts__session_id',
      );

  $$AnalyticsBestEffortsTableProcessedTableManager
  get analyticsBestEffortsRefs {
    final manager = $$AnalyticsBestEffortsTableTableManager(
      $_db,
      $_db.analyticsBestEfforts,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _analyticsBestEffortsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WorkoutSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetCadence => $composableBuilder(
    column: $table.targetCadence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get avgCadence => $composableBuilder(
    column: $table.avgCadence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maxCadence => $composableBuilder(
    column: $table.maxCadence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanceKm => $composableBuilder(
    column: $table.distanceKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get movingDurationSeconds => $composableBuilder(
    column: $table.movingDurationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pauseDurationSeconds => $composableBuilder(
    column: $table.pauseDurationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get avgPaceMinPerKm => $composableBuilder(
    column: $table.avgPaceMinPerKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get bestPaceMinPerKm => $composableBuilder(
    column: $table.bestPaceMinPerKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get estimatedCalories => $composableBuilder(
    column: $table.estimatedCalories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get estimatedSteps => $composableBuilder(
    column: $table.estimatedSteps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get routePointsJson => $composableBuilder(
    column: $table.routePointsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get splitsJson => $composableBuilder(
    column: $table.splitsJson,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> workoutSamplesRefs(
    Expression<bool> Function($$WorkoutSamplesTableFilterComposer f) f,
  ) {
    final $$WorkoutSamplesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutSamples,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSamplesTableFilterComposer(
            $db: $db,
            $table: $db.workoutSamples,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> analyticsBestEffortsRefs(
    Expression<bool> Function($$AnalyticsBestEffortsTableFilterComposer f) f,
  ) {
    final $$AnalyticsBestEffortsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.analyticsBestEfforts,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AnalyticsBestEffortsTableFilterComposer(
            $db: $db,
            $table: $db.analyticsBestEfforts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkoutSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetCadence => $composableBuilder(
    column: $table.targetCadence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get avgCadence => $composableBuilder(
    column: $table.avgCadence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maxCadence => $composableBuilder(
    column: $table.maxCadence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanceKm => $composableBuilder(
    column: $table.distanceKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get movingDurationSeconds => $composableBuilder(
    column: $table.movingDurationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pauseDurationSeconds => $composableBuilder(
    column: $table.pauseDurationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get avgPaceMinPerKm => $composableBuilder(
    column: $table.avgPaceMinPerKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get bestPaceMinPerKm => $composableBuilder(
    column: $table.bestPaceMinPerKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get estimatedCalories => $composableBuilder(
    column: $table.estimatedCalories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get estimatedSteps => $composableBuilder(
    column: $table.estimatedSteps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get routePointsJson => $composableBuilder(
    column: $table.routePointsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get splitsJson => $composableBuilder(
    column: $table.splitsJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkoutSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<DateTime> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<double> get targetCadence => $composableBuilder(
    column: $table.targetCadence,
    builder: (column) => column,
  );

  GeneratedColumn<double> get avgCadence => $composableBuilder(
    column: $table.avgCadence,
    builder: (column) => column,
  );

  GeneratedColumn<double> get maxCadence => $composableBuilder(
    column: $table.maxCadence,
    builder: (column) => column,
  );

  GeneratedColumn<double> get distanceKm => $composableBuilder(
    column: $table.distanceKm,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get movingDurationSeconds => $composableBuilder(
    column: $table.movingDurationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pauseDurationSeconds => $composableBuilder(
    column: $table.pauseDurationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<double> get avgPaceMinPerKm => $composableBuilder(
    column: $table.avgPaceMinPerKm,
    builder: (column) => column,
  );

  GeneratedColumn<double> get bestPaceMinPerKm => $composableBuilder(
    column: $table.bestPaceMinPerKm,
    builder: (column) => column,
  );

  GeneratedColumn<int> get estimatedCalories => $composableBuilder(
    column: $table.estimatedCalories,
    builder: (column) => column,
  );

  GeneratedColumn<int> get estimatedSteps => $composableBuilder(
    column: $table.estimatedSteps,
    builder: (column) => column,
  );

  GeneratedColumn<String> get routePointsJson => $composableBuilder(
    column: $table.routePointsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get splitsJson => $composableBuilder(
    column: $table.splitsJson,
    builder: (column) => column,
  );

  Expression<T> workoutSamplesRefs<T extends Object>(
    Expression<T> Function($$WorkoutSamplesTableAnnotationComposer a) f,
  ) {
    final $$WorkoutSamplesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutSamples,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSamplesTableAnnotationComposer(
            $db: $db,
            $table: $db.workoutSamples,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> analyticsBestEffortsRefs<T extends Object>(
    Expression<T> Function($$AnalyticsBestEffortsTableAnnotationComposer a) f,
  ) {
    final $$AnalyticsBestEffortsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.analyticsBestEfforts,
          getReferencedColumn: (t) => t.sessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AnalyticsBestEffortsTableAnnotationComposer(
                $db: $db,
                $table: $db.analyticsBestEfforts,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$WorkoutSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutSessionsTable,
          WorkoutSession,
          $$WorkoutSessionsTableFilterComposer,
          $$WorkoutSessionsTableOrderingComposer,
          $$WorkoutSessionsTableAnnotationComposer,
          $$WorkoutSessionsTableCreateCompanionBuilder,
          $$WorkoutSessionsTableUpdateCompanionBuilder,
          (WorkoutSession, $$WorkoutSessionsTableReferences),
          WorkoutSession,
          PrefetchHooks Function({
            bool workoutSamplesRefs,
            bool analyticsBestEffortsRefs,
          })
        > {
  $$WorkoutSessionsTableTableManager(
    _$AppDatabase db,
    $WorkoutSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> startTime = const Value.absent(),
                Value<DateTime?> endTime = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<double> targetCadence = const Value.absent(),
                Value<double> avgCadence = const Value.absent(),
                Value<double> maxCadence = const Value.absent(),
                Value<double> distanceKm = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<int> movingDurationSeconds = const Value.absent(),
                Value<int> pauseDurationSeconds = const Value.absent(),
                Value<double?> avgPaceMinPerKm = const Value.absent(),
                Value<double?> bestPaceMinPerKm = const Value.absent(),
                Value<int> estimatedCalories = const Value.absent(),
                Value<int> estimatedSteps = const Value.absent(),
                Value<String?> routePointsJson = const Value.absent(),
                Value<String?> splitsJson = const Value.absent(),
              }) => WorkoutSessionsCompanion(
                id: id,
                startTime: startTime,
                endTime: endTime,
                mode: mode,
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
                routePointsJson: routePointsJson,
                splitsJson: splitsJson,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime startTime,
                Value<DateTime?> endTime = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<double> targetCadence = const Value.absent(),
                Value<double> avgCadence = const Value.absent(),
                Value<double> maxCadence = const Value.absent(),
                Value<double> distanceKm = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<int> movingDurationSeconds = const Value.absent(),
                Value<int> pauseDurationSeconds = const Value.absent(),
                Value<double?> avgPaceMinPerKm = const Value.absent(),
                Value<double?> bestPaceMinPerKm = const Value.absent(),
                Value<int> estimatedCalories = const Value.absent(),
                Value<int> estimatedSteps = const Value.absent(),
                Value<String?> routePointsJson = const Value.absent(),
                Value<String?> splitsJson = const Value.absent(),
              }) => WorkoutSessionsCompanion.insert(
                id: id,
                startTime: startTime,
                endTime: endTime,
                mode: mode,
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
                routePointsJson: routePointsJson,
                splitsJson: splitsJson,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WorkoutSessionsTable, WorkoutSession>(table),
                  $$WorkoutSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({workoutSamplesRefs = false, analyticsBestEffortsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (workoutSamplesRefs) db.workoutSamples,
                    if (analyticsBestEffortsRefs) db.analyticsBestEfforts,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (workoutSamplesRefs)
                        await $_getPrefetchedData<
                          WorkoutSession,
                          $WorkoutSessionsTable,
                          WorkoutSample
                        >(
                          currentTable: table,
                          referencedTable: $$WorkoutSessionsTableReferences
                              ._workoutSamplesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkoutSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).workoutSamplesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (analyticsBestEffortsRefs)
                        await $_getPrefetchedData<
                          WorkoutSession,
                          $WorkoutSessionsTable,
                          AnalyticsBestEffort
                        >(
                          currentTable: table,
                          referencedTable: $$WorkoutSessionsTableReferences
                              ._analyticsBestEffortsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkoutSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).analyticsBestEffortsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$WorkoutSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutSessionsTable,
      WorkoutSession,
      $$WorkoutSessionsTableFilterComposer,
      $$WorkoutSessionsTableOrderingComposer,
      $$WorkoutSessionsTableAnnotationComposer,
      $$WorkoutSessionsTableCreateCompanionBuilder,
      $$WorkoutSessionsTableUpdateCompanionBuilder,
      (WorkoutSession, $$WorkoutSessionsTableReferences),
      WorkoutSession,
      PrefetchHooks Function({
        bool workoutSamplesRefs,
        bool analyticsBestEffortsRefs,
      })
    >;
typedef $$WorkoutSamplesTableCreateCompanionBuilder =
    WorkoutSamplesCompanion Function({
      Value<int> id,
      required int sessionId,
      required DateTime timestamp,
      required double cadence,
      required double speedKmH,
      Value<double?> latitude,
      Value<double?> longitude,
    });
typedef $$WorkoutSamplesTableUpdateCompanionBuilder =
    WorkoutSamplesCompanion Function({
      Value<int> id,
      Value<int> sessionId,
      Value<DateTime> timestamp,
      Value<double> cadence,
      Value<double> speedKmH,
      Value<double?> latitude,
      Value<double?> longitude,
    });

final class $$WorkoutSamplesTableReferences
    extends BaseReferences<_$AppDatabase, $WorkoutSamplesTable, WorkoutSample> {
  $$WorkoutSamplesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkoutSessionsTable _sessionIdTable(_$AppDatabase db) => db
      .workoutSessions
      .createAlias('workout_samples__session_id__workout_sessions__id');

  $$WorkoutSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$WorkoutSessionsTableTableManager(
      $_db,
      $_db.workoutSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WorkoutSamplesTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutSamplesTable> {
  $$WorkoutSamplesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cadence => $composableBuilder(
    column: $table.cadence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get speedKmH => $composableBuilder(
    column: $table.speedKmH,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkoutSessionsTableFilterComposer get sessionId {
    final $$WorkoutSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workoutSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSessionsTableFilterComposer(
            $db: $db,
            $table: $db.workoutSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutSamplesTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutSamplesTable> {
  $$WorkoutSamplesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cadence => $composableBuilder(
    column: $table.cadence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get speedKmH => $composableBuilder(
    column: $table.speedKmH,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkoutSessionsTableOrderingComposer get sessionId {
    final $$WorkoutSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workoutSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.workoutSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutSamplesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutSamplesTable> {
  $$WorkoutSamplesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<double> get cadence =>
      $composableBuilder(column: $table.cadence, builder: (column) => column);

  GeneratedColumn<double> get speedKmH =>
      $composableBuilder(column: $table.speedKmH, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  $$WorkoutSessionsTableAnnotationComposer get sessionId {
    final $$WorkoutSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workoutSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.workoutSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutSamplesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutSamplesTable,
          WorkoutSample,
          $$WorkoutSamplesTableFilterComposer,
          $$WorkoutSamplesTableOrderingComposer,
          $$WorkoutSamplesTableAnnotationComposer,
          $$WorkoutSamplesTableCreateCompanionBuilder,
          $$WorkoutSamplesTableUpdateCompanionBuilder,
          (WorkoutSample, $$WorkoutSamplesTableReferences),
          WorkoutSample,
          PrefetchHooks Function({bool sessionId})
        > {
  $$WorkoutSamplesTableTableManager(
    _$AppDatabase db,
    $WorkoutSamplesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutSamplesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutSamplesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutSamplesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<double> cadence = const Value.absent(),
                Value<double> speedKmH = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
              }) => WorkoutSamplesCompanion(
                id: id,
                sessionId: sessionId,
                timestamp: timestamp,
                cadence: cadence,
                speedKmH: speedKmH,
                latitude: latitude,
                longitude: longitude,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                required DateTime timestamp,
                required double cadence,
                required double speedKmH,
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
              }) => WorkoutSamplesCompanion.insert(
                id: id,
                sessionId: sessionId,
                timestamp: timestamp,
                cadence: cadence,
                speedKmH: speedKmH,
                latitude: latitude,
                longitude: longitude,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WorkoutSamplesTable, WorkoutSample>(table),
                  $$WorkoutSamplesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable: $$WorkoutSamplesTableReferences
                                    ._sessionIdTable(db),
                                referencedColumn:
                                    $$WorkoutSamplesTableReferences
                                        ._sessionIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$WorkoutSamplesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutSamplesTable,
      WorkoutSample,
      $$WorkoutSamplesTableFilterComposer,
      $$WorkoutSamplesTableOrderingComposer,
      $$WorkoutSamplesTableAnnotationComposer,
      $$WorkoutSamplesTableCreateCompanionBuilder,
      $$WorkoutSamplesTableUpdateCompanionBuilder,
      (WorkoutSample, $$WorkoutSamplesTableReferences),
      WorkoutSample,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$AnalyticsBestEffortsTableCreateCompanionBuilder =
    AnalyticsBestEffortsCompanion Function({
      Value<int> id,
      required int sessionId,
      required String distanceBucket,
      required int bestDurationSeconds,
      required DateTime computedAt,
    });
typedef $$AnalyticsBestEffortsTableUpdateCompanionBuilder =
    AnalyticsBestEffortsCompanion Function({
      Value<int> id,
      Value<int> sessionId,
      Value<String> distanceBucket,
      Value<int> bestDurationSeconds,
      Value<DateTime> computedAt,
    });

final class $$AnalyticsBestEffortsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $AnalyticsBestEffortsTable,
          AnalyticsBestEffort
        > {
  $$AnalyticsBestEffortsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkoutSessionsTable _sessionIdTable(_$AppDatabase db) => db
      .workoutSessions
      .createAlias('analytics_best_efforts__session_id__workout_sessions__id');

  $$WorkoutSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$WorkoutSessionsTableTableManager(
      $_db,
      $_db.workoutSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AnalyticsBestEffortsTableFilterComposer
    extends Composer<_$AppDatabase, $AnalyticsBestEffortsTable> {
  $$AnalyticsBestEffortsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get distanceBucket => $composableBuilder(
    column: $table.distanceBucket,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bestDurationSeconds => $composableBuilder(
    column: $table.bestDurationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get computedAt => $composableBuilder(
    column: $table.computedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkoutSessionsTableFilterComposer get sessionId {
    final $$WorkoutSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workoutSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSessionsTableFilterComposer(
            $db: $db,
            $table: $db.workoutSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AnalyticsBestEffortsTableOrderingComposer
    extends Composer<_$AppDatabase, $AnalyticsBestEffortsTable> {
  $$AnalyticsBestEffortsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get distanceBucket => $composableBuilder(
    column: $table.distanceBucket,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bestDurationSeconds => $composableBuilder(
    column: $table.bestDurationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get computedAt => $composableBuilder(
    column: $table.computedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkoutSessionsTableOrderingComposer get sessionId {
    final $$WorkoutSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workoutSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.workoutSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AnalyticsBestEffortsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AnalyticsBestEffortsTable> {
  $$AnalyticsBestEffortsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get distanceBucket => $composableBuilder(
    column: $table.distanceBucket,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bestDurationSeconds => $composableBuilder(
    column: $table.bestDurationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get computedAt => $composableBuilder(
    column: $table.computedAt,
    builder: (column) => column,
  );

  $$WorkoutSessionsTableAnnotationComposer get sessionId {
    final $$WorkoutSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workoutSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.workoutSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AnalyticsBestEffortsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AnalyticsBestEffortsTable,
          AnalyticsBestEffort,
          $$AnalyticsBestEffortsTableFilterComposer,
          $$AnalyticsBestEffortsTableOrderingComposer,
          $$AnalyticsBestEffortsTableAnnotationComposer,
          $$AnalyticsBestEffortsTableCreateCompanionBuilder,
          $$AnalyticsBestEffortsTableUpdateCompanionBuilder,
          (AnalyticsBestEffort, $$AnalyticsBestEffortsTableReferences),
          AnalyticsBestEffort,
          PrefetchHooks Function({bool sessionId})
        > {
  $$AnalyticsBestEffortsTableTableManager(
    _$AppDatabase db,
    $AnalyticsBestEffortsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AnalyticsBestEffortsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AnalyticsBestEffortsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$AnalyticsBestEffortsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<String> distanceBucket = const Value.absent(),
                Value<int> bestDurationSeconds = const Value.absent(),
                Value<DateTime> computedAt = const Value.absent(),
              }) => AnalyticsBestEffortsCompanion(
                id: id,
                sessionId: sessionId,
                distanceBucket: distanceBucket,
                bestDurationSeconds: bestDurationSeconds,
                computedAt: computedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                required String distanceBucket,
                required int bestDurationSeconds,
                required DateTime computedAt,
              }) => AnalyticsBestEffortsCompanion.insert(
                id: id,
                sessionId: sessionId,
                distanceBucket: distanceBucket,
                bestDurationSeconds: bestDurationSeconds,
                computedAt: computedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AnalyticsBestEffortsTable, AnalyticsBestEffort>(
                    table,
                  ),
                  $$AnalyticsBestEffortsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable:
                                    $$AnalyticsBestEffortsTableReferences
                                        ._sessionIdTable(db),
                                referencedColumn:
                                    $$AnalyticsBestEffortsTableReferences
                                        ._sessionIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AnalyticsBestEffortsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AnalyticsBestEffortsTable,
      AnalyticsBestEffort,
      $$AnalyticsBestEffortsTableFilterComposer,
      $$AnalyticsBestEffortsTableOrderingComposer,
      $$AnalyticsBestEffortsTableAnnotationComposer,
      $$AnalyticsBestEffortsTableCreateCompanionBuilder,
      $$AnalyticsBestEffortsTableUpdateCompanionBuilder,
      (AnalyticsBestEffort, $$AnalyticsBestEffortsTableReferences),
      AnalyticsBestEffort,
      PrefetchHooks Function({bool sessionId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$WorkoutSessionsTableTableManager get workoutSessions =>
      $$WorkoutSessionsTableTableManager(_db, _db.workoutSessions);
  $$WorkoutSamplesTableTableManager get workoutSamples =>
      $$WorkoutSamplesTableTableManager(_db, _db.workoutSamples);
  $$AnalyticsBestEffortsTableTableManager get analyticsBestEfforts =>
      $$AnalyticsBestEffortsTableTableManager(_db, _db.analyticsBestEfforts);
}
