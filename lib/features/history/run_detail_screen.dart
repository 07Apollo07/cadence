import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/storage/app_database.dart';
import '../../core/theme/app_colors.dart';
import 'models/gps_track_point.dart';
import 'models/km_split.dart';
import 'repositories/gps_session_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
          // Center map on current animated point if tracking
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

  @override
  Widget build(BuildContext context) {
    final s = widget.session;
    final allLatLngs = _points
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList();

    // Sub-list of points for animation
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Map Header
            SizedBox(
              height: 280,
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
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
                              color: AppColors.textMuted.withValues(alpha: 0.4),
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
                      if (visibleLatLngs.isNotEmpty)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: currentAnimatedPoint,
                              width: 32,
                              height: 32,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.traceCalm,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.directions_run,
                                  size: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  // Map Controls (Zoom & Recenter)
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
            // Below map: Animate Run button / controls
            if (_points.length > 2)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: !_isPlayingAnimation && _animationProgress == 0.0
                    ? SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.traceCalm,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(
                            Icons.play_arrow,
                            color: Colors.black,
                          ),
                          label: const Text(
                            'Animate Run',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          onPressed: _startPlayback,
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfacePanel,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.hairline),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                _isPlayingAnimation
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: AppColors.traceCalm,
                              ),
                              onPressed: _togglePlayback,
                            ),
                            Expanded(
                              child: Slider(
                                value: _animationProgress,
                                activeColor: AppColors.traceCalm,
                                inactiveColor: AppColors.hairline,
                                onChanged: (val) {
                                  setState(() {
                                    _animationProgress = val;
                                    if (_points.isNotEmpty) {
                                      final idx =
                                          (_animationProgress *
                                                  (_points.length - 1))
                                              .round();
                                      final pt = _points[idx];
                                      _mapController.move(
                                        LatLng(pt.latitude, pt.longitude),
                                        _mapController.camera.zoom,
                                      );
                                    }
                                  });
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.stop,
                                color: AppColors.statusDanger,
                              ),
                              onPressed: () {
                                _stopPlayback();
                                setState(() {
                                  _animationProgress = 0.0;
                                });
                              },
                            ),
                            PopupMenuButton<double>(
                              icon: Text(
                                '${_playbackSpeedMultiplier}x',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              onSelected: (speed) {
                                setState(() {
                                  _playbackSpeedMultiplier = speed;
                                });
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 1.0,
                                  child: Text('1x speed'),
                                ),
                                const PopupMenuItem(
                                  value: 2.0,
                                  child: Text('2x speed'),
                                ),
                                const PopupMenuItem(
                                  value: 5.0,
                                  child: Text('5x speed'),
                                ),
                                const PopupMenuItem(
                                  value: 10.0,
                                  child: Text('10x speed'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
              ),

            Padding(
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
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Moving Time',
                          _formatDuration(s.movingDurationSeconds),
                          '',
                          Icons.timer,
                        ),
                      ),
                      const SizedBox(width: 12),
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
                  const SizedBox(height: 12),
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
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Avg Cadence',
                          s.avgCadence.toStringAsFixed(0),
                          'SPM',
                          Icons.bolt,
                        ),
                      ),
                      const SizedBox(width: 12),
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
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Target Cadence',
                          s.targetCadence.toStringAsFixed(0),
                          'SPM',
                          Icons.track_changes,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Max Cadence',
                          s.maxCadence.toStringAsFixed(0),
                          'SPM',
                          Icons.flash_on,
                        ),
                      ),
                      const SizedBox(width: 12),
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

                  const SizedBox(height: 24),
                  const Text(
                    'Cadence & Pace Profile',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Custom Chart for Cadence vs Target over points
                  Container(
                    height: 180,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfacePanel,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.hairline),
                    ),
                    child: _points.length < 2
                        ? const Center(
                            child: Text(
                              'Not enough points for graph',
                              style: TextStyle(color: AppColors.textMuted),
                            ),
                          )
                        : CustomPaint(
                            size: const Size(double.infinity, 140),
                            painter: _CadenceGraphPainter(
                              points: _points,
                              targetCadence: s.targetCadence,
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
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.surfaceRaised,
                                  child: Text(
                                    'KM ${split.kilometer}',
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  'Pace: ${split.paceFormatted} /km',
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  'Time: ${split.timeFormatted} • Cadence: ${split.avgCadence.toStringAsFixed(0)} SPM',
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                                trailing: Text(
                                  '${split.avgSpeedKmH.toStringAsFixed(1)} km/h',
                                  style: const TextStyle(
                                    color: AppColors.traceCalm,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
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
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
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

class _CadenceGraphPainter extends CustomPainter {
  final List<GpsTrackPoint> points;
  final double targetCadence;

  _CadenceGraphPainter({required this.points, required this.targetCadence});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paintLine = Paint()
      ..color = AppColors.traceCalm
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final paintTarget = Paint()
      ..color = Colors.amber.withValues(alpha: 0.7)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = ui.Path();
    final targetPath = ui.Path();

    double minCadence = 100.0;
    double maxCadence = 220.0;
    for (var p in points) {
      if (p.cadenceSpm < minCadence) minCadence = p.cadenceSpm;
      if (p.cadenceSpm > maxCadence) maxCadence = p.cadenceSpm;
    }
    minCadence = (minCadence - 10).clamp(0, 300);
    maxCadence = (maxCadence + 10).clamp(150, 300);
    final range = maxCadence - minCadence;

    final width = size.width;
    final height = size.height;

    for (int i = 0; i < points.length; i++) {
      final x = (i / (points.length - 1)) * width;
      final normalizedCadence =
          (points[i].cadenceSpm - minCadence) / (range == 0 ? 1 : range);
      final y = height - (normalizedCadence * height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      // Target line y
      final normTarget =
          (targetCadence - minCadence) / (range == 0 ? 1 : range);
      final targetY = height - (normTarget * height);
      if (i == 0) {
        targetPath.moveTo(0, targetY);
      } else {
        targetPath.lineTo(width, targetY);
      }
    }

    canvas.drawPath(targetPath, paintTarget);
    canvas.drawPath(path, paintLine);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
