import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/app_database.dart';
import '../../core/theme/app_colors.dart';
import 'models/gps_track_point.dart';
import 'models/km_split.dart';
import 'repositories/gps_session_repository.dart';

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

    const leftPad = 36.0;
    const rightPad = 10.0;
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
              boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 4)],
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

  @override
  Widget build(BuildContext context) {
    final s = widget.session;
    final allLatLngs = _points
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList();

    final animatedCount = _points.isEmpty
        ? 0
        : (_animationProgress * _points.length)
            .ceil()
            .clamp(1, _points.length);
    final visibleLatLngs = allLatLngs.isEmpty
        ? <LatLng>[]
        : allLatLngs.sublist(0, animatedCount);

    final currentAnimatedPoint = visibleLatLngs.isNotEmpty
        ? visibleLatLngs.last
        : (allLatLngs.isNotEmpty
              ? allLatLngs.first
              : const LatLng(37.7749, -122.4194));

    final idleSeconds = (s.durationSeconds -
            s.movingDurationSeconds -
            s.pauseDurationSeconds)
        .clamp(0, 999999);

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
                      initialCameraFit: allLatLngs.isNotEmpty
                          ? CameraFit.bounds(
                              bounds: LatLngBounds.fromPoints(allLatLngs),
                              padding: const EdgeInsets.all(36.0),
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
                              color:
                                  AppColors.textMuted.withValues(alpha: 0.35),
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
                            if (allLatLngs.isNotEmpty) {
                              _mapController.fitCamera(
                                CameraFit.bounds(
                                  bounds: LatLngBounds.fromPoints(allLatLngs),
                                  padding: const EdgeInsets.all(36.0),
                                ),
                              );
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
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.surfacePanel.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.hairline),
                      ),
                      child: const Text(
                        '© OpenStreetMap contributors',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (_points.isNotEmpty)
              Container(
                color: AppColors.surfacePanel,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                              final idx = (_animationProgress *
                                      (_points.length - 1))
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
                          'Distance',
                          s.distanceKm.toStringAsFixed(2),
                          'km',
                          Icons.map,
                        ),
                      ),
                      const SizedBox(width: 8),
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
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Pause Time',
                          _formatDuration(s.pauseDurationSeconds),
                          '',
                          Icons.pause_circle,
                          color: Colors.orange,
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
                          'Avg Pace',
                          s.avgPaceMinPerKm?.toStringAsFixed(1) ?? '--',
                          'min/km',
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
                          'Avg Cadence',
                          s.avgCadence.toStringAsFixed(0),
                          'SPM',
                          Icons.bolt,
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
                          'Calories',
                          s.estimatedCalories.toString(),
                          'kcal',
                          Icons.local_fire_department,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Steps',
                          '${s.estimatedSteps}',
                          'steps',
                          Icons.directions_walk,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(child: SizedBox()),
                      const SizedBox(width: 8),
                      const Expanded(child: SizedBox()),
                    ],
                  ),

                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Pace Profile',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 3,
                            decoration: BoxDecoration(
                              color: AppColors.traceCalm,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Pace (min/km)',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
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
                            details.localPosition, constraints.maxWidth),
                        onPanUpdate: (details) => _onGraphScrub(
                            details.localPosition, constraints.maxWidth),
                        onTapDown: (details) => _onGraphScrub(
                            details.localPosition, constraints.maxWidth),
                        child: Container(
                          height: 180,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surfacePanel,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.hairline),
                          ),
                          child: _points.length < 2
                              ? const Center(
                                  child: Text(
                                    'Not enough points for graph',
                                    style:
                                        TextStyle(color: AppColors.textMuted),
                                  ),
                                )
                              : CustomPaint(
                                  size: Size(constraints.maxWidth, 156),
                                  painter: _PaceGraphPainter(
                                    points: _points,
                                    animationProgress: _animationProgress,
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
                                  barFactor = 1.0 -
                                      ((split.avgPaceMinPerKm - minP) /
                                              (maxP - minP) *
                                              0.7);
                                  barFactor = barFactor.clamp(0.2, 1.0);
                                }
                              }

                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
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
                                                      color: AppColors
                                                          .textPrimary,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  if (isFastest) ...[
                                                    const SizedBox(width: 8),
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 6,
                                                          vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: Colors
                                                            .green.shade900
                                                            .withValues(
                                                                alpha: 0.6),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                4),
                                                        border: Border.all(
                                                            color: Colors
                                                                .green.shade400,
                                                            width: 0.8),
                                                      ),
                                                      child: Text(
                                                        'FASTEST',
                                                        style: TextStyle(
                                                          color: Colors
                                                              .green.shade300,
                                                          fontSize: 9,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ] else if (isSlowest) ...[
                                                    const SizedBox(width: 8),
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 6,
                                                          vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: Colors
                                                            .amber.shade900
                                                            .withValues(
                                                                alpha: 0.6),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                4),
                                                        border: Border.all(
                                                            color: Colors
                                                                .amber.shade400,
                                                            width: 0.8),
                                                      ),
                                                      child: Text(
                                                        'SLOWEST',
                                                        style: TextStyle(
                                                          color: Colors
                                                              .amber.shade300,
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

class _PaceGraphPainter extends CustomPainter {
  final List<GpsTrackPoint> points;
  final double animationProgress;

  _PaceGraphPainter({
    required this.points,
    required this.animationProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    const leftPadding = 36.0;
    const rightPadding = 10.0;
    const topPadding = 16.0;
    const bottomPadding = 20.0;

    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - topPadding - bottomPadding;

    if (chartWidth <= 0 || chartHeight <= 0) return;

    // Convert points to pace values (min/km)
    final paceValues = <double>[];
    for (final p in points) {
      double pace = p.speedKmH > 0.5 ? (60.0 / p.speedKmH) : 15.0;
      pace = pace.clamp(2.0, 15.0);
      paceValues.add(pace);
    }

    double minPace = paceValues.reduce((a, b) => a < b ? a : b);
    double maxPace = paceValues.reduce((a, b) => a > b ? a : b);

    if ((maxPace - minPace) < 1.0) {
      minPace = (minPace - 0.5).clamp(2.0, 15.0);
      maxPace = (maxPace + 0.5).clamp(2.0, 15.0);
    }

    final range = maxPace - minPace;

    final gridPaint = Paint()
      ..color = AppColors.hairline
      ..strokeWidth = 1.0;

    const textStyle = TextStyle(
      color: AppColors.textMuted,
      fontSize: 9,
    );

    // Top grid line & label (Fastest Pace)
    final topTextPainter = TextPainter(
      text: TextSpan(text: '${_formatPaceString(minPace)}/k', style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    topTextPainter.paint(canvas, Offset(0, topPadding - 6));
    canvas.drawLine(
      const Offset(leftPadding, topPadding),
      Offset(size.width - rightPadding, topPadding),
      gridPaint,
    );

    // Bottom grid line & label (Slowest Pace)
    final bottomTextPainter = TextPainter(
      text: TextSpan(text: '${_formatPaceString(maxPace)}/k', style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    bottomTextPainter.paint(
      canvas,
      Offset(0, topPadding + chartHeight - 6),
    );
    canvas.drawLine(
      Offset(leftPadding, topPadding + chartHeight),
      Offset(size.width - rightPadding, topPadding + chartHeight),
      gridPaint,
    );

    // Construct curve path
    final path = ui.Path();
    final fillPath = ui.Path();

    final pointsCount = points.length;

    for (int i = 0; i < pointsCount; i++) {
      final x = leftPadding + (i / (pointsCount - 1)) * chartWidth;
      final normPace = (paceValues[i] - minPace) / range;
      final y = topPadding + (normPace * chartHeight);

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

    // Area fill
    final fillPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, topPadding),
        Offset(0, topPadding + chartHeight),
        [
          AppColors.traceCalm.withValues(alpha: 0.35),
          AppColors.traceCalm.withValues(alpha: 0.02),
        ],
      );
    canvas.drawPath(fillPath, fillPaint);

    // Pace Line
    final linePaint = Paint()
      ..color = AppColors.traceCalm
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, linePaint);

    // Scrubber vertical line & indicator dot
    if (animationProgress > 0.0) {
      final activeIdx = (animationProgress * (pointsCount - 1))
          .round()
          .clamp(0, pointsCount - 1);
      final activeX =
          leftPadding + (activeIdx / (pointsCount - 1)) * chartWidth;
      final activeNorm = (paceValues[activeIdx] - minPace) / range;
      final activeY = topPadding + (activeNorm * chartHeight);

      final scrubberPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.8)
        ..strokeWidth = 1.5;
      canvas.drawLine(
        Offset(activeX, topPadding),
        Offset(activeX, topPadding + chartHeight),
        scrubberPaint,
      );

      final dotOuterPaint = Paint()..color = Colors.white;
      final dotInnerPaint = Paint()..color = AppColors.traceCalm;
      canvas.drawCircle(Offset(activeX, activeY), 5, dotOuterPaint);
      canvas.drawCircle(Offset(activeX, activeY), 3, dotInnerPaint);
    }
  }

  String _formatPaceString(double pace) {
    if (pace <= 0 || pace.isNaN || pace.isInfinite) return '--:--';
    final m = pace.floor();
    final s = ((pace - m) * 60).round();
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  bool shouldRepaint(covariant _PaceGraphPainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.points != points;
  }
}
