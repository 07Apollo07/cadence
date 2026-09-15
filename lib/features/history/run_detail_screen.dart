import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/app_database.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/cadence_provider.dart';
import 'models/gps_track_point.dart';
import 'models/km_split.dart';
import 'repositories/gps_session_repository.dart';

enum TrackGraphType { pace, cadence, stride, speed }

class RunDetailScreen extends ConsumerStatefulWidget {
  final WorkoutSession session;

  const RunDetailScreen({super.key, required this.session});

  @override
  ConsumerState<RunDetailScreen> createState() => _RunDetailScreenState();
}

class _RunDetailScreenState extends ConsumerState<RunDetailScreen> {
  final MapController _mapController = MapController();

  // Animation playback state
  bool _isPlayingAnimation = false;
  double _animationProgress = 0.0; // 0.0 to 1.0
  double _playbackSpeedMultiplier = 1.0;
  Timer? _animationTimer;

  List<GpsTrackPoint> _points = [];
  List<KmSplit> _splits = [];
  TrackGraphType _selectedGraphType = TrackGraphType.pace;

  @override
  void initState() {
    super.initState();
    _parseJsonData();
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    super.dispose();
  }

  void _parseJsonData() {
    try {
      if (widget.session.routePointsJson != null &&
          widget.session.routePointsJson!.isNotEmpty) {
        final list = jsonDecode(widget.session.routePointsJson!) as List;
        _points = list
            .map((e) => GpsTrackPoint.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}

    try {
      if (widget.session.splitsJson != null &&
          widget.session.splitsJson!.isNotEmpty) {
        final list = jsonDecode(widget.session.splitsJson!) as List;
        _splits = list
            .map((e) => KmSplit.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
  }

  void _togglePlayback() {
    if (_points.isEmpty) return;
    if (_isPlayingAnimation) {
      _stopPlayback();
    } else {
      _startPlayback();
    }
  }

  void _startPlayback() {
    if (_animationProgress >= 1.0) {
      _animationProgress = 0.0;
    }
    setState(() {
      _isPlayingAnimation = true;
    });

    const fps = 30;
    final totalDurationMs = widget.session.movingDurationSeconds > 0
        ? widget.session.movingDurationSeconds * 1000
        : (_points.length * 500);

    final intervalMs = (1000 ~/ fps);
    final incrementPerTick =
        (intervalMs / totalDurationMs) * _playbackSpeedMultiplier;

    _animationTimer = Timer.periodic(Duration(milliseconds: intervalMs), (
      timer,
    ) {
      setState(() {
        _animationProgress += incrementPerTick;
        if (_animationProgress >= 1.0) {
          _animationProgress = 1.0;
          _stopPlayback();
        } else {
          if (_points.isNotEmpty) {
            final idx = (_animationProgress * (_points.length - 1)).round();
            final pt = _points[idx];
            _mapController.move(
              LatLng(pt.latitude, pt.longitude),
              _mapController.camera.zoom,
            );
          }
        }
      });
    });
  }

  void _stopPlayback() {
    _animationTimer?.cancel();
    _animationTimer = null;
    setState(() {
      _isPlayingAnimation = false;
    });
  }

  void _onGraphScrub(Offset localPosition, double graphWidth) {
    if (graphWidth <= 0 || _points.isEmpty) return;
    if (_isPlayingAnimation) _stopPlayback();

    const leftPad = 44.0;
    const rightPad = 16.0;
    final chartWidth = graphWidth - leftPad - rightPad;
    if (chartWidth <= 0) return;

    final relativeX = (localPosition.dx - leftPad).clamp(0.0, chartWidth);
    final progress = (relativeX / chartWidth).clamp(0.0, 1.0);

    setState(() {
      _animationProgress = progress;
      final idx = (_animationProgress * (_points.length - 1)).round();
      final pt = _points[idx];
      _mapController.move(
        LatLng(pt.latitude, pt.longitude),
        _mapController.camera.zoom,
      );
    });
  }

  String get _graphTitle {
    switch (_selectedGraphType) {
      case TrackGraphType.pace:
        return 'Pace Profile';
      case TrackGraphType.cadence:
        return 'Cadence Profile';
      case TrackGraphType.stride:
        return 'Stride Length';
      case TrackGraphType.speed:
        return 'Speed Profile';
    }
  }

  Widget _buildGraphTab(String label, TrackGraphType type, Color activeColor) {
    final isSelected = _selectedGraphType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedGraphType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceRaised : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? activeColor : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) {
      return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime dt) {
    return '${dt.month}/${dt.day}/${dt.year} • ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  List<Marker> _buildMapMarkers(
    List<LatLng> allLatLngs,
    LatLng currentAnimatedPoint,
  ) {
    final markers = <Marker>[];
    if (allLatLngs.isEmpty) return markers;

    // Start Marker
    markers.add(
      Marker(
        point: allLatLngs.first,
        width: 30,
        height: 30,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.green.shade600,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 4)],
          ),
          child: const Icon(Icons.play_arrow, size: 18, color: Colors.white),
        ),
      ),
    );

    // Finish Marker
    if (allLatLngs.length > 1) {
      markers.add(
        Marker(
          point: allLatLngs.last,
          width: 30,
          height: 30,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.statusDanger,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: const [
                BoxShadow(color: Colors.black38, blurRadius: 4),
              ],
            ),
            child: const Icon(Icons.flag, size: 16, color: Colors.white),
          ),
        ),
      );
    }

