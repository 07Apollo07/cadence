class KmSplit {
  final int kilometer;
  final int durationSeconds;
  final double avgSpeedKmH;
  final double avgPaceMinPerKm;
  final double avgCadence;

  const KmSplit({
    required this.kilometer,
    required this.durationSeconds,
    required this.avgSpeedKmH,
    required this.avgPaceMinPerKm,
    required this.avgCadence,
  });

  String get paceFormatted {
    final mins = avgPaceMinPerKm.floor();
    final secs = ((avgPaceMinPerKm - mins) * 60).round();
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }

  String get timeFormatted {
    final mins = durationSeconds ~/ 60;
    final secs = durationSeconds % 60;
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() => {
    'km': kilometer,
    'dur': durationSeconds,
    'speed': avgSpeedKmH,
    'pace': avgPaceMinPerKm,
    'cadence': avgCadence,
  };

  factory KmSplit.fromJson(Map<String, dynamic> json) => KmSplit(
    kilometer: json['km'] as int,
    durationSeconds: json['dur'] as int,
    avgSpeedKmH: (json['speed'] as num).toDouble(),
    avgPaceMinPerKm: (json['pace'] as num).toDouble(),
    avgCadence: (json['cadence'] as num).toDouble(),
  );
}