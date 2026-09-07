import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/providers/cadence_provider.dart';
import '../../core/theme/app_colors.dart';
import 'gps_controller.dart';
import 'target_actual_panel.dart';

class GpsScreen extends ConsumerStatefulWidget {
  const GpsScreen({super.key});

  @override
  ConsumerState<GpsScreen> createState() => _GpsScreenState();
}

class _GpsScreenState extends ConsumerState<GpsScreen> {
  LatLng _initialCenter = const LatLng(37.7749, -122.4194);
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _loadInitialLocation();
  }

  Future<void> _loadInitialLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      Position? pos = await Geolocator.getLastKnownPosition();
      pos ??= await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium, timeLimit: Duration(seconds: 4)),
      );

      if (mounted) {
        final loc = LatLng(pos.latitude, pos.longitude);
        setState(() {
          _initialCenter = loc;
        });
        _mapController.move(loc, 17.0);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final gpsState = ref.watch(gpsControllerProvider);
    final cadenceState = ref.watch(cadenceProvider);
    
    final center = gpsState.routePoints.isNotEmpty 
        ? gpsState.routePoints.last 
        : _initialCenter;

    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      appBar: AppBar(
        title: const Text('GPS Run Tracker'),
        backgroundColor: AppColors.surfacePanel,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: center,
                    initialZoom: 17.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.cadence.app',
                    ),
                    CircleLayer(
                      circles: [
                        CircleMarker(
                          point: center,
                          color: cadenceState.activeColor.withValues(alpha: 0.15),
                          borderStrokeWidth: 1.5,
                          borderColor: cadenceState.activeColor.withValues(alpha: 0.6),
                          useRadiusInMeter: true,
                          radius: gpsState.lastRawAccuracy ?? 15.0,
                        ),
                      ],
                    ),
                    if (gpsState.routePoints.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: gpsState.routePoints,
                            color: cadenceState.activeColor,
                            strokeWidth: 5.0,
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: center,
                          width: 24,
                          height: 24,
                          child: Container(
                            decoration: BoxDecoration(
                              color: cadenceState.activeColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
                        heroTag: 'zoom_in',
                        backgroundColor: AppColors.surfacePanel,
                        foregroundColor: AppColors.textPrimary,
                        onPressed: () {
                          final currentZoom = _mapController.camera.zoom;
                          _mapController.move(_mapController.camera.center, currentZoom + 1);
                        },
                        child: const Icon(Icons.add),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton.small(
                        heroTag: 'zoom_out',
                        backgroundColor: AppColors.surfacePanel,
                        foregroundColor: AppColors.textPrimary,
                        onPressed: () {
                          final currentZoom = _mapController.camera.zoom;
                          _mapController.move(_mapController.camera.center, currentZoom - 1);
                        },
                        child: const Icon(Icons.remove),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton.small(
                        heroTag: 'recenter',
                        backgroundColor: AppColors.surfacePanel,
                        foregroundColor: cadenceState.activeColor,
                        onPressed: () {
                          final target = gpsState.routePoints.isNotEmpty 
                              ? gpsState.routePoints.last 
                              : _initialCenter;
                          _mapController.move(target, 17.0);
                        },
                        child: const Icon(Icons.my_location),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 16,
                  bottom: 16,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton.small(
                        heroTag: 'rotate_left',
                        backgroundColor: AppColors.surfacePanel,
                        foregroundColor: AppColors.textPrimary,
                        onPressed: () {
                          final currentRotation = _mapController.camera.rotation;
                          _mapController.rotate(currentRotation - 15);
                        },
                        child: const Icon(Icons.rotate_left),
                      ),
                      const SizedBox(width: 8),
                      FloatingActionButton.small(
                        heroTag: 'reset_north',
                        backgroundColor: AppColors.surfacePanel,
                        foregroundColor: cadenceState.activeColor,
                        onPressed: () {
                          _mapController.rotate(0.0);
                        },
                        child: const Icon(Icons.explore),
                      ),
                      const SizedBox(width: 8),
                      FloatingActionButton.small(
                        heroTag: 'rotate_right',
                        backgroundColor: AppColors.surfacePanel,
                        foregroundColor: AppColors.textPrimary,
                        onPressed: () {
                          final currentRotation = _mapController.camera.rotation;
                          _mapController.rotate(currentRotation + 15);
                        },
                        child: const Icon(Icons.rotate_right),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 72),
              color: AppColors.surfacePanel,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const TargetActualPanel(),
                  if (gpsState.isIdle)
                    ElevatedButton.icon(
                      onPressed: () {
                        ref.read(gpsControllerProvider.notifier).startTracking();
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('START GPS RUN'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cadenceState.activeColor,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    )
                  else if (gpsState.isTracking)
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              ref.read(gpsControllerProvider.notifier).pauseTracking();
                            },
                            icon: const Icon(Icons.pause),
                            label: const Text('PAUSE'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.black,
                              minimumSize: const Size(0, 50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              textStyle: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              ref.read(gpsControllerProvider.notifier).stopTracking();
                            },
                            icon: const Icon(Icons.stop),
                            label: const Text('STOP'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.statusDanger,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(0, 50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              textStyle: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    )
                  else if (gpsState.isPaused)
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              ref.read(gpsControllerProvider.notifier).resumeTracking();
                            },
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('RESUME'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: cadenceState.activeColor,
                              foregroundColor: Colors.black,
                              minimumSize: const Size(0, 50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              textStyle: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              ref.read(gpsControllerProvider.notifier).stopTracking();
                            },
                            icon: const Icon(Icons.stop),
                            label: const Text('STOP'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.statusDanger,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(0, 50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              textStyle: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