    // 1 KM Split Markers
    for (final split in _splits) {
      final targetDist = split.kilometer.toDouble();
      GpsTrackPoint? closestPt;
      double minDiff = 999999;
      for (final pt in _points) {
        final diff = (pt.distanceFromStartKm - targetDist).abs();
        if (diff < minDiff) {
          minDiff = diff;
          closestPt = pt;
        }
      }
      if (closestPt != null && minDiff < 0.3) {
        markers.add(
          Marker(
            point: closestPt.latLng,
            width: 24,
            height: 24,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfacePanel,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.traceCalm, width: 2.0),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 2),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                '${split.kilometer}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }
    }

    // Active Runner Marker
    if (_animationProgress > 0.0) {
      markers.add(
        Marker(
          point: currentAnimatedPoint,
          width: 34,
          height: 34,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.traceCalm,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: const [
                BoxShadow(color: Colors.black38, blurRadius: 6),
              ],
            ),
            child: const Icon(
              Icons.directions_run,
              size: 18,
              color: Colors.black,
            ),
          ),
        ),
      );
    }

    return markers;
  }

  Widget _buildMovementModeBreakdown() {
    if (_points.isEmpty) return const SizedBox.shrink();

    int walking = 0;
    int jogging = 0;
    int running = 0;
    for (final p in _points) {
      if (p.movementMode == MovementMode.walking) {
        walking++;
      } else if (p.movementMode == MovementMode.jogging) {
        jogging++;
      } else if (p.movementMode == MovementMode.running) {
        running++;
      }
    }
    final total = _points.length;
    if (total == 0) return const SizedBox.shrink();

    final walkPct = (walking / total * 100).round();
    final jogPct = (jogging / total * 100).round();
    final runPct = (running / total * 100).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfacePanel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Movement Mode Breakdown',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Row(
              children: [
                if (walking > 0)
                  Expanded(
                    flex: walking,
                    child: Container(height: 10, color: Colors.blue.shade400),
                  ),
                if (jogging > 0)
                  Expanded(
                    flex: jogging,
                    child: Container(height: 10, color: AppColors.traceCalm),
                  ),
                if (running > 0)
                  Expanded(
                    flex: running,
                    child: Container(height: 10, color: Colors.orange.shade400),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _modeLegendItem('Walking', '$walkPct%', Colors.blue.shade400),
              _modeLegendItem('Jogging', '$jogPct%', AppColors.traceCalm),
              _modeLegendItem('Running', '$runPct%', Colors.orange.shade400),
            ],
          ),
        ],
      ),
    );
  }

  Widget _modeLegendItem(String label, String pct, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          '$label ($pct)',
          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.session;
    final allLatLngs = _points
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList();

    final hasValidBounds =
        allLatLngs.length >= 2 &&
        allLatLngs.any(
          (p) =>
              p.latitude != allLatLngs.first.latitude ||
              p.longitude != allLatLngs.first.longitude,
        );

    final animatedCount = _points.isEmpty
        ? 0
        : (_animationProgress * _points.length).ceil().clamp(1, _points.length);
    final visibleLatLngs = allLatLngs.isEmpty
        ? <LatLng>[]
        : allLatLngs.sublist(0, animatedCount);

    final currentAnimatedPoint = visibleLatLngs.isNotEmpty
        ? visibleLatLngs.last
        : (allLatLngs.isNotEmpty
              ? allLatLngs.first
              : const LatLng(37.7749, -122.4194));

    final idleSeconds =
        (s.durationSeconds - s.movingDurationSeconds - s.pauseDurationSeconds)
            .clamp(0, 999999);

    final avgSpeed = s.movingDurationSeconds > 0
        ? (s.distanceKm / (s.movingDurationSeconds / 3600.0))
        : 0.0;

    double maxSpeed = 0.0;
    if (_points.isNotEmpty) {
      maxSpeed = _points.map((p) => p.speedKmH).reduce((a, b) => a > b ? a : b);
    } else {
      maxSpeed = avgSpeed;
    }

    KmSplit? fastestSplit;
    KmSplit? slowestSplit;
    if (_splits.isNotEmpty) {
      fastestSplit = _splits.reduce(
        (a, b) => a.avgPaceMinPerKm < b.avgPaceMinPerKm ? a : b,
      );
      slowestSplit = _splits.reduce(
        (a, b) => a.avgPaceMinPerKm > b.avgPaceMinPerKm ? a : b,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      appBar: AppBar(
        title: Text('Run Details • ${_formatDate(s.startTime)}'),
        backgroundColor: AppColors.surfacePanel,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.statusDanger),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppColors.surfacePanel,
                  title: const Text(
                    'Delete Workout',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  content: const Text(
                    'Are you sure you want to delete this recorded run?',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: AppColors.statusDanger),
                      ),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await ref
                    .read(gpsSessionRepositoryProvider)
                    .deleteSession(s.id);
                if (context.mounted) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Map Header (pinned at top)
          SizedBox(
            height: 260,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCameraFit: hasValidBounds
                        ? CameraFit.bounds(
                            bounds: LatLngBounds.fromPoints(allLatLngs),
                            padding: const EdgeInsets.all(36.0),
                            maxZoom: 16.5,
                          )
                        : null,
                    initialCenter: allLatLngs.isNotEmpty
                        ? allLatLngs.first
                        : const LatLng(37.7749, -122.4194),
                    initialZoom: 15.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.cadence.app',
                    ),
                    if (allLatLngs.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: allLatLngs,
                            color: AppColors.textMuted.withValues(alpha: 0.35),
                            strokeWidth: 4.0,
                          ),
                          if (visibleLatLngs.isNotEmpty)
                            Polyline(
                              points: visibleLatLngs,
                              color: AppColors.traceCalm,
                              strokeWidth: 6.0,
                            ),
                        ],
                      ),
                    MarkerLayer(
                      markers: _buildMapMarkers(
                        allLatLngs,
                        currentAnimatedPoint,
                      ),
                    ),
                  ],
                ),
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton.small(
                        heroTag: 'detail_zoom_in',
                        backgroundColor: AppColors.surfacePanel,
                        foregroundColor: AppColors.textPrimary,
                        onPressed: () {
                          final currentZoom = _mapController.camera.zoom;
                          _mapController.move(
                            _mapController.camera.center,
                            currentZoom + 1,
                          );
                        },
                        child: const Icon(Icons.add),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton.small(
                        heroTag: 'detail_zoom_out',
                        backgroundColor: AppColors.surfacePanel,
                        foregroundColor: AppColors.textPrimary,
                        onPressed: () {
                          final currentZoom = _mapController.camera.zoom;
                          _mapController.move(
                            _mapController.camera.center,
                            currentZoom - 1,
                          );
                        },
                        child: const Icon(Icons.remove),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton.small(
                        heroTag: 'detail_recenter',
                        backgroundColor: AppColors.surfacePanel,
                        foregroundColor: AppColors.traceCalm,
                        onPressed: () {
                          final target = visibleLatLngs.isNotEmpty
                              ? visibleLatLngs.last
                              : (allLatLngs.isNotEmpty
                                    ? allLatLngs.first
                                    : const LatLng(37.7749, -122.4194));
                          _mapController.move(target, 15.0);
                        },
                        child: const Icon(Icons.my_location),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton.small(
                        heroTag: 'detail_fit_bounds',
                        backgroundColor: AppColors.surfacePanel,
                        foregroundColor: AppColors.traceCalm,
                        onPressed: () {
                          if (hasValidBounds) {
                            _mapController.fitCamera(
                              CameraFit.bounds(
                                bounds: LatLngBounds.fromPoints(allLatLngs),
                                padding: const EdgeInsets.all(36.0),
                                maxZoom: 16.5,
                              ),
                            );
                          } else if (allLatLngs.isNotEmpty) {
                            _mapController.move(allLatLngs.first, 15.0);
                          }
                        },
                        child: const Icon(Icons.center_focus_strong),
                      ),
                    ],
                  ),
                ),
                // Map Controls (Rotation)
                Positioned(
                  left: 16,
                  bottom: 16,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton.small(
                        heroTag: 'detail_rotate_left',
                        backgroundColor: AppColors.surfacePanel,
                        foregroundColor: AppColors.textPrimary,
                        onPressed: () {
                          final currentRotation =
                              _mapController.camera.rotation;
                          _mapController.rotate(currentRotation - 15);
                        },
                        child: const Icon(Icons.rotate_left),
                      ),
                      const SizedBox(width: 8),
                      FloatingActionButton.small(
                        heroTag: 'detail_reset_north',
                        backgroundColor: AppColors.surfacePanel,
                        foregroundColor: AppColors.traceCalm,
                        onPressed: () {
                          _mapController.rotate(0.0);
                        },
                        child: const Icon(Icons.explore),
                      ),
                      const SizedBox(width: 8),
                      FloatingActionButton.small(
                        heroTag: 'detail_rotate_right',
                        backgroundColor: AppColors.surfacePanel,
                        foregroundColor: AppColors.textPrimary,
                        onPressed: () {
                          final currentRotation =
                              _mapController.camera.rotation;
                          _mapController.rotate(currentRotation + 15);
                        },
                        child: const Icon(Icons.rotate_right),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfacePanel.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.hairline),
                    ),
                    child: const Text(
                      '© OpenStreetMap contributors',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (_points.isNotEmpty)
            Container(
              color: AppColors.surfacePanel,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _isPlayingAnimation
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      color: AppColors.traceCalm,
                      size: 32,
                    ),
                    onPressed: _togglePlayback,
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.traceCalm,
                        thumbColor: AppColors.traceCalm,
                        trackHeight: 3,
                      ),
                      child: Slider(
                        value: _animationProgress,
                        onChanged: (val) {
                          if (_isPlayingAnimation) _stopPlayback();
                          setState(() {
                            _animationProgress = val;
                            final idx =
                                (_animationProgress * (_points.length - 1))
                                    .round();
                            final pt = _points[idx];
                            _mapController.move(
                              LatLng(pt.latitude, pt.longitude),
                              _mapController.camera.zoom,
                            );
                          });
                        },
                      ),
                    ),
                  ),
                  PopupMenuButton<double>(
                    initialValue: _playbackSpeedMultiplier,
                    onSelected: (speed) {
                      setState(() {
                        _playbackSpeedMultiplier = speed;
                      });
                      if (_isPlayingAnimation) {
                        _stopPlayback();
                        _startPlayback();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceRaised,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${_playbackSpeedMultiplier.toStringAsFixed(_playbackSpeedMultiplier.truncateToDouble() == _playbackSpeedMultiplier ? 0 : 1)}x',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 0.5, child: Text('0.5x speed')),
                      PopupMenuItem(value: 1.0, child: Text('1x speed')),
                      PopupMenuItem(value: 2.0, child: Text('2x speed')),
                      PopupMenuItem(value: 5.0, child: Text('5x speed')),
                      PopupMenuItem(value: 10.0, child: Text('10x speed')),
                    ],
                  ),
                ],
              ),
            ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main Metrics Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Moving Time',
                          _formatDuration(s.movingDurationSeconds),
                          '',
                          Icons.timer,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          'Idle Time',
                          _formatDuration(idleSeconds),
                          '',
                          Icons.timer_outlined,
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          'Pause Time',
                          _formatDuration(s.pauseDurationSeconds),
                          '',
                          Icons.pause_circle,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Distance',
                          s.distanceKm.toStringAsFixed(2),
                          'km',
                          Icons.map,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          'Total Time',
                          _formatDuration(s.durationSeconds),
                          '',
                          Icons.access_time,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          'Steps',
                          '${s.estimatedSteps}',
                          'steps',
                          Icons.directions_walk,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Avg Pace',
                          s.avgPaceMinPerKm?.toStringAsFixed(1) ?? '--',
                          'min/km',
                          Icons.speed,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          'Avg Cadence',
                          s.avgCadence.toStringAsFixed(0),
                          'SPM',
                          Icons.bolt,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          'Avg Speed',
                          avgSpeed.toStringAsFixed(1),
                          'km/h',
                          Icons.directions_run,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Max Pace',
                          s.bestPaceMinPerKm?.toStringAsFixed(1) ?? '--',
                          'min/km',
                          Icons.history,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          'Max Cadence',
                          s.maxCadence.toStringAsFixed(0),
                          'SPM',
                          Icons.flash_on,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          'Max Speed',
                          maxSpeed.toStringAsFixed(1),
                          'km/h',
                          Icons.speed,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Avg Stride',
                          (_points.isNotEmpty
                                  ? (_points
                                            .map((p) => p.strideLengthMeters)
                                            .reduce((a, b) => a + b) /
                                        _points.length)
                                  : 0.75)
                              .toStringAsFixed(2),
                          'm',
                          Icons.straighten,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(child: SizedBox()),
                      const SizedBox(width: 8),
                      const Expanded(child: SizedBox()),
                    ],
                  ),

                  const SizedBox(height: 24),
                  _buildMovementModeBreakdown(),

                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _graphTitle,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          _buildGraphTab(
                            'Pace',
                            TrackGraphType.pace,
                            AppColors.traceCalm,
                          ),
                          const SizedBox(width: 4),
                          _buildGraphTab(
                            'Cadence',
                            TrackGraphType.cadence,
                            Colors.orangeAccent,
                          ),
                          const SizedBox(width: 4),
                          _buildGraphTab(
                            'Stride',
                            TrackGraphType.stride,
                            const Color(0xFFC084FC),
                          ),
                          const SizedBox(width: 4),
                          _buildGraphTab(
                            'Speed',
                            TrackGraphType.speed,
                            const Color(0xFF38BDF8),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      return GestureDetector(
                        onPanDown: (details) => _onGraphScrub(
                          details.localPosition,
                          constraints.maxWidth,
                        ),
                        onPanUpdate: (details) => _onGraphScrub(
                          details.localPosition,
                          constraints.maxWidth,
                        ),
                        onTapDown: (details) => _onGraphScrub(
                          details.localPosition,
                          constraints.maxWidth,
                        ),
                        child: Container(
                          height: 190,
                          decoration: BoxDecoration(
                            color: AppColors.surfacePanel,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.hairline),
                          ),
                          child: _points.length < 2
                              ? const Center(
                                  child: Text(
                                    'Not enough points for graph',
                                    style: TextStyle(
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                )
                              : CustomPaint(
                                  size: Size(constraints.maxWidth, 190),
                                  painter: _WorkoutGraphPainter(
                                    points: _points,
                                    animationProgress: _animationProgress,
                                    graphType: _selectedGraphType,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                  if (_points.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 4, left: 4),
                      child: Text(
                        'Tap or drag on graph to scrub route on map',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),
                  const Text(
                    '1 KM Splits Breakdown',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _splits.isEmpty
                      ? const Text(
                          'No splits recorded.',
                          style: TextStyle(color: AppColors.textMuted),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: AppColors.surfacePanel,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.hairline),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _splits.length,
                            separatorBuilder: (context, index) => const Divider(
                              color: AppColors.hairline,
                              height: 1,
                            ),
                            itemBuilder: (context, idx) {
                              final split = _splits[idx];
                              final isFastest = split == fastestSplit;
                              final isSlowest =
                                  split == slowestSplit && _splits.length > 1;

                              double barFactor = 1.0;
                              if (fastestSplit != null &&
                                  slowestSplit != null) {
                                final minP = fastestSplit.avgPaceMinPerKm;
                                final maxP = slowestSplit.avgPaceMinPerKm;
                                if (maxP > minP) {
                                  barFactor =
                                      1.0 -
                                      ((split.avgPaceMinPerKm - minP) /
                                          (maxP - minP) *
                                          0.7);
                                  barFactor = barFactor.clamp(0.2, 1.0);
                                }
                              }

                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 16,
                                          backgroundColor:
                                              AppColors.surfaceRaised,
                                          child: Text(
                                            '${split.kilometer}',
                                            style: const TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    'Pace: ${split.paceFormatted} /km',
                                                    style: const TextStyle(
                                                      color:
                                                          AppColors.textPrimary,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  if (isFastest) ...[
                                                    const SizedBox(width: 8),
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 6,
                                                            vertical: 2,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors
                                                            .green
                                                            .shade900
                                                            .withValues(
                                                              alpha: 0.6,
                                                            ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              4,
                                                            ),
                                                        border: Border.all(
                                                          color: Colors
                                                              .green
                                                              .shade400,
                                                          width: 0.8,
                                                        ),
                                                      ),
                                                      child: Text(
                                                        'FASTEST',
                                                        style: TextStyle(
                                                          color: Colors
                                                              .green
                                                              .shade300,
                                                          fontSize: 9,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ] else if (isSlowest) ...[
                                                    const SizedBox(width: 8),
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 6,
                                                            vertical: 2,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors
                                                            .amber
                                                            .shade900
                                                            .withValues(
                                                              alpha: 0.6,
                                                            ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              4,
                                                            ),
                                                        border: Border.all(
                                                          color: Colors
                                                              .amber
                                                              .shade400,
                                                          width: 0.8,
                                                        ),
                                                      ),
                                                      child: Text(
                                                        'SLOWEST',
                                                        style: TextStyle(
                                                          color: Colors
                                                              .amber
                                                              .shade300,
                                                          fontSize: 9,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'Time: ${split.timeFormatted} • Cadence: ${split.avgCadence.toStringAsFixed(0)} SPM',
                                                style: const TextStyle(
                                                  color: AppColors.textMuted,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          '${split.avgSpeedKmH.toStringAsFixed(1)} km/h',
                                          style: const TextStyle(
                                            color: AppColors.traceCalm,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(2),
                                      child: LinearProgressIndicator(
                                        value: barFactor,
                                        minHeight: 4,
                                        backgroundColor:
                                            AppColors.surfaceRaised,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              isFastest
                                                  ? Colors.green.shade400
                                                  : (isSlowest
                                                        ? Colors.amber.shade400
                                                        : AppColors.traceCalm),
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    String unit,
    IconData icon, {
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfacePanel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color ?? AppColors.textMuted),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color ?? AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 2),
                Text(
                  unit,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _WorkoutGraphPainter extends CustomPainter {
  final List<GpsTrackPoint> points;
  final double animationProgress;
  final TrackGraphType graphType;

  _WorkoutGraphPainter({
    required this.points,
    required this.animationProgress,
    required this.graphType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    const leftPadding = 44.0;
    const rightPadding = 16.0;
    const topPadding = 18.0;
    const bottomPadding = 24.0;

    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - topPadding - bottomPadding;

    if (chartWidth <= 0 || chartHeight <= 0) return;

    // 1. Extract values & configuration based on graphType
    final values = <double>[];
    Color themeColor;
    final bool isPace = graphType == TrackGraphType.pace;

    switch (graphType) {
      case TrackGraphType.pace:
        themeColor = AppColors.traceCalm;
        for (final p in points) {
          final pace = p.speedKmH > 0.5 ? (60.0 / p.speedKmH) : 15.0;
          values.add(pace.clamp(2.0, 15.0));
        }
        break;
      case TrackGraphType.cadence:
        themeColor = Colors.orangeAccent;
        for (final p in points) {
          values.add(p.cadenceSpm);
        }
        break;
      case TrackGraphType.stride:
        themeColor = const Color(0xFFC084FC); // Purple
        for (final p in points) {
          values.add(p.strideLengthMeters);
        }
        break;
      case TrackGraphType.speed:
        themeColor = const Color(0xFF38BDF8); // Cyan
        for (final p in points) {
          values.add(p.speedKmH);
        }
        break;
    }

    double minVal = values.reduce((a, b) => a < b ? a : b);
    double maxVal = values.reduce((a, b) => a > b ? a : b);

    // Provide baseline cushion if values are uniform/flat
    switch (graphType) {
      case TrackGraphType.pace:
        if ((maxVal - minVal) < 1.0) {
          minVal = (minVal - 0.5).clamp(2.0, 15.0);
          maxVal = (maxVal + 0.5).clamp(2.0, 15.0);
        }
        break;
      case TrackGraphType.cadence:
        if ((maxVal - minVal) < 10.0) {
          minVal = (minVal - 10).clamp(40.0, 240.0);
          maxVal = (maxVal + 10).clamp(40.0, 240.0);
        }
        break;
      case TrackGraphType.stride:
        if ((maxVal - minVal) < 0.2) {
          minVal = (minVal - 0.1).clamp(0.2, 3.0);
          maxVal = (maxVal + 0.1).clamp(0.2, 3.0);
        }
        break;
      case TrackGraphType.speed:
        if ((maxVal - minVal) < 2.0) {
          minVal = (minVal - 1.0).clamp(0.0, 50.0);
          maxVal = (maxVal + 1.0).clamp(0.0, 50.0);
        }
        break;
    }

    final range = maxVal - minVal;
    if (range <= 0) return;

    final gridPaint = Paint()
      ..color = AppColors.hairline
      ..strokeWidth = 1.0;

    final subGridPaint = Paint()
      ..color = AppColors.hairline.withValues(alpha: 0.5)
      ..strokeWidth = 0.8;

    const labelStyle = TextStyle(
      color: AppColors.textMuted,
      fontSize: 9,
      fontWeight: FontWeight.w500,
    );

    // 2. Y-Axis: 3 horizontal reference lines & right-aligned labels
    void drawYLine(double y, double val) {
      final text = _formatValue(val, graphType, includeUnit: true);
      final textPainter = TextPainter(
        text: TextSpan(text: text, style: labelStyle),
        textAlign: TextAlign.right,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: leftPadding - 6);

      textPainter.paint(canvas, Offset(0, y - (textPainter.height / 2)));
      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(size.width - rightPadding, y),
        y == topPadding || y == topPadding + chartHeight
            ? gridPaint
            : subGridPaint,
      );
    }

    final topVal = isPace ? minVal : maxVal;
    final midVal = (minVal + maxVal) / 2;
    final bottomVal = isPace ? maxVal : minVal;

    drawYLine(topPadding, topVal);
    drawYLine(topPadding + (chartHeight / 2), midVal);
    drawYLine(topPadding + chartHeight, bottomVal);

    // 3. X-Axis: Distance ticks and vertical guidelines
    final totalDistKm = points.last.distanceFromStartKm > 0
        ? points.last.distanceFromStartKm
        : (points.length * 0.01);

    const tickFractions = [0.0, 0.25, 0.5, 0.75, 1.0];
    for (final f in tickFractions) {
      final x = leftPadding + (f * chartWidth);

      // Intermediate vertical guide line
      if (f > 0.0 && f < 1.0) {
        final vGridPaint = Paint()
          ..color = AppColors.hairline.withValues(alpha: 0.3)
          ..strokeWidth = 0.8;
        canvas.drawLine(
          Offset(x, topPadding),
          Offset(x, topPadding + chartHeight),
          vGridPaint,
        );
      }

      // Small tick mark below axis
      canvas.drawLine(
        Offset(x, topPadding + chartHeight),
        Offset(x, topPadding + chartHeight + 3),
        gridPaint,
      );

      // Distance label
      final distText = '${(totalDistKm * f).toStringAsFixed(1)}k';
      final xPainter = TextPainter(
        text: TextSpan(text: distText, style: labelStyle),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();

      double textX = x - (xPainter.width / 2);
      if (f == 0.0) textX = leftPadding;
      if (f == 1.0) textX = size.width - rightPadding - xPainter.width;

      xPainter.paint(canvas, Offset(textX, topPadding + chartHeight + 5));
    }

    // 4. Data curve path & area fill
    final path = ui.Path();
    final fillPath = ui.Path();
    final pointsCount = points.length;

    for (int i = 0; i < pointsCount; i++) {
      final x = leftPadding + (i / (pointsCount - 1)) * chartWidth;
      final norm = isPace
          ? (values[i] - minVal) / range
          : 1.0 - ((values[i] - minVal) / range);
      final y = topPadding + (norm * chartHeight);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, topPadding + chartHeight);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(leftPadding + chartWidth, topPadding + chartHeight);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, topPadding),
        Offset(0, topPadding + chartHeight),
        [
          themeColor.withValues(alpha: 0.32),
          themeColor.withValues(alpha: 0.02),
        ],
      );
    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = themeColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, linePaint);

    // 5. Vertical Scrubber line, indicator dot, and floating HUD tooltip
    if (animationProgress > 0.0) {
      final activeIdx = (animationProgress * (pointsCount - 1)).round().clamp(
        0,
        pointsCount - 1,
      );
      final activePoint = points[activeIdx];
      final activeVal = values[activeIdx];
      final activeX =
          leftPadding + (activeIdx / (pointsCount - 1)) * chartWidth;
      final activeNorm = isPace
          ? (activeVal - minVal) / range
          : 1.0 - ((activeVal - minVal) / range);
      final activeY = topPadding + (activeNorm * chartHeight);

      // Scrubber vertical line
      final scrubberPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.85)
        ..strokeWidth = 1.5;
      canvas.drawLine(
        Offset(activeX, topPadding),
        Offset(activeX, topPadding + chartHeight),
        scrubberPaint,
      );

      // Scrubber point circle
      final dotOuterPaint = Paint()..color = Colors.white;
      final dotInnerPaint = Paint()..color = themeColor;
      canvas.drawCircle(Offset(activeX, activeY), 5.5, dotOuterPaint);
      canvas.drawCircle(Offset(activeX, activeY), 3.5, dotInnerPaint);

      // Floating HUD Tooltip Badge
      final primaryText = _formatValue(activeVal, graphType, includeUnit: true);
      final secondaryText =
          '${activePoint.distanceFromStartKm.toStringAsFixed(2)} km';

      final tooltipValPainter = TextPainter(
        text: TextSpan(
          text: primaryText,
          style: TextStyle(
            color: themeColor,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final tooltipDistPainter = TextPainter(
        text: TextSpan(
          text: secondaryText,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 9,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final badgeW =
          (tooltipValPainter.width > tooltipDistPainter.width
              ? tooltipValPainter.width
              : tooltipDistPainter.width) +
          16.0;
      const badgeH = 34.0;

      // Position tooltip horizontally centered on activeX, clamped within bounds
      double badgeX = activeX - (badgeW / 2);
      if (badgeX < leftPadding) badgeX = leftPadding;
      if (badgeX + badgeW > size.width - rightPadding) {
        badgeX = size.width - rightPadding - badgeW;
      }

      // Position tooltip above the point if room, else below
      double badgeY = activeY - badgeH - 8;
      if (badgeY < topPadding) {
        badgeY = activeY + 10;
      }

      final badgeRect = Rect.fromLTWH(badgeX, badgeY, badgeW, badgeH);
      final badgeRRect = RRect.fromRectAndRadius(
        badgeRect,
        const Radius.circular(6),
      );

      // Background bubble
      final bgPaint = Paint()
        ..color = const Color(0xF0131A21)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(badgeRRect, bgPaint);

      // Border outline
      final borderPaint = Paint()
        ..color = themeColor.withValues(alpha: 0.6)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;
      canvas.drawRRect(badgeRRect, borderPaint);

      // Text lines
      tooltipValPainter.paint(
        canvas,
        Offset(badgeX + (badgeW - tooltipValPainter.width) / 2, badgeY + 4),
      );
      tooltipDistPainter.paint(
        canvas,
        Offset(badgeX + (badgeW - tooltipDistPainter.width) / 2, badgeY + 18),
      );
    }
  }

  String _formatValue(
    double val,
    TrackGraphType type, {
    bool includeUnit = false,
  }) {
    switch (type) {
      case TrackGraphType.pace:
        if (val <= 0 || val.isNaN || val.isInfinite) return '--:--';
        final m = val.floor();
        final s = ((val - m) * 60).round();
        final str = '$m:${s.toString().padLeft(2, '0')}';
        return includeUnit ? '$str/k' : str;
      case TrackGraphType.cadence:
        return includeUnit ? '${val.round()} spm' : '${val.round()}';
      case TrackGraphType.stride:
        return includeUnit
            ? '${val.toStringAsFixed(2)}m'
            : val.toStringAsFixed(2);
      case TrackGraphType.speed:
        return includeUnit
            ? '${val.toStringAsFixed(1)}km/h'
            : val.toStringAsFixed(1);
    }
  }

  @override
  bool shouldRepaint(covariant _WorkoutGraphPainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.points != points ||
        oldDelegate.graphType != graphType;
  }
}
